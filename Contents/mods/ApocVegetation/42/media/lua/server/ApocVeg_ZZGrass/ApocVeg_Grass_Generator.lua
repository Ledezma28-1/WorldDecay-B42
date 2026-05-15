local ApocVeg_Grass = require('ApocVeg_ZZGrass/ApocVeg_Grass')
local ApocVeg_CustomNames_Integration = require('ApocVeg_CustomNames/ApocVeg_CustomNames_Integration')

local cachedGrassPercentage = nil
local cachedGrassPercentageOnRoad = nil
local cachedCustomGrassPercentage = nil
local cachedCustomGrassPercentageOnRoad = nil
local cachedIndoorGrassPercentage = nil
local function getGrassPercentage()
    if cachedGrassPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.grassPercentage')
        cachedGrassPercentage = opt and opt:getValue() or 30
    end
    return cachedGrassPercentage
end
local function getGrassPercentageOnRoad()
    if cachedGrassPercentageOnRoad == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.grassPercentageOnRoad')
        cachedGrassPercentageOnRoad = opt and opt:getValue() or 20
    end
    return cachedGrassPercentageOnRoad
end
local function getCustomGrassPercentage()
    if cachedCustomGrassPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.customGrassPercentage')
        cachedCustomGrassPercentage = opt and opt:getValue() or 10
    end
    return cachedCustomGrassPercentage
end
local function getCustomGrassPercentageOnRoad()
    if cachedCustomGrassPercentageOnRoad == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.customGrassPercentageOnRoad')
        cachedCustomGrassPercentageOnRoad = opt and opt:getValue() or 10
    end
    return cachedCustomGrassPercentageOnRoad
end
local function getIndoorGrassPercentage()
    if cachedIndoorGrassPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.indoorGrassPercentage')
        cachedIndoorGrassPercentage = opt and opt:getValue() or 0
    end
    return cachedIndoorGrassPercentage
end

local function LoadGridsquare(square, checkResult)
    if not square then return end
    if not checkResult then return end
    if square:getZ() ~= 0 then return end
    local squareCheckOk = checkResult.passed
    if not squareCheckOk and getIndoorGrassPercentage() <= 0 then return end
    if not squareCheckOk then
        if getIndoorGrassPercentage() > 0 and checkResult.room and not checkResult.water
                and not checkResult.isSolid and not checkResult.hasStairs
                and not checkResult.hasDoor then
                if getIndoorGrassPercentage() >= ZombRand(1, 101) then
                    local floor = square:getFloor()
                    if floor then
                        local floorSprite = floor:getSprite()
                        if floorSprite then
                            local randomGrass = ApocVeg_Grass.getRandomVanillaGrass()
                            if randomGrass then
                                local obj = IsoObject.new(getCell(), square, randomGrass)
                                square:AddSpecialObject(obj)
                                ApocVeg_CustomNames_Integration.applyCustomNameToObject(obj)
                                local objModData = obj:getModData()
                                if objModData then
                                    objModData["ApocVeg_Cleanable"] = "grass"
                                end
obj:transmitCompleteItemToClients()
                                return true
                            end
                        end
                    end
                end
            end
            return
    end
    
    local isRoad = checkResult.isRoad
    
    local vanillaPct = isRoad and getGrassPercentageOnRoad() or getGrassPercentage()
    if vanillaPct > 0 and vanillaPct >= ZombRand(1, 101) then
        local floor = square:getFloor()
        if floor then
            local floorSprite = floor:getSprite()
            if floorSprite then
                local currentFloorTile = floorSprite:getName()
                if currentFloorTile ~= nil then
                    local randomGrass = ApocVeg_Grass.getRandomVanillaGrass()
                    if randomGrass then
                        local obj = IsoObject.new(getCell(), square, randomGrass)
                        square:AddSpecialObject(obj)
                        ApocVeg_CustomNames_Integration.applyCustomNameToObject(obj)
                        local objModData = obj:getModData()
                        if objModData then
                            objModData["ApocVeg_Cleanable"] = "grass"
                        end
                        obj:transmitCompleteItemToClients()
                    end
                end
            end
        end
    end

    local customPct = isRoad and getCustomGrassPercentageOnRoad() or getCustomGrassPercentage()
    if customPct > 0 and customPct >= ZombRand(1, 101) then
        local floor = square:getFloor()
        if floor then
            local floorSprite = floor:getSprite()
            if floorSprite then
                local currentFloorTile = floorSprite:getName()
                if currentFloorTile ~= nil then
                    local randomGrass = ApocVeg_Grass.getRandomCustomGrass()
                    if randomGrass then
                        local obj = IsoObject.new(getCell(), square, randomGrass)
                        square:AddSpecialObject(obj)
                        ApocVeg_CustomNames_Integration.applyCustomNameToObject(obj)
                        local objModData = obj:getModData()
                        if objModData then
                            objModData["ApocVeg_Cleanable"] = "grass"
                        end
                        obj:transmitCompleteItemToClients()
                    end
                end
            end
        end
    end
end

if not ApocVeg_PlacementGenerators then ApocVeg_PlacementGenerators = {} end
table.insert(ApocVeg_PlacementGenerators, LoadGridsquare)

return ApocVeg_Grass
