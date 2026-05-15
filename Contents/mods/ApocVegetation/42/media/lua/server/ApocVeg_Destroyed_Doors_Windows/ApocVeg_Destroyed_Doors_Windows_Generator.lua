local ApocVeg_Destroyed_Doors_Windows = require('ApocVeg_Destroyed_Doors_Windows/ApocVeg_Destroyed_Doors_Windows')

local cachedDestroyedDoorsPercentage = nil
local cachedDestroyedWindowsPercentage = nil
local function getDestroyedDoorsPercentage()
    if cachedDestroyedDoorsPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.destroyedDoorsPercentage')
        cachedDestroyedDoorsPercentage = opt and opt:getValue() or 30
    end
    return cachedDestroyedDoorsPercentage
end
local function getDestroyedWindowsPercentage()
    if cachedDestroyedWindowsPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.destroyedWindowsPercentage')
        cachedDestroyedWindowsPercentage = opt and opt:getValue() or 30
    end
    return cachedDestroyedWindowsPercentage
end

local function LoadGridsquare(square, checkResult)
    if not square then return end
    if not checkResult then return end
    if not checkResult.room then return end
    if square:getZ() ~= 0 then return end

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
            if ApocVeg_Destroyed_Doors_Windows.isDoor(obj) then
                if not ApocVeg_Destroyed_Doors_Windows.isDestroyed(obj) then
                    if getDestroyedDoorsPercentage() >= ZombRand(1, 101) then
                        ApocVeg_Destroyed_Doors_Windows.destroyDoor(obj)
                    end
                end
            elseif ApocVeg_Destroyed_Doors_Windows.isWindow(obj) then
                if not ApocVeg_Destroyed_Doors_Windows.isDestroyed(obj) then
                    if getDestroyedWindowsPercentage() >= ZombRand(1, 101) then
                        ApocVeg_Destroyed_Doors_Windows.destroyWindow(obj)
                    end
                end
            end
        end
    end
end

if not ApocVeg_ModifierGenerators then ApocVeg_ModifierGenerators = {} end
table.insert(ApocVeg_ModifierGenerators, LoadGridsquare)

return ApocVeg_Destroyed_Doors_Windows
