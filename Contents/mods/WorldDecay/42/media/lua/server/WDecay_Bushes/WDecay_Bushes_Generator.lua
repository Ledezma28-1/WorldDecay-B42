local randomizer = newrandom()
randomizer:seed(ZombRand(1, 2147483647))

local WDecay_Bushes = require('WDecay_Bushes/WDecay_Bushes')
local WDecay_CustomNames_Integration = require('WDecay_CustomNames/WDecay_CustomNames_Integration')

local cachedBushesPercentage = nil
local cachedBushesPercentageOnRoad = nil
local cachedIndoorBushesPercentage = nil
local function getBushesPercentage()
    if cachedBushesPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.bushesPercentage')
        cachedBushesPercentage = opt and opt:getValue() or 20
    end
    return cachedBushesPercentage
end
local function getBushesPercentageOnRoad()
    if cachedBushesPercentageOnRoad == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.bushesPercentageOnRoad')
        cachedBushesPercentageOnRoad = opt and opt:getValue() or 0
    end
    return cachedBushesPercentageOnRoad
end
local function getIndoorBushesPercentage()
    if cachedIndoorBushesPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.indoorBushesPercentage')
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
    
    if percentage >= randomizer:random(1, 101) then
        local sqModData = square:getModData()
        if sqModData and sqModData["WDecay_HasTree"] then return end
        local floor = square:getFloor()
        local currentFloorTile = floor and floor:getSprite() and floor:getSprite():getName()

        if currentFloorTile ~= nil then
            local randomBush = WDecay_Bushes.getRandomBush()

            if randomBush then
                local obj = IsoObject.new(getCell(), square, randomBush)
                square:AddSpecialObject(obj)
                WDecay_CustomNames_Integration.applyCustomNameToObject(obj)
                local objModData = obj:getModData()
                if objModData then
                    objModData["WDecay_Cleanable"] = "bush"
                end
                obj:transmitCompleteItemToClients()
                return true
            end
        end
    end
    return false
end

if not WDecay_PlacementGenerators then WDecay_PlacementGenerators = {} end
table.insert(WDecay_PlacementGenerators, LoadGridsquare)

return WDecay_Bushes
