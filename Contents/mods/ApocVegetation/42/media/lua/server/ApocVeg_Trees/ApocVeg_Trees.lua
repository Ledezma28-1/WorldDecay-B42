local ApocVeg_Trees = {}

ApocVeg_Trees.treeSprites = {
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

ApocVeg_Trees.foliageIndices = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}

ApocVeg_Trees._foliageLookup = {}
for _, treeSprite in ipairs(ApocVeg_Trees.treeSprites) do
    ApocVeg_Trees._foliageLookup[treeSprite] = {}
    for _, idx in ipairs(ApocVeg_Trees.foliageIndices) do
        if idx ~= 4 and idx ~= 5 and idx ~= 6 and idx ~= 7 then
            local foliageName = treeSprite:gsub("_(%d+)$", "_" .. tostring(idx))
            local sprite = getSprite(foliageName)
            if sprite and sprite:getID() ~= 20000000 then
                ApocVeg_Trees._foliageLookup[treeSprite][idx] = foliageName
            end
        end
    end
end

function ApocVeg_Trees.getRandomTreeSprite()
    if #ApocVeg_Trees.treeSprites == 0 then
        return nil
    end
    return ApocVeg_Trees.treeSprites[ZombRand(1, #ApocVeg_Trees.treeSprites + 1)]
end

function ApocVeg_Trees.getRandomFoliageIndex()
    if #ApocVeg_Trees.foliageIndices == 0 then
        return nil
    end
    return ApocVeg_Trees.foliageIndices[ZombRand(1, #ApocVeg_Trees.foliageIndices + 1)]
end

local DEFAULT_SPRITE_ID = 20000000

function ApocVeg_Trees.getFoliageSpriteName(treeSpriteName, foliageIndex)
    if not treeSpriteName or not foliageIndex then
        return nil
    end
    if foliageIndex == 4 or foliageIndex == 5 or foliageIndex == 6 or foliageIndex == 7 then
        return nil
    end
    local lookup = ApocVeg_Trees._foliageLookup[treeSpriteName]
    if lookup then
        return lookup[foliageIndex]
    end
    return nil
end

function ApocVeg_Trees.isTreeSprite(spriteName)
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

return ApocVeg_Trees
