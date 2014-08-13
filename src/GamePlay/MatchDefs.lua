require "Cocos2d"
require "Cocos2dConstants"

MatchDefs = {
    STUN_TIME = 2.0,
    MAX_CARD_ICON_LEN = 32,
    PITCH_POINT_ALMOST_EQUAL_DISTANCE = 4.0,
    GOALKEEPER_ORBIT_RATE = 100,
    BACK_ORBIT_RATE = 150,
    HALF_BACK_ORBIT_RATE = 150,
    FORWARD_ORBIT_RATE = 100,
    
    FORMATION =
    {
        "F_4_4_2",
        "F_3_2_3_2",
        "NONE",
    },
    
    InitFormation = {
        -- F_4_4_2
        {
            cc.p(25, 325),
            cc.p(140, 120), cc.p(140, 222.5), cc.p(140, 427.5), cc.p(140, 530),
            cc.p(300, 120), cc.p(300, 222.5), cc.p(300, 427.5), cc.p(300, 530),
            cc.p(440, 260), cc.p(500, 330),
        },
        -- F_3_2_3_2
        {
            cc.p(25, 325),
            cc.p(140, 190), cc.p(140, 325), cc.p(140, 460),
            cc.p(240, 230), cc.p(240, 420),
            cc.p(340, 190), cc.p(340, 325), cc.p(340, 460),
            cc.p(440, 260), cc.p(500, 330),
        },
    },
    
    HomeFormation = {
        -- F_4_4_2
        {
            cc.p(0, 325),
            cc.p(0, 120), cc.p(0, 222.5), cc.p(0, 427.5), cc.p(0, 530),
            cc.p(0, 120), cc.p(0, 222.5), cc.p(0, 427.5), cc.p(0, 530),
            cc.p(0, 260), cc.p(0, 330),
        },
        -- F_3_2_3_2
        {
            cc.p(0, 325),
            cc.p(0, 190), cc.p(0, 325), cc.p(0, 460),
            cc.p(-50, 230), cc.p(-50, 420),
            cc.p(50, 190), cc.p(50, 325), cc.p(50, 460),
            cc.p(0, 260), cc.p(0, 330),
        },
    },
    
    OFFSET_Y = 100,          -- 无球球员横向移动的偏移范围
    PASS_BALL_REDUCTION = 200,   -- 传球的衰减距离，超过这个距离的传球可能性会减小
    DEFENDER_PLAYER_RADIUS = 100, -- 检查这个半径范围内的对方球员为防守球员
    DRIBBLE_CHECK_DIST = 200,    -- 传球的检查长度，在这个长度的前方范围没有对方球员则可以传球
    ASSIST_DEFEND_DIST = 75,  -- 协防球员与控球球员间保持的一定距离
    
    PITCH_WIDTH = 1000,
    PITCH_HEIGHT = 650,
    
    GOAL_KEEPER_LINE = 50,
    -- 进攻中，球在己方半场
    ATK_DEF_BACK_LINE_MIN = 50,
    ATK_DEF_BACK_LINE_MAX = 200,
    ATK_DEF_HALF_BACK_LINE_MIN = 200,
    ATK_DEF_HALF_BACK_LINE_MAX = 400,
    ATK_DEF_FORWORD_LINE_MIN = 480,
    ATK_DEF_FORWORD_LINE_MAX = 800,
    -- 进攻中，球在对方半场
    ATK_ATK_BACK_LINE_MIN = 500,
    ATK_ATK_BACK_LINE_MAX = 650,
    ATK_ATK_HALF_BACK_LINE_MIN = 650,
    ATK_ATK_HALF_BACK_LINE_MAX = 800,
    ATK_ATK_FORWORD_LINE_MIN = 850,
    ATK_ATK_FORWORD_LINE_MAX = 950,
    
    -- 防守中，球在己方半场
    DEF_DEF_BACK_LINE_MIN = 50,
    DEF_DEF_BACK_LINE_MAX = 200,
    DEF_DEF_HALF_BACK_LINE_MIN = 200,
    DEF_DEF_HALF_BACK_LINE_MAX = 400,
    DEF_DEF_FORWORD_LINE_MIN = 400,
    DEF_DEF_FORWORD_LINE_MAX = 500,
    -- 防守中，球在对方半场
    DEF_ATK_BACK_LINE_MIN = 100,
    DEF_ATK_BACK_LINE_MAX = 350,
    DEF_ATK_HALF_BACK_LINE_MIN = 350,
    DEF_ATK_HALF_BACK_LINE_MAX = 550,
    DEF_ATK_FORWORD_LINE_MIN = 650,
    DEF_ATK_FORWORD_LINE_MAX = 750,
    
    -- 球员碰撞距离
    PLAYER_DISTANCE = 40,
    
    -- 抢球队员接近球多久后触发
    PLAYER_ENCOUNTER_TRIGGER_TIME = 1.0,
    
    MATCH_STEP =
    {
        "WAIT_START",
        "COUNT_DOWN",
        "MATCHING",
        "PLAY_ANIM",
        "NONE",
    },

    SIDE =
    {
        "LEFT",
        "RIGHT",
        "NONE",
    },

    TEAM_STATE =
    {
        "KICKOFF",
        "ATTACKING",
        "DEFENDING",
        "NONE",
    },

    AI_CLASS =
    {
        "GOAL_KEEPER",
        "BACK",
        "HALF_BACK",
        "FORWARD",
    },

    AI_STATE =
    {
        "WAIT",
        "BACKHOME",
        "AI_CONTROL",
        "USER_CONTROL",
        "SUPPORT",
        "CHASE",
        "NETWORK",
        "NONE",
    },

    AI_STATE_SUPPORT =
    {
        "FIND_POS",
        "MOVE_TO_POS",
        "NONE",
    },

    AI_STATE_CONTROL =
    {
        "DRIBBLE",
        "NONE",
    },


    PLAYER_INS =
    {
        "TAKCLE",
        "BLOCK",
        "INTERCEPT",
        "HIT",
        "TAKE",
        "NONE",
    },


    JS_RET_VAL =
    {
        "FAIL",
        "SUCCESS",
        "RANDOM_BALL",
        "NONE",
    },


    MENU_TYPE =
    {
        "DEFAULT_ATK_G",      -- 控球方 地面带球中断: 传球 射门 二过一
        "ENCOUNTER_ATK_G",    -- 控球方 地面遭遇: 盘带 传球 射门 二过一
        "ONE_ZERO_ATK_G",     -- 控球方 单刀: 射门 盘带
        "ENCOUNTER_ATK_OPPSITE_A",  -- 控球方 对方禁区内半空遭遇: 盘带 传球 射门
        "ENCOUNTER_ATK_SELF_A",  -- 控球方 己方禁区内半空遭遇: 传球 解围
        "ENCOUTNER_DEF_G",    -- 防守方 地面遭遇: 铲球 拦截 封堵
        "ENCOUNTER_DEF_SELF_A",    -- 防守方 己方禁区内半空遭遇: 解围 拦截 封堵
        "ENCOUNTER_DEF_OPPSITE_A", -- 防守方 对方禁区半空遭遇: 拦截 封堵
        "GOAL_KEEPER_DEF_G",  -- 防守方 守门员防守: 接球 击球
        "ONE_ZERO_DEF_G",     -- 防守方 单刀门将: 封堵盘带 封堵射门
        "GOAL_KEEPER_DEF_A",  -- 防守方 守门员空中遭遇: 出击 待机
        "NONE",
    },

    MENU_ITEMS =
    {
        "Pass",
        "Dribble",
        "OneTwo",
        "Shoot",
        "Tackle",
        "Intercept",
        "Block",
        "Hit",
        "Attack",
        "Wait",
        "Clear",
        "Catch",
        "BlockDribble",
        "BlockShoot",
        "None",
    },

    GAME_EVENT =       -- 指令的发起事件，这里不分攻防
    {
        "ACTIVE_PASS",            -- 主动传球
        "ACTIVE_SHOOT",           -- 主动射门
        "ACTIVE_ONE_TWO_PASS",    -- 主动二过一
        "GROUND_ENCOUNTER",       -- 普通地面遭遇
        "AIR_ENCOUNTER_ATTACK",   -- 控球方对方禁区半空遭遇
        "AIR_ENCOUNTER_DEFFEND",  -- 控球方己方禁区半空遭遇
        "ONE_ZERO_ATTACK",        -- 单刀球
    },

    MATCH_FLOW_TYPE =      -- 相对应CFBInstruction的类型
    {
        "PASSBALL",
        "SHOOT_GROUND",
        "SHOOT_AIR",
        "NONE",
    },

    
}