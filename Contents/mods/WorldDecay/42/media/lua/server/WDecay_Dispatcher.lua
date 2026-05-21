local CACHE_VERSION = 2
local DEBUG_MODE = false

local seenChunks = {}
local modDataTable = nil

local chunkQueueHigh = {}
local chunkQueueLow = {}
local chunkQueueTailHigh = 0
local chunkQueueTailLow = 0
local chunkQueueHeadHigh = 1
local chunkQueueHeadLow = 1
local chunkQueueHighChunks = {}
local chunkQueueHighKeys = {}
local chunkQueueLowChunks = {}
local chunkQueueLowKeys = {}
local PRIORITY_RADIUS = 5
local pendingChunks = {}

local TIME_BUDGET_MS = 200
local SCAN_INTERVAL = 100
local scanInterval = 100
local scanIntervalSet = false
local SCAN_RADIUS = 15
local scanTimer = 0
local debugTickCounter = 0

local spawnX = nil
local spawnY = nil
local spawnAttempts = 0
local MAX_SPAWN_ATTEMPTS = 10

local dispatcherConfigLoaded = false
local function loadDispatcherConfig()
    local function getInt(name, default)
        local opt = getSandboxOptions():getOptionByName('WDecay.' .. name)
        return opt and opt:getValue() or default
    end

    local function getBool(name, default)
        local opt = getSandboxOptions():getOptionByName('WDecay.' .. name)
        if opt then return opt:getValue() end

        return default
    end

    TIME_BUDGET_MS = getInt('timeBudgetMs', 200)
    SCAN_INTERVAL = getInt('scanInterval', 100)
    SCAN_RADIUS = getInt('scanRadius', 15)
    PRIORITY_RADIUS = getInt('priorityRadius', 5)
    DEBUG_MODE = getBool('debugMode', false)
    dispatcherConfigLoaded = true
end

local perfTickCounter = 0

local function GenerateKey(wx, wy)
    return wx * 1000000 + wy
end

local function sqDist(px, py, wx, wy)
    local dx = px - (wx * 8 + 4)
    local dy = py - (wy * 8 + 4)
    return dx * dx + dy * dy
end

local function dispatchGenerators(square, checkResult, level)
    if checkResult and checkResult.tooManyPhysicsShapes then
        return
    end

    if WDecay_PlacementGenerators then
        for i = 1, #WDecay_PlacementGenerators do
            local fn = WDecay_PlacementGenerators[i]
            if fn and fn(square, checkResult, level) then
                if WDecay_DebugCountPlacement then
                    WDecay_DebugCountPlacement(i)
                end

                break
            end
        end
    end

    if not checkResult or (not checkResult.hasWalls and not checkResult.hasWindows
        and not checkResult.isRoad and not checkResult.room
        and not checkResult.hasFences and not checkResult.hasRoof) then
        return
    end

    if WDecay_ModifierGenerators then
        local mg = WDecay_ModifierGenerators
        if checkResult.hasWalls or checkResult.hasWindows or checkResult.hasFences or checkResult.room then
            local fn = mg[1]
            if fn then fn(square, checkResult, level) end

            if WDecay_DebugCountModifier then WDecay_DebugCountModifier(1) end
        end

        if checkResult.isRoad then
            local fn = mg[2]
            if fn then fn(square, checkResult, level) end

            if WDecay_DebugCountModifier then WDecay_DebugCountModifier(2) end
        end

        if checkResult.room then
            local fn = mg[3]
            if fn then fn(square, checkResult, level) end

            if WDecay_DebugCountModifier then WDecay_DebugCountModifier(3) end
        end

        if checkResult.hasFences then
            local fn = mg[4]
            if fn then fn(square, checkResult, level) end

            if WDecay_DebugCountModifier then WDecay_DebugCountModifier(4) end
        end

        if checkResult.room then
            local fn = mg[5]
            if fn then fn(square, checkResult, level) end

            if WDecay_DebugCountModifier then WDecay_DebugCountModifier(5) end
        end

        if checkResult.hasWalls or checkResult.hasFences then
            local fn = mg[6]
            if fn then fn(square, checkResult, level) end

            if WDecay_DebugCountModifier then WDecay_DebugCountModifier(6) end
        end

        if checkResult.room then
            local fn = mg[7]
            if fn then fn(square, checkResult, level) end

            if WDecay_DebugCountModifier then WDecay_DebugCountModifier(7) end
        end

        if checkResult.hasRoof then
            local fn = mg[8]
            if fn then fn(square, checkResult, level) end

            if WDecay_DebugCountModifier then WDecay_DebugCountModifier(8) end
        end
    end
end

local WDecay_SquareCheck = require('wdecay_squarecheck/wdecay_squarecheck')

local function processChunkSquares(chunk)
    local cachedMinLevel = chunk:getMinLevel()
    local cachedMaxLevel = chunk:getMaxLevel()

    local testSquare = nil
    local testZ = cachedMinLevel
    while testZ <= cachedMaxLevel do
        testSquare = chunk:getGridSquare(0, 0, testZ)
        if testSquare and testSquare:getChunk() then break end

        testSquare = nil
        testZ = testZ + 1
    end

    if not testSquare then
        return false
    end

    local chunkStartMs = 0
    if DEBUG_MODE then
        chunkStartMs = getTimestampMs()
    end

    local sqErrors = 0
    for z = cachedMinLevel, cachedMaxLevel do
        for x = 0, 7 do
            for y = 0, 7 do
                local square = chunk:getGridSquare(x, y, z)
                if square then
                    local checkResult = WDecay_SquareCheck.checkAll(square)
                    local ok, err = pcall(dispatchGenerators, square, checkResult, z)

                    if not ok then
                        sqErrors = sqErrors + 1
                        
                        if sqErrors == 1 then
                            print("[WDecay] Square dispatch error: " .. tostring(err):sub(1, 120))
                        end
                    else
                        if sqModData then
                            sqModData["WDecay_Processed"] = true
                        end
                    end
                end
            end
        end
    end

    if sqErrors > 0 then
        print("[WDecay] Chunk completed with " .. sqErrors .. " square errors")
    end

    if WDecay_Debug and WDecay_Debug.totalChunksProcessed then
        WDecay_Debug.totalChunksProcessed = WDecay_Debug.totalChunksProcessed + 1
    end

    if DEBUG_MODE and WDecay_Debug and WDecay_Debug.totalChunkTimeMs then
        local elapsed = getTimestampMs() - chunkStartMs
        WDecay_Debug.totalChunkTimeMs = WDecay_Debug.totalChunkTimeMs + elapsed
    end

    return true
end

local function ScanChunksAroundPos(worldX, worldY, radius)
    if not modDataTable then return end

    local cx0 = math.floor((worldX - radius * 8) / 8)
    local cx1 = math.floor((worldX + radius * 8) / 8)
    local cy0 = math.floor((worldY - radius * 8) / 8)
    local cy1 = math.floor((worldY + radius * 8) / 8)
    local queued = 0
    for wx = cx0, cx1 do
        for wy = cy0, cy1 do
            local key = GenerateKey(wx, wy)
            if not seenChunks[key] and not pendingChunks[key] then
                local sq = getSquare(wx * 8, wy * 8, 0)
                if sq then
                    local chunk = sq:getChunk()
                    if chunk then
                        pendingChunks[key] = true
                        local dx = (wx * 8 + 4) - worldX
                        local dy = (wy * 8 + 4) - worldY
                        local sqDistance = dx * dx + dy * dy
                        local isPriority = sqDistance <= PRIORITY_RADIUS * PRIORITY_RADIUS * 64
                        if isPriority then
                            chunkQueueTailHigh = chunkQueueTailHigh + 1
                            chunkQueueHighChunks[chunkQueueTailHigh] = chunk
                            chunkQueueHighKeys[chunkQueueTailHigh] = key
                        else
                            chunkQueueTailLow = chunkQueueTailLow + 1
                            chunkQueueLowChunks[chunkQueueTailLow] = chunk
                            chunkQueueLowKeys[chunkQueueTailLow] = key
                        end

                        queued = queued + 1
                    end
                end
            end
        end
    end

    if DEBUG_MODE and queued > 0 then
        print("[WDecay] Scan queued " .. queued .. " chunks around " .. worldX .. "," .. worldY)
    end
end

local function queueChunk(chunk)
    local wx = chunk.wx
    local wy = chunk.wy
    if wx == nil then
        local refSquare = chunk:getGridSquare(0, 0, chunk:getMinLevel())
        if refSquare then
            wx = math.floor(refSquare:getX() / 8)
            wy = math.floor(refSquare:getY() / 8)
        else
            return
        end
    end

    local key = GenerateKey(wx, wy)
    if not seenChunks[key] and not pendingChunks[key] then
        pendingChunks[key] = true
        local targetDist = 999999
        local cx, cy = wx * 8 + 4, wy * 8 + 4
        if spawnX and spawnY then
            local dx = cx - spawnX
            local dy = cy - spawnY
            targetDist = dx * dx + dy * dy
        end

        if targetDist <= PRIORITY_RADIUS * PRIORITY_RADIUS * 64 then
            chunkQueueTailHigh = chunkQueueTailHigh + 1
            chunkQueueHighChunks[chunkQueueTailHigh] = chunk
            chunkQueueHighKeys[chunkQueueTailHigh] = key
        else
            chunkQueueTailLow = chunkQueueTailLow + 1
            chunkQueueLowChunks[chunkQueueTailLow] = chunk
            chunkQueueLowKeys[chunkQueueTailLow] = key
        end
    end
end

local function OnTick()

    if not dispatcherConfigLoaded then
        loadDispatcherConfig()
    end

    if not modDataTable then
        modDataTable = ModData.getOrCreate("WDecay_ChunkCache")
        if modDataTable then
            if not modDataTable._version or modDataTable._version ~= CACHE_VERSION then
                local keysToClear = {}
                for k in pairs(modDataTable) do
                    keysToClear[#keysToClear + 1] = k
                end

                for i = 1, #keysToClear do
                    modDataTable[keysToClear[i]] = nil
                end

                modDataTable._version = CACHE_VERSION
                seenChunks = {}
                if DEBUG_MODE then
                    print("[WDecay] Chunk cache initialized (lazy)")
                end
            else
                for k, v in pairs(modDataTable) do
                    if k ~= "_version" and v then
                        seenChunks[k] = true
                    end
                end

                local count = 0
                for _ in pairs(seenChunks) do count = count + 1 end

                if DEBUG_MODE then
                    print("[WDecay] Chunk cache loaded: " .. count .. " seen chunks")
                end
            end

            scanTimer = scanInterval
        end
    end

    if not scanIntervalSet and modDataTable then
        scanInterval = SCAN_INTERVAL
        if isMultiplayer() then
            scanInterval = SCAN_INTERVAL * 2
        end

        scanIntervalSet = true
    end

    scanTimer = scanTimer + 1
    if scanTimer >= scanInterval then
        scanTimer = 0
        if modDataTable then
            local player = getSpecificPlayer(0)
            if player then
                local px = math.floor(player:getX())
                local py = math.floor(player:getY())
                if px ~= 0 or py ~= 0 then
                    if not spawnX then
                        spawnX = px
                        spawnY = py
                    end

                    local ok, err = pcall(ScanChunksAroundPos, px, py, SCAN_RADIUS)
                    if not ok then
                        print("[WDecay] Scan error: " .. tostring(err):sub(1, 120))
                    end
                end
            else
                local onlinePlayers = getOnlinePlayers()
                if onlinePlayers and onlinePlayers.size then
                    local playerCount = onlinePlayers:size()
                    if playerCount > 0 then
                        for i = 0, playerCount - 1 do
                            local p = onlinePlayers:get(i)
                            if p then
                                local px = math.floor(p:getX())
                                local py = math.floor(p:getY())
                                if px ~= 0 or py ~= 0 then
                                    if not spawnX then
                                        spawnX = px
                                        spawnY = py
                                    end

                                    local ok, err = pcall(ScanChunksAroundPos, px, py, SCAN_RADIUS)
                                    if not ok then
                                        print("[WDecay] Scan error: " .. tostring(err):sub(1, 120))
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if spawnX and spawnX ~= 0 and spawnAttempts < MAX_SPAWN_ATTEMPTS then
                local radius = SCAN_RADIUS
                if spawnAttempts < 5 then
                    radius = SCAN_RADIUS * 2
                end

                spawnAttempts = spawnAttempts + 1
                local ok, err = pcall(ScanChunksAroundPos, spawnX, spawnY, radius)
                if not ok then
                    print("[WDecay] Spawn scan error: " .. tostring(err):sub(1, 120))
                end
            end
        end
    end

    if chunkQueueHeadHigh > chunkQueueTailHigh and chunkQueueHeadLow > chunkQueueTailLow then
        chunkQueueHeadHigh = 1
        chunkQueueTailHigh = 0
        chunkQueueHeadLow = 1
        chunkQueueTailLow = 0
        return
    end

    if DEBUG_MODE then
        debugTickCounter = debugTickCounter + 1
        if debugTickCounter >= 30 then
            debugTickCounter = 0
            local highCount = chunkQueueTailHigh - chunkQueueHeadHigh + 1
            local lowCount = chunkQueueTailLow - chunkQueueHeadLow + 1
            print("[WDecay] Queue: high=" .. highCount .. " low=" .. lowCount)
        end
    end

    local deadline = getTimestampMs() + TIME_BUDGET_MS
    local checkCounter = 0
    local CHECK_EVERY = 1

    while chunkQueueHeadHigh <= chunkQueueTailHigh do
        checkCounter = checkCounter + 1
        if checkCounter >= CHECK_EVERY then
            checkCounter = 0
            if getTimestampMs() >= deadline then return end
        end

        local chunk = chunkQueueHighChunks[chunkQueueHeadHigh]
        local key = chunkQueueHighKeys[chunkQueueHeadHigh]
        chunkQueueHighChunks[chunkQueueHeadHigh] = nil
        chunkQueueHighKeys[chunkQueueHeadHigh] = nil
        chunkQueueHeadHigh = chunkQueueHeadHigh + 1
        if chunk ~= nil then
            if DEBUG_MODE and WDecay_Debug then
                WDecay_Debug.chunksHigh = WDecay_Debug.chunksHigh + 1
            end

            if pendingChunks[key] then
                pendingChunks[key] = nil
                local ok, result = pcall(processChunkSquares, chunk)
                if WDecay_DebugCountChunk then
                    WDecay_DebugCountChunk(ok and result)
                end

                if not ok then
                    print("[WDecay] Chunk " .. key .. " error: " .. tostring(result):sub(1, 120))
                elseif result then
                    seenChunks[key] = true
                    if modDataTable then
                        modDataTable[key] = true
                    end
                end
            end
        end
    end

    while chunkQueueHeadLow <= chunkQueueTailLow do
        checkCounter = checkCounter + 1
        if checkCounter >= CHECK_EVERY then
            checkCounter = 0
            if getTimestampMs() >= deadline then return end
        end

        local chunk = chunkQueueLowChunks[chunkQueueHeadLow]
        local key = chunkQueueLowKeys[chunkQueueHeadLow]
        chunkQueueLowChunks[chunkQueueHeadLow] = nil
        chunkQueueLowKeys[chunkQueueHeadLow] = nil
        chunkQueueHeadLow = chunkQueueHeadLow + 1
        if chunk ~= nil then
            if DEBUG_MODE and WDecay_Debug then
                WDecay_Debug.chunksLow = WDecay_Debug.chunksLow + 1
            end

            if pendingChunks[key] then
                pendingChunks[key] = nil
                local ok, result = pcall(processChunkSquares, chunk)
                if WDecay_DebugCountChunk then
                    WDecay_DebugCountChunk(ok and result)
                end

                if not ok then
                    print("[WDecay] Chunk " .. key .. " error: " .. tostring(result):sub(1, 120))
                elseif result then
                    seenChunks[key] = true
                    if modDataTable then
                        modDataTable[key] = true
                    end
                end
            end
        end
    end

    if chunkQueueHeadHigh > chunkQueueTailHigh and chunkQueueHeadLow > chunkQueueTailLow then
        chunkQueueHeadHigh = 1
        chunkQueueTailHigh = 0
        chunkQueueHeadLow = 1
        chunkQueueTailLow = 0
    end

    if DEBUG_MODE then
        perfTickCounter = perfTickCounter + 1
        if perfTickCounter >= 100 then
            perfTickCounter = 0
            if WDecay_Debug and WDecay_Debug.printPerfSummary then
                WDecay_Debug.printPerfSummary(debugTickCounter)
            end
        end
    end
end

Events.OnTick.Add(OnTick)

Events.OnCreatePlayer.Add(function(playerIndex, player)
    spawnX = math.floor(player:getX())
    spawnY = math.floor(player:getY())
end)

Events.OnInitGlobalModData.Add(function(isNewGame)
    if not isServer() then return end

    modDataTable = ModData.getOrCreate("WDecay_ChunkCache")
    scanTimer = scanInterval

    if isNewGame or not modDataTable._version or modDataTable._version ~= CACHE_VERSION then
        local keysToClear = {}
        for k in pairs(modDataTable) do
            keysToClear[#keysToClear + 1] = k
        end

        for i = 1, #keysToClear do
            modDataTable[keysToClear[i]] = nil
        end

        modDataTable._version = CACHE_VERSION
        seenChunks = {}
        if DEBUG_MODE then
            print("[WDecay] Chunk cache initialized (new game or version upgrade)")
        end
    else
        for k, v in pairs(modDataTable) do
            if k ~= "_version" and v then
                seenChunks[k] = true
            end
        end

        local count = 0
        for _ in pairs(seenChunks) do count = count + 1 end

        if DEBUG_MODE then
            print("[WDecay] Chunk cache loaded: " .. count .. " seen chunks")
        end
    end
end)

function WDecay_Dispatcher_IsQueueIdle()
    return chunkQueueHeadHigh > chunkQueueTailHigh and chunkQueueHeadLow > chunkQueueTailLow
end
