require "BuildingObjects/ISRemovePlantCursor"

local ISRemovePlantCursor_getRemovableObject = ISRemovePlantCursor.getRemovableObject
function ISRemovePlantCursor:getRemovableObject(square)
    local vanillaPass = ISRemovePlantCursor_getRemovableObject(self, square)
    if vanillaPass then
        return vanillaPass
    end

    local function findRemovableInList(objects)
        if not objects then return nil end
        for i=1,objects:size() do
            local object = objects:get(i-1)

            local modData = object:getModData()
            if modData and modData["ApocVeg_Cleanable"] then
                local cleanableType = modData["ApocVeg_Cleanable"]
                if self.removeType == "grass" and cleanableType == "grass" then
                    return object
                elseif self.removeType == "bush" and (cleanableType == "bush" or cleanableType == "roof" or cleanableType == "wall" or cleanableType == "trash" or cleanableType == "vehicle" or cleanableType == "tree" or cleanableType == "barricade" or cleanableType == "fence" or cleanableType == "crack") then
                    return object
                elseif self.removeType == "wallVine" and cleanableType == "vine" then
                    return object
                end
            end

            local attached = object:getAttachedAnimSprite()
            if attached then
                for n=0,attached:size()-1 do
                    local sprite = attached:get(n)
                    local parentSprite = sprite:getParentSprite()

                    if self.removeType == "bush" and parentSprite and parentSprite:getProperties()
                            and parentSprite:getProperties():Is(IsoFlagType.canBeCut) then
                        return object
                    end

                    if self.removeType == "grass" and parentSprite then
                        local props = parentSprite:getProperties()
                        local hasFlag = false
                        if props and IsoFlagType.canBeRemoved then
                            local ok, result = pcall(function() return props:Is(IsoFlagType.canBeRemoved) end)
                            hasFlag = ok and result
                        end
                        if hasFlag and (not luautils.stringStarts(parentSprite:getName(), "f_wallvines_")) then
                            return object
                        end
                    end
                end
            end

            if self.removeType == "grass" and object:getSprite() and object:getSprite():getName()
                    and (luautils.stringStarts(object:getSprite():getName(), "d_generic_")
                    or luautils.stringStarts(object:getSprite():getName(), "e_newgrass_")) then
                return object
            end

            if self.removeType == "wallVine" and object:getSprite() and object:getSprite():getName()
                    and luautils.stringStarts(object:getSprite():getName(), "f_wallvines_") then
                return object
            end

            if self.removeType == "bush" and object:getSprite() and object:getSprite():getName()
                    and luautils.stringStarts(object:getSprite():getName(), "trash_01_") then
                return object
            end

            if self.removeType == "bush" and object:getSprite() and object:getSprite():getName()
                    and (luautils.stringStarts(object:getSprite():getName(), "roofs_burnt_") or
                    luautils.stringStarts(object:getSprite():getName(), "roofs_03_") or
                    luautils.stringStarts(object:getSprite():getName(), "roofs_04_") or
                    luautils.stringStarts(object:getSprite():getName(), "carpentry_02_58")) then
                return object
            end

            if self.removeType == "bush" and object:getSprite() and object:getSprite():getName()
                    and (luautils.stringStarts(object:getSprite():getName(), "walls_burnt_") or
                    luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_68") or
                    luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_69") or
                    luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_70") or
                    luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_75") or
                    luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_76") or
                    luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_77") or
                    luautils.stringStarts(object:getSprite():getName(), "walls_exterior_wooden_01_78")) then
                return object
            end

            if self.removeType == "bush" and object:getClass() == BaseVehicle.class then
                return object
            end

            if self.removeType == "bush" and object:getClass() == IsoAnimal.class then
                if object:getModData()["ApocVeg_Animal"] then
                    return object
                end
            end

            if self.removeType == "bush" and object:getClass() == IsoTree.class then
                if object:getModData()["ApocVeg_Tree"] then
                    return object
                end
            end

            if self.removeType == "bush" and object:getSprite() and object:getSprite():getName()
                    and luautils.stringStarts(object:getSprite():getName(), "f_bushes_") then
                return object
            end
        end
        return nil
    end

    return findRemovableInList(square:getObjects()) or findRemovableInList(square:getSpecialObjects())
end


local function onRemovePlantCommand(module, command, player, args)
    if module == "onRemovePlant" then

        if not IsoFlagType[command] then return end

        local sq = getCell():getGridSquare(args.x, args.y, args.z)
        if not sq then return end

        for i=0,sq:getObjects():size()-1 do
            local object = sq:getObjects():get(i)

            if object then
                local modData = object:getModData()
                if modData and modData["ApocVeg_Cleanable"] then
                    local cleanableType = modData["ApocVeg_Cleanable"]
                    if command == "canBeRemoved" and cleanableType == "grass" then
                        sq:transmitRemoveItemFromSquare(object)
                        break
                    elseif command == "canBeCut" and (cleanableType == "bush" or cleanableType == "roof" or cleanableType == "wall" or cleanableType == "trash" or cleanableType == "vehicle" or cleanableType == "tree" or cleanableType == "barricade" or cleanableType == "fence" or cleanableType == "crack") then
                        sq:transmitRemoveItemFromSquare(object)
                        break
                    elseif command == "canBeCut" and cleanableType == "vine" then
                        sq:transmitRemoveItemFromSquare(object)
                        local neighbour = getCell():getGridSquare(sq:getX(), sq:getY(), sq:getZ() + 1)
                        if neighbour then
                            local neighbourObjs = neighbour:getObjects()
                            if neighbourObjs then
                                for j = neighbourObjs:size() - 1, 0, -1 do
                                    local neighbourObj = neighbourObjs:get(j)
                                    if neighbourObj then
                                        local neighbourModData = neighbourObj:getModData()
                                        if neighbourModData and neighbourModData["ApocVeg_Cleanable"] == "vine" then
                                            neighbour:transmitRemoveItemFromSquare(neighbourObj)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        break
                    end
                end

                local attached = object:getAttachedAnimSprite()
                if attached then
                    for n = attached:size()-1, 0, -1 do
                        local sprite = attached:get(n)
                        local parentSprite = sprite:getParentSprite()

                        if parentSprite and parentSprite:getProperties()
                                and parentSprite:getProperties():Is(IsoFlagType[command])
                                and (not luautils.stringStarts(parentSprite:getName(), "f_wallvines_")) then
                            object:RemoveAttachedAnim(n)
                            object:transmitUpdatedSpriteToClients()
                            break
                        end
                    end
                end

                if object:getSprite() and object:getSprite():getName()
                        and luautils.stringStarts(object:getSprite():getName(), "f_bushes_") then
                    sq:transmitRemoveItemFromSquare(object)
                    break
                end

                if object:getSprite() and object:getSprite():getName()
                        and (luautils.stringStarts(object:getSprite():getName(), "d_generic_")
                        or luautils.stringStarts(object:getSprite():getName(), "e_newgrass_")) then
                    sq:transmitRemoveItemFromSquare(object)
                    break
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
                    break
                end

                if object:getSprite() and object:getSprite():getName()
                        and luautils.stringStarts(object:getSprite():getName(), "trash_01_") then
                    sq:transmitRemoveItemFromSquare(object)
                    break
                end

                if object:getSprite() and object:getSprite():getName()
                        and (luautils.stringStarts(object:getSprite():getName(), "roofs_burnt_") or
                        luautils.stringStarts(object:getSprite():getName(), "roofs_03_") or
                        luautils.stringStarts(object:getSprite():getName(), "roofs_04_") or
                        luautils.stringStarts(object:getSprite():getName(), "carpentry_02_58")) then
                    sq:transmitRemoveItemFromSquare(object)
                    break
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
                    break
                end

                if object:getClass() == BaseVehicle.class then
                    sq:transmitRemoveItemFromSquare(object)
                    break
                end

                if object:getClass() == IsoAnimal.class then
                    if object:getModData()["ApocVeg_Animal"] then
                        sq:transmitRemoveItemFromSquare(object)
                        break
                    end
                end

                if object:getClass() == IsoTree.class then
                    if object:getModData()["ApocVeg_Tree"] then
                        sq:transmitRemoveItemFromSquare(object)
                        break
                    end
                end

            end
        end

        for i=0,sq:getSpecialObjects():size()-1 do
            local object = sq:getSpecialObjects():get(i)

            if object then
                local modData = object:getModData()
                if modData and modData["ApocVeg_Cleanable"] then
                    local cleanableType = modData["ApocVeg_Cleanable"]
                    if command == "canBeRemoved" and cleanableType == "grass" then
                        sq:transmitRemoveItemFromSquare(object)
                        break
                    elseif command == "canBeCut" and (cleanableType == "bush" or cleanableType == "roof" or cleanableType == "wall" or cleanableType == "trash" or cleanableType == "vehicle" or cleanableType == "tree" or cleanableType == "barricade" or cleanableType == "fence" or cleanableType == "crack") then
                        sq:transmitRemoveItemFromSquare(object)
                        break
                    elseif command == "canBeCut" and cleanableType == "vine" then
                        sq:transmitRemoveItemFromSquare(object)
                        local neighbour = getCell():getGridSquare(sq:getX(), sq:getY(), sq:getZ() + 1)
                        if neighbour then
                            local neighbourObjs = neighbour:getObjects()
                            if neighbourObjs then
                                for j = neighbourObjs:size() - 1, 0, -1 do
                                    local neighbourObj = neighbourObjs:get(j)
                                    if neighbourObj then
                                        local neighbourModData = neighbourObj:getModData()
                                        if neighbourModData and neighbourModData["ApocVeg_Cleanable"] == "vine" then
                                            neighbour:transmitRemoveItemFromSquare(neighbourObj)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        break
                    end
                end

                local attached = object:getAttachedAnimSprite()
                if attached then
                    for n = attached:size()-1, 0, -1 do
                        local sprite = attached:get(n)
                        local parentSprite = sprite:getParentSprite()

                        if parentSprite and parentSprite:getProperties()
                                and parentSprite:getProperties():Is(IsoFlagType[command])
                                and (not luautils.stringStarts(parentSprite:getName(), "f_wallvines_")) then
                            object:RemoveAttachedAnim(n)
                            object:transmitUpdatedSpriteToClients()
                            break
                        end
                    end
                end

                if object:getSprite() and object:getSprite():getName()
                        and luautils.stringStarts(object:getSprite():getName(), "f_bushes_") then
                    sq:transmitRemoveItemFromSquare(object)
                    break
                end

                if object:getSprite() and object:getSprite():getName()
                        and (luautils.stringStarts(object:getSprite():getName(), "d_generic_")
                        or luautils.stringStarts(object:getSprite():getName(), "e_newgrass_")) then
                    sq:transmitRemoveItemFromSquare(object)
                    break
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
                    break
                end

                if object:getSprite() and object:getSprite():getName()
                        and luautils.stringStarts(object:getSprite():getName(), "trash_01_") then
                    sq:transmitRemoveItemFromSquare(object)
                    break
                end

                if object:getSprite() and object:getSprite():getName()
                        and (luautils.stringStarts(object:getSprite():getName(), "roofs_burnt_") or
                        luautils.stringStarts(object:getSprite():getName(), "roofs_03_") or
                        luautils.stringStarts(object:getSprite():getName(), "roofs_04_") or
                        luautils.stringStarts(object:getSprite():getName(), "carpentry_02_58")) then
                    sq:transmitRemoveItemFromSquare(object)
                    break
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
                    break
                end

                if object:getClass() == BaseVehicle.class then
                    sq:transmitRemoveItemFromSquare(object)
                    break
                end

                if object:getClass() == IsoAnimal.class then
                    if object:getModData()["ApocVeg_Animal"] then
                        sq:transmitRemoveItemFromSquare(object)
                        break
                    end
                end

                if object:getClass() == IsoTree.class then
                    if object:getModData()["ApocVeg_Tree"] then
                        sq:transmitRemoveItemFromSquare(object)
                        break
                    end
                end

            end
        end
    end
end
Events.OnClientCommand.Add(onRemovePlantCommand)
