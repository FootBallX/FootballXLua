require "Cocos2d"
require "Cocos2dConstants"
require "Common"
require "constVar"
require "GameDatas"
require "GamePlay.MatchDefs"
require "GamePlay.FBPitch"


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
--    
--    BREAK_IF_FAILED(m_pitch->init(pitchWidth, pitchHeight));
--    
--    m_teams[0] = new CFBTeam(FBDefs::SIDE::LEFT);
--    m_teams[1] = new CFBTeam(FBDefs::SIDE::RIGHT);
--    
--    m_playerDistanceSq = FBDefs::PLAYER_DISTANCE * FBDefs::PLAYER_DISTANCE;
--
--    m_matchStep = FBDefs::MATCH_STEP::WAIT_START;
end

--    
--    void update(float dt);
--    
--    bool startMatch();
--    void setControlSide(FBDefs::SIDE side);
--    bool checkControlSide(FBDefs::SIDE side);
--    CFBTeam* getControlSideTeam();
--    FBDefs::SIDE getControlSide();
--    
--    CFBTeam* getTeam(FBDefs::SIDE side);
--    CFBTeam* getOtherTeam(CFBTeam* team);
--    
--    CFBTeam* getAttackingTeam();
--    CFBTeam* getDefendingTeam();
--    
--    bool isBallOnTheSide(FBDefs::SIDE side);
--    void setBallPosition(const cocos2d::Point& pos);
--    float getBallPosRateBySide(FBDefs::SIDE side);
--    const cocos2d::Point& getBallPosition();
--    
--    void pauseGame(bool p);
--    bool isPausing() { return m_isPause; }
--    
--    void tryPassBall(CFBPlayer* from, CFBPlayer* to);
--    void tryShootBall(CFBPlayer* player, bool isAir);
--    
--    void playAnimation(const string& name, float delay);
--    void onAnimationEnd();
--    
--    FBDefs::MATCH_STEP getMatchStep();
--    void setBallControllerMove(const cocos2d::Point& vec);
--    
--    int getOneTwoPlayer();      // 自动选取二过一的协助球员
--    
--    int getCountDownTime();
--    unsigned int getTime();
--
--    void setMenuItem(FBDefs::MENU_ITEMS mi, int targetPlayer = -1);

g_matchManager = MatchManager.new() 


