local ApocVeg_Cracks = {}

ApocVeg_Cracks.roadTiles = {
    'blends_street_01_0',
    'blends_street_01_5',
    'blends_street_01_16',
    'blends_street_01_21',
    'blends_street_01_32',
    'blends_street_01_37',
    'blends_street_01_38',
    'blends_street_01_39',
    'blends_street_01_48',
    'blends_street_01_53',
    'blends_street_01_54',
    'blends_street_01_55',
    'blends_street_01_64',
    'blends_street_01_69',
    'blends_street_01_70',
    'blends_street_01_71',
    'blends_street_01_80',
    'blends_street_01_85',
    'blends_street_01_86',
    'blends_street_01_87',
    'blends_street_01_96',
    'blends_street_01_101',
    'blends_street_01_102',
    'blends_street_01_103',
    'floors_exterior_tilesandstone_01_3',
    'floors_exterior_tilesandstone_01_4',
    'floors_exterior_tilesandstone_01_5',
    'floors_exterior_tilesandstone_01_6',
}

ApocVeg_Cracks.naturalTiles = {
    'blends_natural_01_16',
    'blends_natural_01_21',
    'blends_natural_01_22',
    'blends_natural_01_23',
    'blends_natural_01_32',
    'blends_natural_01_37',
    'blends_natural_01_38',
    'blends_natural_01_39',
    'blends_natural_01_48',
    'blends_natural_01_49',
    'blends_natural_01_53',
    'blends_natural_01_54',
    'blends_natural_01_55',
}

ApocVeg_Cracks.roadCrackOverlays = {
    "blends_streetoverlays_01_0",
    "blends_streetoverlays_01_1",
    "blends_streetoverlays_01_2",
    "blends_streetoverlays_01_3",
    "blends_streetoverlays_01_4",
    "blends_streetoverlays_01_5",
    "blends_streetoverlays_01_6",
    "blends_streetoverlays_01_7",
    "blends_streetoverlays_01_8",
    "blends_streetoverlays_01_9",
    "blends_streetoverlays_01_10",
    "blends_streetoverlays_01_11",
    "blends_streetoverlays_01_12",
    "blends_streetoverlays_01_13",
    "blends_streetoverlays_01_14",
    "blends_streetoverlays_01_15",
    "blends_streetoverlays_01_16",
    "blends_streetoverlays_01_17",
    "blends_streetoverlays_01_18",
    "blends_streetoverlays_01_19",
    "blends_streetoverlays_01_20",
    "blends_streetoverlays_01_21",
    "blends_streetoverlays_01_22",
    "blends_streetoverlays_01_23",
    "blends_streetoverlays_01_24",
    "blends_streetoverlays_01_25",
    "blends_streetoverlays_01_26",
    "blends_streetoverlays_01_27",
    "blends_streetoverlays_01_28",
    "blends_streetoverlays_01_29",
    "blends_streetoverlays_01_30",
    "blends_streetoverlays_01_31"
}

ApocVeg_Cracks.dirtCrackOverlays = {
    "blends_dirtoverlays_01_0",
    "blends_dirtoverlays_01_1",
    "blends_dirtoverlays_01_2",
    "blends_dirtoverlays_01_3",
    "blends_dirtoverlays_01_4",
    "blends_dirtoverlays_01_5",
    "blends_dirtoverlays_01_6",
    "blends_dirtoverlays_01_7",
    "blends_dirtoverlays_01_8",
    "blends_dirtoverlays_01_9",
    "blends_dirtoverlays_01_10",
    "blends_dirtoverlays_01_11",
    "blends_dirtoverlays_01_12",
    "blends_dirtoverlays_01_13",
    "blends_dirtoverlays_01_14",
    "blends_dirtoverlays_01_15",
    "blends_dirtoverlays_01_16",
    "blends_dirtoverlays_01_17",
    "blends_dirtoverlays_01_18",
    "blends_dirtoverlays_01_19",
    "blends_dirtoverlays_01_20",
    "blends_dirtoverlays_01_21",
    "blends_dirtoverlays_01_22",
    "blends_dirtoverlays_01_23",
    "blends_dirtoverlays_01_24",
    "blends_dirtoverlays_01_25",
    "blends_dirtoverlays_01_26",
    "blends_dirtoverlays_01_27",
    "blends_dirtoverlays_01_28",
    "blends_dirtoverlays_01_29",
    "blends_dirtoverlays_01_30",
    "blends_dirtoverlays_01_31"
}

local roadTilesSet = {}
for _, v in ipairs(ApocVeg_Cracks.roadTiles) do roadTilesSet[v] = true end
local naturalTilesSet = {}
for _, v in ipairs(ApocVeg_Cracks.naturalTiles) do naturalTilesSet[v] = true end

function ApocVeg_Cracks.isTileInArray(tileName, tileArray)
    if not tileName or not tileArray then return false end
    for i = 1, #tileArray do
        if tileArray[i] == tileName then
            return true
        end
    end
    return false
end

function ApocVeg_Cracks.getRandomRoadCrackOverlay()
    if #ApocVeg_Cracks.roadCrackOverlays == 0 then
        return nil
    end
    return ApocVeg_Cracks.roadCrackOverlays[ZombRand(1, #ApocVeg_Cracks.roadCrackOverlays + 1)]
end

function ApocVeg_Cracks.getRandomDirtCrackOverlay()
    if #ApocVeg_Cracks.dirtCrackOverlays == 0 then
        return nil
    end
    return ApocVeg_Cracks.dirtCrackOverlays[ZombRand(1, #ApocVeg_Cracks.dirtCrackOverlays + 1)]
end

function ApocVeg_Cracks.isCrackOverlay(spriteName)
    if not spriteName then return false end
    return luautils.stringStarts(spriteName, "blends_streetoverlays_01_") or
           luautils.stringStarts(spriteName, "blends_dirtoverlays_01_")
end

function ApocVeg_Cracks.isRoadTile(tileName)
    return roadTilesSet[tileName] == true
end

function ApocVeg_Cracks.isNaturalTile(tileName)
    return naturalTilesSet[tileName] == true
end

return ApocVeg_Cracks
