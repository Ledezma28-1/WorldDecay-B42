local Tiles = require("WDecay_Overlays/Data/Tiles")
local Sprites = require("WDecay_Overlays/Data/Sprites")

local randomizer = newrandom()
randomizer:seed(ZombRand(1, 2147483647))

local sandboxCache = {}
local function sb(key, fallback)
    if sandboxCache[key] == nil then
        local s = getSandboxOptions()
        if not s then sandboxCache[key] = fallback
        else
            local o = s:getOptionByName('WDecay.' .. key)
            local v = o and o:getValue()
            sandboxCache[key] = v ~= nil and v or fallback
        end
    end
    return sandboxCache[key]
end

local OVERLAY_DENSITY = 60

local function computeChance(intensity)
    local c = math.ceil(OVERLAY_DENSITY / intensity)
    return math.max(1, c)
end

local function mixSprites(list, target, intensity)
    if intensity <= 0 or #list == 0 then return end
    for i = 1, intensity do
        target[#target + 1] = list[randomizer:random(1, #list + 1)]
    end
end

local function registerTileOverlays()
    if TILEZED then return end

    local gNat = sb('grassPercentage', 30)
    local gRoad = sb('grassPercentageOnRoad', 20)
    local cNat = sb('customGrassPercentage', 10)
    local cRoad = sb('customGrassPercentageOnRoad', 10)
    local dNat = sb('dryGrassPercentage', 15)
    local dRoad = sb('dryGrassPercentageOnRoad', 10)
    local lNat = sb('floorLeavesPercentage', 10)
    local lRoad = sb('floorLeavesPercentageOnRoad', 5)
    local bNat = sb('groundDebrisPercentage', 15)
    local bRoad = sb('groundDebrisPercentageOnRoad', 8)
    local trash = sb('trashPercentage', 8)
    local crack = sb('roadCrackOverlayPercentage', 10)

    local registry = {}

    for _, tile in ipairs(Tiles.natural) do
        local pool = {}
        mixSprites(Sprites.vanilla, pool, gNat)
        mixSprites(Sprites.custom, pool, cNat)
        mixSprites(Sprites.dry, pool, dNat)
        mixSprites(Sprites.leaves, pool, lNat)
        mixSprites(Sprites.debris, pool, bNat)
        local top = math.max(gNat, cNat, dNat, lNat, bNat)
        if #pool > 0 and top > 0 then
            registry[tile] = {{ name = "other", chance = computeChance(top), usage = "", tiles = pool }}
        end
    end

    for _, tile in ipairs(Tiles.road) do
        local pool = {}
        mixSprites(Sprites.vanilla, pool, gRoad)
        mixSprites(Sprites.custom, pool, cRoad)
        mixSprites(Sprites.dry, pool, dRoad)
        mixSprites(Sprites.leaves, pool, lRoad)
        mixSprites(Sprites.debris, pool, bRoad)
        mixSprites(Sprites.trash, pool, trash)
        mixSprites(Sprites.crack, pool, crack)
        local top = math.max(gRoad, cRoad, dRoad, lRoad, bRoad, trash, crack)
        if #pool > 0 and top > 0 then
            registry[tile] = {{ name = "other", chance = computeChance(top), usage = "", tiles = pool }}
        end
    end

    getTileOverlays():addOverlays(registry)
end

registerTileOverlays()

Events.OnInitGlobalModData.Add(function(isNewGame)
    sandboxCache = {}
    registerTileOverlays()
end)
