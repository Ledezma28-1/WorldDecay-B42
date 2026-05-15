local ApocVeg_Fences = require('ApocVeg_Fences/ApocVeg_Fences')

local cachedFencePercentage = nil
local cachedFenceBreakChance = nil
local cachedFenceBendChance = nil
local cachedFenceDestroyWeight = nil
local cachedFenceBendSeverity = nil
local function getFencePercentage()
    if cachedFencePercentage == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.fencePercentage')
        cachedFencePercentage = opt and opt:getValue() or 20
    end
    return cachedFencePercentage
end
local function getFenceBreakChance()
    if cachedFenceBreakChance == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.fenceBreakChance')
        cachedFenceBreakChance = opt and opt:getValue() or 0
    end
    return cachedFenceBreakChance
end
local function getFenceBendChance()
    if cachedFenceBendChance == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.fenceBendChance')
        cachedFenceBendChance = opt and opt:getValue() or 0
    end
    return cachedFenceBendChance
end
local function getFenceDestroyWeight()
    if cachedFenceDestroyWeight == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.fenceDestroyWeight')
        cachedFenceDestroyWeight = opt and opt:getValue() or 20
    end
    return cachedFenceDestroyWeight
end
local function getFenceBendSeverity()
    if cachedFenceBendSeverity == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.fenceBendSeverity')
        cachedFenceBendSeverity = opt and opt:getValue() or 4
    end
    return cachedFenceBendSeverity
end

local function LoadGridsquare(square, checkResult)
    if not square then return end
    if not checkResult then return end
    if not checkResult.hasFences then return end
    if square:getZ() ~= 0 then return end

    local objects = checkResult.objects
    if not objects then return end
    if not objects or objects:size() == 0 then return end

    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        if obj and ApocVeg_Fences.isFence(obj) then
            if not ApocVeg_Fences.isAlreadyDamaged(obj) then
                if ApocVeg_Fences.isBreakableFence(obj) then
                    local chance = getFenceBreakChance()
                    if chance > 0 and chance >= ZombRand(1, 101) then
                        ApocVeg_Fences.applyBreakableFenceDamage(obj, getFenceDestroyWeight())
                        local objModData = obj:getModData()
                        if objModData and not objModData["ApocVeg_Cleanable"] then
                            objModData["ApocVeg_Cleanable"] = "fence"
                        end
                    end
                elseif ApocVeg_Fences.isBendableFence(obj) then
                    local chance = getFenceBendChance()
                    if chance > 0 and chance >= ZombRand(1, 101) then
                        ApocVeg_Fences.applyBendableFenceDamage(obj, getFenceBendSeverity())
                        local objModData = obj:getModData()
                        if objModData and not objModData["ApocVeg_Cleanable"] then
                            objModData["ApocVeg_Cleanable"] = "fence"
                        end
                    end
                end
            end
        end
    end
end

if not ApocVeg_ModifierGenerators then ApocVeg_ModifierGenerators = {} end
table.insert(ApocVeg_ModifierGenerators, LoadGridsquare)

return ApocVeg_Fences
