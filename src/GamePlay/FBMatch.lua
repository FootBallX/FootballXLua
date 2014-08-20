require "Cocos2d"
require "Cocos2dConstants"
require "Common"
require "constVar"
require "GameDatas"
require "GamePlay.MatchDefs"
require "GamePlay.FBPitch"

local SIDE =
{
    "SELF",       -- 自己
    "OPP",        -- 对方
    "NONE",
};
    
local MatchManager = class("MatchManager")

function MatchManager:ctor()
    cclog("MatchManager ctor")
    self.m_pitch = nil
    self.m_ballPosition = cc.p(0, 0)
    self.m_matchUI = nil
    self.m_proxy = nil
    
    self.m_teams = {}
    
    self.m_playerDistanceSq = constVar.Sys.numberMax;
    self.m_encounterTime = constVar.Sys.numberMax;
    
    self.m_menuType = MatchDefs.MENU_TYPE.NONE;
    self.m_isAir = false;
    
    self.m_recentEndedFlow = MatchDefs.MATCH_FLOW_TYPE.NONE;
    
    self.m_defendPlayerIds = {};
    HDVector.extend(self.m_defendPlayerIds);
    
    self.m_involvePlayerIds = {};
    
    self.m_currentInstruction = nil;

    self.m_isPause = false;
    
    self.m_controlSide = MatchDefs.SIDE.NONE;
    
    self.m_vecFromUser = cc.p(0, 0);        -- 玩家当前操作的缓存
end

--    bool init(float pitchWidth, float pitchHeight, IFBMatchUI* matchUI, CFBMatchProxy* proxy);
function MatchManager:init(pitchWidth, pitchHeight, matchUI, proxy)
    self.m_pitch = require("GamePlay.FBPitch")
    self.m_matchUI = matchUI
    
    self.m_proxy = proxy;
    self.m_proxy:setDelegator(self);

    if not (self.m_pitch:init(pitchWidth, pitchHeight)) then
        return false;
    end

    self.m_teams[0] = new CFBTeam(matchDefs.SIDE.LEFT);
    self.m_teams[1] = new CFBTeam(matchDefs.SIDE.RIGHT);

    self.m_playerDistanceSq = matchDefs.PLAYER_DISTANCE * matchDefs.PLAYER_DISTANCE;

    self.m_matchStep = matchDefs.MATCH_STEP.WAIT_START;

    return true;
end

    
function MatchManager:update(dt)
    self.m_proxy:update(dt);

    if self.m_matchStep == matchDefs.MATCH_STEP.WAIT_START then
        
    elseif self.m_matchStep == matchDefs.MATCH_STEP.COUNT_DOWN then
    
        local delta = self.m_startTime - self.m_proxy:getTime();
        if (delta <= 0) then
        
            self.m_matchStep = matchDefs.MATCH_STEP.MATCHING;
        end
    
    elseif self.m_matchStep == matchDefs.MATCH_STEP.MATCHING then
    
        if (not self.m_isPause) then
        
            self.m_teamsInMatch[SIDE.SELF]:update(dt);
            self.m_teamsInMatch[SIDE.OPP]:update(dt);
        end
        
        if (self.m_currentInstruction ~= nil) then
        
            self.m_currentInstruction:update(dt);
        end
        
        for i = 1, SIDE.NONE do
            if (self.m_syncTime[i] < 0) then
            
                if (i == SIDE.SELF) then
                
                    local hilightPlayer = self.m_teamsInMatch[SIDE.SELF]:getHilightPlayer();
                    hilightPlayer:setMovingVector(self.m_vecFromUser);
                    self.m_teamsInMatch[SIDE.SELF]:think();
                    syncTeam();
                    self.m_syncTime[i] = self.m_SYNC_TIME;
                
                else
                
                    local oppTeam = self.m_teamsInMatch[SIDE.OPP];
                    local num = oppTeam:getPlayerNumber();
                    for j = 1, num do
                        oppTeam:getPlayer(j):setMovingVector(0, 0);
                    end
                end
            end
            
            self.m_syncTime[i] = self.m_syncTime[i] - dt;
        end
    elseif self.m_matchStep == matchDefs.MATCH_STEP.PLAY_ANIM then
    end
end
    
function MatchManager:startMatch()
    self.m_proxy:start();
end


function MatchManager:setControlSide(side)
    self.m_controlSide = side;
    
    self.m_teamsInMatch[SIDE.SELF] = self.m_teams[side];
    self.m_teamsInMatch[SIDE.OPP] = self.m_teams[self.m_pitch:getOtherSide(side)];
end


function MatchManager:checkControlSide(side)
    return self.m_controlSide == side;
end


function MatchManager:getControlSideTeam()
    return self:getTeam(self.m_controlSide);
end



function MatchManager:getControlSide()
    return self.m_controlSide;
end

 
function MatchManager:getTeam(side)
    return self.m_teams[side];
end


function MatchManager:getOtherTeam(team)
    if (self.m_teams[SIDE.SELF] == team) then
        return self.m_teams[SIDE.OPP];
    elseif (self.m_teams[SIDE.OPP] == team) then
        return self.m_teams[SIDE.SELF];
    end
    
    return nil;
end
   
function MatchManager:getAttackingTeam()
    local team = getTeam(matchDefs.SIDE.LEFT);
    local player = team:getHilightPlayer();
    if (player ~= nil and player.m_isBallController) then
    
        return team;
    end
    
    team = getTeam(matchDefs.SIDE.RIGHT);
    player = team:getHilightPlayer();
    if (player and playe.m_isBallController) then
    
        return team;
    end

    return nil;

end


function MatchManager:getDefendingTeam()
    local team = self:getTeam(matchDefs.SIDE.LEFT);
    local player = team:getHilightPlayer();
    if (not player or not player.m_isBallController) then
    
        return team;
    end
    
    team = getTeam(matchDefs.SIDE.RIGHT);
    player = team:getHilightPlayer();
    if (not player or not player.m_isBallController) then
    
        return team;
    end
    
    return nil;

end


function MatchManager:isBallOnTheSide(side)
    local pos = self:getBallPosition();
    local pitch = self:getPitch();
    if (side == matchDefs.SIDE.LEFT) then
    
        return pos.x < pitch:getPitchWidth() * 0.5;
    
    else
    
        return pos.x > pitch:getPitchWidth() * 0.5;
    end
    
    return false;

end


function MatchManager:setBallPosition(pos)
    self.m_ball:setBallPos(pos);
end


function MatchManager:getBallPosRateBySide(side)
    local pos = self:getBallPosition();
    local pitch = self:getPitch();
    local rate = pos.x / pitch:getPitchWidth();
    if (side == matchDefs.SIDE.RIGHT) then
    
        rate = 1 - rate;
    end
    
    return rate;

end



function MatchManager:getBallPosition()
    return self.m_ball:getBallPos();
end
  
function MatchManager:pauseGame(p)
    self.m_isPause = p;

    self.m_matchUI:onPauseGame(p);
end


function MatchManager:isPausing()
    return self.m_isPause; 
end
    
function MatchManager:tryPassBall(from, to)
    local team = from:getOwnerTeam();
    local size = team:getSide();
    local pitch = g_matchManager:getPitch();
    local otherSide = pitch:getOtherSide(size);
    local otherTeam = g_matchManager:getTeam(otherSide);
    local otherTeamMembers = otherTeam:getTeamMembers();
    
    self.m_currentInstruction = INS_FAC:getPassBallIns();
    self.m_currentInstruction:addPlayer(from);
    
    for x = 1, #self.m_defendPlayerIds do
        local pO = otherTeam:getPlayer(x);
        local roll = RANDOM_MGR:getRand() % 300;
        if (roll > 200) then
        
            pO:setInstruction(matchDefs.PLAYER_INS.TAKCLE);
        
        elseif (roll > 100) then
        
            pO:setInstruction(matchDefs.PLAYER_INS.INTERCEPT);
        
        else
        
            pO:setInstruction(matchDefs.PLAYER_INS.BLOCK);
        end
        
        self.m_currentInstruction:addPlayer(pO);
    end
    
    local fpos = from:getPosition();
    local tpos = to:getPosition();
    
    local involvePlayers = {};
    HDVector.extend(involvePlayers);
--    vector<pair<local, CFBPlayer*>> involvePlayers;
    for i = 1, #otherTeamMembers do
        local player = otherTeamMembers[i];
        if (not player.m_isGoalKeeper) then
            local it = self.m_defendPlayerIds.find(player.m_positionInFormation, nil);
            if (it == nil) then
            
                local ppos = player:getPosition();
                if (matchDefs.isPointOnTheWay(fpos, tpos, ppos)) then
                
                    local dist = cc.pGetDistance(fpos, ppos);
                    involvePlayers.push_back({dist = dist,player = player});
                end
            end
        end
    end
    
    table.sort(involePlayers, function(o1, o2)
        return o1.dist < o2.dist;
    end)
    
    for i = 1, #involvePlayers do
        local a = involvePlayers[i];
        local pO = a.player;
        local roll = math.random(0, 300);
        if (roll > 200) then
        
            pO:setInstruction(matchDefs.PLAYER_INS.TAKCLE);
        
        elseif (roll > 100) then
        
            pO:setInstruction(matchDefs.PLAYER_INS.INTERCEPT);
        
        else
        
            pO:setInstruction(matchDefs.PLAYER_INS.BLOCK);
        end
        self.m_currentInstruction:addPlayer(pO);
    end
    
    self.m_currentInstruction:addPlayer(to);
    
    self.m_currentInstruction:start(bind(&CFBMatch.onInstructionEnd, this));
    
    pauseGame(true);

end



function MatchManager:tryShootBall(CFBPlayer* player, bool isAir);
    
function MatchManager:playAnimation(const string& name, float delay);
function MatchManager:onAnimationEnd();
    
function MatchManager:getMatchStep();
function MatchManager:setBallControllerMove(const cocos2d::Point& vec);
    
function MatchManager:getOneTwoPlayer();      // 自动选取二过一的协助球员
    
function MatchManager:getCountDownTime();
function MatchManager:getTime();

function MatchManager:setMenuItem(FBDefs::MENU_ITEMS mi, int targetPlayer = -1);

g_matchManager = MatchManager.new() 


