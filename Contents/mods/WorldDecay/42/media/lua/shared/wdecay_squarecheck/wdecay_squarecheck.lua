local WDecay_SquareCheck = {}

local roadTiles = {
    "blends_street_01_0",
    "blends_street_01_5",
    "blends_street_01_16",
    "blends_street_01_21",
    "blends_street_01_32",
    "blends_street_01_37",
    "blends_street_01_38",
    "blends_street_01_39",
    "blends_street_01_48",
    "blends_street_01_53",
    "blends_street_01_54",
    "blends_street_01_55",
    "blends_street_01_64",
    "blends_street_01_69",
    "blends_street_01_70",
    "blends_street_01_71",
    "blends_street_01_80",
    "blends_street_01_85",
    "blends_street_01_86",
    "blends_street_01_87",
    "blends_street_01_96",
    "blends_street_01_101",
    "blends_street_01_102",
    "blends_street_01_103",
    "floors_exterior_tilesandstone_01_3",
    "floors_exterior_tilesandstone_01_4",
    "floors_exterior_tilesandstone_01_5",
    "floors_exterior_tilesandstone_01_6",
}
local roadTilesSet = {}
for _, v in ipairs(roadTiles) do roadTilesSet[v] = true end

local naturalTiles = {
    "blends_natural_01_16",
    "blends_natural_01_21",
    "blends_natural_01_22",
    "blends_natural_01_23",
    "blends_natural_01_32",
    "blends_natural_01_37",
    "blends_natural_01_38",
    "blends_natural_01_39",
    "blends_natural_01_48",
    "blends_natural_01_49",
    "blends_natural_01_53",
    "blends_natural_01_54",
    "blends_natural_01_55",
}
local naturalTilesSet = {}
for _, v in ipairs(naturalTiles) do naturalTilesSet[v] = true end

function WDecay_SquareCheck.isWater(square)
    if not square then return false end

    return square:getProperties():has(IsoFlagType.water)
end

function WDecay_SquareCheck.checkWater(square)
    if not square then return false end

    return not WDecay_SquareCheck.isWater(square)
end

function WDecay_SquareCheck.hasRoadTiles(square)
    if not square then return false end

    local objects = square:getObjects()
    if objects then
        for i = 0, objects:size() - 1 do
            local obj = objects:get(i)
            if obj:getClass() == IsoObject.class and obj:getSprite() and obj:getSprite():getName() then
                if roadTilesSet[obj:getSprite():getName()] then
                    return true
                end
            end
        end
    end

    return false
end

function WDecay_SquareCheck.checkRoad(square)
    return WDecay_SquareCheck.hasRoadTiles(square)
end

function WDecay_SquareCheck.hasNaturalTiles(square)
    if not square then return false end

    local objects = square:getObjects()
    if objects then
        for i = 0, objects:size() - 1 do
            local obj = objects:get(i)
            if obj:getClass() == IsoObject.class and obj:getSprite() and obj:getSprite():getName() then
                if naturalTilesSet[obj:getSprite():getName()] then
                    return true
                end
            end
        end
    end

    return false
end

function WDecay_SquareCheck.checkNatural(square)
    return WDecay_SquareCheck.hasNaturalTiles(square)
end

function WDecay_SquareCheck.hasLadderOrRope(square)
    if not square then return false end

    local props = square:getProperties()
    if not props then return false end

    return props:has(IsoFlagType.climbSheetTopW) or
        props:has(IsoFlagType.climbSheetTopN) or
        props:has(IsoFlagType.climbSheetTopE) or
        props:has(IsoFlagType.climbSheetTopS) or
        props:has(IsoFlagType.climbSheetW) or
        props:has(IsoFlagType.climbSheetN) or
        props:has(IsoFlagType.climbSheetE) or
        props:has(IsoFlagType.climbSheetS)
end

function WDecay_SquareCheck.checkSquare(square)
    if not square then return false end

    if WDecay_SquareCheck.isWater(square) then return false end

    if square:getRoom() then return false end

    if square:HasStairs() then return false end

    if not square:hasFloor(true) then return false end

    local door = square:getDoor(true) or square:getDoor(false) or square:haveDoor()
    if door then return false end

    local objects = square:getObjects()
    if objects then
        for i = 0, objects:size() - 1 do
            local obj = objects:get(i)
            if obj:getClass() == IsoObject.class and obj:getSprite() and
                obj:getSprite():getProperties() and
                obj:getSprite():getProperties():isTable() and
                obj:getSprite():getProperties():isTableTop() then
                return false
            end
        end
    end

    if WDecay_SquareCheck.hasLadderOrRope(square) then return false end

    if square:isSolid() or square:isSolidTrans() then return false end

    local cell = square:getCell()
    local x, y, z = square:getX(), square:getY(), square:getZ()
    local adjacent = cell:getGridSquare(x - 1, y, z)
    if adjacent and square:getDoorFrameTo(adjacent) then return false end

    adjacent = cell:getGridSquare(x + 1, y, z)
    if adjacent and square:getDoorFrameTo(adjacent) then return false end

    adjacent = cell:getGridSquare(x, y - 1, z)
    if adjacent and square:getDoorFrameTo(adjacent) then return false end

    adjacent = cell:getGridSquare(x, y + 1, z)
    if adjacent and square:getDoorFrameTo(adjacent) then return false end

    return true
end

function WDecay_SquareCheck.checkSquareForTrees(square)
    if not square then return false end

    if WDecay_SquareCheck.isWater(square) then return false end

    if square:getRoom() then return false end

    if square:HasStairs() then return false end

    if not square:hasFloor(true) then return false end

    local door = square:getDoor(true) or square:getDoor(false) or square:haveDoor()
    if door then return false end

    local objects = square:getObjects()
    if objects then
        for i = 0, objects:size() - 1 do
            local obj = objects:get(i)
            if obj:getClass() == IsoObject.class and obj:getSprite() and
                obj:getSprite():getProperties() and
                obj:getSprite():getProperties():isTable() and
                obj:getSprite():getProperties():isTableTop() then
                return false
            end
        end
    end

    if WDecay_SquareCheck.hasLadderOrRope(square) then return false end

    if square:isSolid() or square:isSolidTrans() then return false end

    local cell = square:getCell()
    local x, y, z = square:getX(), square:getY(), square:getZ()
    local adjacent = cell:getGridSquare(x - 1, y, z)
    if adjacent and square:getDoorFrameTo(adjacent) then return false end

    adjacent = cell:getGridSquare(x + 1, y, z)
    if adjacent and square:getDoorFrameTo(adjacent) then return false end

    adjacent = cell:getGridSquare(x, y - 1, z)
    if adjacent and square:getDoorFrameTo(adjacent) then return false end

    adjacent = cell:getGridSquare(x, y + 1, z)
    if adjacent and square:getDoorFrameTo(adjacent) then return false end

    if not square:isSolidFloor() then return false end

    return true
end

function WDecay_SquareCheck.checkSquareForVehicles(square)
    if not square then return false end

    if WDecay_SquareCheck.isWater(square) then return false end

    if not WDecay_SquareCheck.hasRoadTiles(square) then return false end

    return true
end

function WDecay_SquareCheck.checkSquareForStories(square)
    if not square then return false end

    if WDecay_SquareCheck.isWater(square) then return false end

    if not square:isSolidFloor() then return false end

    if not WDecay_SquareCheck.hasNaturalTiles(square) then return false end

    if WDecay_SquareCheck.hasRoadTiles(square) then return false end

    return true
end

function WDecay_SquareCheck.checkSquareForBarricades(square)
    if not square then return false end

    if WDecay_SquareCheck.isWater(square) then return false end

    if not square:hasFloor(true) then return false end

    return true
end

function WDecay_SquareCheck.hasRoadTilesFast(square, objects)
    if not square then return false end

    if not objects then objects = square:getObjects() end

    if objects then
        for i = 0, objects:size() - 1 do
            local obj = objects:get(i)
            if obj:getClass() == IsoObject.class and obj:getSprite() and obj:getSprite():getName() then
                if roadTilesSet[obj:getSprite():getName()] then
                    return true
                end
            end
        end
    end

    return false
end

function WDecay_SquareCheck.hasNaturalTilesFast(square, objects)
    if not square then return false end

    if not objects then objects = square:getObjects() end

    if objects then
        for i = 0, objects:size() - 1 do
            local obj = objects:get(i)
            if obj:getClass() == IsoObject.class and obj:getSprite() and obj:getSprite():getName() then
                if naturalTilesSet[obj:getSprite():getName()] then
                    return true
                end
            end
        end
    end

    return false
end

function WDecay_SquareCheck.isPhysicsSaturated(square)
    if not square then return true end

    local props = square:getProperties()
    if not props then return true end

    local count = 0
    if props:has(IsoFlagType.solid) then count = count + 1 end

    if props:has(IsoFlagType.solidtrans) then count = count + 1 end

    if props:has(IsoFlagType.solidfloor) then count = count + 1 end

    if props:has(IsoFlagType.DoorWallW) then count = count + 1 end

    if props:has(IsoFlagType.DoorWallN) then count = count + 1 end

    if props:has(IsoFlagType.collideW) then count = count + 1 end

    if props:has(IsoFlagType.collideN) then count = count + 1 end

    return count >= 4
end

function WDecay_SquareCheck.checkPlacement(square)
    if not square then return nil end

    local r = {
        water = false,
        room = nil,
        passed = false,
        tooManyPhysicsShapes = false,
        objects = nil,
        hasRoof = false,
        isUrban = false,
        hasFurniture = false
    }
    r.objects = square:getObjects()
    r.water = square:getProperties():has(IsoFlagType.water)
    if r.water then return r end

    r.room = square:getRoom()
    if r.room then
        r.hasWalls = false
        r.hasFences = false
        r.hasWindows = false
        r.isUrban = true
        if r.objects then
            for i = 0, r.objects:size() - 1 do
                local obj = r.objects:get(i)
                if obj and obj:getSprite() then
                    local sprite = obj:getSprite()
                    local props = sprite:getProperties()
                    if props then
                        if props:has("WallN") or props:has("WallW") then
                            r.hasWalls = true
                        end
                    end

                    local name = sprite:getName()
                    if name then
                        if luautils.stringStarts(name, "fencing_") then
                            r.hasFences = true
                        end
                    end

                    if obj:getClass() == IsoWindow.class or instanceof(obj, "IsoWindowFrame") then
                        r.hasWindows = true
                    end

                    if not r.hasFurniture then
                        local texName = obj:getTextureName()
                        if texName and luautils.stringStarts(texName, "fixtures_") then
                            r.hasFurniture = true
                        end
                    end

                    if r.hasWalls and r.hasFences and r.hasWindows and r.hasFurniture then break end
                end
            end
        end

        return r
    end

    if not square:hasFloor(true) then return r end

    if square:getDoor(true) or square:getDoor(false) or square:haveDoor() then return r end

    r.hasStairs = false
    r.hasFloor = true
    r.hasDoor = false
    r.hasTable = false
    r.hasLadder = false
    r.isSolid = false
    r.hasDoorFrame = false
    r.isSolidFloor = false
    r.isRoad = false
    r.isNatural = false
    r.hasWalls = false
    r.hasFences = false
    r.hasWindows = false
    r.isUrban = false
    r.hasFurniture = false
    if r.objects then
        for i = 0, r.objects:size() - 1 do
            local obj = r.objects:get(i)
            if obj:getClass() == IsoObject.class and obj:getSprite() and
                obj:getSprite():getProperties() and
                obj:getSprite():getProperties():isTable() and
                obj:getSprite():getProperties():isTableTop() then
                r.hasTable = true
                break
            end
        end
    end

    if r.hasTable then return r end

    r.hasLadder = WDecay_SquareCheck.hasLadderOrRope(square)
    if r.hasLadder then return r end

    r.isSolid = square:isSolid() or square:isSolidTrans()
    if r.isSolid then return r end

    local cell = square:getCell()
    local x, y, z = square:getX(), square:getY(), square:getZ()
    local adjacent = cell:getGridSquare(x - 1, y, z)
    if adjacent and square:getDoorFrameTo(adjacent) then r.hasDoorFrame = true end

    if not r.hasDoorFrame then
        adjacent = cell:getGridSquare(x + 1, y, z)
        if adjacent and square:getDoorFrameTo(adjacent) then r.hasDoorFrame = true end
    end

    if not r.hasDoorFrame then
        adjacent = cell:getGridSquare(x, y - 1, z)
        if adjacent and square:getDoorFrameTo(adjacent) then r.hasDoorFrame = true end
    end

    if not r.hasDoorFrame then
        adjacent = cell:getGridSquare(x, y + 1, z)
        if adjacent and square:getDoorFrameTo(adjacent) then r.hasDoorFrame = true end
    end

    if r.hasDoorFrame then return r end

    r.isSolidFloor = square:isSolidFloor()
    r.isRoad = WDecay_SquareCheck.hasRoadTilesFast(square, r.objects)
    r.isNatural = WDecay_SquareCheck.hasNaturalTilesFast(square, r.objects)
    r.tooManyPhysicsShapes = WDecay_SquareCheck.isPhysicsSaturated(square)
    if r.tooManyPhysicsShapes then return r end

    if r.isRoad then
        r.isUrban = true
    elseif r.hasWalls then
        r.isUrban = true
    else
        local cell = square:getCell()
        local x, y, z = square:getX(), square:getY(), square:getZ()
        for dx = -3, 3 do
            for dy = -3, 3 do
                if dx ~= 0 or dy ~= 0 then
                    local adj = cell:getGridSquare(x + dx, y + dy, z)
                    if adj then
                        local adjObjs = adj:getObjects()
                        if adjObjs then
                            for j = 0, adjObjs:size() - 1 do
                                local adjObj = adjObjs:get(j)
                                if adjObj and adjObj:getSprite() then
                                    local adjProps = adjObj:getSprite():getProperties()
                                    if adjProps then
                                        if adjProps:has("WallN") or adjProps:has("WallW") then
                                            r.isUrban = true
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end

                    if r.isUrban then break end
                end
            end

            if r.isUrban then break end
        end
    end

    if r.objects then
        for i = 0, r.objects:size() - 1 do
            local obj = r.objects:get(i)
            if obj and obj:getSprite() then
                local sprite = obj:getSprite()
                local props = sprite:getProperties()
                if props then
                    if props:has("WallN") or props:has("WallW") then
                        r.hasWalls = true
                    end
                end

                local name = sprite:getName()
                if name then
                    if luautils.stringStarts(name, "fencing_") then
                        r.hasFences = true
                    end
                end

                if obj:getClass() == IsoWindow.class or instanceof(obj, "IsoWindowFrame") then
                    r.hasWindows = true
                end

                if not r.hasFurniture then
                    local texName = obj:getTextureName()
                    if texName and luautils.stringStarts(texName, "fixtures_") then
                        r.hasFurniture = true
                    end
                end

                if r.hasWalls and r.hasFences and r.hasWindows and r.hasFurniture then break end
            end
        end
    end

    r.passed = true
    if r.objects then
        for i = 0, r.objects:size() - 1 do
            local obj = r.objects:get(i)
            if obj and obj:getSprite() then
                local name = obj:getSprite():getName()
                if name and luautils.stringStarts(name, "roofs_") then
                    r.hasRoof = true
                    break
                end
            end
        end
    end

    return r
end

function WDecay_SquareCheck.checkAll(square)
    return WDecay_SquareCheck.checkPlacement(square)
end

return WDecay_SquareCheck
