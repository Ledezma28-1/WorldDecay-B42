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

local function isInteriorWall(textureName)
    if not textureName then return false end
    return luautils.stringStarts(textureName, "walls_interior_")
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

local function LoadGridsquare(square, checkResult)
    if not square then return end
    
    local modData = square:getModData()
    if not modData then return end
    if modData["WDecay_Vines"] then return end
    
    modData["WDecay_Vines"] = true
    
    if not getMultiFloorVines() and square:getZ() ~= 0 then return end
    
    if isVinesExteriorOnly() and square:getRoom() then return end
    
    if getVinePercentage() < ZombRand(1, 101) then
        return
    end
    
    local objects = square:getObjects()
    if not objects or objects:size() == 0 then return end
    
    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        if not obj then
        else
            local sprite = obj:getSprite()
            if not sprite then
            else
                local textureName = obj:getTextureName()

                if textureName and isWallTile(textureName) then
                    if not luautils.stringStarts(textureName, "walls_detailling") then
                        local spriteName = sprite:getName()
                        if spriteName then
                            local isLowFenceObj = isLowFence(sprite)


                            if hasWallProperty(sprite, "WallNW") then
                                local randomOverlay = WDecay_Vines.getRandomWallNW()

                                if isLowFenceObj then
                                    randomOverlay = WDecay_Vines.getRandomWallNWLow()
                                end

                                if randomOverlay then
                                    local obj2 = IsoObject.new(getCell(), square, randomOverlay)
                                    square:AddTileObject(obj2)
                                    obj2:transmitCompleteItemToClients()
                                    local obj2ModData = obj2:getModData()
                                    obj2ModData["WDecay_Cleanable"] = "vine"

                                    if false then
                                        local neighbour = getCell():getGridSquare(square:getX(), square:getY(), square:getZ() + 1)
                                        if neighbour then
                                            local neighbourObjs = neighbour:getObjects()
                                            if neighbourObjs then
                                                for j = 0, neighbourObjs:size() - 1 do
                                                    local neighbourObj = neighbourObjs:get(j)
                                                    if neighbourObj then
                                                        local neighbourSprite = neighbourObj:getSprite()
                                                        if neighbourSprite then
                                                            local neighbourSpriteName = neighbourSprite:getName()
                                                            if neighbourSpriteName and
                                                               luautils.stringStarts(tostring(neighbourSpriteName), "walls_") and
                                                               not luautils.stringStarts(tostring(neighbourSpriteName), "walls_detailling") and
                                                               not luautils.stringStarts(tostring(neighbourSpriteName), "walls_exterior_roofs") and
                                                               not luautils.stringStarts(tostring(neighbourSpriteName), "walls_interior") then

                                                                local randomOverlay2 = WDecay_Vines.getRandomWallNWTop()
                                                                if randomOverlay2 then
                                                                    local obj3 = IsoObject.new(getCell(), neighbour, randomOverlay2)
                                                                    neighbour:AddSpecialObject(obj3)
                                                                    obj3:transmitCompleteItemToClients()
                                                                    local obj3ModData = obj3:getModData()
                                                                    obj3ModData["WDecay_Cleanable"] = "vine"
                                                                end
                                                                break
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end

                            if hasWallProperty(sprite, "WallW") or hasWallProperty(sprite, "WindowW") or
                               hasWallProperty(sprite, "doorW") or hasWallProperty(sprite, "DoorWallW") or
                               hasWallProperty(sprite, "attachedW") or hasWallProperty(sprite, "WallWTrans") then

                                local randomOverlay = WDecay_Vines.getRandomWallW()

                                if isLowFenceObj then
                                    randomOverlay = WDecay_Vines.getRandomWallWLow()
                                end

                                if randomOverlay then
                                    local obj2 = IsoObject.new(getCell(), square, randomOverlay)
                                    square:AddTileObject(obj2)
                                    obj2:transmitCompleteItemToClients()
                                    local obj2ModData = obj2:getModData()
                                    obj2ModData["WDecay_Cleanable"] = "vine"

                                    if false then
                                        local neighbour = getCell():getGridSquare(square:getX(), square:getY(), square:getZ() + 1)
                                        if neighbour then
                                            local neighbourObjs = neighbour:getObjects()
                                            if neighbourObjs then
                                                for j = 0, neighbourObjs:size() - 1 do
                                                    local neighbourObj = neighbourObjs:get(j)
                                                    if neighbourObj then
                                                        local neighbourSprite = neighbourObj:getSprite()
                                                        if neighbourSprite then
                                                            local neighbourSpriteName = neighbourSprite:getName()
                                                            if neighbourSpriteName and
                                                               luautils.stringStarts(tostring(neighbourSpriteName), "walls_") and
                                                               not luautils.stringStarts(tostring(neighbourSpriteName), "walls_detailling") and
                                                               not luautils.stringStarts(tostring(neighbourSpriteName), "walls_exterior_roofs") and
                                                               not luautils.stringStarts(tostring(neighbourSpriteName), "walls_interior") then

                                                                local randomOverlay2 = WDecay_Vines.getRandomWallWTop()
                                                                if randomOverlay2 then
                                                                    local obj3 = IsoObject.new(getCell(), neighbour, randomOverlay2)
                                                                    neighbour:AddSpecialObject(obj3)
                                                                    obj3:transmitCompleteItemToClients()
                                                                    local obj3ModData = obj3:getModData()
                                                                    obj3ModData["WDecay_Cleanable"] = "vine"
                                                                end
                                                                break
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end

                            if hasWallProperty(sprite, "WallN") or hasWallProperty(sprite, "WindowN") then
                                local randomOverlay = WDecay_Vines.getRandomWallN()

                                if isLowFenceObj then
                                    randomOverlay = WDecay_Vines.getRandomWallNLow()
                                end

                                if randomOverlay then
                                    local obj2 = IsoObject.new(getCell(), square, randomOverlay)
                                    square:AddTileObject(obj2)
                                    obj2:transmitCompleteItemToClients()
                                    local obj2ModData = obj2:getModData()
                                    obj2ModData["WDecay_Cleanable"] = "vine"

                                    if false then
                                        local neighbour = getCell():getGridSquare(square:getX(), square:getY(), square:getZ() + 1)
                                        if neighbour then
                                            local neighbourObjs = neighbour:getObjects()
                                            if neighbourObjs then
                                                for j = 0, neighbourObjs:size() - 1 do
                                                    local neighbourObj = neighbourObjs:get(j)
                                                    if neighbourObj then
                                                        local neighbourSprite = neighbourObj:getSprite()
                                                        if neighbourSprite then
                                                            local neighbourSpriteName = neighbourSprite:getName()
                                                            if neighbourSpriteName and
                                                               luautils.stringStarts(tostring(neighbourSpriteName), "walls_") and
                                                               not luautils.stringStarts(tostring(neighbourSpriteName), "walls_detailling") and
                                                               not luautils.stringStarts(tostring(neighbourSpriteName), "walls_exterior_roofs") and
                                                               not luautils.stringStarts(tostring(neighbourSpriteName), "walls_interior") then

                                                                local randomOverlay2 = WDecay_Vines.getRandomWallNTop()
                                                                if randomOverlay2 then
                                                                    local obj3 = IsoObject.new(getCell(), neighbour, randomOverlay2)
                                                                    neighbour:AddSpecialObject(obj3)
                                                                    obj3:transmitCompleteItemToClients()
                                                                    local obj3ModData = obj3:getModData()
                                                                    obj3ModData["WDecay_Cleanable"] = "vine"
                                                                end
                                                                break
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
end

if not WDecay_ModifierGenerators then WDecay_ModifierGenerators = {} end
table.insert(WDecay_ModifierGenerators, LoadGridsquare)

return WDecay_Vines
