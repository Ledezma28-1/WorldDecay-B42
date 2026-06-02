require('TimedActions/ISBaseTimedAction');

CleanVegAction = ISBaseTimedAction:derive("CleanVegAction");

function CleanVegAction:isValid()
    return true
end

function CleanVegAction:waitToStart()
    self.character:faceLocation(self.square:getX(), self.square:getY())
    return self.character:shouldBeTurning()
end

function CleanVegAction:update()
    self.character:faceLocation(self.square:getX(), self.square:getY())
    self.character:setMetabolicTarget(Metabolics.LightWork);end

function CleanVegAction:start()
    self:setActionAnim("RemoveGrass")
    self:setOverrideHandModels(nil, nil)
    self.square:playSound("RemovePlant");
    self.character:reportEvent("EventCleanVeg");
end

function CleanVegAction:stop()
    ISBaseTimedAction.stop(self);
end

function CleanVegAction:perform()
    local args = { x = self.square:getX(), y = self.square:getY(), z = self.square:getZ() }
    sendClientCommand(self.character, 'CleanVeg', 'CleanVegCommand', args)
    ISBaseTimedAction.perform(self);
end

function CleanVegAction:new(character, square, time)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.square = square;
    o.stopOnWalk = false;
    o.stopOnRun = true;
    o.maxTime = time;
    o.caloriesModifier = 10;
    if character:isTimedActionInstant() then
        o.maxTime = 1;
    end
    return o;
end
