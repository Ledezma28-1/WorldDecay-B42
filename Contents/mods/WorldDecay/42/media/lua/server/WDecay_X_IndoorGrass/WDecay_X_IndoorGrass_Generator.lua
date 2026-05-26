local randomizer = newrandom()

local WDecay_Object_Buffer = require("WDecay_Object_Buffer")
local WDecay_Grass = require('WDecay_Grass/WDecay_Grass')

local cachedIndoorGrassPct = nil
local function getIndoorGrassPct()
    if cachedIndoorGrassPct == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.indoorGrassPercentage')
        cachedIndoorGrassPct = opt and opt:getValue() or 0
    end
    return cachedIndoorGrassPct
end

local function LoadGridsquare(square, checkResult, level)
    if not square then return end
    if not checkResult then return end

    local isIndoor = checkResult.room ~= nil
    if not isIndoor then return end

    if checkResult.water then return end

    local floor = square:getFloor()
    if not floor then return end

    local sqModData = floor:getModData()
    if sqModData and sqModData["WDecay_FloorOverlay"] then return end
    if sqModData then sqModData["WDecay_FloorOverlay"] = true end

    local grassPct = getIndoorGrassPct()
    if grassPct > 0 and grassPct >= randomizer:random(1, 101) then
        local sprite = WDecay_Grass.getRandomVanillaGrass()
        if sprite then
            local obj = WDecay_Object_Buffer.getObject(sprite)
            if obj then
                obj:setSquare(square)
                square:AddSpecialObject(obj)
                obj:transmitCompleteItemToClients()
            end
        end
    end
end

if not WDecay_ModifierGenerators then WDecay_ModifierGenerators = {} end
table.insert(WDecay_ModifierGenerators, LoadGridsquare)
