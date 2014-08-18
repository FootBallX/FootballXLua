
Test = class("Test")

function Test:ctor()
    self.a = 9;
end

function Test:B()
    return self:A()
end


function Test:A()
    return false and 1 or 2;
end



return Test.new()
