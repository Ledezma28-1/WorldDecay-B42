local ApocVeg_Stories = require('ApocVeg_Stories/ApocVeg_Stories')
local ApocVeg_SquareCheck = require('apocveg_squarecheck/apocveg_squarecheck')

local cachedStoriesRarity = nil
local function getStoriesRarity()
    if cachedStoriesRarity == nil then
        local opt = getSandboxOptions():getOptionByName('ApocVeg.storiesRarity')
        cachedStoriesRarity = opt and opt:getValue() or 2
    end
    return cachedStoriesRarity
end

local storiesChance = {
    [1] = 0,      
    [2] = 10000,  
    [3] = 5000,   
    [4] = 2000,   
    [5] = 1000,   
}

local function LoadGridsquare(square, checkResult)
    return
end

return ApocVeg_Stories
