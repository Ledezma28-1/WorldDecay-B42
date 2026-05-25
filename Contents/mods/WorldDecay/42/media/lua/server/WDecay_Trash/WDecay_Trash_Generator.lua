local WDecay_Object_Buffer = require("WDecay_Object_Buffer")

local randomizer = newrandom()
randomizer:seed(ZombRand(1, 2147483647))

local WDecay_Trash = require('WDecay_Trash/WDecay_Trash')
local WDecay_CustomNames_Integration = require('WDecay_CustomNames/WDecay_CustomNames_Integration')

local cachedTrashPercentage = nil
local cachedTrashPercentageOnRoad = nil
local function getTrashPercentage()
    if cachedTrashPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.trashPercentage')
        cachedTrashPercentage = opt and opt:getValue() or 8
    end

    return cachedTrashPercentage
end

local function getTrashPercentageOnRoad()
    if cachedTrashPercentageOnRoad == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.trashPercentageOnRoad')
        cachedTrashPercentageOnRoad = opt and opt:getValue() or 8
    end

    return cachedTrashPercentageOnRoad
end

local function LoadGridsquare(square, checkResult, level)
    if not square then return end

    if not checkResult or not checkResult.passed then return end

    if not checkResult.objects then return end

    if level ~= 0 then return end

    local isRoad = checkResult.isRoad
    local isUrban = checkResult.isUrban
    if isUrban == nil then isUrban = true end

    local percentage
    if isRoad then
        percentage = getTrashPercentageOnRoad()
    elseif isUrban then
        percentage = getTrashPercentage()
    else
        percentage = getTrashPercentage() * 0.1
    end

    if percentage >= randomizer:random(1, 101) then
        local randomTrash = WDecay_Trash.getRandomTrash()

        if randomTrash then
            local newSprite = WDecay_Object_Buffer.getObject(randomTrash)
            newSprite:setSquare(square)
            square:AddSpecialObject(newSprite)
            square:RecalcPropertiesIfNeeded()
            newSprite:transmitCompleteItemToClients()
            return true
            
        end
    end

    return false
end

if not WDecay_PlacementGenerators then WDecay_PlacementGenerators = {} end

table.insert(WDecay_PlacementGenerators, LoadGridsquare)

return WDecay_Trash
