local debugCounters = {}
local debugLastPrint = 0
local DEBUG_PRINT_INTERVAL = 600

local function initDebugCounters()
    debugCounters.ChunksProcessed = 0
    debugCounters.ChunksFailed = 0
    debugCounters.SquaresProcessed = 0
    
    if not ApocVeg_PlacementGenerators then return end
    if not ApocVeg_ModifierGenerators then return end
    
    debugCounters.Placement = {}
    debugCounters.Modifier = {}
    
    for i = 1, #ApocVeg_PlacementGenerators do
        debugCounters.Placement[i] = 0
    end
    for i = 1, #ApocVeg_ModifierGenerators do
        debugCounters.Modifier[i] = 0
    end
end

Events.OnGameStart.Add(function()
    initDebugCounters()
    print("[ApocVeg-Debug] Counters initialized")
end)

Events.EveryOneMinute.Add(function()
    if not debugCounters.Placement then return end
    
    debugLastPrint = debugLastPrint + 1
    if debugLastPrint < 10 then return end
    debugLastPrint = 0
    
    local placementTotal = 0
    for i = 1, #debugCounters.Placement do
        placementTotal = placementTotal + debugCounters.Placement[i]
    end
    
    local modifierTotal = 0
    for i = 1, #debugCounters.Modifier do
        modifierTotal = modifierTotal + debugCounters.Modifier[i]
    end
    
    print("[ApocVeg-Debug] === STATUS ===")
    print("[ApocVeg-Debug] Chunks processed: " .. debugCounters.ChunksProcessed)
    print("[ApocVeg-Debug] Chunks failed (not ready): " .. debugCounters.ChunksFailed)
    print("[ApocVeg-Debug] Placement generators calls: " .. placementTotal)
    print("[ApocVeg-Debug] Modifier generators calls: " .. modifierTotal)
    
    if ApocVeg_PlacementGenerators then
        for i = 1, #ApocVeg_PlacementGenerators do
            if debugCounters.Placement[i] > 0 then
                print("[ApocVeg-Debug]   Placement[" .. i .. "]: " .. debugCounters.Placement[i] .. " calls")
            end
        end
    end
    
    if ApocVeg_ModifierGenerators then
        for i = 1, #ApocVeg_ModifierGenerators do
            if debugCounters.Modifier[i] > 0 then
                print("[ApocVeg-Debug]   Modifier[" .. i .. "]: " .. debugCounters.Modifier[i] .. " calls")
            end
        end
    end
    
    print("[ApocVeg-Debug] ==============")
end)

function ApocVeg_DebugCountPlacement(index)
    if debugCounters.Placement and debugCounters.Placement[index] then
        debugCounters.Placement[index] = debugCounters.Placement[index] + 1
    end
end

function ApocVeg_DebugCountModifier(index)
    if debugCounters.Modifier and debugCounters.Modifier[index] then
        debugCounters.Modifier[index] = debugCounters.Modifier[index] + 1
    end
end

function ApocVeg_DebugCountChunk(success)
    if not debugCounters.ChunksProcessed then return end
    if success then
        debugCounters.ChunksProcessed = debugCounters.ChunksProcessed + 1
    else
        debugCounters.ChunksFailed = debugCounters.ChunksFailed + 1
    end
end

function ApocVeg_DebugPrintStatus()
    if not debugCounters.Placement then
        print("[ApocVeg-Debug] Counters not initialized yet")
        return
    end
    
    print("[ApocVeg-Debug] === MANUAL STATUS ===")
    print("[ApocVeg-Debug] Chunks processed: " .. debugCounters.ChunksProcessed)
    print("[ApocVeg-Debug] Chunks failed (not ready): " .. debugCounters.ChunksFailed)
    
    if ApocVeg_PlacementGenerators then
        print("[ApocVeg-Debug] Placement generators (" .. #ApocVeg_PlacementGenerators .. " total):")
        for i = 1, #ApocVeg_PlacementGenerators do
            print("[ApocVeg-Debug]   [" .. i .. "] calls=" .. debugCounters.Placement[i])
        end
    end
    
    if ApocVeg_ModifierGenerators then
        print("[ApocVeg-Debug] Modifier generators (" .. #ApocVeg_ModifierGenerators .. " total):")
        for i = 1, #ApocVeg_ModifierGenerators do
            print("[ApocVeg-Debug]   [" .. i .. "] calls=" .. debugCounters.Modifier[i])
        end
    end
    
    print("[ApocVeg-Debug] ===================")
end

function ApocVeg_DebugPrintVineCounters()
    if not vineDebugCounters then
        print("[ApocVeg-Debug] Vine counters not available")
        return
    end
    print("[ApocVeg-Debug] === VINE DEBUG ===")
    print("[ApocVeg-Debug] Indoor squares checked: " .. vineDebugCounters.indoor)
    print("[ApocVeg-Debug] Blocked by exteriorOnly: " .. vineDebugCounters.exteriorBlocked)
    print("[ApocVeg-Debug] Failed chance check (indoor): " .. vineDebugCounters.chanceFail)
    print("[ApocVeg-Debug] No matching walls found: " .. vineDebugCounters.noWalls)
    print("[ApocVeg-Debug] Vines placed: " .. vineDebugCounters.placed)
    print("[ApocVeg-Debug] ===================")
end

print("[ApocVeg-Debug] Debug module loaded. Type in console: ApocVeg_DebugPrintStatus()")

ApocVeg_Debug = {
    chunksHigh = 0,
    chunksLow = 0,
    totalChunkTimeMs = 0,
    totalChunksProcessed = 0,
    objectsPlaced = 0,
    objectsPlacedInChunk = 0
}

function ApocVeg_Debug.resetPerfCounters()
    ApocVeg_Debug.chunksHigh = 0
    ApocVeg_Debug.chunksLow = 0
    ApocVeg_Debug.totalChunkTimeMs = 0
    ApocVeg_Debug.totalChunksProcessed = 0
    ApocVeg_Debug.objectsPlaced = 0
end

function ApocVeg_Debug.printPerfSummary(tickCounter)
    local avg = 0
    if ApocVeg_Debug.totalChunksProcessed > 0 then
        avg = math.floor(ApocVeg_Debug.totalChunkTimeMs / ApocVeg_Debug.totalChunksProcessed)
    end
    print("[ApocVeg] Perf tick=" .. tickCounter .. " chunks(H=" .. ApocVeg_Debug.chunksHigh .. "/L=" .. ApocVeg_Debug.chunksLow .. ") avg=" .. avg .. "ms total=" .. ApocVeg_Debug.totalChunksProcessed .. " placed=" .. ApocVeg_Debug.objectsPlaced)
    ApocVeg_Debug.resetPerfCounters()
end
