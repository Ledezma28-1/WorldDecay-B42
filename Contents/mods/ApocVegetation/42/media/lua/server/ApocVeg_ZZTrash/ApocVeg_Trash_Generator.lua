local ApocVeg_Trash = require('ApocVeg_ZZTrash/ApocVeg_Trash')
local ApocVeg_CustomNames_Integration = require('ApocVeg_CustomNames/ApocVeg_CustomNames_Integration')

local cachedTrashPercentage = nil
local cachedTrashPercentageOnRoad = nil
local function getTrashPercentage()
    if cachedTrashPercentage == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.trashPercentage')
        cachedTrashPercentage = opt and opt:getValue() or 8
    end
    return cachedTrashPercentage
end
local function getTrashPercentageOnRoad()
    if cachedTrashPercentageOnRoad == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.trashPercentageOnRoad')
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
    
    if percentage >= ZombRand(1, 101) then
        local currentFloorTile = square:getFloor() and square:getFloor():getSprite():getName()
        
        if currentFloorTile ~= nil then
            local randomTrash = ApocVeg_Trash.getRandomTrash()
            
            if randomTrash then
                local newSprite = IsoObject.new(getCell(), square, randomTrash)
                if newSprite then
                    square:AddSpecialObject(newSprite)
                    square:RecalcProperties()
                    
                    ApocVeg_CustomNames_Integration.applyCustomNameToObject(newSprite)
                    
                    local objModData = newSprite:getModData()
                    if objModData then
                        objModData["ApocVeg_Cleanable"] = "trash"
                    end
                    
                    newSprite:transmitCompleteItemToClients()
                    return true
                end
            end
        end
    end
    return false
end

if not ApocVeg_PlacementGenerators then ApocVeg_PlacementGenerators = {} end
table.insert(ApocVeg_PlacementGenerators, LoadGridsquare)

return ApocVeg_Trash
