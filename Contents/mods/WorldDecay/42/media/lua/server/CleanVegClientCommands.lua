require('luautils');

local function onCleanVegCommand(module, command, player, args)
    if module == 'CleanVeg' then
        if command == 'CleanVegCommand' then
            local sq = getCell():getGridSquare(args.x, args.y, args.z)

            if not sq then return end

            local function tryCleanObject(sq, object)
                if not object then return false end

                local modData = object:getModData()
                if modData and modData["WDecay_Cleanable"] then
                    sq:transmitRemoveItemFromSquare(object)
                    return true
                end

                local attached = object:getAttachedAnimSprite()
                if attached then
                    for n = attached:size()-1, 0, -1 do
                        local sprite = attached:get(n)
                        local parentSprite = sprite:getParentSprite()

                        if parentSprite then
                            local props = parentSprite:getProperties()
                            local parentName = parentSprite:getName()
                            if props and parentName and (not luautils.stringStarts(parentName, "f_wallvines_")) then
                                object:RemoveAttachedAnim(n)
                                object:transmitUpdatedSpriteToClients()
                                return true
                            end
                        end
                    end
                end

                if object:getSprite() and object:getSprite():getName()
                        and luautils.stringStarts(object:getSprite():getName(), "f_bushes_") then
                    sq:transmitRemoveItemFromSquare(object)
                    return true
                end

                if object:getSprite() and object:getSprite():getName()
                        and (luautils.stringStarts(object:getSprite():getName(), "d_generic_")
                        or luautils.stringStarts(object:getSprite():getName(), "e_newgrass_")) then
                    sq:transmitRemoveItemFromSquare(object)
                    return true
                end

                if object:getSprite() and object:getSprite():getName()
                        and luautils.stringStarts(object:getSprite():getName(), "f_wallvines_") then
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
                    sq:transmitRemoveItemFromSquare(object)
                    return true
                end

                if object:getSprite() and object:getSprite():getName()
                        and (luautils.stringStarts(object:getSprite():getName(), "roofs_burnt_") or
                        luautils.stringStarts(object:getSprite():getName(), "roofs_03_") or
                        luautils.stringStarts(object:getSprite():getName(), "roofs_04_") or
                        luautils.stringStarts(object:getSprite():getName(), "carpentry_02_58")) then
                    sq:transmitRemoveItemFromSquare(object)
                    return true
                end

                if object:getSprite() and object:getSprite():getName()
                        and (luautils.stringStarts(object:getSprite():getName(), "walls_burnt_") or
                        luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_68") or
                        luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_69") or
                        luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_70") or
                        luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_75") or
                        luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_76") or
                        luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_77") or
                        luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_78")) then
                    sq:transmitRemoveItemFromSquare(object)
                    return true
                end

                if object:getClass() == BaseVehicle.class then
                    sq:transmitRemoveItemFromSquare(object)
                    return true
                end

                if object:getClass() == IsoTree.class then
                    if object:getModData()["WDecay_Tree"] then
                        sq:transmitRemoveItemFromSquare(object)
                        return true
                    end
                end

                if object:getClass() == IsoBarricade.class then
                    if object:getModData()["WDecay_Barricade"] then
                        sq:transmitRemoveItemFromSquare(object)
                        return true
                    end
                end

                if object:getAttachedAnimSprite() then
                    for n = object:getAttachedAnimSprite():size() - 1, 0, -1 do
                        local sprite = object:getAttachedAnimSprite():get(n)
                        if sprite and sprite:getParentSprite() and sprite:getParentSprite():getName() then
                            local parentName = sprite:getParentSprite():getName()
                            if luautils.stringStarts(parentName, "blends_streetoverlays_01_") or
                               luautils.stringStarts(parentName, "blends_dirtoverlays_01_") then
                            else
                                object:RemoveAttachedAnim(n)
                                object:transmitUpdatedSpriteToClients()
                                return true
                            end
                        end
                    end
                end

                if object:getSprite() and object:getSprite():getName()
                        and luautils.stringStarts(object:getSprite():getName(), "fencing_damaged_") then
                    sq:transmitRemoveItemFromSquare(object)
                    return true
                end

                if object:getSprite() and object:getSprite():getName()
                        and (luautils.stringStarts(object:getSprite():getName(), "carpentry_02_58") or
                             luautils.stringStarts(object:getSprite():getName(), "carpentry_02_57") or
                             luautils.stringStarts(object:getSprite():getName(), "carpentry_02_56")) then
                    sq:transmitRemoveItemFromSquare(object)
                    return true
                end

                return false
            end

            local objects = sq:getObjects()
            for i=0,objects:size()-1 do
                if tryCleanObject(sq, objects:get(i)) then
                    break
                end
            end

            local specialObjects = sq:getSpecialObjects()
            for i=0,specialObjects:size()-1 do
                if tryCleanObject(sq, specialObjects:get(i)) then
                    break
                end
            end
        end
    end
end

Events.OnClientCommand.Add(onCleanVegCommand)
