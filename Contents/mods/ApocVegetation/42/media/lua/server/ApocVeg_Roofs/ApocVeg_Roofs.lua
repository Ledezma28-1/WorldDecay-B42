local ApocVeg_Roofs = {}

ApocVeg_Roofs.roofTop = {
    "roofs_01_22",
    "roofs_01_23",
    "roofs_02_22",
    "roofs_02_23",
    "roofs_03_22",
    "roofs_04_22",
    "roofs_01_90",
    "roofs_01_91",
    "roofs_01_92",
    "roofs_01_93",
    "roofs_02_90",
    "roofs_02_91",
    "roofs_02_92",
    "roofs_02_93",
    "roofs_05_22",
    "roofs_05_23",
    "roofs_06_22",
    "roofs_06_23",
    "roofs_04_55",
    "floors_exterior_street_01_16",
    "floors_exterior_street_01_17",
    "floors_exterior_street_01_0",
    "floors_exterior_street_01_14",
    "floors_exterior_tilesandstone_01_4",
    "floors_interior_tilesandwood_01_16"
}

ApocVeg_Roofs.roofDestroy = {
    "roofs_burnt_01_22",
    "roofs_03_22",
    "roofs_03_23",
    "roofs_04_22",
    "roofs_04_23",
    "carpentry_02_58"
}

local roofTopSet = {}
for _, v in ipairs(ApocVeg_Roofs.roofTop) do roofTopSet[v] = true end

function ApocVeg_Roofs.isTileInArray(tileName, tileArray)
    if not tileName or not tileArray then return false end
    for i = 1, #tileArray do
        if tileArray[i] == tileName then
            return true
        end
    end
    return false
end

function ApocVeg_Roofs.isRoofTop(tileName)
    return roofTopSet[tileName] == true
end

function ApocVeg_Roofs.isFlatRoofCap(sprite)
    if not sprite then return false end
    local props = sprite:getProperties()
    if not props then return false end
    local group = props:get("RoofGroup")
    if not group then return false end
    return group == "1" or group == "3" or group == "5" or group == "7" or group == "9"
end

function ApocVeg_Roofs.isRoofDestroy(tileName)
    return ApocVeg_Roofs.isTileInArray(tileName, ApocVeg_Roofs.roofDestroy)
end

function ApocVeg_Roofs.getRandomRoofDestroy()
    if #ApocVeg_Roofs.roofDestroy == 0 then
        return nil
    end
    return ApocVeg_Roofs.roofDestroy[ZombRand(1, #ApocVeg_Roofs.roofDestroy + 1)]
end

function ApocVeg_Roofs.isRoofSprite(spriteName)
    if not spriteName then return false end
    return luautils.stringStarts(spriteName, "roofs_") or
           luautils.stringStarts(spriteName, "floors_exterior_street_") or
           luautils.stringStarts(spriteName, "floors_exterior_tilesandstone_") or
           luautils.stringStarts(spriteName, "floors_interior_tilesandwood_")
end

return ApocVeg_Roofs
