local ApocVeg_Destroyed_Doors_Windows = {}

ApocVeg_Destroyed_Doors_Windows.destroyTypes = {
    "DoorWallW",
    "DoorWallN",
    "WindowN",
    "WindowW"
}

function ApocVeg_Destroyed_Doors_Windows.isDoor(object)
    if not object then return false end
    return object:getClass() == IsoDoor.class
end

function ApocVeg_Destroyed_Doors_Windows.isWindow(object)
    if not object then return false end
    local sprite = object:getSprite()
    if not sprite then return false end
    local properties = sprite:getProperties()
    if not properties then return false end
    local propertyNames = properties:getPropertyNames()
    if not propertyNames then return false end
    local propertyStr = tostring(propertyNames)
    return propertyStr:contains("WindowN") or propertyStr:contains("WindowW")
end

function ApocVeg_Destroyed_Doors_Windows.isDestroyed(object)
    if not object then return false end
    
    if object.isDestroyed then
        local success, result = pcall(function()
            return object:isDestroyed()
        end)
        if success then
            return result
        end
    end
    
    if object.getSprite then
        local sprite = object:getSprite()
        if sprite then
            local spriteName = sprite:getName()
            if spriteName and spriteName:contains("smashed") then
                return true
            end
        end
    end
    
    return false
end

function ApocVeg_Destroyed_Doors_Windows.destroyDoor(door)
    if not door then return false end
    if door:getClass() ~= IsoDoor.class then return false end
    
    if door:isDestroyed() then
        return false
    end
    
    local success = pcall(function()
        door:destroy()
    end)
    
    return success
end

function ApocVeg_Destroyed_Doors_Windows.destroyWindow(window)
    if not window then return false end
    
    if not window.smashWindow then
        if window.getWindow then
            window = window:getWindow()
            if not window then return false end
        else
            return false
        end
    end
    
    if not window.smashWindow then return false end
    
    local sprite = window:getSprite()
    if sprite then
        local spriteName = sprite:getName()
        if spriteName and spriteName:contains("smashed") then
            return false
        end
    end
    
    if not instanceof(window, "IsoWindow") then return false end
    
    local success = pcall(function()
        window:smashWindow()
    end)
    
    return success
end

return ApocVeg_Destroyed_Doors_Windows
