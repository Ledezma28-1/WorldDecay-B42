local ApocVeg_Trees = require('ApocVeg_Trees/ApocVeg_Trees')

local cachedTreePercentage = nil
local cachedTreePercentageOnRoad = nil
local function getTreePercentage()
    if cachedTreePercentage == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.treePercentage')
        cachedTreePercentage = opt and opt:getValue() or 17
    end
    return cachedTreePercentage
end
local function getTreePercentageOnRoad()
    if cachedTreePercentageOnRoad == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.treePercentageOnRoad')
        cachedTreePercentageOnRoad = opt and opt:getValue() or 0
    end
    return cachedTreePercentageOnRoad
end

local function hasNaturalFloor(square, objects)
    if not square then return false end
    if not objects then return false end
    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        if obj and obj:getSprite() then
            local spriteName = obj:getSprite():getName()
            if spriteName and luautils.stringStarts(spriteName, "blends_natural") then
                return true
            end
        end
    end
    return false
end

local function LoadGridsquare(square, checkResult)
    if not square then return end
    if not checkResult or not checkResult.passed then return end
    if not checkResult.isSolidFloor then return end
    
    if square:getZ() ~= 0 then return end
    
    local isRoad = checkResult.isRoad
    
    if not isRoad and not hasNaturalFloor(square, checkResult.objects) then return end
    
    local percentage = isRoad and getTreePercentageOnRoad() or getTreePercentage()
    
    if percentage >= ZombRand(1, 101) then
        local randomTreeSprite = ApocVeg_Trees.getRandomTreeSprite()
        
        if randomTreeSprite then
            local newTree = IsoTree.new(square, getSprite(randomTreeSprite))
            
            if newTree then
                square:AddSpecialObject(newTree)

                local attachedSprites = ArrayList.new()
                newTree:setAttachedAnimSprite(attachedSprites)

                local treeSprite = newTree:getSprite()
                if treeSprite then
                    local treeSpriteName = treeSprite:getName()

                    local foliageIndex = ApocVeg_Trees.getRandomFoliageIndex()

                    if foliageIndex then
                        local foliageSpriteName = ApocVeg_Trees.getFoliageSpriteName(treeSpriteName, foliageIndex)

                        if foliageSpriteName then
                            local foliageSprite = getSprite(foliageSpriteName)

                            if foliageSprite then
                                attachedSprites:add(foliageSprite:newInstance())
                            end
                        end
                    end
                end

                local treeModData = newTree:getModData()
                if treeModData then
                    treeModData["ApocVeg_Tree"] = true
                    treeModData["ApocVeg_Cleanable"] = "tree"
                end

                newTree:transmitCompleteItemToClients()
                local sqModData = square:getModData()
                if sqModData then
                    sqModData["ApocVeg_HasTree"] = true
                end
                return true
            end
        end
    end
    return false
end

if not ApocVeg_PlacementGenerators then ApocVeg_PlacementGenerators = {} end
table.insert(ApocVeg_PlacementGenerators, LoadGridsquare)

return ApocVeg_Trees
