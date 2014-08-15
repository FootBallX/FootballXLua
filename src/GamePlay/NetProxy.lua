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

return NetProxy