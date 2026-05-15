local ApocVeg_Bushes = require('ApocVeg_ZBushes/ApocVeg_Bushes')
local ApocVeg_CustomNames_Integration = require('ApocVeg_CustomNames/ApocVeg_CustomNames_Integration')

local cachedBushesPercentage = nil
local cachedBushesPercentageOnRoad = nil
local cachedIndoorBushesPercentage = nil
local function getBushesPercentage()
    if cachedBushesPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.bushesPercentage')
        cachedBushesPercentage = opt and opt:getValue() or 20
    end
    return cachedBushesPercentage
end
local function getBushesPercentageOnRoad()
    if cachedBushesPercentageOnRoad == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.bushesPercentageOnRoad')
        cachedBushesPercentageOnRoad = opt and opt:getValue() or 0
    end
    return cachedBushesPercentageOnRoad
end
local function getIndoorBushesPercentage()
    if cachedIndoorBushesPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.indoorBushesPercentage')
        cachedIndoorBushesPercentage = opt and opt:getValue() or 0
    end
    return cachedIndoorBushesPercentage
end

local function LoadGridsquare(square, checkResult)
    if not square then return end
    if not checkResult then return end
    if not checkResult.objects then return end
    if square:getZ() ~= 0 then return end

    local isIndoor = checkResult.room ~= nil
    local isRoad = checkResult.isRoad

    if not checkResult.passed and not isIndoor then return end
    
    local percentage
    if isIndoor then
        percentage = getIndoorBushesPercentage()
    else
        percentage = isRoad and getBushesPercentageOnRoad() or getBushesPercentage()
    end
    
    if percentage <= 0 then return end
    
    if percentage >= ZombRand(1, 101) then
        local sqModData = square:getModData()
        if sqModData and sqModData["ApocVeg_HasTree"] then return end
        local floor = square:getFloor()
        local currentFloorTile = floor and floor:getSprite() and floor:getSprite():getName()

        if currentFloorTile ~= nil then
            local randomBush = ApocVeg_Bushes.getRandomBush()

            if randomBush then
                local obj = IsoObject.new(getCell(), square, randomBush)
                square:AddSpecialObject(obj)
                ApocVeg_CustomNames_Integration.applyCustomNameToObject(obj)
                local objModData = obj:getModData()
                if objModData then
                    objModData["ApocVeg_Cleanable"] = "bush"
                end
                obj:transmitCompleteItemToClients()
                return true
            end
        end
    end
    return false
end

if not ApocVeg_PlacementGenerators then ApocVeg_PlacementGenerators = {} end
table.insert(ApocVeg_PlacementGenerators, LoadGridsquare)

return ApocVeg_Bushes
