local randomizer = newrandom()
randomizer:seed(ZombRand(1, 2147483647))

local DEFAULT_SPRITE_ID = 20000000

local WDecay_Vines = require('WDecay_Vines/WDecay_Vines')

local cachedVinePercentage = nil
local function getVinePercentage()
    if cachedVinePercentage == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.vinePercentage')
        cachedVinePercentage = opt and opt:getValue() or 15
    end

    return cachedVinePercentage
end

local cachedMultiFloorVines = nil
local function getMultiFloorVines()
    if cachedMultiFloorVines == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.multiFloorVines')
        cachedMultiFloorVines = opt and opt:getValue() or false
    end

    return cachedMultiFloorVines
end

local cachedVinesExteriorOnly = nil
local function isVinesExteriorOnly()
    if cachedVinesExteriorOnly == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.vinesExteriorOnly')
        cachedVinesExteriorOnly = opt and opt:getValue()
        if cachedVinesExteriorOnly == nil then cachedVinesExteriorOnly = true end
    end

    return cachedVinesExteriorOnly
end

local cachedVinesOnWalls = nil
local function isVinesOnWalls()
    if cachedVinesOnWalls == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.vinesOnWalls')
        cachedVinesOnWalls = opt and opt:getValue()
        if cachedVinesOnWalls == nil then cachedVinesOnWalls = true end
    end

    return cachedVinesOnWalls
end

local cachedVinesOnFences = nil
local function isVinesOnFences()
    if cachedVinesOnFences == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.vinesOnFences')
        cachedVinesOnFences = opt and opt:getValue()
        if cachedVinesOnFences == nil then cachedVinesOnFences = true end
    end

    return cachedVinesOnFences
end

local function isWallTile(textureName)
    if not textureName then return false end

    return luautils.stringStarts(textureName, "walls_") or
        luautils.stringStarts(textureName, "fixtures_") or
        luautils.stringStarts(textureName, "fencing_") or
        luautils.stringStarts(textureName, "location_")
end

local function isExteriorWall(textureName)
    if not textureName then return false end

    return luautils.stringStarts(textureName, "walls_exterior_") and
        not luautils.stringStarts(textureName, "walls_exterior_roofs_")
end

local function isFenceTile(textureName)
    if not textureName then return false end

    return luautils.stringStarts(textureName, "fencing_") or
        luautils.stringStarts(textureName, "fixtures_railings")
end

local function hasWallProperty(sprite, propertyName)
    if not sprite then return false end

    local properties = sprite:getProperties()
    if not properties then return false end

    return properties:has(propertyName)
end

local function isLowFence(sprite)
    if not sprite or not sprite:getProperties() then return false end

    return sprite:getProperties():has('FenceTypeLow')
end

local function attachVineSprite(obj, spriteName)
    if not obj or not spriteName then return end

    local vineSprite = getSprite(spriteName)
    if not vineSprite then return end

    if vineSprite:getID() == DEFAULT_SPRITE_ID then return end

    local attachedSprites = obj:getAttachedAnimSprite()
    if not attachedSprites then
        attachedSprites = ArrayList.new()
        obj:setAttachedAnimSprite(attachedSprites)
    end

    local alreadyAttached = false
    for n = 0, attachedSprites:size() - 1 do
        local existing = attachedSprites:get(n)
        if existing and existing:getParentSprite() and existing:getParentSprite():getID() == vineSprite:getID() then
            alreadyAttached = true
            break
        end
    end

    if not alreadyAttached then
        attachedSprites:add(vineSprite:newInstance())
        local modData = obj:getModData()
        if modData then
            modData["WDecay_Vines"] = "placed"
            modData["WDecay_Cleanable"] = "vine"
        end

        obj:transmitCompleteItemToClients()
    end
end

local function processWallObject(obj)
    if not obj then return end

    local modData = obj:getModData()
    if modData and modData["WDecay_Vines"] == "placed" then return end

    local sprite = obj:getSprite()
    if not sprite then return end

    local textureName = obj:getTextureName()
    if not textureName then return end

    if not isWallTile(textureName) then return end

    if luautils.stringStarts(textureName, "walls_detailling") then return end

    local isLowFenceObj = isLowFence(sprite)

    if isVinesOnWalls() then
        if hasWallProperty(sprite, "WallNW") or hasWallProperty(sprite, "attachedNW") then
            local randomOverlay = WDecay_Vines.getRandomWallNW()
            if isLowFenceObj then
                randomOverlay = WDecay_Vines.getRandomWallNWLow()
            end

            if randomOverlay then
                attachVineSprite(obj, randomOverlay)
            end
        end

        if hasWallProperty(sprite, "WallW") or hasWallProperty(sprite, "WindowW") or
            hasWallProperty(sprite, "doorW") or hasWallProperty(sprite, "DoorWallW") or
            hasWallProperty(sprite, "attachedW") or hasWallProperty(sprite, "WallWTrans") or
            hasWallProperty(sprite, "attachedE") then

            local randomOverlay = WDecay_Vines.getRandomWallW()
            if isLowFenceObj then
                randomOverlay = WDecay_Vines.getRandomWallWLow()
            end

            if randomOverlay then
                attachVineSprite(obj, randomOverlay)
            end
        end

        if hasWallProperty(sprite, "WallN") or hasWallProperty(sprite, "WindowN") or
            hasWallProperty(sprite, "doorN") or hasWallProperty(sprite, "DoorWallN") or
            hasWallProperty(sprite, "attachedN") or hasWallProperty(sprite, "attachedS") then
            local randomOverlay = WDecay_Vines.getRandomWallN()
            if isLowFenceObj then
                randomOverlay = WDecay_Vines.getRandomWallNLow()
            end

            if randomOverlay then
                attachVineSprite(obj, randomOverlay)
            end
        end
    end

    if isVinesOnFences() and isFenceTile(textureName) then
        local randomOverlay = WDecay_Vines.getRandomWallW()
        if isLowFenceObj then
            randomOverlay = WDecay_Vines.getRandomWallWLow()
        end

        if randomOverlay then
            attachVineSprite(obj, randomOverlay)
        end
    end
end

local function LoadGridsquare(square, checkResult, level)
    if not square then return end

    if not checkResult then return end

    if not getMultiFloorVines() and level ~= 0 then return end

    if isVinesExteriorOnly() and checkResult and checkResult.room then return end

    if getVinePercentage() < randomizer:random(1, 101) then
        return
    end

    local objects = square:getObjects()
    local objectCount = objects:size()

    if not objects or objectCount == 0 then return end

    for i = 0, objectCount - 1 do
        local obj = objects:get(i)
        if obj then
            processWallObject(obj)
        end
    end
end

if not WDecay_ModifierGenerators then WDecay_ModifierGenerators = {} end

table.insert(WDecay_ModifierGenerators, LoadGridsquare)

return WDecay_Vines
