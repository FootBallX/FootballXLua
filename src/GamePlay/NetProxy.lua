require "Cocos2d"
require "Cocos2dConstants"
require "Common"
require "constVar"
require "GameDatas"
require "GameElement.PlayerInfo"

local NetProxy = class("NetProxy")
local pomelo = PomeloClient:getInstance()
local PLAYER_INFO = g_PlayerInfo;

local START_STEP =
{
    "SYNC_TIME_BEGIN",
    "SYNC_TIME",
    "SYNC_TIME_END",
    "WAITING_MATCH_INFO",
    "NONE",
};

function NetProxy:ctor()
    self.m_syncedTimer = nil
    self.m_startStep = START_STEP.NONE;
    self.m_startSyncTime = 2.0;
    self.m_match = nil;

    self:init();
end


function NetProxy:init()
    local function netHandler(event, msg)
        if (event == constVar.Event.pushSync) then
            self:onSync(msg);
        elseif (event == constVar.Event.pushStartMatch) then
            self:onStartMatch(msg);
        elseif (event == constVar.Event.pushEndMatch) then
            self:onEndMatch(msg);
        elseif (event == constVar.Event.pushTriggerMenu) then
            self:onTriggerMenu(msg);
        elseif (event == constVar.Event.pushInstructions) then
            self:onInstructionResult(msg);
        elseif (event == constVar.Event.pushInstructionsDone) then
            self:onInstructionDone(msg);
        elseif (event == constVar.Event.pushResumeMatch) then
            self:onResumeMatch(msg);
        elseif (event == constVar.Event.matchGetInfo) then
            self:onGetMatchInfo(msg);
        end
    end

    pomelo:registerScriptHandler(netHandler);

    pomelo:addListener(constVar.Event.pushSync);
    pomelo:addListener(constVar.Event.pushStartMatch);
    pomelo:addListener(constVar.Event.pushEndMatch);
    pomelo:addListener(constVar.Event.pushTriggerMenu);
    pomelo:addListener(constVar.Event.pushInstructions);
    pomelo:addListener(constVar.Event.pushInstructionsDone);
    pomelo:addListener(constVar.Event.pushResumeMatch);

end

function NetProxy:setDelegator(dele)
    self.m_match = dele
end

function NetProxy:start()
    self.m_startStep = START_STEP.SYNC_TIME_BEGIN;
end

function NetProxy:sendTeamPosition(p, ballPlayerId, side)
    local msg = {
        teamPos = {},
        side = side,
        ballPosPlayerId = ballPlayerId,
        timeStamp = self.m_syncedTimer.getTime(),
    }

    for i = 1, #p do
        msg.teamPos[i] = p[i]
    end
    
    pomelo:request(constVar.Event.matchSync, json.encode(msg))
end

function NetProxy:sendMenuCmd(mi, playerId)
    local msg = 
    {
        cmd = mi,
    }

    if (playerId > -1) then
        msg["targetPlayerId"] = playerId;
    end
    
    pomelo:request(constVar.Event.matchMenuCmd, json.encode(msg))

end

function NetProxy:sendInstructionMovieEnd()
    pomelo:request(constVar.Event.matchInsructionMovieEnd, "")
end

function NetProxy:update(dt)
    self.m_syncedTimer.update(dt);

    if self.m_startStep == START_STEP.SYNC_TIME_BEGIN then
    
        if (self.m_startSyncTime < 0) then
            self.m_startStep = START_STEP.SYNC_TIME;
            self.m_syncedTimer:startSyncTime();
        else
            self.m_startSyncTime = self.m_startSyncTime - dt;
        end
    
    elseif self.m_startStep == START_STEP.SYNC_TIME then
        if not self.m_syncedTimer.isSyncing() then
            self.m_startStep = START_STEP.SYNC_TIME_END;
        end
    elseif self.m_startStep == START_STEP.SYNC_TIME_END then
        self.m_startStep = START_STEP.WAITING_MATCH_INFO;
        pomelo:request(constVar.Event.matchGetInfo, "")
    elseif self.m_startStep == START_STEP.WAITING_MATCH_INFO then
    end

end

function NetProxy:getTime()
    return self.m_syncedTimer:getTime();
end

function NetProxy:getDeltaTime(time)
    return (self.m_syncedTimer:getTime() - time) / 1000.0;
end

function NetProxy:onSync(msg)
    local msgJson = json.decode(msg);
    local teamPos= msgJson.teamPos;
    local v = {};
    HDVector.extend(v);

    local size = #teamPos;
    for i = 1, size do    
        v.push_back(teamPos[i]);
    end
    
    self.m_match:teamPositionAck(msgJson.side, v, msgJson.ballPosPlayerId, msgJson.timeStamp);

end



function NetProxy:onStartMatch(msg)
    local msgJson = json.decode(msg);
    
    self.m_match:startMatchAck(msgJson.startTime);
end



function NetProxy:onEndMatch(msg)
    self.m_match:endMatchAck();
end



function NetProxy:onTriggerMenu(msg)
    local msgJson = json.decode(msg);
    
    local type = msgJson.menuType;
    if (type == matchDefs.MENU_TYPE.NONE) then
        -- show the waiting interface.
        return;
    end
    
    -- CC_ASSERT(type >= 0 and type < (unsigned local)matchDefs.MENU_TYPE.NONE);
    
    local av = {};
    HDVector.extend(av);
    local dv = {};
    HDVector.extend(dv);
    
    local ja = msgJson.attackPlayers;
    local i;
    -- CC_ASSERT(ja.size() > 0);
    for i = 1, #ja do
        av.push_back(ja[i]);
    end


    ja = msgJson.defendplayers;
    -- CC_ASSERT(ja.size() > 0);
    for i = 1, #ja do
        dv.push_back(ja[i]);
    end
    
    
    self.m_match:triggerMenuAck(type, av, dv);
end



function NetProxy:onInstructionResult(msg)

    local res = self.m_match:getInstructionResult();
    res.instructions.clear();
    
    local msgJson = json.decode(msg);
    
    local ja = msgJson.instructions;
    for i = 1, #ja do    
        local ins = ja[i];
        res.instructions:pushIns(ins.side, ins.playerNumber, ins.ins, ins.result);

        local insStru = res.instructions[i];
        
        local animsJson = ins.animations;
        for j = 1, #animsJson do
            local animObj = animsJson[j];
            insStru:pushAnim(animObj.animId, animObj.delay);
        end
    end
    
    res.ballSide = msgJson.ballSide;
    res.playerNumber = msgJson.playerNumber;
    res.ballPosX = msgJson.ballPosX;
    res.ballPosY = msgJson.ballPosY;
    
    self.m_match:instructionResultAck();
end



function NetProxy:onGetMatchInfo(msg)
    local msgJson = json.decode(msg);
    
    local left = msgJson.left;
    local right = msgJson.right;

    local u1 = msgJson.leftUid;
    local u2 = msgJson.rightUid;
    
    local side = matchDefs.SIDE.NONE;
    local kickOffSide = matchDefs.SIDE.LEFT;
    
    if (u1 == PLAYER_INFO.m_uid) then
        side = matchDefs.SIDE.LEFT;
    elseif (u2 == PLAYER_INFO.m_uid) then
        side = matchDefs.SIDE.RIGHT;
    end
    
    if ( 1 == msgJson.kickOffSide) then
        kickOffSide = matchDefs.SIDE.RIGHT;
    end
    
    local kickOffPlayer = msgJson.kickOffPlayer;
    
    local size = #left;
    
    local info = {card : require("GameElement.Card").new()};
    for  i = 1, size do
        local player = left[i];
        local card = info.card;
        card.m_cardID = player.pcId;
        card.m_speed = player.speed;
        card.m_icon = player.icon;
        card.m_strength = player.strength;
        card.m_dribbleSkill = player.dribbleSkill;
        card.m_passSkill = player.passSkill;
        card.m_shootSkill = player.shootSkill;
        card.m_defenceSkill = player.defenceSkill;
        card.m_attackSkill = player.attackSkill;
        card.m_groundSkill = player.groundSkill;
        card.m_airSkill = player.airSkill;
        local position = player.position;
        info.position = cc.p(position.x, position.y);
        local homePosition = player.homePosition;
        info.homePosition = cc.p(homePosition.x, homePosition.y);
        info.aiClass = player.aiClass;
        
        self.m_match:addPlayer(matchDefs.SIDE.LEFT, info);

        
        
        player = right[i];
        card.m_cardID = player.pcId;
        card.m_speed = player.speed;
        card.m_icon =  player.icon;
        card.m_strength = player.strength;
        card.m_dribbleSkill = player.dribbleSkill;
        card.m_passSkill = player.passSkill;
        card.m_shootSkill = player.shootSkill;
        card.m_defenceSkill = player.defenceSkill;
        card.m_attackSkill = player.attackSkill;
        card.m_groundSkill = player.groundSkill;
        card.m_airSkill = player.airSkill;
        position = player.position;
        info.position = cc.p(position.x, position.y);
        homePosition = player.homePosition;
        info.homePosition = cc.p(homePosition.x, homePosition.y);
        info.aiClass = player.aiClass;
        
        self.m_match:addPlayer(matchDefs.SIDE.RIGHT, info);
    end
    
    
    self.m_match:matchInfoAck(side, kickOffSide, kickOffPlayer);
    
    self.m_startStep = START_STEP.NONE;

    pomelo:notify(constVar.Event.matchHandlerReady, "");

end



function NetProxy:onInstructionDone(msg)

    self.m_match:instructionAck(0);
end



function NetProxy:onResumeMatch(msg)
    self.m_match:resumeMatch();
end


return NetProxy