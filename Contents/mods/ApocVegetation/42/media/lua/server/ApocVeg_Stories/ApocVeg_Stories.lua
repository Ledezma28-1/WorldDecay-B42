local ApocVeg_Stories = {}

ApocVeg_Stories.storyIndices = {
    14,
    13,
    4,
    19,
    38,
    28,
    32,
    27,
    29,
    16
}

function ApocVeg_Stories.getRandomStoryIndex()
    if #ApocVeg_Stories.storyIndices == 0 then
        return nil
    end
    return ApocVeg_Stories.storyIndices[ZombRand(1, #ApocVeg_Stories.storyIndices + 1)]
end

function ApocVeg_Stories.getStoryDefinition(index)
    local randomZoneList = getWorld():getRandomizedZoneList()
    if randomZoneList and index then
        return randomZoneList:get(index)
    end
    return nil
end

function ApocVeg_Stories.isValidIndex(index)
    if not index then return false end
    for i = 1, #ApocVeg_Stories.storyIndices do
        if ApocVeg_Stories.storyIndices[i] == index then
            return true
        end
    end
    return false
end

function ApocVeg_Stories.getMinimumWidth(storyDef)
    if storyDef then
        return storyDef:getMinimumWidth()
    end
    return 0
end

function ApocVeg_Stories.getMinimumHeight(storyDef)
    if storyDef then
        return storyDef:getMinimumHeight()
    end
    return 0
end

function ApocVeg_Stories.randomizeZoneStory(storyDef, zone)
    if storyDef and zone then
        storyDef:randomizeZoneStory(zone)
    end
end

return ApocVeg_Stories
