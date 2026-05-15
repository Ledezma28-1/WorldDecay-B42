local ApocVeg_CustomNames = require('ApocVeg_CustomNames/ApocVeg_CustomNames')

local function applyCustomNameToObject(object)
    if not object then return end
    
    local spriteName = nil
    if object:getSprite() then
        spriteName = object:getSprite():getName()
    end
    
    if not spriteName then return end
    
    local customName = ApocVeg_CustomNames.getCustomName(spriteName)
    
    if customName then
        object:getModData()["ApocVeg_CustomName"] = customName
    end
end

function getApocVegCustomName(object)
    if not object then return nil end
    
    local modData = object:getModData()
    if modData and modData["ApocVeg_CustomName"] then
        return modData["ApocVeg_CustomName"]
    end
    
    return nil
end

function hasApocVegCustomName(object)
    if not object then return false end
    
    local modData = object:getModData()
    if modData and modData["ApocVeg_CustomName"] then
        return true
    end
    
    return false
end

_ApocVeg_CustomNames = {
    applyCustomNameToObject = applyCustomNameToObject,
    getCustomName = getApocVegCustomName,
    hasCustomName = hasApocVegCustomName
}

return _ApocVeg_CustomNames
