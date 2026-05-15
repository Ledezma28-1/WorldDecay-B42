local ApocVeg_Walls = require('ApocVeg_Walls/ApocVeg_Walls')

local cachedWallPercentage = nil
local function getWallPercentage()
    if cachedWallPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.wallPercentage')
        cachedWallPercentage = opt and opt:getValue() or 10
    end
    return cachedWallPercentage
end

local function LoadGridsquare(square, checkResult)
    if not square then return end
    if not checkResult then return end
    if not checkResult.room then return end
    if square:getZ() ~= 0 then return end
    
    local objects = checkResult.objects
    if not objects then return end
    if objects:size() == 0 then return end

    local diagWalls = 0
    local diagBurned = 0
    
    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        if obj then
            local sprite = obj:getSprite()
            if sprite then
                local textureName = obj:getTextureName()

                if textureName and ApocVeg_Walls.isExteriorWall(textureName) then
                    diagWalls = diagWalls + 1
                    if getWallPercentage() >= ZombRand(1, 101) then
                        local spriteName = sprite:getName()
                        if spriteName then
                            local properties = sprite:getProperties()
                            if properties then
                                if not (properties:has("DoorWallN") or properties:has("DoorWallW") or
                                        properties:has("WindowN") or properties:has("WindowW")) then

                                    for _, prop in ipairs(ApocVeg_Walls.wallProperties) do
                                        if properties:has(prop) then
                                            local burnedTextures = ApocVeg_Walls.getBurnedTextures(prop)
                                            if burnedTextures and #burnedTextures > 0 then
                                                local randomTexture = burnedTextures[ZombRand(1, #burnedTextures + 1)]

                                                obj:setSpriteFromName(randomTexture)

                                                diagBurned = diagBurned + 1

                                                local objModData = obj:getModData()
                                                if objModData and not objModData["ApocVeg_Cleanable"] then
                                                    objModData["ApocVeg_Cleanable"] = "wall"
                                                end

                                                obj:transmitUpdatedSpriteToClients()

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

    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        if obj then
            local sprite = obj:getSprite()
            if sprite then
                local textureName = obj:getTextureName()

                if textureName and ApocVeg_Walls.isInteriorWall(textureName) then
                    if getWallPercentage() >= ZombRand(1, 101) then
                        local spriteName = sprite:getName()
                        if spriteName then
                            local properties = sprite:getProperties()
                            if properties then
                                if not (properties:has("DoorWallN") or properties:has("DoorWallW") or
                                        properties:has("WindowN") or properties:has("WindowW")) then

                                    for _, prop in ipairs(ApocVeg_Walls.wallProperties) do
                                        if properties:has(prop) then
                                            local burnedTextures = ApocVeg_Walls.getBurnedTextures(prop)
                                            if burnedTextures and #burnedTextures > 0 then
                                                local randomTexture = burnedTextures[ZombRand(1, #burnedTextures + 1)]

                                                obj:setSpriteFromName(randomTexture)

                                                local objModData = obj:getModData()
                                                if objModData and not objModData["ApocVeg_Cleanable"] then
                                                    objModData["ApocVeg_Cleanable"] = "wall"
                                                end

                                                obj:transmitUpdatedSpriteToClients()

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

if not ApocVeg_ModifierGenerators then ApocVeg_ModifierGenerators = {} end
table.insert(ApocVeg_ModifierGenerators, LoadGridsquare)

return ApocVeg_Walls
