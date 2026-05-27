local WDecay_Object_Buffer_Types = require("WDecay_Object_Buffer_Types")
local WDecay_Object_Buffer = {}
local isDebug = isDebugEnabled()

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
local OBJECT_BUFFER_SCHEDULE_MS = 300
local MAX_AVAILABLE_TIME_MS = 6
local MIN_AVAILABLE_TIME_MS = 2
local previousBufferDelta = 0
local scheduleTimeCounterMs = 0
local globalStartTimeMs = 0
local globalDelta = 0

--Ticks
local MAX_TICKS_FOR_ACTION = 20
local tickCounter = 0

--Sprite Vars
local spriteLookup = {}

--Moddata Vars
--modDataLookup[keyName] = { key = modDataKey, value = modDataValue }
local modDataLookup = {}

--objectTypeLookup[Key] = WDecay_Object_Buffer_Types
local objectTypeLookup = {}
--objectCreationFunctionLookup[WDecay_Object_Buffer_Types] = function(key)
local objectCreationFunctionLookup = {}
--bufferObjectCreationFunctionLookup[WDecay_Object_Buffer_Types] = function(key)
local bufferObjectCreationFunctionLookup = {}

--Object Configurator
local objectConfiguratorLookUp = {}

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

local function callConfigurator(key, object, modDataLookup)
    local configurator = objectConfiguratorLookUp[key]

    if configurator then
        configurator(key, object, modDataLookup)
    end
end

local function setModData(modDataKey, modData)
    if modDataLookup and modDataLookup[modDataKey] then
        for key, value in pairs(modDataLookup[modDataKey]) do
            modData[key] = value
        end
    else
        writeLogDebug("Moddata not found for key '" .. tostring(modDataKey) .. "'.")
    end
end

local function createIsoTreeObject(key)
    writeLogDebug("Create new IsoObject with spriteName '" .. key .. "'.")

    local object = IsoTree.new()
    local modData = object:getModData()
    object:setSpriteFromName(key)
    setModData(key, modData)
    callConfigurator(key, object, modData)
    return object
end

local function allocateNewIsoTree(key)
    local object = 0
    local buffer = objectBufferLookup[key].buffer
    local count = objectBufferLookup[key].calculatedPart
    local hasModData = modDataLookup[key]
    local modData = nil

    if buffer then
        local bufferCount = #buffer

        for i = 1, count do
            object = IsoTree.new()
            object:setSpriteFromName(key)

            if hasModData then
                modData = object:getModData()
                setModData(key, modData)
            end

            callConfigurator(key, object, modData)
            buffer[bufferCount + i] = object
            objectCount = objectCount + 1
        end
    end
end

local function createIsoObject(key)
    writeLogDebug("Create new IsoObject with spriteName '" .. key .. "'.")

    local object = IsoObject.new(key)
    object:setSpriteFromName(key)
    local modData = object:getModData()
    setModData(key, modData)
    callConfigurator(key, object, modData)
    return object
end

local function allocateNewIsoObjects(key)
    local object = 0
    local buffer = objectBufferLookup[key].buffer
    local count = objectBufferLookup[key].calculatedPart
    local hasModData = modDataLookup[key]
    local modData = nil

    if buffer then
        local bufferCount = #buffer

        for i = 1, count do
            object = IsoObject.new(key)
            object:setSpriteFromName(key)

            if hasModData then
                modData = object:getModData()
                setModData(key, modData)
            end

            callConfigurator(key, object, modData)

            buffer[bufferCount + i] = object
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
                    bufferObjectCreationFunctionLookup[objectTypeLookup[keyName]](keyName)
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

local function initCreationFunctions()
    bufferObjectCreationFunctionLookup[WDecay_Object_Buffer_Types.IsoObjectType] = allocateNewIsoObjects
    objectCreationFunctionLookup[WDecay_Object_Buffer_Types.IsoObjectType] = createIsoObject

    bufferObjectCreationFunctionLookup[WDecay_Object_Buffer_Types.IsoTreeType] = allocateNewIsoTree
    objectCreationFunctionLookup[WDecay_Object_Buffer_Types.IsoTreeType] = createIsoTreeObject
end

local function initObjectBuffer()
    if isClient() then return end

    writeLog("Initialize object buffer...")
    local startTime = getTimestampMs()

    for i = 1, #lookUpKeys do
        objectBufferLookup[lookUpKeys[i]] = { buffer = table.newarray(), calculatedPart = 0, partOfTotalBuffer = 0 }
    end

    initCreationFunctions()

    local initDelta = getTimestampMs() - startTime
    writeLog("Object buffer initialized successfully in " .. tostring(initDelta) .. "ms!")
    printBuffer()
end

--- Function to register tables of spritenames, to buffer the data for later usage
---@param spriteNames table
---@param type IsoObjectType | IsoTreeType
function WDecay_Object_Buffer.register(spriteNames, type)
    if isClient() then return end

    WDecay_Object_Buffer.registerWithModData(spriteNames, nil, nil, type)
end

--- Function to register tables of spritenames, to buffer the data for later usage
---@param spriteNames table
---@param modDataKey string
---@param modDataValue string
---@param type IsoObjectType | IsoTreeType
function WDecay_Object_Buffer.registerWithModData(spriteNames, modDataKey, modDataValue, type)
    if isClient() then return end

    if modDataKey and modDataValue then  
        WDecay_Object_Buffer.registerWithModDataPairList(spriteNames, { [modDataKey] = modDataValue }, type)
    else
        WDecay_Object_Buffer.registerWithModDataPairList(spriteNames, nil, type)
    end
end

--- Function to register tables of spritenames, to buffer the data for later usage. 
--- Example of a modDataPairs table = { [key] = value }
---@param spriteNames table
---@param modDataPairs table
---@param type IsoObjectType | IsoTreeType
function WDecay_Object_Buffer.registerWithModDataPairList(spriteNames, modDataPairs, type)
    if isClient() then return end

    if WDecay_Object_Buffer_Types.isValidObjectType(type) then
        writeLog("Loading '" .. tostring(#spriteNames) .. "' sprites in the buffer.")
        local keyName = nil
        local startTime = getTimestampMs()
        local beginPos = #lookUpKeys
        local validSpriteCount = 0

        for i = 1, #spriteNames do
            keyName = spriteNames[i]

            if keyName then
                if modDataPairs and not modDataLookup[keyName] then
                    modDataLookup[keyName] = {}

                    for key, value in pairs(modDataPairs) do
                        modDataLookup[keyName][key] = value
                        writeLogDebug("Added moddata to the sprite '" .. tostring(keyName) .. "' with modData[" .. tostring(key) .. "] = '" .. tostring(value) .. "'.")
                    end
                end

                if not objectTypeLookup[keyName] then
                    objectTypeLookup[keyName] = type
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
    else
        writeLogDebug("Incompatible type '" .. tostring(type) .. "' in sprite-array '" .. tostring(spriteNames) .. "'.")
    end

    printBuffer()
end

--- Registers a list of sprite names with an optional configurator function to customize objects during buffer allocation and direct creation.
--- The configurator function is applied to each object, allowing modifications before the object is stored in the buffer or returned.
---@param spriteName string A list of sprite names to register in the buffer.
---@param configurator function A function that receives the object and the key, used to configure each object individually. Example function header = function config(spriteName, object, modData) ModData can be nil!
function WDecay_Object_Buffer.registerConfigurator(spriteNames, configurator)
    if isClient() then return end

    if spriteNames then 
        for __, value in pairs(spriteNames) do
            writeLogDebug("Registering new configurator for sprite name '" .. value .. "'.")
            --Is the sprite existing
            if spriteLookup[value] then 
                objectConfiguratorLookUp[value] = configurator
            else
                writeLogDebug("Registering failed, because the sprite name '" .. value .. "' is not found in the object buffer.")
            end 
        end
    else
        writeLogDebug("An error occured in registerWithObjectBufferConfigurator, because spriteNames is not a key/value table.")
    end

    printBuffer()
end

--- Function to get buffered objects, when these are generated. When they are not generated, a new object get created
---@param spriteName string
---@return IsoObject | IsoTree
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
            return objectCreationFunctionLookup[objectTypeLookup[spriteName]](spriteName)
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
        if isClient() then return end

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
