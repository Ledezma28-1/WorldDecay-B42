local ApocVeg_Vines = {}

ApocVeg_Vines.wallW = {
    "f_wallvines_1_43",
    "f_wallvines_1_42",
    "f_wallvines_1_37",
    "f_wallvines_1_36",
    "f_wallvines_1_31",
    "f_wallvines_1_30",
    "f_wallvines_1_25",
    "f_wallvines_1_24"
}

ApocVeg_Vines.wallW_top = {
    "f_wallvines_1_37",
    "f_wallvines_1_36",
    "f_wallvines_1_31",
    "f_wallvines_1_30",
    "f_wallvines_1_25",
    "f_wallvines_1_24"
}

ApocVeg_Vines.wallW_low = {
    "f_wallvines_1_25",
    "f_wallvines_1_24"
}

ApocVeg_Vines.wallN = {
    "f_wallvines_1_45",
    "f_wallvines_1_44",
    "f_wallvines_1_39",
    "f_wallvines_1_38",
    "f_wallvines_1_33",
    "f_wallvines_1_32",
    "f_wallvines_1_27",
    "f_wallvines_1_26"
}

ApocVeg_Vines.wallN_top = {
    "f_wallvines_1_39",
    "f_wallvines_1_38",
    "f_wallvines_1_33",
    "f_wallvines_1_32",
    "f_wallvines_1_27",
    "f_wallvines_1_26"
}

ApocVeg_Vines.wallN_low = {
    "f_wallvines_1_27",
    "f_wallvines_1_26"
}

ApocVeg_Vines.wallNW = {
    "f_wallvines_1_47",
    "f_wallvines_1_46",
    "f_wallvines_1_41",
    "f_wallvines_1_40",
    "f_wallvines_1_34",
    "f_wallvines_1_35",
    "f_wallvines_1_29",
    "f_wallvines_1_28"
}

ApocVeg_Vines.wallNW_top = {
    "f_wallvines_1_41",
    "f_wallvines_1_40",
    "f_wallvines_1_34",
    "f_wallvines_1_35",
    "f_wallvines_1_29",
    "f_wallvines_1_28"
}

ApocVeg_Vines.wallNW_low = {
    "f_wallvines_1_29",
    "f_wallvines_1_28"
}

ApocVeg_Vines.wallProperties = {
    "WallNW",
    "WallW",
    "WallN",
    "WindowN",
    "WindowW",
    "DoorWallW",
    "DoorWallN"
}

function ApocVeg_Vines.getRandomWallW()
    if #ApocVeg_Vines.wallW == 0 then
        return nil
    end
    return ApocVeg_Vines.wallW[ZombRand(1, #ApocVeg_Vines.wallW + 1)]
end

function ApocVeg_Vines.getRandomWallWTop()
    if #ApocVeg_Vines.wallW_top == 0 then
        return nil
    end
    return ApocVeg_Vines.wallW_top[ZombRand(1, #ApocVeg_Vines.wallW_top + 1)]
end

function ApocVeg_Vines.getRandomWallWLow()
    if #ApocVeg_Vines.wallW_low == 0 then
        return nil
    end
    return ApocVeg_Vines.wallW_low[ZombRand(1, #ApocVeg_Vines.wallW_low + 1)]
end

function ApocVeg_Vines.getRandomWallN()
    if #ApocVeg_Vines.wallN == 0 then
        return nil
    end
    return ApocVeg_Vines.wallN[ZombRand(1, #ApocVeg_Vines.wallN + 1)]
end

function ApocVeg_Vines.getRandomWallNTop()
    if #ApocVeg_Vines.wallN_top == 0 then
        return nil
    end
    return ApocVeg_Vines.wallN_top[ZombRand(1, #ApocVeg_Vines.wallN_top + 1)]
end

function ApocVeg_Vines.getRandomWallNLow()
    if #ApocVeg_Vines.wallN_low == 0 then
        return nil
    end
    return ApocVeg_Vines.wallN_low[ZombRand(1, #ApocVeg_Vines.wallN_low + 1)]
end

function ApocVeg_Vines.getRandomWallNW()
    if #ApocVeg_Vines.wallNW == 0 then
        return nil
    end
    return ApocVeg_Vines.wallNW[ZombRand(1, #ApocVeg_Vines.wallNW + 1)]
end

function ApocVeg_Vines.getRandomWallNWTop()
    if #ApocVeg_Vines.wallNW_top == 0 then
        return nil
    end
    return ApocVeg_Vines.wallNW_top[ZombRand(1, #ApocVeg_Vines.wallNW_top + 1)]
end

function ApocVeg_Vines.getRandomWallNWLow()
    if #ApocVeg_Vines.wallNW_low == 0 then
        return nil
    end
    return ApocVeg_Vines.wallNW_low[ZombRand(1, #ApocVeg_Vines.wallNW_low + 1)]
end

function ApocVeg_Vines.isVine(spriteName)
    if not spriteName then return false end
    return luautils.stringStarts(spriteName, "f_wallvines_")
end

function ApocVeg_Vines.isTallVine(spriteName)
    if not spriteName then return false end
    return spriteName == "f_wallvines_1_47" or spriteName == "f_wallvines_1_46" or
           spriteName == "f_wallvines_1_43" or spriteName == "f_wallvines_1_42" or
           spriteName == "f_wallvines_1_44" or spriteName == "f_wallvines_1_45"
end

return ApocVeg_Vines
