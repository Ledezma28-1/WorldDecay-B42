local WDecay_SquareCheck = {}

--package zombie.iso.zones;
local ZONE_TOWN = "TownZone"
local ZONE_TRAILER_PARK = "TrailerPark"

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

local ISO_OBJECT_CLASS = IsoObject.class

local function hasRoadTilesFast(spriteName)
    if roadTilesSet[spriteName] then
        return true
    else
        return false
    end

end

local function isPhysicsSaturated(props)
    return props:getFlagsList():size() >= 5
end

local function fastCheckPlacement(square, level)
    if not square then return nil end

    local r = {
        isGoodSquare = square:isGoodSquare(),
        room = nil,
        passed = false,
        tooManyPhysicsShapes = false,
        objects = nil,
        hasRoof = false,
        isUrban = false,
        hasFurniture = false
    }

    if square and r.isGoodSquare then
        r.objects = square:getObjects()
        r.props = square:getProperties()

        r.hasDoorFrame = square:isDoorSquare()
        if r.hasDoorFrame then return r end

        if r.props then
            r.tooManyPhysicsShapes = isPhysicsSaturated(r.props)
            if r.tooManyPhysicsShapes then return r end

            if r.props:isTable() and r.props:isTableTop() then
                r.hasTable = true
                return r
            end
        end

        r.room = square:getRoom()

        if r.room then
            r.hasWalls = square:isWallSquareNW()
            r.hasFences = square:hasFence()
            r.hasWindows = square:hasWindowOrWindowFrame()
            r.isIndoor = true
            r.isUrban = true
        end

        if r.objects then
            local objCount = r.objects:size() - 1

            for i = 0, objCount do
                local obj = r.objects:get(i)

                if obj:getClass() == ISO_OBJECT_CLASS then
                    local sprite = obj:getSprite()

                    if sprite then
                        local spriteName = sprite:getName()

                        if spriteName then
                            r.isRoad = hasRoadTilesFast(spriteName)
                        end
                    end
                end
            end
        end

        if r.isRoad then
            r.isUrban = true
        elseif r.hasWalls then
            r.isUrban = true
        else
            local squareZone = square:getZoneType()
            r.isUrban = squareZone == ZONE_TOWN or
                squareZone == ZONE_TRAILER_PARK
        end

        if level == 0 then
            r.isNatural = square:hasNaturalFloor()
            if r.isNatural then return r end
        end

        if level > 0 then
            r.hasRoof = square:getSquareAbove() == nil or square:haveRoofFull()
        end

        r.isSolid = square:isSolidFloor()
        if r.isSolid then return r end
    end

    return r
end

function WDecay_SquareCheck.checkAll(square, level)
    return fastCheckPlacement(square, level)
end

return WDecay_SquareCheck
