local WDecay_Barricades = require('WDecay_Barricades/WDecay_Barricades')
local WDecay_SquareCheck = require('wdecay_squarecheck/wdecay_squarecheck')

local randomizer = newrandom()
randomizer:seed(ZombRand(1, 2147483647) )

local cachedBarricadePercentage = nil
local function getBarricadePercentage()
    if cachedBarricadePercentage == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.barricadePercentage')
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
            
            if WDecay_Barricades.isWindow(obj) then
                isBarricadableObject = true
                isExterior = true
            elseif WDecay_Barricades.isDoor(obj) then
                if WDecay_Barricades.isExteriorDoor(obj) and WDecay_Barricades.canBarricadeDoor(obj) then
                    isBarricadableObject = true
                    isExterior = true
                end
            end
            
            if isBarricadableObject and isExterior then
                if not WDecay_Barricades.hasBarricade(obj) then
                    if getBarricadePercentage() >= randomizer:random(1, 101) then
                        local barricadeType = WDecay_Barricades.getRandomBarricadeType()
                        local healthLevel = WDecay_Barricades.getRandomHealthLevel()

                        if barricadeType and healthLevel then
                            local success = false
                            local barricade = IsoBarricade.AddBarricadeToObject(obj, false)

                            if barricade then
                                if barricadeType == "wood" then
                                    local numPlanks = randomizer:random(1, 5)
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
                                    barricadeModData["WDecay_Barricade"] = true
                                    barricadeModData["WDecay_Cleanable"] = "barricade"
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

if not WDecay_ModifierGenerators then WDecay_ModifierGenerators = {} end
table.insert(WDecay_ModifierGenerators, LoadGridsquare)

return WDecay_Barricades
