require "Cocos2d"
require "Cocos2dConstants"
require "Common"
require "constVar"
require "GameDatas"

local NetProxy = class("NetProxy")

local pomelo = PomeloClient:getInstance()

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
    
    CJsonTArray ja(docs.getChild("instructions"));
    for (size_t i = 0; i < ja.size(); ++i)
    
        local ins = ja.get(i);
        res.instructions.push_back(
                                   CFBInstructionResult.InsStructure(
                                                                      ins.getInt("side"),
                                                                      ins.getInt("playerNumber"),
                                                                      ins.getInt("ins"),
                                                                      ins.getInt("result")
                                                                      )
                                   );
        
        local insStru = res.instructions[i];
        
        CJsonTArray animsJson(ins.getChild("animations"));
        for (size_t j = 0; j < animsJson.size(); ++j)
        
            local animObj = animsJson.get(j);
            insStru.animations.push_back(
                                         CFBInstructionResult
                                         .InsStructure
                                         .Animation(
                                                     animObj.getInt("animId"),
                                                     animObj.getFloat("delay")
                                                     )
                                         );
        end
    end
    
    res.ballSide = docs.getInt("ballSide");
    res.playerNumber = docs.getInt("playerNumber");
    res.ballPosX = docs.getFloat("ballPosX");
    res.ballPosY = docs.getFloat("ballPosY");
    
    self.m_match:instructionResultAck();
end



function NetProxy:onGetMatchInfo(msg)

    CCPomeloReponse* ccpomeloresp = (CCPomeloReponse*)r;
    CJsonT docs(ccpomeloresp:docs);
    
    CJsonTArray left(docs.getChild("left"));
    CJsonTArray right(docs.getChild("right"));

    unsigned local u1 = docs.getUInt("leftUid");
    unsigned local u2 = docs.getUInt("rightUid");
    
    matchDefs.SIDE side = matchDefs.SIDE.NONE;
    matchDefs.SIDE kickOffSide = matchDefs.SIDE.LEFT;
    
    if (u1 == PLAYER_INFO:getUID())
    
        side = matchDefs.SIDE.LEFT;
    end
    else if (u2 == PLAYER_INFO:getUID())
    
        side = matchDefs.SIDE.RIGHT;
    end
    else
    
        CC_ASSERT(false);
    end
    
    if ( 1 == docs.getInt("kickOffSide"))
    
        kickOffSide = matchDefs.SIDE.RIGHT;
    end
    
    local kickOffPlayer = docs.getInt("kickOffPlayer");
    
    local size = (local)left.size();
    CC_ASSERT(size == right.size());
    
    CFBPlayerInitInfo info;
    for (local i = 0; i < size; ++i)
    
        
            CJsonT player(left.get(i));
            local card = info.card;
            card.self.m_cardID = player.getUInt("pcId");
            card.self.m_speed = player.getFloat("speed");
            strncpy(card.self.m_icon, player.getString("icon"), matchDefs.MAX_CARD_ICON_LEN - 1);
            card.self.m_strength = player.getFloat("strength");
            card.self.m_dribbleSkill = player.getFloat("dribbleSkill");
            card.self.m_passSkill = player.getFloat("passSkill");
            card.self.m_shootSkill = player.getFloat("shootSkill");
            card.self.m_defenceSkill = player.getFloat("defenceSkill");
            card.self.m_attackSkill = player.getFloat("attackSkill");
            card.self.m_groundSkill = player.getFloat("groundSkill");
            card.self.m_airSkill = player.getFloat("airSkill");
            CJsonT position(player.getChild("position"));
            info.position.x = position.getFloat("x");
            info.position.y = position.getFloat("y");
            CJsonT homePosition(player.getChild("homePosition"));
            info.homePosition.x = homePosition.getFloat("x");
            info.homePosition.y = homePosition.getFloat("y");
            info.aiClass = player.getInt("aiClass");
            
            self.m_match:addPlayer(matchDefs.SIDE.LEFT, info);
        end
        
        
            CJsonT player(right.get(i));
            local card = info.card;
            card.self.m_cardID = player.getUInt("pcId");
            card.self.m_speed = player.getFloat("speed");
            strncpy(card.self.m_icon, player.getString("icon"), matchDefs.MAX_CARD_ICON_LEN - 1);
            card.self.m_strength = player.getFloat("strength");
            card.self.m_dribbleSkill = player.getFloat("dribbleSkill");
            card.self.m_passSkill = player.getFloat("passSkill");
            card.self.m_shootSkill = player.getFloat("shootSkill");
            card.self.m_defenceSkill = player.getFloat("defenceSkill");
            card.self.m_attackSkill = player.getFloat("attackSkill");
            card.self.m_groundSkill = player.getFloat("groundSkill");
            card.self.m_airSkill = player.getFloat("airSkill");
            CJsonT position(player.getChild("position"));
            info.position.x = position.getFloat("x");
            info.position.y = position.getFloat("y");
            CJsonT homePosition(player.getChild("homePosition"));
            info.homePosition.x = homePosition.getFloat("x");
            info.homePosition.y = homePosition.getFloat("y");
            info.aiClass = player.getInt("aiClass");
            
            self.m_match:addPlayer(matchDefs.SIDE.RIGHT, info);
        end

    end
    
    
    self.m_match:matchInfoAck(side, kickOffSide, kickOffPlayer);
    
    self.m_startStep = START_STEP.NONE;
    const char *route = "match.matchHandler.ready";
    CJsonT msg;
    POMELO:notify(route, msg, [](Node* node, void* resp)
    end);
    msg.release();
end



function NetProxy:onInstructionDone(msg)

    self.m_match:instructionAck(0);
end



function NetProxy:onResumeMatch(msg)
    self.m_match:resumeMatch();
end


return NetProxy