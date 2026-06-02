local randomizer = newrandom()
randomizer:seed(ZombRand(1, 2147483647))

local WDecay_Destroyed_Doors_Windows = require('WDecay_Destroyed_Doors_Windows/WDecay_Destroyed_Doors_Windows')

local cachedDestroyedDoorsPercentage = nil
local cachedDestroyedWindowsPercentage = nil
local function getDestroyedDoorsPercentage()
    if cachedDestroyedDoorsPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.destroyedDoorsPercentage')
        cachedDestroyedDoorsPercentage = opt and opt:getValue() or 30
    end

    return cachedDestroyedDoorsPercentage
end

local function getDestroyedWindowsPercentage()
    if cachedDestroyedWindowsPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.destroyedWindowsPercentage')
        cachedDestroyedWindowsPercentage = opt and opt:getValue() or 30
    end

    return cachedDestroyedWindowsPercentage
end

local function LoadGridsquare(square, checkResult, level)
    if not square then return end

    if not checkResult then return end

    if not checkResult.room then return end

    if level ~= 0 then return end

    local objects = checkResult.objects or square:getObjects()
    if not objects or objects:size() == 0 then return end

    local objectsToProcess = {}
    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        if obj then
            objectsToProcess[#objectsToProcess + 1] = obj
        end
    end

    for _, obj in ipairs(objectsToProcess) do
        if obj == nil then
        else
            if WDecay_Destroyed_Doors_Windows.isDoor(obj) then
                if not WDecay_Destroyed_Doors_Windows.isDestroyed(obj) then
                    if getDestroyedDoorsPercentage() >= randomizer:random(1, 101) then
                        WDecay_Destroyed_Doors_Windows.destroyDoor(obj)
                    end
                end
            elseif WDecay_Destroyed_Doors_Windows.isWindow(obj) then
                if not WDecay_Destroyed_Doors_Windows.isDestroyed(obj) then
                    if getDestroyedWindowsPercentage() >= randomizer:random(1, 101) then
                        WDecay_Destroyed_Doors_Windows.destroyWindow(obj)
                    end
                end
            end
        end
    end
end

if not WDecay_ModifierGenerators then WDecay_ModifierGenerators = {} end

table.insert(WDecay_ModifierGenerators, LoadGridsquare)

return WDecay_Destroyed_Doors_Windows
