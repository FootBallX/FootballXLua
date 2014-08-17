
Test = class("Test")

function Test:ctor()
    self.a = 9;
end

function Test:B()
    return self:A()
end


function Test:A()
    return self.a
end



return Test.new()
