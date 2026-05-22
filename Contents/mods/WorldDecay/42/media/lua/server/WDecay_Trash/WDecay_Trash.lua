local WDecay_Object_Buffer = require("WDecay_Object_Buffer")

local randomizer = newrandom()
randomizer:seed(ZombRand(1, 2147483647))

local WDecay_Trash = {}

WDecay_Trash.trashSprites = {
    "trash_01_0",
    "trash_01_1",
    "trash_01_2",
    "trash_01_3",
    "trash_01_4",
    "trash_01_5",
    "trash_01_6",
    "trash_01_7",
    "trash_01_8",
    "trash_01_9",
    "trash_01_10",
    "trash_01_11",
    "trash_01_12",
    "trash_01_13",
    "trash_01_14",
    "trash_01_15",
    "trash_01_16",
    "trash_01_17",
    "trash_01_18",
    "trash_01_19",
    "trash_01_20",
    "trash_01_21",
    "trash_01_22",
    "trash_01_23",
    "trash_01_24",
    "trash_01_25",
    "trash_01_26",
    "trash_01_27",
    "trash_01_28",
    "trash_01_29",
    "trash_01_30",
    "trash_01_31",
    "trash_01_32",
    "trash_01_33",
    "trash_01_34",
    "trash_01_35",
    "trash_01_36",
    "trash_01_37",
    "trash_01_38",
    "trash_01_39",
    "trash_01_40",
    "trash_01_41",
    "trash_01_42",
    "trash_01_43",
    "trash_01_44",
    "trash_01_45",
    "trash_01_46",
    "trash_01_47",
    "trash_01_48",
    "trash_01_49",
    "trash_01_50",
    "trash_01_51"
}

WDecay_Object_Buffer.register(WDecay_Trash.trashSprites)

WDecay_Trash.customName = {
    ["trash_01_0"] = "Trash",
    ["trash_01_1"] = "Trash",
    ["trash_01_2"] = "Trash",
    ["trash_01_3"] = "Trash",
    ["trash_01_4"] = "Trash",
    ["trash_01_5"] = "Trash",
    ["trash_01_6"] = "Trash",
    ["trash_01_7"] = "Trash",
    ["trash_01_8"] = "Trash",
    ["trash_01_9"] = "Trash",
    ["trash_01_10"] = "Trash",
    ["trash_01_11"] = "Trash",
    ["trash_01_12"] = "Trash",
    ["trash_01_13"] = "Trash",
    ["trash_01_14"] = "Trash",
    ["trash_01_15"] = "Trash",
    ["trash_01_16"] = "Trash",
    ["trash_01_17"] = "Trash",
    ["trash_01_18"] = "Trash",
    ["trash_01_19"] = "Trash",
    ["trash_01_20"] = "Trash",
    ["trash_01_21"] = "Trash",
    ["trash_01_22"] = "Trash",
    ["trash_01_23"] = "Trash",
    ["trash_01_24"] = "Trash",
    ["trash_01_25"] = "Trash",
    ["trash_01_26"] = "Trash",
    ["trash_01_27"] = "Trash",
    ["trash_01_28"] = "Trash",
    ["trash_01_29"] = "Trash",
    ["trash_01_30"] = "Trash",
    ["trash_01_31"] = "Trash",
    ["trash_01_32"] = "Trash",
    ["trash_01_33"] = "Trash",
    ["trash_01_34"] = "Trash",
    ["trash_01_35"] = "Trash",
    ["trash_01_36"] = "Trash",
    ["trash_01_37"] = "Trash",
    ["trash_01_38"] = "Trash",
    ["trash_01_39"] = "Trash",
    ["trash_01_40"] = "Trash",
    ["trash_01_41"] = "Trash",
    ["trash_01_42"] = "Trash",
    ["trash_01_43"] = "Trash",
    ["trash_01_44"] = "Trash",
    ["trash_01_45"] = "Trash",
    ["trash_01_46"] = "Trash",
    ["trash_01_47"] = "Trash",
    ["trash_01_48"] = "Trash",
    ["trash_01_49"] = "Trash",
    ["trash_01_50"] = "Trash",
    ["trash_01_51"] = "Trash"
}

function WDecay_Trash.getRandomTrash()
    if #WDecay_Trash.trashSprites == 0 then
        return nil
    end

    return WDecay_Trash.trashSprites[randomizer:random(1, #WDecay_Trash.trashSprites + 1)]
end

function WDecay_Trash.getCustomName(spriteName)
    return WDecay_Trash.customName[spriteName] or nil
end

function WDecay_Trash.isTrash(spriteName)
    if not spriteName then return false end

    return luautils.stringStarts(spriteName, "trash_01_")
end

return WDecay_Trash
