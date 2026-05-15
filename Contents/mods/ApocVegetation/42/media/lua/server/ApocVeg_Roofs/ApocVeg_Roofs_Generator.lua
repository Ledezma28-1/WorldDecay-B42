local ApocVeg_Roofs = require('ApocVeg_Roofs/ApocVeg_Roofs')
local ApocVeg_Grass = require('ApocVeg_ZZGrass/ApocVeg_Grass')
local ApocVeg_Bushes = require('ApocVeg_ZBushes/ApocVeg_Bushes')

local cachedRoofPercentage = nil
local function getRoofPercentage()
    if cachedRoofPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.roofPercentage')
        cachedRoofPercentage = opt and opt:getValue() or 20
    end
    return cachedRoofPercentage
end

local cachedRoofGrassPercentage = nil
local function getRoofGrassPercentage()
    if cachedRoofGrassPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.roofGrassPercentage')
        cachedRoofGrassPercentage = opt and opt:getValue() or 0
    end
    return cachedRoofGrassPercentage
end

local cachedRoofCustomGrassPercentage = nil
local function getRoofCustomGrassPercentage()
    if cachedRoofCustomGrassPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.roofCustomGrassPercentage')
        cachedRoofCustomGrassPercentage = opt and opt:getValue() or 0
    end
    return cachedRoofCustomGrassPercentage
end

local function isRoofSquare(sprite, spriteName)
    if sprite then
        local props = sprite:getProperties()
        if props and props:get("RoofGroup") then
            return true
        end
    end
    if spriteName then
        if luautils.stringStarts(spriteName, "roofs_") then
            return true
        end
    end
    return false
end

local function LoadGridsquare(square, checkResult)
    if not square then return end

    local modData = square:getModData()
    if not modData then return end
    if modData["ApocVeg_Roofs"] then return end

    modData["ApocVeg_Roofs"] = true

    if square:getZ() <= 1 then return end

    local objects = square:getObjects()
    if not objects or objects:size() == 0 then return end

    local isRoof = false

    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        if obj then
            local sprite = obj:getSprite()
            if sprite then
                if isRoofSquare(sprite, sprite:getName()) then
                    isRoof = true
                    break
                end
            end
        end
    end

    if not isRoof then return end

    local bushPct = getRoofPercentage()
    if bushPct > 0 and bushPct >= ZombRand(1, 101) then
        local randomBush = ApocVeg_Bushes.getRandomBush()
        if randomBush then
            local bushObj = IsoObject.new(getCell(), square, randomBush)
            square:AddSpecialObject(bushObj)
            local bushModData = bushObj:getModData()
            if bushModData then
                bushModData["ApocVeg_Cleanable"] = "bush"
            end
            bushObj:transmitCompleteItemToClients()
        end
    end

    local roofGrassPct = getRoofGrassPercentage()
    local roofCustomPct = getRoofCustomGrassPercentage()
    local totalGrassPct = roofGrassPct + roofCustomPct
    if totalGrassPct > 0 and totalGrassPct >= ZombRand(1, 101) then
        local useCustom = roofCustomPct > 0 and ZombRand(1, roofGrassPct + roofCustomPct + 1) > roofGrassPct
        local randomGrass
        if useCustom then
            randomGrass = ApocVeg_Grass.getRandomCustomGrass()
        else
            randomGrass = ApocVeg_Grass.getRandomVanillaGrass()
        end
        if randomGrass then
            local grassObj = IsoObject.new(getCell(), square, randomGrass)
            square:AddSpecialObject(grassObj)
            local grassModData = grassObj:getModData()
            if grassModData then
                grassModData["ApocVeg_Cleanable"] = "grass"
            end
            grassObj:transmitCompleteItemToClients()
        end
    end
end

if not ApocVeg_ModifierGenerators then ApocVeg_ModifierGenerators = {} end
table.insert(ApocVeg_ModifierGenerators, LoadGridsquare)
ApocVeg_ModifierGenerators[8] = LoadGridsquare

return ApocVeg_Roofs
