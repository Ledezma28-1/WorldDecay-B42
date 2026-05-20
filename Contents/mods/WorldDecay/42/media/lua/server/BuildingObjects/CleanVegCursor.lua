if not ISBuildingObject then
    return
end

CleanVegCursor = ISBuildingObject:derive("CleanVegCursor")

local CLEAN_TIME = 75

local function singleTileClean(player, square)
    if luautils.walkAdj(player, square, true) then
        ISTimedActionQueue.add(CleanVegAction:new(player, square, CLEAN_TIME))
    end
end

local function areaClean(player, centerSquare, areaSize)
    local cell = getCell()
    local z = centerSquare:getZ()
    local cx = centerSquare:getX()
    local cy = centerSquare:getY()
    local half = math.floor(areaSize / 2)

    local squares = {}
    for dx = -half, half do
        for dy = -half, half do
            local sq = cell:getGridSquare(cx + dx, cy + dy, z)
            if sq and CleanVegCursor.hasCleanable(sq) then
                squares[#squares + 1] = sq
            end
        end
    end

    if #squares == 0 then return end

    local idx = 0
    local function nextTile()
        idx = idx + 1
        if idx > #squares then return end

        local sq = squares[idx]
        local walk = ISWalkToTimedAction:new(player, sq)
        walk:setOnComplete(function()
            ISTimedActionQueue.add(CleanVegAction:new(player, sq, CLEAN_TIME))
            nextTile()
        end)
        ISTimedActionQueue.add(walk)
    end

    nextTile()
end

function CleanVegCursor:create(x, y, z, north, sprite)
    local square = getWorld():getCell():getGridSquare(x, y, z)
    if self.areaSize then
        areaClean(self.character, square, self.areaSize)
    else
        singleTileClean(self.character, square)
    end
end

function CleanVegCursor.hasCleanable(square)
    local function isCleanableObject(object)
        if not object then return false end

        local modData = object:getModData()
        if modData and modData["WDecay_Cleanable"] then
            return true
        end

        if object:getTextureName() and luautils.stringStarts(object:getTextureName(), "blends_grassoverlays") then
            return true
        elseif object:getSprite() and object:getSprite():getName() and (
            luautils.stringStarts(object:getSprite():getName(), "f_bushes_") or
                luautils.stringStarts(object:getSprite():getName(), "d_generic_") or
                luautils.stringStarts(object:getSprite():getName(), "e_newgrass_") or
                luautils.stringStarts(object:getSprite():getName(), "f_wallvines_") or
                luautils.stringStarts(object:getSprite():getName(), "trash_01_") or
                luautils.stringStarts(object:getSprite():getName(), "roofs_burnt_") or
                luautils.stringStarts(object:getSprite():getName(), "roofs_03_") or
                luautils.stringStarts(object:getSprite():getName(), "roofs_04_") or
                luautils.stringStarts(object:getSprite():getName(), "carpentry_02_58") or
                luautils.stringStarts(object:getSprite():getName(), "walls_burnt_") or
                luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_68") or
                luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_69") or
                luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_70") or
                luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_75") or
                luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_76") or
                luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_77") or
                luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_78")
            ) then
            return true
        elseif object:getClass() == BaseVehicle.class then
            return true
        else
            local attached = object:getAttachedAnimSprite()
            if attached then
                for n = 1, attached:size() do
                    local sprite = attached:get(n - 1)
                    if sprite and sprite:getParentSprite() and sprite:getParentSprite():getName() and
                        (luautils.stringStarts(sprite:getParentSprite():getName(), "blends_grassoverlays")
                            or luautils.stringStarts(sprite:getParentSprite():getName(), "d_plants")
                            or luautils.stringStarts(sprite:getParentSprite():getName(), "f_wallvines")
                            or luautils.stringStarts(sprite:getParentSprite():getName(), "d_generic")
                            or luautils.stringStarts(sprite:getParentSprite():getName(), "blends_natural")
                            or luautils.stringStarts(sprite:getParentSprite():getName(), "e_newgrass")
                            or luautils.stringStarts(sprite:getParentSprite():getName(), "vegetation_farm")
                            or luautils.stringStarts(sprite:getParentSprite():getName(), "f_bushes_")
                            or luautils.stringStarts(sprite:getParentSprite():getName(), "d_generic_")) then
                        return true
                    end
                end
            end
        end

        return false
    end

    local function hasCleanableInList(objects)
        if not objects then return false end

        for i = 0, objects:size() - 1 do
            if isCleanableObject(objects:get(i)) then
                return true
            end
        end

        return false
    end

    return hasCleanableInList(square:getObjects()) or hasCleanableInList(square:getSpecialObjects())
end

function CleanVegCursor:isValid(square)
    return CleanVegCursor.hasCleanable(square)
end

function CleanVegCursor:render(x, y, z, square)
    if not CleanVegCursor.floorSprite then
        CleanVegCursor.floorSprite = IsoSprite.new()
        CleanVegCursor.floorSprite:LoadFramesNoDirPageSimple('media/ui/FloorTileCursor.png')
    end

    if self.areaSize then
        local cell = getCell()
        local half = math.floor(self.areaSize / 2)
        local sx = square:getX()
        local sy = square:getY()

        for dx = -half, half do
            for dy = -half, half do
                local sq = cell:getGridSquare(sx + dx, sy + dy, z)
                if sq then
                    local r, g, b, a = 0.0, 1.0, 0.0, 0.6
                    if not CleanVegCursor.hasCleanable(sq) then
                        r, g, a = 1.0, 0.0, 0.3
                    end

                    CleanVegCursor.floorSprite:RenderGhostTileColor(sx + dx, sy + dy, z, r, g, b, a)
                end
            end
        end
    else
        local r, g, b, a = 0.0, 1.0, 0.0, 0.8
        if not CleanVegCursor.hasCleanable(square) then
            r, g = 1.0, 0.0
        end

        CleanVegCursor.floorSprite:RenderGhostTileColor(x, y, z, r, g, b, a)
    end
end

function CleanVegCursor:new(sprite, northSprite, character, areaSize)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o:init()
    o:setSprite(sprite)
    o:setNorthSprite(northSprite)
    o.character = character
    o.player = character:getPlayerNum()
    o.noNeedHammer = true
    o.skipBuildAction = true
    o.areaSize = areaSize
    return o
end
