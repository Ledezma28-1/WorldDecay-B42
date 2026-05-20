local randomizer = newrandom()
randomizer:seed(ZombRand(1, 2147483647))

local WDecay_Cracks = require('WDecay_Cracks/WDecay_Cracks')

local cachedRoadCrackOverlayPercentage = nil
local cachedDirtCrackOverlayPercentage = nil
local function getRoadCrackOverlayPercentage()
    if cachedRoadCrackOverlayPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.roadCrackOverlayPercentage')
        cachedRoadCrackOverlayPercentage = opt and opt:getValue() or 10
    end

    return cachedRoadCrackOverlayPercentage
end

local function getDirtCrackOverlayPercentage()
    if cachedDirtCrackOverlayPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.dirtCrackOverlayPercentage')
        cachedDirtCrackOverlayPercentage = opt and opt:getValue() or 10
    end

    return cachedDirtCrackOverlayPercentage
end

local DEFAULT_SPRITE_ID = 20000000

local function LoadGridsquare(square, checkResult, level)
    if not square then return end

    if not checkResult then return end

    if not checkResult.isRoad then return end

    if level ~= 0 then return end

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
                if objModData and objModData["WDecay_Crack"] == "placed" then
                elseif WDecay_Cracks.isRoadTile(spriteName) then
                    if getRoadCrackOverlayPercentage() >= randomizer:random(1, 101) then
                        local blendsType = "street"
                        if randomizer:random(1, 10) == 1 then
                            blendsType = "dirt"
                        end

                        local overlayId = tostring(randomizer:random(0, 32))
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
                                    objModData2["WDecay_Crack"] = "placed"
                                    objModData2["WDecay_Cleanable"] = "crack"
                                end

                                obj:transmitCompleteItemToClients()
                            end
                        end
                    end
                elseif WDecay_Cracks.isNaturalTile(spriteName) then
                    if getDirtCrackOverlayPercentage() >= randomizer:random(1, 101) then
                        local overlayId = tostring(randomizer:random(0, 32))
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
                                    objModData2["WDecay_Crack"] = "placed"
                                    objModData2["WDecay_Cleanable"] = "crack"
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

if not WDecay_ModifierGenerators then WDecay_ModifierGenerators = {} end

table.insert(WDecay_ModifierGenerators, LoadGridsquare)

return WDecay_Cracks
