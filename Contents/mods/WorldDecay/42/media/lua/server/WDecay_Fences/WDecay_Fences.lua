local randomizer = newrandom()
randomizer:seed(ZombRand(1, 2147483647))

local IS_COLLIDE_N = IsoFlagType.collideN
local IS_COLLIDE_W = IsoFlagType.collideW

local WDecay_Fences = {}

function WDecay_Fences.isBreakableFence(obj)
    if not obj then return false end

    return BrokenFences.getInstance():isBreakableObject(obj)
end

function WDecay_Fences.isBendableFence(obj)
    if not obj then return false end

    return BentFences.getInstance():isBendableFence(obj)
end

function WDecay_Fences.isFence(obj)
    if not obj then return false end

    return WDecay_Fences.isBreakableFence(obj) or WDecay_Fences.isBendableFence(obj)
end

function WDecay_Fences.isAlreadyDamaged(obj)
    if not obj then return false end

    local sprite = obj:getSprite()
    if not sprite then return false end

    local spriteName = sprite:getName()
    if not spriteName then return false end

    return luautils.stringStarts(spriteName, "fencing_damaged_")
end

function WDecay_Fences.determineDirection(obj)
    if not obj then return nil end

    local sprite = obj:getSprite()
    if not sprite then return nil end

    local properties = sprite:getProperties()
    if not properties then return nil end

    if properties:has(IS_COLLIDE_N) then
        if randomizer:random(0, 2) == 0 then
            return IsoDirections.N
        else
            return IsoDirections.S
        end
    elseif properties:has(IS_COLLIDE_W) then
        if randomizer:random(0, 2) == 0 then
            return IsoDirections.W
        else
            return IsoDirections.E
        end
    end

    return nil
end

function WDecay_Fences.getRandomStage(severity)
    severity = severity or 4
    if severity == 1 then
        return 1
    elseif severity == 2 then
        return 2
    elseif severity == 3 then
        return 3
    else
        local roll = randomizer:random(0, 100)
        if roll < 33 then
            return 1
        elseif roll < 66 then
            return 2
        else
            return 3
        end
    end
end

function WDecay_Fences.applyBreakableFenceDamage(obj, destroyWeight)
    if not obj then return false end

    local dir = WDecay_Fences.determineDirection(obj)
    if not dir then return false end

    destroyWeight = destroyWeight or 20
    local roll = randomizer:random(0, 100)
    if roll < destroyWeight then
        BrokenFences.getInstance():destroyFence(obj, dir)
        local function tagFenceDebris(sq)
            if not sq then return end

            local objs = sq:getObjects()
            if objs then
                for i = 0, objs:size() - 1 do
                    local o = objs:get(i)
                    if o and o:getSprite() and o:getSprite():getName() then
                        local name = o:getSprite():getName()
                        if luautils.stringStarts(name, "fencing_damaged_") or
                            luautils.stringStarts(name, "carpentry_02_") then
                            local md = o:getModData()
                            if md and not md["WDecay_Cleanable"] then
                                md["WDecay_Cleanable"] = "fence"
                            end
                        end
                    end
                end
            end
        end

        local cell = getCell()
        local sq = obj:getSquare()
        local sx, sy, sz = sq:getX(), sq:getY(), sq:getZ()
        tagFenceDebris(sq)
        tagFenceDebris(cell:getGridSquare(sx + 1, sy, sz))
        tagFenceDebris(cell:getGridSquare(sx - 1, sy, sz))
        tagFenceDebris(cell:getGridSquare(sx, sy + 1, sz))
        tagFenceDebris(cell:getGridSquare(sx, sy - 1, sz))
    else
        local damageRoll = randomizer:random(0, 100)
        if damageRoll < 50 then
            BrokenFences.getInstance():updateSprite(obj, true, false)
        else
            BrokenFences.getInstance():updateSprite(obj, false, true)
        end
    end

    return true
end

function WDecay_Fences.applyBendableFenceDamage(obj, severity)
    if not obj then return false end

    local dir = WDecay_Fences.determineDirection(obj)
    if not dir then return false end

    local stage = WDecay_Fences.getRandomStage(severity)

    BentFences.getInstance():swapTiles(obj, dir, true, stage)
    local sq = obj:getSquare()
    if sq then
        local objs = sq:getObjects()
        if objs then
            for i = 0, objs:size() - 1 do
                local o = objs:get(i)
                if o and o:getSprite() and o:getSprite():getName() and
                    luautils.stringStarts(o:getSprite():getName(), "fencing_damaged_") then
                    local md = o:getModData()
                    if md and not md["WDecay_Cleanable"] then
                        md["WDecay_Cleanable"] = "fence"
                    end
                end
            end
        end
    end

    return true
end

return WDecay_Fences
