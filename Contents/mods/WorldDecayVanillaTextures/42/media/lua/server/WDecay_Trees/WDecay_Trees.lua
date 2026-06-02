local WDecay_Object_Buffer = require("WDecay_Object_Buffer")
local WDecay_Object_Buffer_Types = require("WDecay_Object_Buffer_Types")

local randomizer = newrandom()
randomizer:seed(ZombRand(1, 2147483647))

local WDecay_Trees = {}

WDecay_Trees.treeSprites = {
    "e_dogwood_1_0",
    "e_dogwood_1_1",
    "e_riverbirch_1_0",
    "e_riverbirch_1_1",
    "e_easternredbud_1_0",
    "e_easternredbud_1_1",
    "e_redmaple_1_0",
    "e_redmaple_1_1",
    "e_americanlinden_1_0",
    "e_americanlinden_1_1",
    "e_yellowwood_1_0",
    "e_yellowwood_1_1",
    "e_cockspurhawthorn_1_0",
    "e_cockspurhawthorn_1_1",
    "e_carolinasilverbell_1_0",
    "e_carolinasilverbell_1_1",
    "e_americanholly_1_0",
    "e_americanholly_1_1",
    "e_canadianhemlock_1_0",
    "e_canadianhemlock_1_1",
    "e_virginiapine_1_0",
    "e_virginiapine_1_1",
    "e_dogwoodJUMBO_1_0",
    "e_dogwoodJUMBO_1_1",
    "e_riverbirchJUMBO_1_0",
    "e_riverbirchJUMBO_1_1",
    "e_easternredbudJUMBO_1_0",
    "e_easternredbudJUMBO_1_1",
    "e_redmapleJUMBO_1_0",
    "e_redmapleJUMBO_1_1",
    "e_americanlindenJUMBO_1_0",
    "e_americanlindenJUMBO_1_1",
    "e_yellowwoodJUMBO_1_0",
    "e_yellowwoodJUMBO_1_1",
    "e_cockspurhawthornJUMBO_1_0",
    "e_cockspurhawthornJUMBO_1_1",
    "e_carolinasilverbellJUMBO_1_0",
    "e_carolinasilverbellJUMBO_1_1",
    "e_americanhollyJUMBO_1_0",
    "e_americanhollyJUMBO_1_1",
    "e_canadianhemlockJUMBO_1_0",
    "e_canadianhemlockJUMBO_1_1",
    "e_virginiapineJUMBO_1_0",
    "e_virginiapineJUMBO_1_1"
}

WDecay_Object_Buffer.registerWithModDataPairList(WDecay_Trees.treeSprites,
    { ["WDecay_Tree"] = true, ["WDecay_Cleanable"] = "tree" },
    WDecay_Object_Buffer_Types.IsoTreeType)

WDecay_Trees.foliageIndices = { 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 }

WDecay_Trees._foliageLookup = {}
for _, treeSprite in ipairs(WDecay_Trees.treeSprites) do
    WDecay_Trees._foliageLookup[treeSprite] = {}
    for _, idx in ipairs(WDecay_Trees.foliageIndices) do
        if idx ~= 4 and idx ~= 5 and idx ~= 6 and idx ~= 7 then
            local foliageName = treeSprite:gsub("_(%d+)$", "_" .. tostring(idx))
            local sprite = getSprite(foliageName)
            if sprite and sprite:getID() ~= 20000000 then
                WDecay_Trees._foliageLookup[treeSprite][idx] = foliageName
            end
        end
    end
end

function WDecay_Trees.getRandomTreeSprite()
    if #WDecay_Trees.treeSprites == 0 then
        return nil
    end

    return WDecay_Trees.treeSprites[randomizer:random(1, #WDecay_Trees.treeSprites + 1)]
end

function WDecay_Trees.getRandomFoliageIndex()
    if #WDecay_Trees.foliageIndices == 0 then
        return nil
    end

    return WDecay_Trees.foliageIndices[randomizer:random(1, #WDecay_Trees.foliageIndices + 1)]
end

function WDecay_Trees.getFoliageSpriteName(treeSpriteName, foliageIndex)
    if not treeSpriteName or not foliageIndex then
        return nil
    end

    if foliageIndex == 4 or foliageIndex == 5 or foliageIndex == 6 or foliageIndex == 7 then
        return nil
    end

    local lookup = WDecay_Trees._foliageLookup[treeSpriteName]
    if lookup then
        return lookup[foliageIndex]
    end

    return nil
end

local function applyFoliageVariant(spriteName, object, modData)
    local attachedSprites = ArrayList.new()
    object:setAttachedAnimSprite(attachedSprites)

    local foliageIndex = WDecay_Trees.getRandomFoliageIndex()

    if foliageIndex then
        local foliageSpriteName = WDecay_Trees.getFoliageSpriteName(spriteName, foliageIndex)

        if foliageSpriteName then
            local foliageSprite = getSprite(foliageSpriteName)

            if foliageSprite then
                attachedSprites:add(foliageSprite:newInstance())
            end
        end
    end
end

WDecay_Object_Buffer.registerConfigurator(WDecay_Trees.treeSprites, applyFoliageVariant)

return WDecay_Trees
