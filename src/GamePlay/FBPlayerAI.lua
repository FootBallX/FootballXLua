
FBPlayerAI = class("FBPlayerAI")


--if (self.m_aiType == matchDefs.AI_CLASS.GOALKEEPER) then
--
--elseif (self.m_aiType == matchDefs.AI_CLASS.BACK) then
--
--elseif (self.m_aiType == matchDefs.AI_CLASS.HALF_BACK) then
--
--elseif (self.m_aiType == matchDefs.AI_CLASS.FORWARD) then
--
--end
    

function FBPlayerAI:ator()
    self.m_team = nil;
    self.m_player = nil;
    self.m_origHomePosition = cc.p(0, 0);
    self.m_homePosition = cc.p(0, 0);
    self.m_defendOrbitRadius = 0;
    self.m_defendOrbitRadiusSq = 0;
    self.m_defendOrbitRadiusx2Sq = 0;
    
    self.m_state = matchDefs.AI_STATE.NONE;
    self.m_controlState = matchDefs.AI_STATE_CONTROL.NONE;
    self.m_moveToTarget = cc.p(0, 0);
    self.m_waitTime = 0.0;
    self.m_passBallScore = 0;
    
    self.m_aiType = matchDefs.AI_CLASS.NONE;
end


function FBPlayerAI:init(team, player, homePos, orbit, type)
    if (player == nil) then return false end
    if (team == nil) then return false end
    
    self.m_team = team;
    self.m_player = player;
    
    self.m_homePosition = homePos;
    self.m_origHomePosition = self.m_homePosition;
    
    self.m_defendOrbitRadius = orbit;
    self.m_defendOrbitRadiusSq = self.m_defendOrbitRadius * self.m_defendOrbitRadius;
    self.m_defendOrbitRadiusx2Sq = (2 * self.m_defendOrbitRadius) * (2 * self.m_defendOrbitRadius);
    
    self.m_state = matchDefs.AI_STATE.NONE;

    self.m_aiType = type;
    if (self.m_aiType == matchDefs.AI_CLASS.GOALKEEPER) then
        self.m_player.m_isGoalKeeper = true;
    elseif (self.m_aiType == matchDefs.AI_CLASS.BACK) then
        self.m_player.m_isGoalKeeper = false;
    elseif (self.m_aiType == matchDefs.AI_CLASS.HALF_BACK) then
        self.m_player.m_isGoalKeeper = false;
    elseif (self.m_aiType == matchDefs.AI_CLASS.FORWARD) then
        self.m_player.m_isGoalKeeper = false;
    end
    
    return true;
end


function FBPlayerAI:setNetworkControl(networkControl)
    if (networkControl) then
        self.m_state = matchDefs.AI_STATE.NETWORK;
    else
        self.m_state = matchDefs.AI_STATE.NONE;
    end
end


function FBPlayerAI:think()
    if (self.m_state == matchDefs.AI_STATE.NETWORK) then return end
    
    if (self.m_team:getHilightPlayer() ~= self.m_player) then
        if (self.m_team:isAttacking()) then
            self:thinkOnAttacking();
        elseif (self.m_team:isDefending()) then
            self:thinkOnDefending();
        end
    else
        self.m_state = matchDefs.AI_STATE.USER_CONTROL;
    end
end



function FBPlayerAI:thinkOnAttacking()

    self:considerSupport();
    if (self.m_state == matchDefs.AI_STATE.NONE) then
        self:updateHomePosition();
        
        local pitch = g_matchManager:getPitch();
        local homePos = pitch:transformBySide(self.m_homePosition, self.m_team:getSide());
        self.m_player:moveTo(homePos);
    end
end



function FBPlayerAI:thinkOnDefending()
    self:considerChase();
    if (self.m_state == matchDefs.AI_STATE.NONE) then
        self:updateHomePosition();
        
        local pitch = g_matchManager:getPitch();
        local homePos = pitch:transformBySide(self.m_homePosition, self.m_team:getSide());
        
        self.m_player:moveTo(homePos);
    end
end



function FBPlayerAI:updateHomePosition()
    if (self.m_aiType == matchDefs.AI_CLASS.GOALKEEPER) then
        local pitch = g_matchManager:getPitch();
        local pitchHeight = pitch:getPitchHeight();
        local halfPitchHeight = pitchHeight * 0.5;
        local ballPos = g_matchManager:getBallPosition();
        
        local yRate = (ballPos.y - halfPitchHeight) / halfPitchHeight;
        local yOffset = yRate * 0.2;
        
        self.m_homePosition.y = self.m_origHomePosition.y + yOffset;
        self.m_homePosition.x = self.m_origHomePosition.x;
    elseif (self.m_aiType == matchDefs.AI_CLASS.BACK) then
        local pitch = g_matchManager:getPitch();
    
        local pitchHeight = pitch:getPitchHeight();
        local halfPitchHeight = pitchHeight * 0.5;
        local ballPos = g_matchManager:getBallPosition();
        
        local yRate = (ballPos.y - halfPitchHeight) / halfPitchHeight;
        
        local yOffset = yRate * matchDefs.OFFSET_Y;
        self.m_homePosition.y = self.m_origHomePosition.y + yOffset;
        
        local side = self.m_team:getSide();
        local ballRate = g_matchManager:getBallPosRateBySide(side);
        
        if (self.m_team:isAttacking()) then
        
            if (g_matchManager:isBallOnTheSide(side)) then
            
                ballRate = ballRate / 0.5;
                self.m_homePosition.x = self.m_origHomePosition.x + matchDefs.ATK_DEF_BACK_LINE_MIN + (matchDefs.ATK_DEF_BACK_LINE_MAX - matchDefs.ATK_DEF_BACK_LINE_MIN) * ballRate;
            
            else
            
                ballRate = 1 - (1 - ballRate) / 0.5;
                self.m_homePosition.x = self.m_origHomePosition.x + matchDefs.ATK_ATK_BACK_LINE_MIN + (matchDefs.ATK_ATK_BACK_LINE_MAX - matchDefs.ATK_ATK_BACK_LINE_MIN) * ballRate;
            end
        
        else
        
            if (g_matchManager:isBallOnTheSide(side)) then
            
                ballRate = ballRate / 0.5;
                self.m_homePosition.x = self.m_origHomePosition.x + matchDefs.DEF_DEF_BACK_LINE_MIN + (matchDefs.DEF_DEF_BACK_LINE_MAX - matchDefs.DEF_DEF_BACK_LINE_MIN) * ballRate;
            
            else
            
                ballRate = 1 - (1 - ballRate) / 0.5;
                self.m_homePosition.x = self.m_origHomePosition.x + matchDefs.DEF_ATK_BACK_LINE_MIN + (matchDefs.DEF_ATK_BACK_LINE_MAX - matchDefs.DEF_ATK_BACK_LINE_MIN) * ballRate;
            end
        end
    elseif (self.m_aiType == matchDefs.AI_CLASS.HALF_BACK) then
        local pitch = g_matchManager:getPitch();
        
        local pitchHeight = pitch:getPitchHeight();
        local halfPitchHeight = pitchHeight * 0.5;
        local ballPos = g_matchManager:getBallPosition();
        
        local yRate = (ballPos.y - halfPitchHeight) / halfPitchHeight;
        local yOffset = yRate * matchDefs.OFFSET_Y;
        self.m_homePosition.y = self.m_origHomePosition.y + yOffset;
        
        local side = self.m_team:getSide();
        local ballRate = g_matchManager:getBallPosRateBySide(side);
        
        if (self.m_team:isAttacking()) then
        
            if (g_matchManager:isBallOnTheSide(side)) then
            
                ballRate = ballRate / 0.5;
                self.m_homePosition.x = self.m_origHomePosition.x + matchDefs.ATK_DEF_HALF_BACK_LINE_MIN + (matchDefs.ATK_DEF_HALF_BACK_LINE_MAX - matchDefs.ATK_DEF_HALF_BACK_LINE_MIN) * ballRate;
            
            else
            
                ballRate = 1 - (1 - ballRate) / 0.5;
                self.m_homePosition.x = self.m_origHomePosition.x + matchDefs.ATK_ATK_HALF_BACK_LINE_MIN + (matchDefs.ATK_ATK_HALF_BACK_LINE_MAX - matchDefs.ATK_ATK_HALF_BACK_LINE_MIN) * ballRate;
            end
        
        else
        
            if (g_matchManager:isBallOnTheSide(side)) then
            
                ballRate = ballRate / 0.5;
                self.m_homePosition.x = self.m_origHomePosition.x + matchDefs.DEF_DEF_HALF_BACK_LINE_MIN + (matchDefs.DEF_DEF_HALF_BACK_LINE_MAX - matchDefs.DEF_DEF_HALF_BACK_LINE_MIN) * ballRate;
            
            else
            
                ballRate = 1 - (1 - ballRate) / 0.5;
                self.m_homePosition.x = self.m_origHomePosition.x + matchDefs.DEF_ATK_HALF_BACK_LINE_MIN + (matchDefs.DEF_ATK_HALF_BACK_LINE_MAX - matchDefs.DEF_ATK_HALF_BACK_LINE_MIN) * ballRate;
            end
        end

    elseif (self.m_aiType == matchDefs.AI_CLASS.FORWARD) then
        local pitch = g_matchManager:getPitch();
        
        local pitchHeight = pitch:getPitchHeight();
        local halfPitchHeight = pitchHeight * 0.5;
        local ballPos = g_matchManager:getBallPosition();
        
        local yRate = (ballPos.y - halfPitchHeight) / halfPitchHeight;
        local yOffset = yRate * matchDefs.OFFSET_Y;
        self.m_homePosition.y = self.m_origHomePosition.y + yOffset;
        
        local side = self.m_team:getSide();
        local ballRate = g_matchManager:getBallPosRateBySide(side);
        
        if (self.m_team:isAttacking()) then
        
            if (g_matchManager:isBallOnTheSide(side)) then
            
                ballRate = ballRate / 0.5;
                self.m_homePosition.x = self.m_origHomePosition.x + matchDefs.ATK_DEF_FORWORD_LINE_MIN + (matchDefs.ATK_DEF_FORWORD_LINE_MAX - matchDefs.ATK_DEF_FORWORD_LINE_MIN) * ballRate;
            
            else
            
                ballRate = 1 - (1 - ballRate) / 0.5;
                self.m_homePosition.x = self.m_origHomePosition.x + matchDefs.ATK_ATK_FORWORD_LINE_MIN + (matchDefs.ATK_ATK_FORWORD_LINE_MAX - matchDefs.ATK_ATK_FORWORD_LINE_MIN) * ballRate;
            end
        
        else
        
            if (g_matchManager:isBallOnTheSide(side)) then
            
                ballRate = ballRate / 0.5;
                self.m_homePosition.x = self.m_origHomePosition.x + matchDefs.DEF_DEF_FORWORD_LINE_MIN + (matchDefs.DEF_DEF_FORWORD_LINE_MAX - matchDefs.DEF_DEF_FORWORD_LINE_MIN) * ballRate;
            
            else
            
                ballRate = 1 - (1 - ballRate) / 0.5;
                self.m_homePosition.x = self.m_origHomePosition.x + matchDefs.DEF_ATK_FORWORD_LINE_MIN + (matchDefs.DEF_ATK_FORWORD_LINE_MAX - matchDefs.DEF_ATK_FORWORD_LINE_MIN) * ballRate;
            end
        end
        
        self:PreventOffside(self.m_homePosition.x);
    end
end


function FBPlayerAI:update(dt)
    self.m_player:update(dt);
end



function FBPlayerAI:considerSupport()
    if (self.m_aiType == matchDefs.AI_CLASS.GOALKEEPER) then

    elseif (self.m_aiType == matchDefs.AI_CLASS.BACK) then

    elseif (self.m_aiType == matchDefs.AI_CLASS.HALF_BACK) then

    elseif (self.m_aiType == matchDefs.AI_CLASS.FORWARD) then
        if (self.m_state == matchDefs.AI_STATE.BACKHOME) then

            local side = self.m_team:getSide();
            if (not g_matchManager:isBallOnTheSide(side)) then

                if (self.m_state ~= matchDefs.AI_STATE.SUPPORT and self.m_state ~= matchDefs.AI_STATE.WAIT) then

                    self.m_state = matchDefs.AI_STATE.SUPPORT;
                    self.m_supportState = matchDefs.AI_STATE_SUPPORT.FIND_POS;
                end
            end
        end
    end


end


function FBPlayerAI:returnToHome(dt)
    local pitch = g_matchManager:getPitch();
    local homePos = pitch:transformBySide(self.m_homePosition, self.m_team:getSide());

    self.m_player:moveTo(homePos);
end



function FBPlayerAI:chaseBall(dt)
    local pitch = g_matchManager:getPitch();
    local homePos = pitch:transformBySide(self.m_homePosition, self.m_team:getSide());
    
    if (self.m_team:isDefending()) then
        local ballPos = g_matchManager:getBallPosition();
        
        local ls = (homePos - self.m_player:getPosition()).getLengthSq();
        if (ls >= self.m_defendOrbitRadiusx2Sq) then
            self.m_state = matchDefs.AI_STATE.BACKHOME;
            
            local actp = self.m_team:getActivePlayer();
            local assp = self.m_team:getAssistantPlayer();
            
            if (actp == self.m_player.m_positionInFormation) then
                self.m_team:setActivePlayer(-1);
                
                if (assp > -1) then
                
                    local playerAI = self.m_team:getPlayer(assp):getBrain();
                    playerAI.m_state = matchDefs.AI_STATE.BACKHOME;
                    
                    self.m_team:setAssistantPlayer(-1);
                end
            
            elseif (assp == self.m_player.m_positionInFormation) then
            
                self.m_team:setAssistantPlayer(-1);
            end
        else
            local actp = self.m_team:getActivePlayer();
            if (actp == -1) then
            
                self.m_team:setActivePlayer(self.m_player.m_positionInFormation);
            
            elseif (actp == self.m_player.m_positionInFormation) then
            
                self.m_player:moveTo(ballPos);
            
            else
            
                local assp = self.m_team:getAssistantPlayer();
                if (assp == -1) then
                
                    self.m_team:setAssistantPlayer(self.m_player.m_positionInFormation);
                
                elseif (assp == self.m_player.m_positionInFormation) then
                
                    self.m_player:moveTo(pitch:getBestAssistantDeffendingPosition(ballPos, self.m_team:getSide()));
                
                else
                
                    this.m_state = matchDefs.AI_STATE.BACKHOME;
                end
            end
        end
    end
end



function FBPlayerAI:considerChase()

    local ballPos = g_matchManager:getBallPosition();
    local pitch = g_matchManager:getPitch();
    local homePos = pitch:transformBySide(self.m_homePosition, self.m_team:getSide());

    if (self.m_state ~= matchDefs.AI_STATE.CHASE) then
    
        if ((homePos - ballPos).getLengthSq() < self.m_defendOrbitRadiusSq) then
        
            self.m_state = matchDefs.AI_STATE.CHASE;
        end
    end
    
    if (self.m_state == matchDefs.AI_STATE.CHASE) then
    
        local actp = self.m_team:getActivePlayer();
        local assp = self.m_team:getAssistantPlayer();
        
        if ((homePos - self.m_player:getPosition()).getLengthSq() >= self.m_defendOrbitRadiusx2Sq) then
        
            self.m_state = matchDefs.AI_STATE.NONE;
            
            if (actp == self.m_player.m_positionInFormation) then
            
                self.m_team:setActivePlayer(-1);
                
                if (assp > -1) then
                
                    local playerAI = self.m_team:getPlayer(assp):getBrain();
                    playerAI.m_state = matchDefs.AI_STATE.NONE;
                    
                    self.m_team:setAssistantPlayer(-1);
                end
            
            elseif (assp == self.m_player.m_positionInFormation) then
            
                self.m_team:setAssistantPlayer(-1);
            end
        else
        
            if (actp == -1 or actp == self.m_player.m_positionInFormation) then
            
                self.m_team:setActivePlayer(self.m_player.m_positionInFormation);
                self.m_player:moveTo(ballPos);
            
            elseif (assp == -1 or assp == self.m_player.m_positionInFormation) then
            
                self.m_team:setAssistantPlayer(self.m_player.m_positionInFormation);
                self.m_player:moveTo(pitch:getBestAssistantDeffendingPosition(ballPos, self.m_team:getSide()));
            end
        end
    end
end



function FBPlayerAI:updateWait(dt)

    if (self.m_state == matchDefs.AI_STATE.WAIT) then
    
        self.m_waitTime = self.m_waitTime - dt;
        if (self.m_waitTime <= 0.0) then
        
            -- debug
            if (self.m_team:getSide() == matchDefs.SIDE.LEFT) then
            
                cclog("1");
            end
            -- end
            self.m_state = matchDefs.AI_STATE.NONE;
        end
    end
end



function FBPlayerAI:startWait(t)

    self.m_waitTime = t;
    self.m_state = matchDefs.AI_STATE.WAIT;
end



function FBPlayerAI:updateAIControlBall(dt)

    if self.m_controlState == matchDefs.AI_STATE_CONTROL.DRIBBLE then
        if (self.m_player:moveTo(self.m_moveToTarget)) then
        
            self.m_controlState = matchDefs.AI_STATE_CONTROL.NONE;
        end
    end
end



function FBPlayerAI:PreventOffside(x)

    local pitch = g_matchManager:getPitch();
    local side = self.m_team:getSide();
    local otherSide = pitch:getOtherSide(side);
    
    local offsideLine = g_matchManager:getTeam(otherSide):getLastPosOfPlayer();
    offsideLine = pitch:getPitchWidth() - pitch:transformBySide(offsideLine, otherSide);
    
    if (x > offsideLine) then
        x = offsideLine;
    end
    
    return x
end




function FBPlayerAI:increasePassBallScore(inc)

    self.m_passBallScore = self.m_passBallScore + inc;
end



function FBPlayerAI:thinkControlBall()

    self:thinkDribbleBall();
    self:thinkPassBall();
end



function FBPlayerAI:thinkDribbleBall()
    if (self.m_controlState ~= matchDefs.AI_STATE_CONTROL.NONE) then return; end
    
    local side = self.m_team:getSide();
    local pitch = g_matchManager:getPitch();
    local otherSide = pitch:getOtherSide(side);
    local otherTeam = g_matchManager:getTeam(otherSide);
    local otherTeamMembers = otherTeam:getTeamMembers();
    local teamMembers = self.m_team:getTeamMembers();
    
    local p1 = self.m_player:getPosition();
    local aheadPos = p1;
    
    local checkLength = matchDefs.DRIBBLE_CHECK_DIST;
    
    if (side == matchDefs.SIDE.LEFT) then
    
        aheadPos.x = aheadPos.x + checkLength;
    
    else
    
        aheadPos.x = aheadPos.x - checkLength;
    end
    
    local goalDirPos = cc.pAdd(p1, cc.pMul(cc.pNormalize(cc.pSub(pitch:getGoalPos(otherSide), p1)), checkLength));
    
    
    local ok = true;

    for i = 1, #otherTeamMembers do
        local player = otherTeamMembers[i]
        if (matchDefs.isPointOnTheWay(p1, goalDirPos, player:getPosition())) then
            ok = false;
            break;
        end
    end
    
    if (ok) then
    
        self.m_controlState = matchDefs.AI_STATE_CONTROL.DRIBBLE;
        self.m_moveToTarget = goalDirPos;
        return;
    end
    
    for i = 1, #otherTeamMembers do
        local player = otherTeamMembers[i]
    
        if (matchDefs.isPointOnTheWay(p1, aheadPos, player:getPosition())) then
        
            ok = false;
            break;
        end
    end
    
    if (ok) then
    
        self.m_controlState = matchDefs.AI_STATE_CONTROL.DRIBBLE;
        self.m_moveToTarget = aheadPos;
        return;
    end
end



function FBPlayerAI:thinkPassBall()

    if (self.m_controlState ~= matchDefs.AI_STATE_CONTROL.NONE) then return; end
    
    self.m_team:updateFieldStatusOnAttack();
    local target = self.m_team:getPassBallTarget();
    
    if (target) then
    
        g_matchManager:tryPassBall(self.m_player, target);
    end
end


function FBPlayerAI:getPlayer()
    return self.m_player;
end

function FBPlayerAI:getPassBallScore()
    return self.m_passBallScore;
end
    
function FBPlayerAI:setPassBallScore(s)
    self.m_passBallScore = s;
end
    
    
function FBPlayerAI:updateSupport(dt)

    if (self.m_aiType == matchDefs.AI_CLASS.GOALKEEPER) then
    
    elseif (self.m_aiType == matchDefs.AI_CLASS.BACK) then
    
    elseif (self.m_aiType == matchDefs.AI_CLASS.HALF_BACK) then
    
    elseif (self.m_aiType == matchDefs.AI_CLASS.FORWARD) then

        if self.m_supportState == matchDefs.AI_STATE_SUPPORT.FIND_POS then
        
            local pitch = g_matchManager:getPitch();
            self.m_moveToTarget = pitch:getBestSupportPosition(self.m_team:getSide());
            self.m_supportState = matchDefs.AI_STATE_SUPPORT.MOVE_TO_POS;
            self:PreventOffside(self.m_moveToTarget.x);

        
        elseif self.m_supportState == matchDefs.AI_STATE_SUPPORT.MOVE_TO_POS then
        
            if (self.m_player:moveTo(self.m_moveToTarget)) then
            
                self:startWait(2.0);
            end
        end

    end
end

return FBPlayerAI

