local ApocVeg_Cracks = require('ApocVeg_Cracks/ApocVeg_Cracks')

local cachedRoadCrackOverlayPercentage = nil
local cachedDirtCrackOverlayPercentage = nil
local function getRoadCrackOverlayPercentage()
    if cachedRoadCrackOverlayPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.roadCrackOverlayPercentage')
        cachedRoadCrackOverlayPercentage = opt and opt:getValue() or 10
    end
    return cachedRoadCrackOverlayPercentage
end
local function getDirtCrackOverlayPercentage()
    if cachedDirtCrackOverlayPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.dirtCrackOverlayPercentage')
        cachedDirtCrackOverlayPercentage = opt and opt:getValue() or 10
    end
    return cachedDirtCrackOverlayPercentage
end

local DEFAULT_SPRITE_ID = 20000000

local function LoadGridsquare(square, checkResult)
    if not square then return end
    if not checkResult then return end
    if not checkResult.isRoad then return end
    if square:getZ() ~= 0 then return end
    if checkResult.water then return end
    
    local objects = checkResult.objects
    if not objects or objects:size() == 0 then return end
    
    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        if obj and obj:getSprite() and obj:getClass() == IsoObject.class then
            local sprite = obj:getSprite()
            local spriteName = sprite:getName()

            if spriteName then
                local objModData = obj:getModData()
                if objModData and objModData["ApocVeg_Crack"] == "placed" then
                elseif ApocVeg_Cracks.isRoadTile(spriteName) then
                    if getRoadCrackOverlayPercentage() >= ZombRand(1, 101) then
                        local blendsType = "street"
                        if ZombRand(1, 10) == 1 then
                            blendsType = "dirt"
                        end

                        local overlayId = tostring(ZombRand(0, 32))
                        local overlayName = "blends_" .. blendsType .. "overlays_01_" .. overlayId

                        local overlaySprite = getSprite(overlayName)
                        if overlaySprite and overlaySprite:getID() ~= DEFAULT_SPRITE_ID then
                            local attachedSprites = obj:getAttachedAnimSprite()
                            if not attachedSprites then
                                attachedSprites = ArrayList.new()
                                obj:setAttachedAnimSprite(attachedSprites)
                            end
                            
                            local alreadyAttached = false
                            for n = 0, attachedSprites:size() - 1 do
                                local existing = attachedSprites:get(n)
                                if existing and existing:getParentSprite() and existing:getParentSprite():getID() == overlaySprite:getID() then
                                    alreadyAttached = true
                                    break
                                end
                            end
                            
                            if not alreadyAttached then
                                attachedSprites:add(overlaySprite:newInstance())
                                local objModData2 = obj:getModData()
                                if objModData2 then
                                    objModData2["ApocVeg_Crack"] = "placed"
                                    objModData2["ApocVeg_Cleanable"] = "crack"
                                end
                                obj:transmitCompleteItemToClients()
                            end
                        end
                    end
                elseif ApocVeg_Cracks.isNaturalTile(spriteName) then
                    if getDirtCrackOverlayPercentage() >= ZombRand(1, 101) then
                        local overlayId = tostring(ZombRand(0, 32))
                        local overlayName = "blends_dirtoverlays_01_" .. overlayId

                        local overlaySprite = getSprite(overlayName)
                        if overlaySprite and overlaySprite:getID() ~= DEFAULT_SPRITE_ID then
                            local attachedSprites = obj:getAttachedAnimSprite()
                            if not attachedSprites then
                                attachedSprites = ArrayList.new()
                                obj:setAttachedAnimSprite(attachedSprites)
                            end
                            
                            local alreadyAttached = false
                            for n = 0, attachedSprites:size() - 1 do
                                local existing = attachedSprites:get(n)
                                if existing and existing:getParentSprite() and existing:getParentSprite():getID() == overlaySprite:getID() then
                                    alreadyAttached = true
                                    break
                                end
                            end
                            
                            if not alreadyAttached then
                                attachedSprites:add(overlaySprite:newInstance())
                                local objModData2 = obj:getModData()
                                if objModData2 then
                                    objModData2["ApocVeg_Crack"] = "placed"
                                    objModData2["ApocVeg_Cleanable"] = "crack"
                                end
                                obj:transmitCompleteItemToClients()
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

return ApocVeg_Cracks
