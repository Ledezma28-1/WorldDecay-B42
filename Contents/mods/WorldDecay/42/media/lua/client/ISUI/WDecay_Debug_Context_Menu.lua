local isDebug = isDebugEnabled()

WD_DebugTools = require("Debug/WD_DebugTools")

local DEBUG_TOOLS = "#### - Debug Tools - ####"
local GENERATE_SQUARE = "Generate Square"
local PRINT_CHECKRESULT = "Print Checkresult"
local STFU_OBJECT_BUFFER = "STFU Object-Buffer!"

local function onSelectSquare(worldobjects, square, playerId, selectionFlag)
    if selectionFlag == WD_DebugTools.FLAG_STFU_OBJECT_BUFFER then
        WD_DebugTools.disableObjectBufferLog()
    else
        local debugCursor = DebugCursor:new(playerId, selectionFlag)
        getCell():setDrag(debugCursor, playerId)
    end
end

local function addSquareGenCheck(player, context, worldobjects)
    print("TEST")

    if worldobjects then
        local size = #worldobjects
        local object = nil
        local square = nil

        for i = 1, size do
            object = worldobjects[i]
            if object then
                square = object:getSquare()

                if square then
                    break
                end
            end
        end

        if square then
            local subMenuOption = context:addOption(DEBUG_TOOLS)
            local subMenu = ISContextMenu:getNew(context)
            context:addSubMenu(subMenuOption, subMenu)
            subMenu:addOption(GENERATE_SQUARE, worldobjects, onSelectSquare, square, player, WD_DebugTools.FLAG_GENERATE_SQUARE)
            subMenu:addOption(PRINT_CHECKRESULT, worldobjects, onSelectSquare, square, player, WD_DebugTools.FLAG_PRINT_CHECKRESULT)
            subMenu:addOption(STFU_OBJECT_BUFFER, worldobjects, onSelectSquare, square, player, WD_DebugTools.FLAG_STFU_OBJECT_BUFFER)
        end
    end
end

local function initDebugContext()
    if isDebug then
        Events.OnFillWorldObjectContextMenu.Add(addSquareGenCheck)
    end
end

initDebugContext()
