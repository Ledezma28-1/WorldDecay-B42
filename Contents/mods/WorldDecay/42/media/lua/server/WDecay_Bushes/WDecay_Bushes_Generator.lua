local WDecay_Object_Buffer = require('WDecay_Object_Buffer')

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

local function LoadGridsquare(square, checkResult, level)
    if not square then return end

    if not checkResult then return end

    if level ~= 0 and not checkResult.hasRoof then return end

    local isRoad = checkResult.isRoad

    local percentage
    if checkResult.isIndoor then
        percentage = getIndoorBushesPercentage()
    else
        percentage = isRoad and getBushesPercentageOnRoad() or getBushesPercentage()
    end

    if percentage <= 0 then return end

    if percentage >= randomizer:random(1, 101) then
        local floor = square:getFloor()

        if floor then
            local sqModData = floor:getModData()
            if sqModData and sqModData["WDecay_HasTree"] then return end
            
            local randomBush = WDecay_Bushes.getRandomBush()

            if randomBush then
                local obj = WDecay_Object_Buffer.getObject(randomBush)
                obj:setSquare(square)
                square:AddSpecialObject(obj)
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
