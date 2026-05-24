local WDecay_Object_Buffer = {}
local isDebug = isDebugEnabled()

--Buffered objectData
local bufferedKey = ""
local bufferedModDataKey = nil
local bufferedModDataValue = nil

--Buffer Vars
local MAX_OBJECT_BUFFER_SIZE = 500000
local defaultObjectAlloc = 16384
local lastAllocSize = 2147483647
--objectBufferLookup[lookUpKeys[i]] = { buffer = table.newarray(), calculatedPart = 0, partOfTotalBuffer = 0 }
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
local spriteLookup = {}

--Moddata Vars
--modDataLookup[keyName] = { key = modDataKey, value = modDataValue }
local modDataLookup = {}

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

local function createIsoObject(key)
    writeLogDebug("Create new IsoObject with spriteName '" .. key .. "'.")

    if bufferedKey ~= key then
        local modData = modDataLookup[key]
        bufferedKey = key
        bufferedModDataKey = modData.key
        bufferedModDataValue = modData.value
    end

    local object = IsoObject.new()
    object:setSprite(key)
    object:getModData()[bufferedModDataKey] = bufferedModDataValue
    return object
end

local function allocateNewIsoObjects(key)
    local object = 0
    local buffer = objectBufferLookup[key].buffer
    local count = objectBufferLookup[key].calculatedPart
    local modData = modDataLookup[key]
    local modDataKey = nil
    local modDataValue = nil
    local hasModData = false

    if modData then
        modDataKey = modData.key
        modDataValue = modData.value
        hasModData = modDataKey and modDataValue
    end
    
    local objModData = nil

    if buffer then
        for j = 1, count do
            object = IsoObject.new()
            object:setSprite(key)

            if hasModData then
                objModData = object:getModData()
                objModData[modDataKey] = modDataValue
            end

            buffer[#buffer + 1] = object
            objectCount = objectCount + 1
        end
    end
end

local function calculatePartSize()
    local keyCount = #lookUpKeys
    local partPercantage = 0
    local maxSizePerPart = MAX_OBJECT_BUFFER_SIZE / keyCount
    local partPercantageSum = 0
    local key = ""

    --Balancing
    for i = 1, keyCount do
        key = lookUpKeys[i]
        partPercantage = (#objectBufferLookup[key].buffer / maxSizePerPart - 1) * -1
        partPercantageSum = partPercantageSum + partPercantage
        objectBufferLookup[key].partOfTotalBuffer = partPercantage
    end

    --Null division Guard
    if partPercantageSum <= 0 then return end

    local totalMissing = partPercantageSum * maxSizePerPart
    local availableElements = totalMissing

    if availableElements > defaultObjectAlloc then
        availableElements = defaultObjectAlloc
    end

    local sum = 0

    for i = 1, keyCount do
        key = lookUpKeys[i]
        objectBufferLookup[key].calculatedPart = math.ceil((objectBufferLookup[key].partOfTotalBuffer / partPercantageSum) * availableElements)
        sum = sum + objectBufferLookup[key].calculatedPart
    end
end

local function fillBuffer()
    if scheduleTimeCounterMs >= OBJECT_BUFFER_SCHEDULE_MS and isBufferActivate then
        local startTime = getTimestampMs()
        local delta = 0
        scheduleTimeCounterMs = 0

        if objectCount < MAX_OBJECT_BUFFER_SIZE then
            writeLogDebug("Start filling object buffer with '" .. tostring(defaultObjectAlloc) .. "' objects.")
            local keyCount = #lookUpKeys

            --Cut object allocation in 0.75
            if previousBufferDelta > MAX_AVAILABLE_TIME_MS then
                lastAllocSize = defaultObjectAlloc
                defaultObjectAlloc = math.floor(defaultObjectAlloc * 0.75)

                --Deactivate buffer, when the computer is too bad, to process the objects in a certain amount of time
                isBufferActivate = defaultObjectAlloc >= keyCount
            end

            --Calibrate the buffer
            if previousBufferDelta < MIN_AVAILABLE_TIME_MS then

                local newAllocValue = math.floor(defaultObjectAlloc * 1.125)
                if newAllocValue < lastAllocSize then
                    defaultObjectAlloc = newAllocValue
                end
            end

            previousBufferDelta = 0
            local partSum = 0
            local keyName = ""

            --Nessencary to balance the buffer parts
            calculatePartSize()

            for i = 1, keyCount do
                keyName = lookUpKeys[i]

                partSum = partSum + objectBufferLookup[keyName].calculatedPart

                if keyName then
                    allocateNewIsoObjects(keyName)
                else
                    writeLogDebug("Cannot fill buffer: unknown key '" .. tostring(keyName) .. "'.")
                end
            end

            delta = getTimestampMs() - startTime
            previousBufferDelta = delta
            writeLogDebug("Time needed to fill the object buffer: " .. tostring(delta) .. "ms")
            writeLogDebug("Current object buffer size: '" .. tostring(objectCount) .. "'")
            writeLogDebug("Added '" .. tostring(partSum) .. "' objects in the object buffer")
        end
    end

    scheduleTimeCounterMs = scheduleTimeCounterMs + globalDelta
end

local function initObjectBuffer()
    writeLog("Initialize object buffer...")
    local startTime = getTimestampMs()

    for i = 1, #lookUpKeys do
        objectBufferLookup[lookUpKeys[i]] = { buffer = table.newarray(), calculatedPart = 0, partOfTotalBuffer = 0 }
    end

    local initDelta = getTimestampMs() - startTime
    writeLog("Object buffer initialized successfully in " .. tostring(initDelta) .. "ms!")
    printBuffer()
end

function WDecay_Object_Buffer.register(spriteNames)
    WDecay_Object_Buffer.registerWithModData(spriteNames, nil, nil)
end

function WDecay_Object_Buffer.registerWithModData(spriteNames, modDataKey, modDataValue)
    writeLog("Loading '" .. tostring(#spriteNames) .. "' sprites in the buffer.")
    local keyName = nil
    local startTime = getTimestampMs()
    local beginPos = #lookUpKeys
    local validSpriteCount = 0

    for i = 1, #spriteNames do
        keyName = spriteNames[i]

        if keyName then
            --Buffer moddata
            if modDataKey and modDataValue and not modDataLookup[keyName] then
                modDataLookup[keyName] = { key = modDataKey, value = modDataValue }
            end

            if not spriteLookup[keyName] then
                lookUpKeys[beginPos + validSpriteCount + 1] = keyName
                spriteLookup[keyName] = true
                validSpriteCount = validSpriteCount + 1
            else
                writeLogDebug("Duplicate error: Sprite name '" .. keyName .. "' is existing in the sprite lockup table!")
            end
        end
    end

    local spriteDelta = getTimestampMs() - startTime
    writeLog("Time needed to load " .. tostring(validSpriteCount) .. " valid sprites: " .. tostring(spriteDelta) .. "ms")
    printBuffer()
end

function WDecay_Object_Buffer.getObject(spriteName)
    local element = objectBufferLookup[spriteName]

    if element then
        local buffer = element.buffer
        local size = #buffer

        if size > 0 then
            local obj = buffer[size]

            buffer[size] = nil
            objectCount = objectCount - 1

            return obj
        else
            return createIsoObject(spriteName)
        end
    else
        writeLogDebug("Error: Element with spritename '" .. spriteName .. "' not found.")
    end
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
