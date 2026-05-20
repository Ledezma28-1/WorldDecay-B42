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

local function LoadGridsquare(square, checkResult)
    if not square then return end
    if not checkResult or not checkResult.passed then return end
    if not checkResult.objects then return end
    
    if square:getZ() ~= 0 then return end
    
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
        local currentFloorTile = square:getFloor() and square:getFloor():getSprite():getName()
        
        if currentFloorTile ~= nil then
            local randomTrash = WDecay_Trash.getRandomTrash()
            
            if randomTrash then
                local newSprite = IsoObject.new(getCell(), square, randomTrash)
                if newSprite then
                    square:AddSpecialObject(newSprite)
                    square:RecalcProperties()
                    
                    WDecay_CustomNames_Integration.applyCustomNameToObject(newSprite)
                    
                    local objModData = newSprite:getModData()
                    if objModData then
                        objModData["WDecay_Cleanable"] = "trash"
                    end
                    
                    newSprite:transmitCompleteItemToClients()
                    return true
                end
            end
        end
    end
    return false
end

if not WDecay_PlacementGenerators then WDecay_PlacementGenerators = {} end
table.insert(WDecay_PlacementGenerators, LoadGridsquare)

return WDecay_Trash
