require"GamePlay.MatchDefs"

local MD = MatchDefs;

Test = class("Test")

function Test:ctor()
    self.a = 9;
end

function Test:B()
    return self:A()
end


function Test:A()
    return MD.FORMATION;
end



return Test.new()
