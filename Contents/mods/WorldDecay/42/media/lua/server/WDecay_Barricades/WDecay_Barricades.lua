local randomizer = newrandom()
randomizer:seed(ZombRand(1, 2147483647))

local WDecay_Barricades = {}

WDecay_Barricades.barricadeTypes = {
    "wood",
    "metal"
}

WDecay_Barricades.healthLevels = {
    100,
    200,
    300,
    400
}

function WDecay_Barricades.getRandomBarricadeType()
    if #WDecay_Barricades.barricadeTypes == 0 then
        return nil
    end
    return WDecay_Barricades.barricadeTypes[randomizer:random(1, #WDecay_Barricades.barricadeTypes + 1)]
end

function WDecay_Barricades.getRandomHealthLevel()
    if #WDecay_Barricades.healthLevels == 0 then
        return 100
    end
    return WDecay_Barricades.healthLevels[randomizer:random(1, #WDecay_Barricades.healthLevels + 1)]
end

function WDecay_Barricades.isWindow(object)
    if not object then return false end
    local sprite = object:getSprite()
    if not sprite then return false end
    local properties = sprite:getProperties()
    if not properties then return false end
    return properties:has("WindowN") or properties:has("WindowW")
end

function WDecay_Barricades.isDoor(object)
    if not object then return false end
    local sprite = object:getSprite()
    if not sprite then return false end
    local properties = sprite:getProperties()
    if not properties then return false end
    return properties:has("DoorWallW") or properties:has("DoorWallN")
end

function WDecay_Barricades.isExteriorDoor(door)
    if not door then return false end
    
    if door.isExterior then
        return door:isExterior()
    end
    
    return false
end

function WDecay_Barricades.canBarricadeDoor(door)
    if not door then return false end
    
    if door.isBarricadeAllowed then
        return door:isBarricadeAllowed()
    end
    
    return false
end

function WDecay_Barricades.hasBarricade(object)
    if not object then return false end
    local square = object:getSquare()
    if not square then return false end

    local objects = square:getObjects()
    if not objects or objects:size() == 0 then return false end

    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        if obj and obj:getClass() == IsoBarricade.class then
            local barricadedObject = obj:getBarricadedObject()
            if barricadedObject and barricadedObject == object then
                return true
            end
        end
    end

    return false
end

function WDecay_Barricades.isWDecayBarricade(object)
    if not object then return false end
    local modData = object:getModData()
    if not modData then return false end
    return modData["WDecay_Barricade"] == true
end

return WDecay_Barricades
