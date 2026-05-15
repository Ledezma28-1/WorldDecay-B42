local ApocVeg_Walls = {}

ApocVeg_Walls.wallProperties = {
    "WallNW",
    "WallW",
    "WallN"
}

ApocVeg_Walls.burnedTextures = {
    WallNW = {
        "walls_exterior_wooden_01_70",
        "walls_burnt_01_2"
    },
    WallN = {
        "walls_exterior_wooden_01_69",
        "walls_burnt_01_1"
    },
    WallW = {
        "walls_exterior_wooden_01_68",
        "walls_burnt_01_0"
    }
}

function ApocVeg_Walls.hasWallProperty(sprite, propertyName)
    if not sprite or not sprite:getProperties() then return false end
    
    local properties = sprite:getProperties():getPropertyNames()
    if not properties then return false end
    
    local propertyStr = tostring(properties)
    return propertyStr:contains(propertyName)
end

function ApocVeg_Walls.getBurnedTextures(wallType)
    return ApocVeg_Walls.burnedTextures[wallType] or nil
end

function ApocVeg_Walls.getRandomBurnedTexture(wallType)
    local textures = ApocVeg_Walls.getBurnedTextures(wallType)
    if not textures or #textures == 0 then
        return nil
    end
    return textures[ZombRand(1, #textures + 1)]
end

function ApocVeg_Walls.isBurnedWall(spriteName)
    if not spriteName then return false end
    return luautils.stringStarts(spriteName, "walls_burnt_") or
           (luautils.stringStarts(spriteName, "walls_exterior_wooden_01_") and
            (spriteName == "walls_exterior_wooden_01_68" or
             spriteName == "walls_exterior_wooden_01_69" or
             spriteName == "walls_exterior_wooden_01_70" or
             spriteName == "walls_exterior_wooden_01_75" or
             spriteName == "walls_exterior_wooden_01_76" or
             spriteName == "walls_exterior_wooden_01_77" or
             spriteName == "walls_exterior_wooden_01_78"))
end

function ApocVeg_Walls.isExteriorWall(textureName)
    if not textureName then return false end
    return luautils.stringStarts(textureName, "walls_exterior_") and
           not luautils.stringStarts(textureName, "walls_exterior_roofs_")
end

function ApocVeg_Walls.isInteriorWall(textureName)
    if not textureName then return false end
    return luautils.stringStarts(textureName, "walls_interior_")
end

return ApocVeg_Walls
