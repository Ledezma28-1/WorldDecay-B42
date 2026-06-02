require('luautils');

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

local function onCleanVegMenu(worldobjects, square, player, areaSize)
    cleanLog("CleanVegContextMenu area clean selected areaSize=" .. tostring(areaSize) .. " at " .. square:getX() .. "," .. square:getY())
    local bo = CleanVegCursor:new("", "", player, areaSize)
    getCell():setDrag(bo, player:getPlayerNum())
end

local function addCleanVegMenu(player, context, worldobjects)
    local player = getSpecificPlayer(player);
    local square;

    if player:getVehicle() then return end

    for i, v in ipairs(worldobjects) do
        square = v:getSquare();
    end

    if not square then return end

    local function isCleanableObject(object)
        if not object then return false end

        local attached = object:getAttachedAnimSprite()
        if attached then
            for n = 1, attached:size() do
                local sprite = attached:get(n - 1)
                if sprite and sprite:getParentSprite() and sprite:getParentSprite():getName() then
                    local name = sprite:getParentSprite():getName()
                    if luautils.stringStarts(name, "blends_streetoverlays_01_") or luautils.stringStarts(name, "blends_dirtoverlays_01_") then
                        return false
                    end
                end
            end
        end

        local modData = object:getModData()
        if modData and modData["WDecay_Cleanable"] then
            local cleanableType = modData["WDecay_Cleanable"]
            if cleanableType == "grass" or cleanableType == "bush" or cleanableType == "trash" or cleanableType == "vine" then
                cleanLog("CleanVegContextMenu isCleanableObject MATCH sprite=" .. tostring(object:getSprite():getName()) .. " modData=" .. tostring(object:getModData()["WDecay_Cleanable"]))
                return true
            end
        end

        if object:getTextureName() and luautils.stringStarts(object:getTextureName(), "blends_grassoverlays") then
            cleanLog("CleanVegContextMenu isCleanableObject MATCH sprite=" .. tostring(object:getSprite():getName()) .. " modData=" .. tostring(object:getModData()["WDecay_Cleanable"]))
            return true
        elseif object:getSprite() and object:getSprite():getName() and (
            luautils.stringStarts(object:getSprite():getName(), "f_bushes_") or
                luautils.stringStarts(object:getSprite():getName(), "d_generic_") or
                luautils.stringStarts(object:getSprite():getName(), "e_newgrass_") or
                luautils.stringStarts(object:getSprite():getName(), "f_wallvines_") or
                luautils.stringStarts(object:getSprite():getName(), "trash_01_")
            ) then
            cleanLog("CleanVegContextMenu isCleanableObject MATCH sprite=" .. tostring(object:getSprite():getName()) .. " modData=" .. tostring(object:getModData()["WDecay_Cleanable"]))
            return true
        else
            local attached = object:getAttachedAnimSprite()
            if attached then
                for n = 1, attached:size() do
                    local sprite = attached:get(n - 1)

                    if sprite and sprite:getParentSprite() and sprite:getParentSprite():getName() and (
                        luautils.stringStarts(sprite:getParentSprite():getName(), "blends_grassoverlays") or
                            luautils.stringStarts(sprite:getParentSprite():getName(), "d_generic") or
                            luautils.stringStarts(sprite:getParentSprite():getName(), "e_newgrass") or
                            luautils.stringStarts(sprite:getParentSprite():getName(), "f_wallvines") or
                            luautils.stringStarts(sprite:getParentSprite():getName(), "f_bushes_") or
                            luautils.stringStarts(sprite:getParentSprite():getName(), "d_generic_")
                        ) then
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

    local target = hasCleanableInList(square:getObjects()) or hasCleanableInList(square:getSpecialObjects())

    if not target then return end

    local submenuOption = context:addOption(getText('UI_REMOVE_VEG'), worldobjects, nil)
    local subMenu = ISContextMenu:getNew(context)
    context:addSubMenu(submenuOption, subMenu)
    subMenu:addOption(getText('UI_CLEAN_TILE'), worldobjects, onCleanVegMenu, square, player, nil)
    subMenu:addOption(getText('UI_CLEAN_AREA_3'), worldobjects, onCleanVegMenu, square, player, 3)
    subMenu:addOption(getText('UI_CLEAN_AREA_5'), worldobjects, onCleanVegMenu, square, player, 5)
    subMenu:addOption(getText('UI_CLEAN_AREA_10'), worldobjects, onCleanVegMenu, square, player, 10)
end

Events.OnFillWorldObjectContextMenu.Add(addCleanVegMenu);
