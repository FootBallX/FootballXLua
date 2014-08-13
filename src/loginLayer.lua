require "Cocos2d"
require "Cocos2dConstants"
require "constVar"
require "GameDatas"

local pomelo = PomeloClient:getInstance()

local STATES = {
    NONE = 0,
    CONNECT_GATEWAY = 1,
    CONNECT_CONNECTOR = 2
}

local state = STATES.NONE

local cclog = function(...)
    print(string.format(...))
end

local loginLayer = class("loginLayer",function()
    return cc.Scene:create()
end)


function loginLayer.create()
    local scene = loginLayer.new()
    scene:init()
    scene:addChild(scene:createCCS("LoginLayer.json"))
    return scene
end


function loginLayer:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
end

function loginLayer:init()
    local function update(dt)
    end
        
    local function netHandler(event, msg)
        if (event == constVar.Event.onConnected) then
            if (state == STATES.CONNECT_GATEWAY) then
                local data = {
                    userName = "test1",
                    password = "123"
                }
                pomelo:request(constVar.Event.gateQureyConnectorEntry, json.encode(data))
            elseif (state == STATES.CONNECT_CONNECTOR) then
                local data = {
                    userName = "test1",
                    password = "123"
                }
                pomelo:request(constVar.Event.connectorLogin, json.encode(data))
            end
        elseif (event == constVar.Event.onConnectFailed) then
            if (state == STATES.CONNECT_GATEWAY) then
                cclog("fail to connect gateway")
            elseif (state == STATES.CONNECT_CONNECTOR) then
                cclog("fail to connect connector")
            end
            state = STATES.NONE
        elseif (event == constVar.Event.gateQureyConnectorEntry) then
            local msgJson = json.decode(msg)
            pomelo:disconnect()
            if (msgJson.code == constVar.PomeloCode.OK) then
                state = STATES.CONNECT_CONNECTOR
                pomelo:connectA(msgJson.host, msgJson.port)
            else
                cclog("can not get connectors!")
            end
            cclog(msg)

        elseif (event == constVar.Event.connectorLogin) then
            local msgJson = json.decode(msg)
            if (msgJson.code == constVar.PomeloCode.OK) then
                pomelo:request(constVar.Event.connectorGetPlayerInfo, "")
            else
                cclog("fail to login to connector")
            end
        elseif (event == constVar.Event.connectorGetPlayerInfo) then
            local msgJson = json.decode(msg)
            PlayerInfo.uid = msgJson.player.uid
            PlayerInfo.money = msgJson.player.money
            PlayerInfo.nickname = msgJson.player.nickname
            PlayerInfo.level = msgJson.player.level

            --create scene 
            local scene = require("lobbyLayer")
            local gameScene = scene.create()

            if cc.Director:getInstance():getRunningScene() then
                cc.Director:getInstance():replaceScene(gameScene)
            else
                cc.Director:getInstance():runWithScene(gameScene)
            end
        end
    end
    
    local function onNodeEvent(event)
        if "exit" == event then
--            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
            self:unregisterScriptHandler()
        end
    end
    
    pomelo:disconnect()
--    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0.5, false)
    pomelo:registerScriptHandler(netHandler)
    self:registerScriptHandler(onNodeEvent)
end

function loginLayer:createCCS(filename)
    local node = ccs.NodeReader:getInstance():loadNodeWithFile(filename)
    local btnLogin = node:getChildByName("Button_Login")
    local function onLoginClicked(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            pomelo:connectA("127.0.0.1", 3017);
            state = STATES.CONNECT_GATEWAY
        end
    end
    btnLogin:addTouchEventListener(onLoginClicked)
    
    local btnCancel = node:getChildByName("Button_Cancel")
    local function onCancelClicked(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local scene = require("matchLayer")
            local gameScene = scene.create()
            if cc.Director:getInstance():getRunningScene() then
                cc.Director:getInstance():replaceScene(gameScene)
            else
                cc.Director:getInstance():runWithScene(gameScene)
            end
        end
    end
    btnCancel:addTouchEventListener(onCancelClicked)
    return node
end


return loginLayer