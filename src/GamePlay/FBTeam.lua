
local FBTeam = class("FBTeam")

function FBTeam:ctor()
    self.m_side = matchDefs.SIDE.NONE;
    self.m_state = matchDefs.TEAM_STATE.NONE;
    self.m_teamMembers = {}
    HDVector.extend(self.m_teamMembers)
    
    self.m_score = 0;        -- 比分
    self.m_lastPosOfPlayer = 0.0;
    self.m_activePlayerId = -1;   -- 进攻时是控球队员，防守时是上前逼抢的球员
    self.m_assistantPlayerId = -1;  -- 进攻时是助攻接应球员（前锋除外），防守时是协防球员
    self.m_hilightPlayerId = -1;     -- 进攻方就是控球队员，防守方是当前可以控制移动的球员。
end


function FBTeam:addPlayer(info)
    local player = require("GamePlayer.FBPlayer").new(this, info.card);
    player:setPosition(info.position);
    
    if (self.m_aiType == matchDefs.AI_CLASS.GOALKEEPER) then
        player:createBrain(matchDefs.AI_CLASS.GOAL_KEEPER, info.homePosition, matchDefs.GOALKEEPER_ORBIT_RATE);
    elseif (self.m_aiType == matchDefs.AI_CLASS.BACK) then
        player:createBrain(matchDefs.AI_CLASS.BACK, info.homePosition, matchDefs.BACK_ORBIT_RATE);
    elseif (self.m_aiType == matchDefs.AI_CLASS.HALF_BACK) then
        player:createBrain(matchDefs.AI_CLASS.HALF_BACK, info.homePosition, matchDefs.HALF_BACK_ORBIT_RATE);
    elseif (self.m_aiType == matchDefs.AI_CLASS.FORWARD) then
        player:createBrain(matchDefs.AI_CLASS.FORWARD, info.homePosition, matchDefs.FORWARD_ORBIT_RATE);
    end
    
    self.m_teamMembers.push_back(player);
    
    player.m_positionInFormation = #self.m_teamMembers - 1;
end

function FBTeam:update(dt)
    local comp
    if getSide() == matchDefs.SIDE.LEFT then
        comp = function ( a,  b) return a < b; end
    else
        comp = function ( a,  b) return a > b; end
    
    self.m_lastPosOfPlayer = 0;
    for i = 1, #self.m_teamMembers do
    
        local x = self.m_teamMembers[i];
        x:getBrain():update(dt);
        if (x.m_isGoalKeeper == false) then
        
            local pos = x:getPosition();
            if (self.m_lastPosOfPlayer == 0) then
            
                self.m_lastPosOfPlayer = pos.x;
            end
            if (comp(pos.x, self.m_lastPosOfPlayer)) then
            
                self.m_lastPosOfPlayer = pos.x;
            end
        end
    end
end

function FBTeam:think()
    if (isAttacking()) then
    
        updateFieldStatusOnAttack();
    
    elseif (isDefending()) then
    
        updateFieldStatusOnDefend();
    end
    
    for i = 1, #self.m_teamMembers do
        local player = self.m_teamMembers[i];
        if (not player:isStunned()) then
        
            player:getBrain():think();
        end
    end

end

function FBTeam:onStartMatch(networkControl)
    local num = #self.m_teamMembers;
    for i = 1, num do
        local player = self.m_teamMembers[i];
        player:getBrain():setNetworkControl(networkControl);
    end
    
    self:setHilightPlayerId(num - 1);
    return true;

end

function FBTeam:kickOff(playerNumber)
    local player = self:getPlayer(playerNumber);
    player:gainBall();
    self.m_state = matchDefs.TEAM_STATE.ATTACKING;
end

function FBTeam:getHilightPlayer()
    return self:getPlayer(self.m_hilightPlayerId);
end

function FBTeam:getPlayer(idx)
    if (idx >= 1 and idx <= #self.m_teamMembers) then
        return self.m_teamMembers[idx];
    end
    
    return nil;

end

function FBTeam:getPlayerNumber()
    return #self.m_teamMembers;
end

function FBTeam:isAttacking()
    return self.m_state == matchDefs.TEAM_STATE.ATTACKING;
end

function FBTeam:isDefending()
    return self.m_state == matchDefs.TEAM_STATE.DEFENDING;
end

function FBTeam:setAttacking(attacking)
    self.m_state = attacking and matchDefs.TEAM_STATE.ATTACKING or matchDefs.TEAM_STATE.DEFENDING;
end


function FBTeam:loseBall()
    for i = 1, #self.m_teamMembers do
        local player = self.m_teamMembers[i];
        player:loseBall();
    end
end

function FBTeam:gainBall(playerId)
    self.m_teamMembers[playerId]:gainBall();
end

function FBTeam:stun(players)
    for i = 1, #players do
        local p = players[i];
        m_teamMembers[p]:stun();
    end
end

function FBTeam:getTeamMembers()
    return self.m_teamMembers;
end

    
function FBTeam:getLastPosOfPlayer()
    return self.m_lastPosOfPlayer;
end

    
function FBTeam:getActivePlayer()
    return self.m_activePlayerId;
end

function FBTeam:getAssistantPlayer()
    return self.m_assistantPlayerId;
end

function FBTeam:setActivePlayer(p)
    self.m_activePlayerId = p;
end

function FBTeam:setAssistantPlayer(p)
    self.m_assistantPlayerId = p;
end

    
function FBTeam:updateFieldStatusOnAttack()
    local pitch = g_matchManager:getPitch();
    local pp = self:getHilightPlayer();
    
    local sizeSq = matchDefs.PASS_BALL_REDUCTION * matchDefs.PASS_BALL_REDUCTION;
    
    local gridsAroundPlayer;
    HDVector.extend(gridsAroundPlayer);
    
    for i = 1, #self.m_teamMembers do
        local player = self.m_teamMembers[i];
        local ai = player:getBrain();
        ai:setPassBallScore(constVar.Sys.INT_MIN);
        
        local pos = player:getPosition();
        
        if (not player.m_isGoalKeeper and pp ~= player) then
        
            ai:setPassBallScore(0);
            
            -- can shoot directly?
            if (self:canShootDirectly(player)) then
            
                ai:increasePassBallScore(50);
            end
            
            local num = self:getNumberOfDefenderBetweenPlayerAndBall(player);
            ai:increasePassBallScore(-20 * num);
            
            num = self:getNumberOfDefenderAroundPlayer(player);
            ai:increasePassBallScore(-10 * num);
            
            local dist = pp:getPosition().getDistanceSq(pos);
            if (dist > sizeSq) then
            
                ai:increasePassBallScore((dist - sizeSq) * (-1));
            end
        end
        
        if (pitch:getGridsAroundPosition(pos, gridsAroundPlayer)) then
        
            for j = 1, #gridsAroundPlayer do
                local gid = gridsAroundPlayer[j];
            
                pitch:increaseGridDefenceScore(gid, -10);
            end
        end
        
    end
    
    local side = getSide();
    local otherSide = pitch:getOtherSide(side);
    local otherTeam = g_matchManager:getTeam(otherSide);
    local teamMembers = otherTeam:getTeamMembers();
    
    for i = 1, #teamMembers do
        local player = teamMembers[i];
    
        if (pitch:getGridsAroundPosition(player:getPosition(), gridsAroundPlayer)) then
        
            for j = 1, #gridsAroundPlayer do
                local gid = gridsAroundPlayer[j];
            
                pitch:increaseGridDefenceScore(gid, -20);
            end
        end
    end

end

function FBTeam:updateFieldStatusOnDefend()
end

    
function FBTeam:canShootDirectly(player)
    local side = getSide();
    local pitch = g_matchManager:getPitch();
    local otherSide = pitch:getOtherSide(side);
    local gp = pitch:getGoalPos(otherSide);
    
    local otherTeam = g_matchManager:getTeam(otherSide);
    local teamMember = otherTeam:getTeamMembers();
    for i = 1, #teamMember do
        local t = teamMember[i];
    
        if (matchDefs.isPointOnTheWay(player:getPosition(), gp, t:getPosition())) then
        
            return false;
        end
    end
    
    teamMember = self:getTeamMembers();
    for i = 1, #teamMember do
        local t = teamMember[i];
    
        if (t ~= player and matchDefs.isPointOnTheWay(player:getPosition(), gp, t:getPosition())) then
        
            return false;
        end
    end
    return true;

end

function FBTeam:getNumberOfDefenderBetweenPlayerAndBall(CFBPlayer* player)
end

function FBTeam:getNumberOfDefenderAroundPlayer(CFBPlayer* player)
end

    
function FBTeam:setHilightPlayerId(int pid) { m_hilightPlayerId = pid;
end

function FBTeam:getHilightPlayerId() { return m_hilightPlayerId;
end

    
function FBTeam:switchHilightPlayer()
end

    
function FBTeam:getPassBallTarget()
end


function FBTeam:getSide()
end

    
    
return FBTeam


