require "Cocos2d"
require "Cocos2dConstants"
require "Common"
require "constVar"
require "GameDatas"

local pomelo = PomeloClient:getInstance()

local STATES = {
    NONE = 0,
}

local state = STATES.NONE


local lobbyLayer = class("lobbyLayer",function()
    return cc.Scene:create()
end)

function lobbyLayer.create()
    local scene = lobbyLayer.new()
    scene:init()
    scene:addChild(scene:createCCS("LobbyLayer.json"))
    return scene
end


function lobbyLayer:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
    self.labelInfo = nil
    self.buttonReady = nil
end

function lobbyLayer:init()
    local function update(dt)
    end

    local function netHandler(event, msg)
        if (event == constVar.Event.leagueSignUp) then
            local msgJson = json.decode(msg)
            if (msgJson.code == constVar.PomeloCode.OK) then
                self.labelInfo:setString("lobbyInQueue")
                self.buttonReady:setVisible(false)
            else
                cclog("sign up failed!")
            end
        elseif (event == constVar.Event.lobbyOnPair) then
        end
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
    
    pomelo:addListener(constVar.Event.lobbyOnPair)
end

function lobbyLayer:createCCS(filename)
    local node = ccs.NodeReader:getInstance():loadNodeWithFile(filename)
    local btnReady = node:getChildByName("Button_Ready")
    local btnQuit = node:getChildByName("Button_Quit")
    self.labelInfo = node:getChildByName("Label_Info")
    self.buttonReady = btnReady
    local function onReadyClicked(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            pomelo:request(constVar.Event.leagueSignUp, "")
        end
    end
    
    local function onQuitClicked(sender, eventType)
        if (eventType == ccui.TouchEventType.ended) then
            local scene = require("loginLayer")
            local gameScene = scene.create()
            if cc.Director:getInstance():getRunningScene() then
                cc.Director:getInstance():replaceScene(gameScene)
            else
                cc.Director:getInstance():runWithScene(gameScene)
            end
        end
    end
    btnReady:addTouchEventListener(onReadyClicked)
    btnQuit:addTouchEventListener(onQuitClicked)
    return node
end

return lobbyLayer