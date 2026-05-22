local WDecay_Object_Buffer = require('WDecay_Object_Buffer')

local randomizer = newrandom()
randomizer:seed(ZombRand(1, 2147483647))

local WDecay_Bushes = {}

WDecay_Bushes.bushes = {
    "f_bushes_1_65",
    "f_bushes_1_66",
    "f_bushes_1_97",
    "f_bushes_1_98",
    "f_bushes_1_77",
    "f_bushes_1_78",
    "f_bushes_1_110",
    "f_bushes_1_109",
    "f_bushes_1_99",
    "f_bushes_1_67",
    "f_bushes_1_103",
    "f_bushes_1_71",
    "f_bushes_1_69",
    "f_bushes_1_70",
    "f_bushes_1_72",
    "f_bushes_1_73",
    "f_bushes_1_75",
    "f_bushes_1_76",
    "f_bushes_1_79",
    "f_bushes_1_101",
    "f_bushes_1_102",
    "f_bushes_1_104",
    "f_bushes_1_105",
    "f_bushes_1_107",
    "f_bushes_1_108",
    "f_bushes_1_111",
    "f_bushes_1_64",
    "f_bushes_1_96",
    "f_bushes_1_100",
    "f_bushes_1_68",
    "f_bushes_1_106",
    "f_bushes_1_74"
}

WDecay_Object_Buffer.register(WDecay_Bushes.bushes)

function WDecay_Bushes.getRandomBush()
    if #WDecay_Bushes.bushes == 0 then
        return nil
    end

    return WDecay_Bushes.bushes[randomizer:random(1, #WDecay_Bushes.bushes + 1)]
end

return WDecay_Bushes
