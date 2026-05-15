local ApocVeg_Vehicles = require('ApocVeg_Vehicles/ApocVeg_Vehicles')
local ApocVeg_SquareCheck = require('apocveg_squarecheck/apocveg_squarecheck')

local cachedVehicleRarity = nil
local function getVehicleRarity()
    if cachedVehicleRarity == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.vehicleRarity')
        cachedVehicleRarity = opt and opt:getValue() or 2
    end
    return cachedVehicleRarity
end

local vehicleChance = {
    [1] = 0,      
    [2] = 5000,   
    [3] = 2000,   
    [4] = 1000,   
    [5] = 500,    
}

local function LoadGridsquare(square, checkResult)
    if not square then return end
    if not checkResult then return end
    if not checkResult.passed then return end
    if not checkResult.objects then return end
    if checkResult.water then return end
    if not checkResult.isRoad then return end
    
    if square:getZ() ~= 0 then return end
    
    local chance = vehicleChance[getVehicleRarity()] or 0
    if chance > 0 and ZombRand(1, chance) == 1 then
        local randomVehicle = ApocVeg_Vehicles.getRandomVehicle()
        local randomDirection = ApocVeg_Vehicles.getRandomDirection()
        
        if randomVehicle and randomDirection then
            local vehicle = addVehicleDebug(
                tostring(randomVehicle),
                IsoDirections[randomDirection],
                nil,
                square
            )
            
            if vehicle then
                vehicle:setRust(1.0)

                for i = 1, #ApocVeg_Vehicles.vehicleSide do
                    local side = ApocVeg_Vehicles.vehicleSide[i]
                    vehicle:setBloodIntensity(side, ZombRand(0, 101) / 100.0)
                end

                local vehicleModData = vehicle:getModData()
                if vehicleModData then
                    vehicleModData["ApocVeg_Cleanable"] = "vehicle"
                end

                vehicle:transmitCompleteItemToClients()
                return true
            end
        end
    end
    return false
end

if not ApocVeg_PlacementGenerators then ApocVeg_PlacementGenerators = {} end
table.insert(ApocVeg_PlacementGenerators, LoadGridsquare)

return ApocVeg_Vehicles
