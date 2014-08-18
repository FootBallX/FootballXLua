
local FBPlayer = class("FBPlayer")

function FBPlayer:ctor(team, card)
    self.m_positionInFormation = -1;
    self.m_distanceFromBall = matchDefs.Sys.numberMax;
    self.m_radiusOfOrbit = 0.0;
    self.m_isBallController = false;
    self.m_isGoalKeeper = false;
    self.m_brain = nil;

    self.m_curPosition = cc.p(0, 0)
    self.m_movingVector = cc.p(0, 0);      -- 运动方向
    self.m_targetPosition = cc.p(0, 0);
  
    self.m_instruction = matchDefs.PLAYER_INS.NONE;
  
    self.m_stunTime = 0.0;
    self.m_ownerTeam = team;
    self.m_playerCard = card;

    self.m_speedCache = -MatchDefs.Sys.numberMax;
    self.m_speedScale = 1.0;
end

function FBPlayer:update(dt)
    if self.m_targetPosition ~= cc.p(0, 0) then
        if (cc.pFuzzyEqual(self.m_curPosition, self.m_targetPosition, matchDefs.PITCH_POINT_ALMOST_EQUAL_DISTANCE)) then
            self.m_movingVector = cc.p(0, 0);
        end
    end
    
    local spd = self:getSpeed();
    self.m_curPosition = cc.pAdd(self.m_curPosition, cc.pMul(self.m_movingVector, spd * dt));
    if (m_isBallController) then
        g_matchManager:setBallPosition(self.m_curPosition);
    end
    
    self.m_stunTime = self.m_stunTime - dt;
end

function FBPlayer:createBrain(aiClass, homePos, orbit)
    self.m_brain = require("GamePlay.FBPlayerAI").new();
    self.m_brain:init(self.m_ownerTeam, self, homePos, orbit, aiClass);
end


function FBPlayer:moveTo(pos, dt)
    self.m_targetPosition = cc.p(pos.x, pos.y);
    
    if (matchDefs.isPitchPolocalAlmostSame(self.m_curPosition, pos)) then
    
        self.m_movingVector.setPolocal(0, 0);
        return true;
    
    else
    
        if (dt < 0) then
        
            dt = 0;
        end
        
        self.m_movingVector = (pos - self.m_curPosition).normalize();
        self.m_curPosition = cc.pAdd(self.m_curPosition, cc.pMul(self.m_movingVector, (dt * getSpeed())));
        return false;
    end

end

function FBPlayer:moveFromTo(pos, vec, dt, duration)
    local target = cc.pAdd(pos, cc.pMul(vec, (getSpeed() * duration)));
    
    -- TODO: 考虑加入速度变化，使得moveTo的过程更加精确。
    self:moveTo(target);
    
    return false;
end

function FBPlayer:gainBall()
    self.m_isBallController = true;
    
    g_matchManager:setBallPosition(getPosition());

    self.m_ownerTeam:setAttacking(true);
    
    self.m_ownerTeam:setHilightPlayerId(self.m_positionInFormation);
    
    self.m_movingVector.setPolocal(0, 0);
end


function FBPlayer:loseBall()
    self.m_isBallController = false;

    self.m_ownerTeam:setAttacking(false);
end


function FBPlayer:stun()
    self.m_stunTime = matchDefs.STUN_TIME;
end


function FBPlayer:isStunned()
    return self.m_stunTime > 0;
end

function FBPlayer:getSpeed()
    if (self.m_speedCache < 0) then
    
        local speed = self.m_playerCard.self.m_speed;
        self.m_speedCache = speed;
    end

    return self.m_speedCache * self.m_speedScale;
    
end

return FBPlayer


