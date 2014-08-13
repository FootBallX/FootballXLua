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
    self.players = {{}, {}}
    self.pitchRoot = nil
    self.pitchBall = nil
    self.pitchArrow = nil
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
            local eventDispatcher = self:getEventDispatcher()
            eventDispatcher:removeEventListenersForTarget(self)
        end
    end

    local touchBeginPoint = nil
    local function onTouchBegan(touch, event)
        local location = touch:getLocation()
        cclog("onTouchBegan: %0.2f, %0.2f", location.x, location.y)
        touchBeginPoint = {x = location.x, y = location.y}
        -- CCTOUCHBEGAN event must return true
        --[[多点
        for i = 1,table.getn(touches) do
        local location = touches[i]:getLocation()
        Sprite1.addNewSpriteWithCoords(Helper.currentLayer, location)
        end
        ]]--
        return true
    end

    local function onTouchMoved(touch, event)
        local location = touch:getLocation()
        cclog("onTouchMoved: %0.2f, %0.2f", location.x, location.y)
        if touchBeginPoint then
        end
    end

    local function onTouchEnded(touch, event)
        local location = touch:getLocation()
        cclog("onTouchEnded: %0.2f, %0.2f", location.x, location.y)
        touchBeginPoint = nil
    end

    --    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0.5, false)
    pomelo:registerScriptHandler(netHandler)
    self:registerScriptHandler(onNodeEvent)

    --pomelo:addListener(constVar.Event.lobbyOnPair)
    
    local listener = cc.EventListenerTouchOneByOne:create()
    --local listener = cc.EventListenerTouchAllAtOnce:create() 多点
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function matchLayer:createLayer()
    local pitch = cc.Sprite:create(constVar.ResName.pitch)
    pitch:setAnchorPoint(0, 0)
    local gridNode = cc.NodeGrid:create()
    gridNode:addChild(pitch)
    local action = cc.Flip3DEx:create(1, 90, 90)
    gridNode:runAction(action)
    self:addChild(gridNode)
    self.pitchRoot = pitch
    
    self.pitchBall = cc.Sprite:create(constVar.ResName.pitchBall)
    self.pitchArrow = cc.Sprite:create(constVar.ResName.pitchArrow)
    
    self.pitchBall:setPosition(400, 300)
    self.pitchArrow:setPosition(400, 300)
    self.pitchRoot:addChild(self.pitchBall)
    self.pitchRoot:addChild(self.pitchArrow)

    for i = 1, #constVar.ResName.pitchBlackNumber do
        local bg = cc.Sprite:create(constVar.ResName.pitchBlackPoint)
        local sz = bg:getContentSize()
        local num = cc.Sprite:create(constVar.ResName.pitchBlackNumber[i])
        num:setPosition(sz.width * 0.5, sz.height * 0.5)
        bg:addChild(num)
        self.players[1][i] = bg
        
        bg:setPosition(10, 10 + i * 40)
        self.pitchRoot:addChild(bg)
    end

    for i = 1, #constVar.ResName.pitchRedNumber do
        local bg = cc.Sprite:create(constVar.ResName.pitchRedPoint)
        local sz = bg:getContentSize()
        local num = cc.Sprite:create(constVar.ResName.pitchRedNumber[i])
        num:setPosition(sz.width * 0.5, sz.height * 0.5)
        bg:addChild(num)
        self.players[2][i] = bg
        bg:setPosition(200, 10 + i * 40)
        self.pitchRoot:addChild(bg)
    end
end

return matchLayer


