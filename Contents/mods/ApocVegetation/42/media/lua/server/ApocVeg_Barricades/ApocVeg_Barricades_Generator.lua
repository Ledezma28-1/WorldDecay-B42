local ApocVeg_Barricades = require('ApocVeg_Barricades/ApocVeg_Barricades')
local ApocVeg_SquareCheck = require('apocveg_squarecheck/apocveg_squarecheck')

local cachedBarricadePercentage = nil
local function getBarricadePercentage()
    if cachedBarricadePercentage == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.barricadePercentage')
        cachedBarricadePercentage = opt and opt:getValue() or 30
    end
    return cachedBarricadePercentage
end

local function LoadGridsquare(square, checkResult)
    if not square then return end
    if not checkResult then return end
    if checkResult.water then return end
    if not checkResult.hasFloor then return end
    if not checkResult.hasWalls and not checkResult.hasWindows then return end
    
    if square:getZ() ~= 0 then return end

    local objects = checkResult.objects
    if not objects then return end
    if not objects or objects:size() == 0 then return end

    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        if not obj then
        else
            local isBarricadableObject = false
            local isExterior = false
            
            if ApocVeg_Barricades.isWindow(obj) then
                isBarricadableObject = true
                isExterior = true
            elseif ApocVeg_Barricades.isDoor(obj) then
                if ApocVeg_Barricades.isExteriorDoor(obj) and ApocVeg_Barricades.canBarricadeDoor(obj) then
                    isBarricadableObject = true
                    isExterior = true
                end
            end
            
            if isBarricadableObject and isExterior then
                if not ApocVeg_Barricades.hasBarricade(obj) then
                    if getBarricadePercentage() >= ZombRand(1, 101) then
                        local barricadeType = ApocVeg_Barricades.getRandomBarricadeType()
                        local healthLevel = ApocVeg_Barricades.getRandomHealthLevel()

                        if barricadeType and healthLevel then
                            local success = false
                            local barricade = IsoBarricade.AddBarricadeToObject(obj, false)

                            if barricade then
                                if barricadeType == "wood" then
                                    local numPlanks = ZombRand(1, 5)
                                    for i = 1, numPlanks do
                                        if barricade:canAddPlank() then
                                            barricade:addPlank(nil, nil)
                                        end
                                    end
                                elseif barricadeType == "metal" then
                                    barricade:addMetal(nil, nil)
                                end

                                local barricadeModData = barricade:getModData()
                                if barricadeModData then
                                    barricadeModData["ApocVeg_Barricade"] = true
                                    barricadeModData["ApocVeg_Cleanable"] = "barricade"
                                end

                                barricade:setHealth(healthLevel)
                                barricade:transmitCompleteItemToClients()
                                success = true
                            end

                        end
                    end
                end
            end
        end
    end
end

if not ApocVeg_ModifierGenerators then ApocVeg_ModifierGenerators = {} end
table.insert(ApocVeg_ModifierGenerators, LoadGridsquare)

return ApocVeg_Barricades
