local WDecay_Object_Buffer = {}
local isDebug = isDebugEnabled()

--Buffer Vars
local MAX_OBJECT_BUFFER_SIZE = 500000
local defaultObjectAlloc = 16384
local objectBufferLookup = {}
local objectCount = 0
local lookUpKeys = table.newarray()
local isBufferActivate = true

--Time Vars
local OBJECT_BUFFER_SCHEDULE_MS = 500
local MAX_AVAILABLE_TIME_MS = 4
local MIN_AVAILABLE_TIME_MS = 2
local previousBufferDelta = 0
local scheduleTimeCounterMs = 0
local globalStartTimeMs = 0
local globalDelta = 0

--Ticks
local MAX_TICKS_FOR_ACTION = 10
local tickCounter = 0

--Sprite Vars
local spriteManager = IsoSpriteManager.instance
local spriteLookup = {}

--#################  Print Buffer  ################# 
local writeBufferTimeCounterMs = 0
local WB_WAIT_FOR_WRITE = 1000
local writeBuffer = ""

local function writeLog(line)
    writeBuffer = writeBuffer .. "\n" .. "[WDecay] -> [WDecay_Object_Buffer]: " .. line
end

local function writeLogDebug(line)
    if isDebug then
        writeBuffer = writeBuffer .. "\n" .. "[DEBUG-WDecay] -> [WDecay_Object_Buffer]: " .. line
    end
end

local function printBuffer()
    print(writeBuffer)
    writeBuffer = ""
    writeBufferTimeCounterMs = 0
end

local function printToConsole()
    if writeBufferTimeCounterMs >= WB_WAIT_FOR_WRITE then
        --Asking here, because we don't need to compare string per tick.
        if writeBuffer ~= "" then
            printBuffer()
        end
    else
        writeBufferTimeCounterMs = writeBufferTimeCounterMs + globalDelta
    end
end

--#################  Object Buffer  ################# 

local function allocateNewIsoObjects(buffer, count, loadedSprite)
    local object = nil

    for j = 1, count do
        if buffer then
            object = IsoObject.new()
            object:setSprite(loadedSprite)

            buffer[#buffer + 1] = object
            objectCount = objectCount + 1
        end
    end
end

local function calculatePartSize()
    local keyCount = #lookUpKeys
    local availableRemainingElementCount = 0

    if keyCount > 0 then
        local part = 0
        local max = 0
        local balancedCounter = 0
        local totalPartCount = 0
        local firstPart = objectBufferLookup[lookUpKeys[1]].calculatedPart

        for i = 1, keyCount do
            part = objectBufferLookup[lookUpKeys[i]].calculatedPart
            totalPartCount = totalPartCount + part

            if part > max then
                max = part
            end

            if part == max then
                balancedCounter = balancedCounter + 1
            end
        end

        local totalMissingPartCount = totalPartCount - (max * keyCount)

        if totalMissingPartCount < 0 then
            totalMissingPartCount = -1 * totalMissingPartCount
        end

        local totalMissing = totalMissingPartCount

        if totalMissingPartCount >= defaultObjectAlloc then
            totalMissingPartCount = defaultObjectAlloc
        end

        availableRemainingElementCount = defaultObjectAlloc - totalMissingPartCount

        local isBalanced = balancedCounter == keyCount and firstPart == max

        --Balancing
        for i = 1, keyCount do
            if (isBalanced) then
                objectBufferLookup[lookUpKeys[i]].calculatedPart = math.floor((availableRemainingElementCount / keyCount))
            else
                objectBufferLookup[lookUpKeys[i]].calculatedPart = math.floor((max - objectBufferLookup[lookUpKeys[i]].calculatedPart) / totalMissing * totalMissingPartCount + (availableRemainingElementCount / keyCount))
            end
        end
    end
end

local function fillBuffer()
    if scheduleTimeCounterMs >= OBJECT_BUFFER_SCHEDULE_MS and isBufferActivate then
        local startTime = getTimestampMs()
        local delta = 0
        scheduleTimeCounterMs = 0

        if objectCount < MAX_OBJECT_BUFFER_SIZE then
            writeLog("Start filling object buffer with '" .. tostring(defaultObjectAlloc) .. "' objects.")
            local keyCount = #lookUpKeys

            --Cut object allocation in half
            if previousBufferDelta > MAX_AVAILABLE_TIME_MS then
                defaultObjectAlloc = math.floor(defaultObjectAlloc * 0.75)

                --Deactivate buffer, when the computer is too bad, to process the objects in a certain amount of time
                isBufferActivate = defaultObjectAlloc >= keyCount
            end

            --Calibrate the buffer
            if previousBufferDelta < MIN_AVAILABLE_TIME_MS then
                defaultObjectAlloc = math.floor(defaultObjectAlloc * 1.125)
            end

            previousBufferDelta = 0
            local part = 0
            local buffer = nil
            local keyName = ""
            local object = nil
            local loadedSprite = nil

            --Nessencary to balance the buffer parts
            calculatePartSize()

            for i = 1, keyCount do
                keyName = lookUpKeys[i]
                loadedSprite = spriteLookup[keyName]
                buffer = objectBufferLookup[keyName].buffer
                part = objectBufferLookup[keyName].calculatedPart

                writeLog("Allocate " .. tostring(part) .. " objects for index " .. tostring(i) .. " '" .. keyName .. "'...", true)

                if keyName and loadedSprite and buffer then
                    allocateNewIsoObjects(buffer, part, loadedSprite)
                else
                    writeLogDebug("Cannot fill buffer: unknown key '" .. keyName .. "'.")
                end
            end

            delta = getTimestampMs() - startTime
            previousBufferDelta = delta
            writeLog("Time needed to fill the object buffer: " .. tostring(delta) .. "ms")
            writeLog("Current object buffer size: '" .. tostring(objectCount) .. "'")
            writeLog("Added '" .. tostring(part * keyCount) .. "' objects in the object buffer")
        end
    end

    scheduleTimeCounterMs = scheduleTimeCounterMs + globalDelta
end

local function initObjectBuffer()
    writeLog("Initialize object buffer...")
    local startTime = getTimestampMs()

    for i = 1, #lookUpKeys do
        objectBufferLookup[lookUpKeys[i]] = { buffer = table.newarray(10000000), calculatedPart = 0 }
    end

    local initDelta = getTimestampMs() - startTime
    writeLog("Object buffer initialized successfully in " .. tostring(initDelta) .. "ms!")
    printBuffer()
end

function WDecay_Object_Buffer.register(spriteNames)
    writeLog("Loading '" .. tostring(#spriteNames) .. "' sprites in the buffer.")
    local keyName = nil
    local startTime = getTimestampMs()
    local beginPos = #lookUpKeys
    local validSpriteCount = 0

    for i = 1, #spriteNames do
        keyName = spriteNames[i]

        if not spriteLookup[keyName] then
            lookUpKeys[beginPos + i] = keyName
            spriteLookup[keyName] = spriteManager:getSprite(keyName)
            validSpriteCount = validSpriteCount + 1
        else
            writeLogDebug("Duplicate error: Sprite name '" .. keyName .. "' is existing in the sprite lockup table!")
        end
    end

    local spriteDelta = getTimestampMs() - startTime
    writeLog("Time needed to load " .. tostring(validSpriteCount) .. " valid sprites: " .. tostring(spriteDelta) .. "ms")
    printBuffer()
end

function WDecay_Object_Buffer.getObject(spriteName)

end

--#################  Tick-Counter  ################# 
local function OnTick()
    if globalStartTimeMs == 0 then 
        globalStartTimeMs = getTimestampMs()
    end

    --Limit ticks for performance on bad computer
    if tickCounter == MAX_TICKS_FOR_ACTION then
        globalDelta = getTimestampMs() - globalStartTimeMs
        fillBuffer()
        printToConsole()
        --Reset for a new time measurement
        tickCounter = -1
        globalStartTimeMs = 0
    end

    tickCounter = tickCounter + 1
end

--#################  Events  ################# 
Events.OnTickEvenPaused.Add(OnTick)
Events.OnInitGlobalModData.Add(initObjectBuffer)

return WDecay_Object_Buffer
