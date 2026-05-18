local cachedDebugMode = nil
local function isCleanDebug()
    if cachedDebugMode == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.debugMode')
        cachedDebugMode = opt and opt:getValue() or false
    end
    return cachedDebugMode
end

local function cleanLog(msg)
    if isCleanDebug() then
        print("[WDecay-Clean] " .. msg)
    end
end

if ISBuildingObject then
    CleanVegCursor = ISBuildingObject:derive("CleanVegCursor")
else
    CleanVegCursor = {}
end

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

    cleanLog("CleanVegCursor area clean started at " .. cx .. "," .. cy .. " areaSize=" .. tostring(areaSize))

    local squares = {}
    for dx = -half, half do
        for dy = -half, half do
            local sq = cell:getGridSquare(cx + dx, cy + dy, z)
            if sq and CleanVegCursor.hasCleanable(sq) then
                cleanLog("CleanVegCursor cleaning square at " .. (cx + dx) .. "," .. (cy + dy))
                squares[#squares + 1] = sq
            end
        end
    end

    if #squares == 0 then
        cleanLog("CleanVegCursor area clean DONE")
        return
    end

    local idx = 0
    local function nextTile()
        idx = idx + 1
        if idx > #squares then
            cleanLog("CleanVegCursor area clean DONE")
            return
        end
        local sq = squares[idx]
        local walk = ISWalkToTimedAction:new(player, sq)
        walk:setOnComplete(function()
            cleanLog("CleanVegCursor sending server command for " .. sq:getX() .. "," .. sq:getY())
            ISTimedActionQueue.add(CleanVegAction:new(player, sq, CLEAN_TIME))
            nextTile()
        end)
        ISTimedActionQueue.add(walk)
    end
    nextTile()
end

function CleanVegCursor:create(x, y, z, north, sprite)
    local square = getWorld():getCell():getGridSquare(x, y, z)
    if not square then return end
    if self.areaSize then
        areaClean(self.character, square, self.areaSize)
    else
        singleTileClean(self.character, square)
    end
end

function CleanVegCursor.hasCleanable(square)
    local function isCleanableObject(object)
        if not object then return false end

        local att = object:getAttachedAnimSprite()
        if att then
            for n=1,att:size() do
                local sp = att:get(n-1)
                if sp and sp:getParentSprite() and sp:getParentSprite():getName() then
                    local nm = sp:getParentSprite():getName()
                    if luautils.stringStarts(nm, "blends_streetoverlays_01_") or luautils.stringStarts(nm, "blends_dirtoverlays_01_") then
                        return false
                    end
                end
            end
        end

        local modData = object:getModData()
        if modData and modData["WDecay_Cleanable"] then
            local cleanableType = modData["WDecay_Cleanable"]
            if cleanableType == "grass" or cleanableType == "bush" or cleanableType == "trash" or cleanableType == "vine" then
                cleanLog("CleanVegCursor isCleanableObject MATCH " .. tostring(object:getSprite():getName()) .. " type=" .. tostring(cleanableType))
                return true
            end
        end

        if object:getTextureName() and luautils.stringStarts(object:getTextureName(), "blends_grassoverlays") then
            cleanLog("CleanVegCursor isCleanableObject MATCH " .. tostring(object:getSprite():getName()) .. " type=texture")
            return true
        end

        if object:getSprite() and object:getSprite():getName() and (
            luautils.stringStarts(object:getSprite():getName(), "f_bushes_") or
            luautils.stringStarts(object:getSprite():getName(), "d_generic_") or
            luautils.stringStarts(object:getSprite():getName(), "e_newgrass_") or
            luautils.stringStarts(object:getSprite():getName(), "f_wallvines_") or
            luautils.stringStarts(object:getSprite():getName(), "trash_01_")
        ) then
            cleanLog("CleanVegCursor isCleanableObject MATCH " .. tostring(object:getSprite():getName()) .. " type=sprite")
            return true
        end

        local attached = object:getAttachedAnimSprite()
        if attached then
            for n=1,attached:size() do
                local sprite = attached:get(n-1)
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
                    cleanLog("CleanVegCursor isCleanableObject MATCH " .. tostring(object:getSprite():getName()) .. " type=attached")
                    return true
                end
            end
        end

        return false
    end
        if not objects then return false end
        for i=0,objects:size()-1 do
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
                    local r,g,b,a = 0.0, 1.0, 0.0, 0.6
                    if not CleanVegCursor.hasCleanable(sq) then
                        r, g, a = 1.0, 0.0, 0.3
                    end
                    CleanVegCursor.floorSprite:RenderGhostTileColor(sx + dx, sy + dy, z, r, g, b, a)
                end
            end
        end
    else
        local r,g,b,a = 0.0, 1.0, 0.0, 0.8
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
