require "BuildingObjects/ISRemovePlantCursor"

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

local ISRemovePlantCursor_getRemovableObject = ISRemovePlantCursor.getRemovableObject
function ISRemovePlantCursor:getRemovableObject(square)
    local vanillaPass = ISRemovePlantCursor_getRemovableObject(self, square)
    if vanillaPass then
        return vanillaPass
    end

    local function findRemovableInList(objects)
        if not objects then return nil end
        cleanLog("getRemovableObject scanning " .. objects:size() .. " objects, removeType=" .. tostring(self.removeType))
        for i=1,objects:size() do
            local object = objects:get(i-1)

            local modData = object:getModData()
            if modData and modData["WDecay_Cleanable"] then
                local cleanableType = modData["WDecay_Cleanable"]
                if self.removeType == "grass" and cleanableType == "grass" then
                    cleanLog("getRemovableObject MATCH grass modData, sprite=" .. tostring(object:getSprite():getName()) .. " at " .. square:getX() .. "," .. square:getY() .. "," .. square:getZ())
                    return object
                elseif self.removeType == "bush" and (cleanableType == "bush" or cleanableType == "trash") then
                    cleanLog("getRemovableObject MATCH bush/trash modData, sprite=" .. tostring(object:getSprite():getName()) .. " at " .. square:getX() .. "," .. square:getY() .. "," .. square:getZ())
                    return object
                elseif self.removeType == "wallVine" and cleanableType == "vine" then
                    cleanLog("getRemovableObject MATCH vine modData, sprite=" .. tostring(object:getSprite():getName()) .. " at " .. square:getX() .. "," .. square:getY() .. "," .. square:getZ())
                    return object
                end
            end

            local attached = object:getAttachedAnimSprite()
            if attached then
                for n=0,attached:size()-1 do
                    local sprite = attached:get(n)
                    local parentSprite = sprite:getParentSprite()

                    if self.removeType == "bush" and parentSprite and parentSprite:getProperties()
                            and parentSprite:getProperties():has(IsoFlagType.canBeCut) then
                        cleanLog("getRemovableObject MATCH bush attached anim, parent=" .. tostring(parentSprite:getName()) .. " at " .. square:getX() .. "," .. square:getY() .. "," .. square:getZ())
                        return object
                    end

                    if self.removeType == "grass" and parentSprite then
                        local props = parentSprite:getProperties()
                        local hasFlag = false
                        if props and IsoFlagType.canBeRemoved then
                            hasFlag = props:has(IsoFlagType.canBeRemoved)
                        end
                        if hasFlag and (not luautils.stringStarts(parentSprite:getName(), "f_wallvines_")) then
                            cleanLog("getRemovableObject MATCH grass attached anim, parent=" .. tostring(parentSprite:getName()) .. " at " .. square:getX() .. "," .. square:getY() .. "," .. square:getZ())
                            return object
                        end
                    end
                end
            end

            if self.removeType == "grass" and object:getSprite() and object:getSprite():getName()
                    and (luautils.stringStarts(object:getSprite():getName(), "d_generic_")
                    or luautils.stringStarts(object:getSprite():getName(), "e_newgrass_")) then
                cleanLog("getRemovableObject MATCH grass sprite, sprite=" .. tostring(object:getSprite():getName()) .. " at " .. square:getX() .. "," .. square:getY() .. "," .. square:getZ())
                return object
            end

            if self.removeType == "wallVine" and object:getSprite() and object:getSprite():getName()
                    and luautils.stringStarts(object:getSprite():getName(), "f_wallvines_") then
                cleanLog("getRemovableObject MATCH wallVine sprite, sprite=" .. tostring(object:getSprite():getName()) .. " at " .. square:getX() .. "," .. square:getY() .. "," .. square:getZ())
                return object
            end

            if self.removeType == "bush" and object:getSprite() and object:getSprite():getName()
                    and luautils.stringStarts(object:getSprite():getName(), "trash_01_") then
                cleanLog("getRemovableObject MATCH trash sprite, sprite=" .. tostring(object:getSprite():getName()) .. " at " .. square:getX() .. "," .. square:getY() .. "," .. square:getZ())
                return object
            end



            if self.removeType == "bush" and object:getSprite() and object:getSprite():getName()
                    and luautils.stringStarts(object:getSprite():getName(), "f_bushes_") then
                cleanLog("getRemovableObject MATCH bush sprite, sprite=" .. tostring(object:getSprite():getName()) .. " at " .. square:getX() .. "," .. square:getY() .. "," .. square:getZ())
                return object
            end
        end
        cleanLog("getRemovableObject NO MATCH in " .. objects:size() .. " objects, removeType=" .. tostring(self.removeType))
        return nil
    end

    return findRemovableInList(square:getObjects()) or findRemovableInList(square:getSpecialObjects())
end


local function onRemovePlantCommand(module, command, player, args)
    if module == "onRemovePlant" then

        if not IsoFlagType[command] then return end

        local sq = getCell():getGridSquare(args.x, args.y, args.z)
        if not sq then return end

        cleanLog("onRemovePlantCommand command=" .. tostring(command) .. " at " .. args.x .. "," .. args.y .. "," .. args.z)

        for i=0,sq:getObjects():size()-1 do
            local object = sq:getObjects():get(i)

            if object then
                local modData = object:getModData()
                if modData and modData["WDecay_Cleanable"] then
                    local cleanableType = modData["WDecay_Cleanable"]
                    if command == "canBeRemoved" and cleanableType == "grass" then
                        cleanLog("onRemovePlantCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=" .. tostring(cleanableType) .. " at " .. args.x .. "," .. args.y .. "," .. args.z)
                        sq:transmitRemoveItemFromSquare(object)
                        break
                    elseif command == "canBeCut" and (cleanableType == "bush" or cleanableType == "trash") then
                        cleanLog("onRemovePlantCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=" .. tostring(cleanableType) .. " at " .. args.x .. "," .. args.y .. "," .. args.z)
                        sq:transmitRemoveItemFromSquare(object)
                        break
                    elseif command == "canBeCut" and cleanableType == "vine" then
                        cleanLog("onRemovePlantCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=" .. tostring(cleanableType) .. " at " .. args.x .. "," .. args.y .. "," .. args.z)
                        sq:transmitRemoveItemFromSquare(object)
                        local neighbour = getCell():getGridSquare(sq:getX(), sq:getY(), sq:getZ() + 1)
                        if neighbour then
                            local neighbourObjs = neighbour:getObjects()
                            if neighbourObjs then
                                for j = neighbourObjs:size() - 1, 0, -1 do
                                    local neighbourObj = neighbourObjs:get(j)
                                    if neighbourObj then
                                        local neighbourModData = neighbourObj:getModData()
                                        if neighbourModData and neighbourModData["WDecay_Cleanable"] == "vine" then
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
                                and parentSprite:getProperties():has(IsoFlagType[command])
                                and (not luautils.stringStarts(parentSprite:getName(), "f_wallvines_")) then
                            cleanLog("onRemovePlantCommand REMOVED attached anim " .. tostring(parentSprite:getName()) .. " from " .. tostring(object:getSprite():getName()))
                            object:RemoveAttachedAnim(n)
                            object:transmitUpdatedSpriteToClients()
                            break
                        end
                    end
                end

                if object:getSprite() and object:getSprite():getName()
                        and luautils.stringStarts(object:getSprite():getName(), "f_bushes_") then
                    cleanLog("onRemovePlantCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=bush at " .. args.x .. "," .. args.y .. "," .. args.z)
                    sq:transmitRemoveItemFromSquare(object)
                    break
                end

                if object:getSprite() and object:getSprite():getName()
                        and (luautils.stringStarts(object:getSprite():getName(), "d_generic_")
                        or luautils.stringStarts(object:getSprite():getName(), "e_newgrass_")) then
                    cleanLog("onRemovePlantCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=grass at " .. args.x .. "," .. args.y .. "," .. args.z)
                    sq:transmitRemoveItemFromSquare(object)
                    break
                end

                if object:getSprite() and object:getSprite():getName()
                        and luautils.stringStarts(object:getSprite():getName(), "f_wallvines_") then
                    cleanLog("onRemovePlantCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=wallVine at " .. args.x .. "," .. args.y .. "," .. args.z)
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
                    cleanLog("onRemovePlantCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=trash at " .. args.x .. "," .. args.y .. "," .. args.z)
                    sq:transmitRemoveItemFromSquare(object)
                    break
                end

            end
        end

        for i=0,sq:getSpecialObjects():size()-1 do
            local object = sq:getSpecialObjects():get(i)

            if object then
                local modData = object:getModData()
                if modData and modData["WDecay_Cleanable"] then
                    local cleanableType = modData["WDecay_Cleanable"]
                    if command == "canBeRemoved" and cleanableType == "grass" then
                        cleanLog("onRemovePlantCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=" .. tostring(cleanableType) .. " at " .. args.x .. "," .. args.y .. "," .. args.z)
                        sq:transmitRemoveItemFromSquare(object)
                        break
                    elseif command == "canBeCut" and (cleanableType == "bush" or cleanableType == "trash") then
                        cleanLog("onRemovePlantCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=" .. tostring(cleanableType) .. " at " .. args.x .. "," .. args.y .. "," .. args.z)
                        sq:transmitRemoveItemFromSquare(object)
                        break
                    elseif command == "canBeCut" and cleanableType == "vine" then
                        cleanLog("onRemovePlantCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=" .. tostring(cleanableType) .. " at " .. args.x .. "," .. args.y .. "," .. args.z)
                        sq:transmitRemoveItemFromSquare(object)
                        local neighbour = getCell():getGridSquare(sq:getX(), sq:getY(), sq:getZ() + 1)
                        if neighbour then
                            local neighbourObjs = neighbour:getObjects()
                            if neighbourObjs then
                                for j = neighbourObjs:size() - 1, 0, -1 do
                                    local neighbourObj = neighbourObjs:get(j)
                                    if neighbourObj then
                                        local neighbourModData = neighbourObj:getModData()
                                        if neighbourModData and neighbourModData["WDecay_Cleanable"] == "vine" then
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
                                and parentSprite:getProperties():has(IsoFlagType[command])
                                and (not luautils.stringStarts(parentSprite:getName(), "f_wallvines_")) then
                            cleanLog("onRemovePlantCommand REMOVED attached anim " .. tostring(parentSprite:getName()) .. " from " .. tostring(object:getSprite():getName()))
                            object:RemoveAttachedAnim(n)
                            object:transmitUpdatedSpriteToClients()
                            break
                        end
                    end
                end

                if object:getSprite() and object:getSprite():getName()
                        and luautils.stringStarts(object:getSprite():getName(), "f_bushes_") then
                    cleanLog("onRemovePlantCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=bush at " .. args.x .. "," .. args.y .. "," .. args.z)
                    sq:transmitRemoveItemFromSquare(object)
                    break
                end

                if object:getSprite() and object:getSprite():getName()
                        and (luautils.stringStarts(object:getSprite():getName(), "d_generic_")
                        or luautils.stringStarts(object:getSprite():getName(), "e_newgrass_")) then
                    cleanLog("onRemovePlantCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=grass at " .. args.x .. "," .. args.y .. "," .. args.z)
                    sq:transmitRemoveItemFromSquare(object)
                    break
                end

                if object:getSprite() and object:getSprite():getName()
                        and luautils.stringStarts(object:getSprite():getName(), "f_wallvines_") then
                    cleanLog("onRemovePlantCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=wallVine at " .. args.x .. "," .. args.y .. "," .. args.z)
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
                    cleanLog("onRemovePlantCommand REMOVED " .. tostring(object:getSprite():getName()) .. " type=trash at " .. args.x .. "," .. args.y .. "," .. args.z)
                    sq:transmitRemoveItemFromSquare(object)
                    break
                end

            end
        end

        cleanLog("onRemovePlantCommand DONE at " .. args.x .. "," .. args.y .. "," .. args.z)
    end
end
Events.OnClientCommand.Add(onRemovePlantCommand)
