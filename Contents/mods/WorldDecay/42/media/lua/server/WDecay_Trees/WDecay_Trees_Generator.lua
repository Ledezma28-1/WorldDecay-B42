local WDecay_Object_Buffer = require("WDecay_Object_Buffer")

local randomizer = newrandom()
randomizer:seed(ZombRand(1, 2147483647))

local WDecay_Trees = require('WDecay_Trees/WDecay_Trees')

local cachedTreePercentage = nil
local cachedTreePercentageOnRoad = nil
local function getTreePercentage()
    if cachedTreePercentage == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.treePercentage')
        cachedTreePercentage = opt and opt:getValue() or 17
    end

    return cachedTreePercentage
end

local function getTreePercentageOnRoad()
    if cachedTreePercentageOnRoad == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.treePercentageOnRoad')
        cachedTreePercentageOnRoad = opt and opt:getValue() or 0
    end

    return cachedTreePercentageOnRoad
end

local function LoadGridsquare(square, checkResult, level)
    if not square then return end

    if not checkResult then return end

    if not checkResult.isSolid then return end

    if level ~= 0 then return end

    local isRoad = checkResult.isRoad

    if not isRoad and not checkResult.isNatural then return end

    local percentage = isRoad and getTreePercentageOnRoad() or getTreePercentage()

    if percentage >= randomizer:random(1, 101) then
        local randomTreeSprite = WDecay_Trees.getRandomTreeSprite()

        if randomTreeSprite then
            local newTree = WDecay_Object_Buffer.getObject(randomTreeSprite)
            newTree:setSquare(square)
            square:AddSpecialObject(newTree)

            newTree:transmitCompleteItemToClients()
            local sqModData = square:getModData()
            if sqModData then
                sqModData["WDecay_HasTree"] = true
            end

            return true

        end
    end

    return false
end

if not WDecay_PlacementGenerators then WDecay_PlacementGenerators = {} end

table.insert(WDecay_PlacementGenerators, LoadGridsquare)

return WDecay_Trees
