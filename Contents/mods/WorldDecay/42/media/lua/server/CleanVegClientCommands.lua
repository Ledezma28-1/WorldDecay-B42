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

local function onCleanVegCommand(module, command, player, args)
    if module == 'CleanVeg' then
        if command == 'CleanVegCommand' then
            local sq = getCell():getGridSquare(args.x, args.y, args.z)

            if not sq then return end

            cleanLog("onCleanVegCommand at " .. args.x .. "," .. args.y .. "," .. args.z .. " areaSize=" .. tostring(args.areaSize))

            local function tryCleanObject(sq, object)
                if not object then return false end

                local modData = object:getModData()
                if modData and modData["WDecay_Cleanable"] then
                    local cleanableType = modData["WDecay_Cleanable"]
                    if cleanableType == "grass" or cleanableType == "bush" or cleanableType == "trash" or cleanableType == "vine" then
                        cleanLog("onCleanVegCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=" .. tostring(cleanableType))
                        sq:transmitRemoveItemFromSquare(object)
                        return true
                    end
                end

                local attached = object:getAttachedAnimSprite()
                if attached then
                    for n = attached:size() - 1, 0, -1 do
                        local sprite = attached:get(n)
                        local parentSprite = sprite:getParentSprite()

                        if parentSprite then
                            local props = parentSprite:getProperties()
                            local parentName = parentSprite:getName()
                            if props and parentName and (
                                luautils.stringStarts(parentName, "blends_grassoverlays") or
                                    luautils.stringStarts(parentName, "e_newgrass_") or
                                    luautils.stringStarts(parentName, "f_bushes_") or
                                    luautils.stringStarts(parentName, "d_generic_") or
                                    luautils.stringStarts(parentName, "trash_01_")
                                ) then
                                cleanLog("onCleanVegCommand REMOVED attached anim " .. tostring(parentSprite:getName()) .. " from " .. tostring(object:getSprite():getName()))
                                object:RemoveAttachedAnim(n)
                                object:transmitUpdatedSpriteToClients()
                                return true
                            end
                        end
                    end
                end

                if object:getSprite() and object:getSprite():getName()
                    and luautils.stringStarts(object:getSprite():getName(), "f_bushes_") then
                    cleanLog("onCleanVegCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=bush")
                    sq:transmitRemoveItemFromSquare(object)
                    return true
                end

                if object:getSprite() and object:getSprite():getName()
                    and (luautils.stringStarts(object:getSprite():getName(), "d_generic_")
                        or luautils.stringStarts(object:getSprite():getName(), "e_newgrass_")) then
                    cleanLog("onCleanVegCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=grass")
                    sq:transmitRemoveItemFromSquare(object)
                    return true
                end

                if object:getSprite() and object:getSprite():getName()
                    and luautils.stringStarts(object:getSprite():getName(), "f_wallvines_") then
                    cleanLog("onCleanVegCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=vine")
                    sq:transmitRemoveItemFromSquare(object)

                    local neighbour = getCell():getGridSquare(sq:getX(), sq:getY(), sq:getZ() + 1)
                    if neighbour then
                        local neighbourObjs = neighbour:getObjects()
                        if neighbourObjs then
                            for j = neighbourObjs:size() - 1, 0, -1 do
                                local neighbourObj = neighbourObjs:get(j)
                                if neighbourObj and neighbourObj:getSprite() and neighbourObj:getSprite():getName()
                                    and luautils.stringStarts(neighbourObj:getSprite():getName(), "f_wallvines_") then
                                    neighbour:transmitRemoveItemFromSquare(neighbourObj)
                                    break
                                end
                            end
                        end
                    end

                    return true
                end

                if object:getSprite() and object:getSprite():getName()
                    and luautils.stringStarts(object:getSprite():getName(), "trash_01_") then
                    cleanLog("onCleanVegCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=trash")
                    sq:transmitRemoveItemFromSquare(object)
                    return true
                end

                if object:getAttachedAnimSprite() then
                    for n = object:getAttachedAnimSprite():size() - 1, 0, -1 do
                        local sprite = object:getAttachedAnimSprite():get(n)
                        if sprite and sprite:getParentSprite() and sprite:getParentSprite():getName() then
                            local parentName = sprite:getParentSprite():getName()
                            if luautils.stringStarts(parentName, "blends_grassoverlays") or
                                luautils.stringStarts(parentName, "e_newgrass_") or
                                luautils.stringStarts(parentName, "f_bushes_") or
                                luautils.stringStarts(parentName, "d_generic_") or
                                luautils.stringStarts(parentName, "trash_01_") then
                                cleanLog("onCleanVegCommand REMOVED attached anim " .. tostring(sprite:getParentSprite():getName()) .. " from " .. tostring(object:getSprite():getName()))
                                object:RemoveAttachedAnim(n)
                                object:transmitUpdatedSpriteToClients()
                                return true
                            end
                        end
                    end
                end

                return false
            end

            local objects = sq:getObjects()
            for i = objects:size() - 1, 0, -1 do
                tryCleanObject(sq, objects:get(i))
            end

            local specialObjects = sq:getSpecialObjects()
            for i = specialObjects:size() - 1, 0, -1 do
                tryCleanObject(sq, specialObjects:get(i))
            end

            local floor = sq:getFloor()
            if floor then
                tryCleanObject(sq, floor)
                local floorAttached = floor:getAttachedAnimSprite()
                if floorAttached then
                    for n = floorAttached:size() - 1, 0, -1 do
                        local sprite = floorAttached:get(n)
                        if sprite and sprite:getParentSprite() and sprite:getParentSprite():getName() then
                            local pn = sprite:getParentSprite():getName()
                            if luautils.stringStarts(pn, "blends_grassoverlays") or
                                luautils.stringStarts(pn, "e_newgrass_") or
                                luautils.stringStarts(pn, "f_bushes_") or
                                luautils.stringStarts(pn, "d_generic_") or
                                luautils.stringStarts(pn, "trash_01_") then
                                floor:RemoveAttachedAnim(n)
                                floor:transmitUpdatedSpriteToClients()
                                cleanLog("onCleanVegCommand REMOVED floor attached anim " .. tostring(pn))
                            end
                        end
                    end
                end
            end
        end
    end
end

Events.OnClientCommand.Add(onCleanVegCommand)
