
local FBPlayer = class("FBPlayer")

function FBPlayer:ctor()
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
    self.m_ownerTeam = nil;
    self.m_playerCard = nil;

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

    virtual bool createBrain(FBDefs::AI_CLASS aiClass, const Point& homePos, float orbit);
    virtual CFBPlayerAI* getBrain();
    virtual CFBTeam* getOwnerTeam() const;
    
    virtual const CFBCard& getPlayerCard() const { return m_playerCard; }
    
    virtual void setPosition(const cocos2d::Point& pos);
    virtual const cocos2d::Point& getPosition() { return m_curPosition; }
    
    virtual void setMovingVector(const cocos2d::Point& vec);
    virtual void setMovingVector(float x, float y);
    virtual const cocos2d::Point& getMovingVector() { return m_movingVector; }
    virtual bool moveTo(const cocos2d::Point& pos, float dt = 0.f);
    virtual bool moveFromTo(const cocos2d::Point& pos, const cocos2d::Point& vec, float dt, float duration);
    
    virtual void setInstruction(FBDefs::PLAYER_INS ins) { m_instruction = ins; }
    virtual FBDefs::PLAYER_INS getInstruction() { return m_instruction; }

    virtual void gainBall();
    virtual void loseBall();
    virtual void stun();
    virtual bool isStunned();

    virtual float getSpeed();

return FBPlayer