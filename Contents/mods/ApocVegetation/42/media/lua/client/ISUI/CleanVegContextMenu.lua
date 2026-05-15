require('luautils');

local function onCleanVegMenu(worldobjects, square, player, areaSize)
    local bo = CleanVegCursor:new("", "", player, areaSize)
    getCell():setDrag(bo, player:getPlayerNum())
end

local function addCleanVegMenu(player, context, worldobjects)
    local player = getSpecificPlayer(player);
    local square;

    if player:getVehicle() then return end

    for i,v in ipairs(worldobjects) do
        square = v:getSquare();
    end

    if not square then return end

    local function isCleanableObject(object)
        if not object then return false end

        local modData = object:getModData()
        if modData and modData["ApocVeg_Cleanable"] then
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
        elseif object:getClass() == IsoBarricade.class then
            if object:getModData() and object:getModData()["ApocVeg_Barricade"] then
                return true
            end
        else
            local attached = object:getAttachedAnimSprite()
            if attached then
                for n=1,attached:size() do
                    local sprite = attached:get(n-1)

                    if sprite and sprite:getParentSprite() and sprite:getParentSprite():getName() and (
                        luautils.stringStarts(sprite:getParentSprite():getName(), "blends_grassoverlays") or
                        luautils.stringStarts(sprite:getParentSprite():getName(), "d_plants") or
                        luautils.stringStarts(sprite:getParentSprite():getName(), "d_generic") or
                        luautils.stringStarts(sprite:getParentSprite():getName(), "f_wallvines") or
                        luautils.stringStarts(sprite:getParentSprite():getName(), "blends_natural") or
                        luautils.stringStarts(sprite:getParentSprite():getName(), "e_newgrass") or
                        luautils.stringStarts(sprite:getParentSprite():getName(), "vegetation_farm") or
                        luautils.stringStarts(sprite:getParentSprite():getName(), "f_bushes_") or
                        luautils.stringStarts(sprite:getParentSprite():getName(), "d_generic_") or
                        luautils.stringStarts(sprite:getParentSprite():getName(), "blends_streetoverlays_01_") or
                        luautils.stringStarts(sprite:getParentSprite():getName(), "blends_dirtoverlays_01_")
                    ) then
                        return true
                    elseif sprite and luautils.stringStarts(sprite:getParentSprite():getName(), "f_wallvines") then
                        return true
                    end
                end
            end
        end
        return false
    end

    local function hasCleanableInList(objects)
        if not objects then return false end
        for i=0,objects:size()-1 do
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
