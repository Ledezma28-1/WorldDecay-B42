local ApocVeg_Stories_Suppressor = {}

local cachedStoriesRarity = nil
local function getStoriesRarity()
    if cachedStoriesRarity == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.storiesRarity')
        cachedStoriesRarity = opt and opt:getValue() or 2
    end
    return cachedStoriesRarity
end

local storiesChance = {
    [1] = 0,
    [2] = 15,
    [3] = 40,
    [4] = 70,
    [5] = 100,
}

local function LoadGridsquare(square, checkResult)
    if not square then return end
    if not checkResult then return end
    if not checkResult.room then return end
    local rarity = getStoriesRarity()
    if rarity == 1 then return end
    if ZombRand(1, 101) > storiesChance[rarity] then return end
    local objects = square:getObjects()
    if not objects then return end
    for i = objects:size() - 1, 0, -1 do
        local obj = objects:get(i)
        if obj then
            local modData = obj:getModData()
            if modData and modData["story"] then
                square:transmitRemoveItemFromSquare(obj)
            end
        end
    end
end

if not ApocVeg_ModifierGenerators then ApocVeg_ModifierGenerators = {} end
table.insert(ApocVeg_ModifierGenerators, LoadGridsquare)

return ApocVeg_Stories_Suppressor
