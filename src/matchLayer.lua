require "Cocos2d"
require "Cocos2dConstants"
require "constVar"
require "GameDatas"


local pomelo = PomeloClient:getInstance()

local STATES = {
    NONE = 0,
}

local state = STATES.NONE

local cclog = function(...)
    print(string.format(...))
end

local matchLayer = class("matchLayer",function()
    return cc.Scene:create()
end)

function matchLayer.create()
    local scene = matchLayer.new()
    scene:init()
    scene:createLayer()
    return scene
end


function matchLayer:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
    self.labelInfo = nil
    self.buttonReady = nil
end

function matchLayer:init()
    local function update(dt)
    end

    local function netHandler(event, msg)
    --        if (event == constVar.Event.leagueSignUp) then
    --        elseif (event == constVar.Event.lobbyOnPair) then
    --        end
    end

    local function onNodeEvent(event)
        if "exit" == event then
            --            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
            self:unregisterScriptHandler()
        end
    end

    --    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0.5, false)
    pomelo:registerScriptHandler(netHandler)
    self:registerScriptHandler(onNodeEvent)

    --pomelo:addListener(constVar.Event.lobbyOnPair)
end

function matchLayer:createLayer()
    local pitch = cc.Sprite:create("Pitch/pitch.png")
    self:addChild(pitch)
end

return matchLayer


