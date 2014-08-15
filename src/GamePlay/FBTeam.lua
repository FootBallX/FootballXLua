
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


function FBTeam:addPlayer(const CFBPlayerInitInfo& info)
    CFBPlayer* player = new CFBPlayer(this, info.card);
    player->setPosition(info.position);
    
    switch (info.aiClass)
    {
        case 0:
            player->createBrain(FBDefs::AI_CLASS::GOAL_KEEPER, info.homePosition, FBDefs::GOALKEEPER_ORBIT_RATE);
            break;
        case 1:
            player->createBrain(FBDefs::AI_CLASS::BACK, info.homePosition, FBDefs::BACK_ORBIT_RATE);
            break;
        case 2:
            player->createBrain(FBDefs::AI_CLASS::HALF_BACK, info.homePosition, FBDefs::HALF_BACK_ORBIT_RATE);
            break;
        case 3:
            player->createBrain(FBDefs::AI_CLASS::FORWARD, info.homePosition, FBDefs::FORWARD_ORBIT_RATE);
            break;
        default:
            CC_ASSERT(false);
            break;
    }

    m_teamMembers.push_back(player);
    
    player->m_positionInFormation = (int)m_teamMembers.size() - 1;
end

function FBTeam:update(float dt)
end

function FBTeam:think()
end

function FBTeam:onStartMatch(bool networkControl)
end

function FBTeam:kickOff(int playerNumber)
end

function FBTeam:getHilightPlayer()
end

function FBTeam:getPlayer(int idx)
end

function FBTeam:getPlayerNumber()
end

function FBTeam:isAttacking()
    return m_state == FBDefs::TEAM_STATE::ATTACKING;
end

function FBTeam:isDefending()
    return m_state == FBDefs::TEAM_STATE::DEFENDING;
end

function FBTeam:setAttacking(bool attacking)
    m_state = attacking ? FBDefs::TEAM_STATE::ATTACKING : FBDefs::TEAM_STATE::DEFENDING;
end

function FBTeam:loseBall()
end

function FBTeam:gainBall(int playerId)
end

function FBTeam:stun(vector<int>& players)
end

function FBTeam:getTeamMembers()
    return m_teamMembers;
end

    
function FBTeam:getLastPosOfPlayer()
    return m_lastPosOfPlayer;
end

    
function FBTeam:getActivePlayer()
    return m_activePlayerId;
end

function FBTeam:getAssistantPlayer()
    return m_assistantPlayerId;
end

function FBTeam:setActivePlayer(int p)
    m_activePlayerId = p;
end

function FBTeam:setAssistantPlayer(int p)
    m_assistantPlayerId = p;
end

    
function FBTeam:updateFieldStatusOnAttack()
end

function FBTeam:updateFieldStatusOnDefend()
end

    
function FBTeam:canShootDirectly(CFBPlayer* player)
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