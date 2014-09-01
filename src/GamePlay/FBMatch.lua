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

local HDVector = require("Utils.HDVector");
local MD = MatchDefs;
    
local MatchManager = class("MatchManager")

function MatchManager:ctor()
    cclog("MatchManager ctor")
    self.m_pitch = nil

    self.m_matchUI = nil
    self.m_proxy = nil
    
    self.m_teams = {}
    
    self.m_playerDistanceSq = constVar.Sys.numberMax;
    self.m_encounterTime = constVar.Sys.numberMax;
    
    self.m_menuType = MD.MENU_TYPE.NONE;
    self.m_isAir = false;
    
    self.m_recentEndedFlow = MD.MATCH_FLOW_TYPE.NONE;
    
    self.m_defendPlayerIds = {};
    HDVector.extend(self.m_defendPlayerIds);
    
    self.m_involvePlayerIds = {};
    
    self.m_currentInstruction = nil;

    self.m_isPause = false;
    
    self.m_controlSide = MD.SIDE.NONE;
    
    self.m_vecFromUser = cc.p(0, 0);        -- 玩家当前操作的缓存

    self.m_ball = nil; --     CFBBall* m_ball = nullptr;',
    self.m_playerInstructions = {}; HDVector.extend(self.m_playerInstructions); --     vector<FBDefs::MENU_ITEMS> m_playerInstructions;    // 玩家指令',
    self.m_attackPlayerNumbers = {}; HDVector.extend(self.m_attackPlayerNumbers); --     vector<int> m_attackPlayerNumbers;',
    self.m_defendPlayerNumbers = {}; HDVector.extend(self.m_defendPlayerNumbers); --     vector<int> m_defendPlayerNumbers;',
    self.m_targetPlayerId = -1; --     int m_targetPlayerId = -1;       // 仅传球时候有效，传球对象\'',
    self.m_playAnimIndex = 0; --     int m_playAnimIndex = 0;',
    self.m_SYNC_TIME = 1.0; --     const float m_SYNC_TIME = 1.0f;',
    self.m_instructionResult = require("GamePlay.FBInstructionResult").new(); --     CFBInstructionResult m_instructionResult;',
    self.m_teamsInMatch = {}; HDVector.extend(self.m_teamsInMatch); --     CFBTeam* m_teamsInMatch[(int)SIDE::NONE];       // 这里重新组织一下，按照己方和对方保存team',
    self.m_syncTime = {}; HDVector.extend(self.m_syncTime); --     float m_syncTime[(int)SIDE::NONE];',
    self.m_startTime = 0; --     unsigned int m_startTime = 0;',
    self.m_matchStep = MD.MATCH_STEP.NONE; --     FBDefs::MATCH_STEP m_matchStep = FBDefs::MATCH_STEP::NONE;' ],
end

function MatchManager:init(pitchWidth, pitchHeight, matchUI, proxy)
    self.m_pitch = require("GamePlay.FBPitch").new();
    self.m_matchUI = matchUI
    
    self.m_proxy = proxy;
    self.m_proxy:setDelegator(self);

    if not (self.m_pitch:init(pitchWidth, pitchHeight)) then
        return false;
    end

    self.m_teams[0] = require("GamePlay.FBTeam").new(MD.SIDE.LEFT);
    self.m_teams[1] = require("GamePlay.FBTeam").new(MD.SIDE.RIGHT);

    self.m_playerDistanceSq = MD.PLAYER_DISTANCE * MD.PLAYER_DISTANCE;

    self.m_matchStep = MD.MATCH_STEP.WAIT_START;

    return true;
end

    
function MatchManager:update(dt)
    self.m_proxy:update(dt);

    if self.m_matchStep == MD.MATCH_STEP.WAIT_START then
        
    elseif self.m_matchStep == MD.MATCH_STEP.COUNT_DOWN then
    
        local delta = self.m_startTime - self.m_proxy:getTime();
        if (delta <= 0) then
        
            self.m_matchStep = MD.MATCH_STEP.MATCHING;
        end
    
    elseif self.m_matchStep == MD.MATCH_STEP.MATCHING then
    
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
    elseif self.m_matchStep == MD.MATCH_STEP.PLAY_ANIM then
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
    local team = getTeam(MD.SIDE.LEFT);
    local player = team:getHilightPlayer();
    if (player ~= nil and player.m_isBallController) then
    
        return team;
    end
    
    team = getTeam(MD.SIDE.RIGHT);
    player = team:getHilightPlayer();
    if (player and playe.m_isBallController) then
    
        return team;
    end

    return nil;

end


function MatchManager:getDefendingTeam()
    local team = self:getTeam(MD.SIDE.LEFT);
    local player = team:getHilightPlayer();
    if (not player or not player.m_isBallController) then
    
        return team;
    end
    
    team = getTeam(MD.SIDE.RIGHT);
    player = team:getHilightPlayer();
    if (not player or not player.m_isBallController) then
    
        return team;
    end
    
    return nil;

end


function MatchManager:isBallOnTheSide(side)
    local pos = self:getBallPosition();
    local pitch = self:getPitch();
    if (side == MD.SIDE.LEFT) then
    
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
    if (side == MD.SIDE.RIGHT) then
    
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
        
            pO:setInstruction(MD.PLAYER_INS.TAKCLE);
        
        elseif (roll > 100) then
        
            pO:setInstruction(MD.PLAYER_INS.INTERCEPT);
        
        else
        
            pO:setInstruction(MD.PLAYER_INS.BLOCK);
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
                if (MD.isPointOnTheWay(fpos, tpos, ppos)) then
                
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
        
            pO:setInstruction(MD.PLAYER_INS.TAKCLE);
        
        elseif (roll > 100) then
        
            pO:setInstruction(MD.PLAYER_INS.INTERCEPT);
        
        else
        
            pO:setInstruction(MD.PLAYER_INS.BLOCK);
        end
        self.m_currentInstruction:addPlayer(pO);
    end
    
    self.m_currentInstruction:addPlayer(to);
    
    -- TODO: Insturction class needed
    -- self.m_currentInstruction:start(bind(&CFBMatch.onInstructionEnd, this));
    
    pauseGame(true);

end



function MatchManager:tryShootBall(player, isAir)
end
    
function MatchManager:playAnimation(name, delay)
    self.m_matchUI:onPlayAnimation(name, delay);
end


function MatchManager:onAnimationEnd()
    cclog("AnimaitonEnd");
    if (MD.MATCH_STEP.PLAY_ANIM == self.m_matchStep) then
    
        self.m_playAnimIndex = self.m_playAnimIndex + 1;
        self:playAnimInInstructionsResult();
    end
end

function MatchManager:playAnimInInstructionsResult()

    local instructions = self.m_instructionResult.instructions;
    while (self.m_playAnimIndex < instructions.size()) do
    
        local ins = instructions[self.m_playAnimIndex];
        if (ins.animations.size() > 0) then
        
            for i = 1, #ins.animations do
                local ani = ins.animations[i];

                self.m_matchUI:onPlayAnimation(MD.g_aniNames[ani.aniId], ani.delay);
            end
            break;
        
        else
        
            self.m_playAnimIndex = self.m_playAnimIndex + 1;
        end
    end
    
    if (self.m_playAnimIndex >= instructions.size()) then
    
        self.m_proxy:sendInstructionMovieEnd();
    end
end

function MatchManager:getMatchStep()
    return self.m_matchStep;
end


function MatchManager:setBallControllerMove(vec)
    self.m_vecFromUser = vec;
end

    
function MatchManager:getOneTwoPlayer()      -- 自动选取二过一的协助球员
    local team = self:getControlSideTeam();
    local id = team:getHilightPlayerId();
    local ballPos = team:getHilightPlayer():getPosition();
    local tm = team:getTeamMembers();
    local dist = constVar.Sys.numberMax;
    local playerId = -1;
    for i = 1, #tm do

        if (i ~= id) then
        
            local pos = tm[i]:getPosition();
            local len = pos.getDistanceSq(ballPos);
            if (len < dist) then
            
                dist = len;
                playerId = i;
            end
        end
    end

    return playerId;
end
    
function MatchManager:getCountDownTime()
    return -self.m_proxy:getDeltaTime(self.m_startTime);
end


function MatchManager:getTime()
    return self.m_proxy:getTime();
end

function MatchManager:setMenuItem(mi, targetPlayer)
    self.m_playerInstructions.push_back(mi);
    self.m_proxy:sendMenuCmd(mi, targetPlayer);
end


function MatchManager:syncTeam()

    local team = self.m_teamsInMatch[SIDE.SELF];
    
    local v = {};
    HDVector.extend(v);

    local num = team:getPlayerNumber();
    
    for i = 1, num do

        local player = team:getPlayer(i);
        local pos = player:getPosition();
        v.push_back(pos.x);
        v.push_back(pos.y);
        local vec = player:getMovingVector();
        v.push_back(vec.x);
        v.push_back(vec.y);
    end
    
    self.m_proxy:sendTeamPosition(v, team:isAttacking() and team:getHilightPlayerId() or -1, team:getSide());
end

function MatchManager:teamPositionAck(side, p, ballPlayerId, timeStamp)

    local team = self.m_teams[side];
    
    local size = team:getPlayerNumber();
    
    if (timeStamp == 0) then     -- timeStamp为0表示暂停时候的强制同步
    
        for i = 1, size do
            local pos = cc.p(p[i * 4], p[i * 4 + 1]);
            local vec = cc.p(p[i * 4 + 2], p[i * 4 + 3]);
            local player = team:getPlayer(i);
            
            player:loseBall();
            player:setPosition(pos);
            player:setMovingVector(vec);
        end
        
        if (ballPlayerId ~= -1) then
        
            team:getPlayer(ballPlayerId):gainBall();
        end
    
    else
    
        local dt = self.m_proxy:getDeltaTime(timeStamp);
        
        for i = 1, size do

            local pos = cc.p(p[i * 4], p[i * 4 + 1]);
            local vec = cc.p(p[i * 4 + 2], p[i * 4 + 3]);
            local player = team:getPlayer(i);

            player:moveFromTo(pos, vec, dt, self.m_SYNC_TIME);
        end

        self.m_syncTime[SIDE.OPP] = self.m_SYNC_TIME;
    end
end



function MatchManager:startMatchAck(st)

    cclog("diff: %d", st - self.m_proxy:getTime());
    self.m_matchStep = MD.MATCH_STEP.COUNT_DOWN;
    
    self.m_startTime = st;
    
    self.m_syncTime[SIDE.SELF] = self.m_SYNC_TIME;
end



function MatchManager:matchInfoAck(mySide, kickOffSide, kickOffPlayer)


    cclog("side: %d, kick: %d", mySide, kickOffSide);

    self:setControlSide(mySide);
    self.m_teamsInMatch[SIDE.SELF]:onStartMatch(false);
    self.m_teamsInMatch[SIDE.OPP]:onStartMatch(true);
    
    self.m_teams[kickOffSide]:kickOff(kickOffPlayer);
    
    if (self.m_teamsInMatch[SIDE.SELF]:isAttacking()) then
    
        self.m_matchUI:showAttackMenu(true);
    end
end


function MatchManager:endMatchAck()

    self.m_matchUI:onGameEnd();
end



function MatchManager:triggerMenuAck(menuType, attackPlayerNumbers, defendPlayerNumbers)

    local side = getControlSideTeam():isAttacking() and 0 or 1;
    self.m_matchUI:onMenu(menuType, attackPlayerNumbers, defendPlayerNumbers, side);
    self.m_playerInstructions.clear();
    
    self.m_attackPlayerNumbers = attackPlayerNumbers;
    self.m_defendPlayerNumbers = defendPlayerNumbers;
    self.m_targetPlayerId = -1;
end


function MatchManager:instructionAck(countDown)

    if (countDown  > 0) then
    
        -- TODO: 收到countDown后更新客户端显示的倒计时
    else
    
        self.m_playerInstructions.clear();
        self.m_matchUI:waitInstruction();
    end
end



function MatchManager:instructionResultAck()

    self.m_matchStep = MD.MATCH_STEP.PLAY_ANIM;
    self.m_playAnimIndex = 0;

    self:playAnimInInstructionsResult();
end



function MatchManager:getInstructionResult()

    return self.m_instructionResult;
end


function MatchManager:addPlayer(side, info)

    self.m_teams[side]:addPlayer(info);
end


function MatchManager:resumeMatch()

    self:pauseGame(false);
    self.m_matchStep = MD.MATCH_STEP.MATCHING;
    if (self.m_teamsInMatch[SIDE.SELF]:isAttacking()) then
    
        self.m_matchUI:showAttackMenu(true);
    end
    self.m_matchUI:onPauseGame(false);
end


function MatchManager:onInstructionEnd()

    self:pauseGame(false);
    
    self.m_recentEndedFlow = self.m_currentInstruction:getInstructionType();
    self.m_currentInstruction = nil;
    
    self.m_matchUI:onInstrunctionEnd();
    
    self:checkEncounterInPenaltyArea();
end

function MatchManager:updateEncounter(dt)

    self.m_encounterTime = self.m_encounterTime - dt;
    
    if (self.m_menuType ~= MD.MENU_TYPE.NONE) then
    
        if (self.m_encounterTime < 0) then
        
            self.m_encounterTime = constVar.Sys.numberMax;
            
            self.m_menuType = MD.MENU_TYPE.NONE;
        end
    else
    
        self:updateDefendPlayerAroundBall();
        self:checkEncounterInDribble();
        self:checkEncounterInPenaltyArea();
        
        self.m_recentEndedFlow = MD.MATCH_FLOW_TYPE.NONE;
    end
end




function MatchManager:checkEncounterInDribble()

    if (self.m_menuType ~= MD.MENU_TYPE.NONE) then
        return;
    end
    
    local size = self.m_defendPlayerIds.size();
    if (size > 0) then
    
        if (size >= 4) then
        
            self.m_encounterTime = -1;
        
        elseif (self.m_encounterTime > MD.PLAYER_ENCOUNTER_TRIGGER_TIME) then
        
            self.m_encounterTime = MD.PLAYER_ENCOUNTER_TRIGGER_TIME;
        end
        
        local team = self:getControlSideTeam();
        if (team:isAttacking()) then
        
            self.m_menuType = MD.MENU_TYPE.ENCOUNTER_ATK_G;
            self.m_involvePlayerIds.clear();
            self.m_involvePlayerIds.push_back(team:getHilightPlayerId());
        else
        
            self.m_menuType = MD.MENU_TYPE.ENCOUTNER_DEF_G;
            self.m_involvePlayerIds.clear();
            for i = 1, #self.m_defendPlayerIds do
                local p = self.m_defendPlayerIds[i];
                self.m_involvePlayerIds.push_back(p);
            end
        end
        self.m_isAir = false;

    else
    
        self.m_encounterTime = constVar.Sys.numberMax;
        
        self.m_menuType = MD.MENU_TYPE.NONE;
    end
end


-- 进攻方对方禁区拿球，强制触发一次空中遭遇。
function MatchManager:checkEncounterInPenaltyArea()

    -- TODO: 仅当传球，二过一，随机球 刚刚结束，否则直接返回。二过一和随机球还未做判断
    if (self.m_recentEndedFlow ~= MD.MATCH_FLOW_TYPE.PASSBALL) then
        return;
    end
    
    if (self.m_menuType ~= MD.MENU_TYPE.NONE) then
        return;
    end

    local team = self:getAttackingTeam();
    local side = team:getSide();
    local ballPos = self:getBallPosition();

    if (self.m_pitch:isInPenaltyArea(ballPos, self.m_pitch:getOtherSide(side))) then
    
        self.m_encounterTime = -1;
        self.m_isAir = true;
        
        local conTeam = getControlSideTeam();
        if (conTeam:isAttacking()) then
        
            self.m_menuType = MD.MENU_TYPE.ENCOUNTER_ATK_OPPSITE_A;
            self.m_involvePlayerIds.clear();
            self.m_involvePlayerIds.push_back(conTeam:getHilightPlayerId());

        else
        
            self.m_menuType = MD.MENU_TYPE.ENCOUNTER_DEF_SELF_A;
            self.m_involvePlayerIds.clear();
            for i = 1, #self.m_defendPlayerIds do
                local p = self.m_defendPlayerIds[i];
                self.m_involvePlayerIds.push_back(p);
            end
        end
    end
end


function MatchManager:updateDefendPlayerAroundBall()

    self.m_defendPlayerIds.clear();
    
    local ballPos = g_matchManager:getBallPosition();
    
    local defTeam = self:getDefendingTeam();
    local teamMembers = defTeam:getTeamMembers();
    
    for i = 1, #teamMembers do
        local tm = teamMembers[i];
    
        if (not tm.m_isGoalKeeper) then
        
            if (ballPos.getDistanceSq(tm:getPosition()) <= self.m_playerDistanceSq) then
            
                self.m_defendPlayerIds.insert(tm.m_positionInFormation);
            end
        end
    end
end



g_matchManager = MatchManager.new() 


