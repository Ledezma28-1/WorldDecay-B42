local randomizer = newrandom()
randomizer:seed(ZombRand(1, 2147483647))

local WDecay_Fences = require('WDecay_Fences/WDecay_Fences')

local cachedFencePercentage = nil
local cachedFenceBreakChance = nil
local cachedFenceBendChance = nil
local cachedFenceDestroyWeight = nil
local cachedFenceBendSeverity = nil
local function getFencePercentage()
    if cachedFencePercentage == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.fencePercentage')
        cachedFencePercentage = opt and opt:getValue() or 20
    end
    return cachedFencePercentage
end
local function getFenceBreakChance()
    if cachedFenceBreakChance == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.fenceBreakChance')
        cachedFenceBreakChance = opt and opt:getValue() or 0
    end
    return cachedFenceBreakChance
end
local function getFenceBendChance()
    if cachedFenceBendChance == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.fenceBendChance')
        cachedFenceBendChance = opt and opt:getValue() or 0
    end
    return cachedFenceBendChance
end
local function getFenceDestroyWeight()
    if cachedFenceDestroyWeight == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.fenceDestroyWeight')
        cachedFenceDestroyWeight = opt and opt:getValue() or 20
    end
    return cachedFenceDestroyWeight
end
local function getFenceBendSeverity()
    if cachedFenceBendSeverity == nil then
        local opt = getSandboxOptions():getOptionByName('WDecay.fenceBendSeverity')
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
        if obj and WDecay_Fences.isFence(obj) then
            if not WDecay_Fences.isAlreadyDamaged(obj) then
                if WDecay_Fences.isBreakableFence(obj) then
                    local chance = getFenceBreakChance()
                    if chance > 0 and chance >= randomizer:random(1, 101) then
                        WDecay_Fences.applyBreakableFenceDamage(obj, getFenceDestroyWeight())
                        local objModData = obj:getModData()
                        if objModData and not objModData["WDecay_Cleanable"] then
                            objModData["WDecay_Cleanable"] = "fence"
                        end
                    end
                elseif WDecay_Fences.isBendableFence(obj) then
                    local chance = getFenceBendChance()
                    if chance > 0 and chance >= randomizer:random(1, 101) then
                        WDecay_Fences.applyBendableFenceDamage(obj, getFenceBendSeverity())
                        local objModData = obj:getModData()
                        if objModData and not objModData["WDecay_Cleanable"] then
                            objModData["WDecay_Cleanable"] = "fence"
                        end
                    end
                end
            end
        end
    end
end

if not WDecay_ModifierGenerators then WDecay_ModifierGenerators = {} end
table.insert(WDecay_ModifierGenerators, LoadGridsquare)

return WDecay_Fences
