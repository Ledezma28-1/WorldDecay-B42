local WDecay_Vehicles = require('WDecay_Vehicles/WDecay_Vehicles')

local cachedVehicleDecayEnabled = nil
local function isVehicleDecayEnabled()
    if cachedVehicleDecayEnabled == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.vehicleDecayEnabled')
        cachedVehicleDecayEnabled = opt and opt:getValue()
        if cachedVehicleDecayEnabled == nil then cachedVehicleDecayEnabled = true end
    end

    return cachedVehicleDecayEnabled
end

Events.OnSpawnVehicleEnd.Add(function(vehicle)
    if isVehicleDecayEnabled() then
        local modData = vehicle:getModData()
        if not modData["WDecay_Processed"] then
            WDecay_Vehicles.applyDeterioration(vehicle)
            modData["WDecay_Processed"] = true
        end
    end
end)

return WDecay_Vehicles
