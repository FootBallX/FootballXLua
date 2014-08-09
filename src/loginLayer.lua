require "Cocos2d"
require "Cocos2dConstants"
require "constVar"

local cclog = function(...)
    print(string.format(...))
end

local loginLayer = class("loginLayer",function()
    return cc.Scene:create()
end)

function loginLayer.create()
    local scene = loginLayer.new()
    scene:addChild(scene:createCCS("LoginLayer.json"))
    return scene
end


function loginLayer:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
end


local state = 0;

local function onConnectToGateway()
    local data = {
        userName = "test1",
        password = "123"
    }
    PomeloClient:getInstance():request(constVar.Event.gateQureyConnectorEntry, json.encode(data))
end

local function onConnectToConnector()
end

local function netHandler(event, msg)
    cclog("-------------- netHandler in loginLayer")
    if (event == constVar.Event.onConnected) then
        if (state == 0) then
            onConnectToGateway()
        elseif (state == 1) then
            onConnectToConnector()
        end
        cclog("connected")
    elseif (event == constVar.Event.onConnectFailed) then
        cclog("fail to connect")
    elseif (event == constVar.Event.gateQureyConnectorEntry) then
        local msgJson = json.decode(msg)
        cclog(msg)
    end
    cclog("netHandler end-------------")
    
end

function loginLayer:createCCS(filename)
    local node = ccs.NodeReader:getInstance():loadNodeWithFile(filename)
    local btnLogin = node:getChildByName("Button_Login")
    local function onLoginClicked(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            PomeloClient:getInstance():registerScriptHandler(netHandler);
            PomeloClient:getInstance():connectA("127.0.0.1", 3017);
            state = 0
        end
    end
    btnLogin:addTouchEventListener(onLoginClicked)
    return node
end


return loginLayer