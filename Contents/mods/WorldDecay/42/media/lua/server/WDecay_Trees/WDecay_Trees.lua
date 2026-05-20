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

WDecay_Trees.foliageIndices = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}

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

local DEFAULT_SPRITE_ID = 20000000

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

function WDecay_Trees.isTreeSprite(spriteName)
    if not spriteName then return false end
    return luautils.stringStarts(spriteName, "e_") and 
           (luautils.stringStarts(spriteName, "e_dogwood_") or
            luautils.stringStarts(spriteName, "e_riverbirch_") or
            luautils.stringStarts(spriteName, "e_easternredbud_") or
            luautils.stringStarts(spriteName, "e_redmaple_") or
            luautils.stringStarts(spriteName, "e_americanlinden_") or
            luautils.stringStarts(spriteName, "e_yellowwood_") or
            luautils.stringStarts(spriteName, "e_cockspurhawthorn_") or
            luautils.stringStarts(spriteName, "e_carolinasilverbell_") or
            luautils.stringStarts(spriteName, "e_americanholly_") or
            luautils.stringStarts(spriteName, "e_canadianhemlock_") or
            luautils.stringStarts(spriteName, "e_virginiapine_"))
end

return WDecay_Trees
