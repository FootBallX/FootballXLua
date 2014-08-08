require "Cocos2d"
require "Cocos2dConstants"

local loginLayer = class("loginLayer",function()
    return cc.Scene:create()
end)

function loginLayer.create()
    local scene = loginLayer.new()
    scene:addChild(scene:createCCS("Login.json"))
    return scene
end


function loginLayer:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
end


function loginLayer:createCCS(filename)
    local node = ccs.NodeReader:getInstance():loadNodeWithFile(filename)
    return node
end


return loginLayer