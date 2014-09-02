
constVar = {
    Event = {
        onConnected = "connected",
        onConnectFailed = "connectFailed",
        gateQureyConnectorEntry = "gate.gateHandler.queryConnectorEntry",
        connectorLogin = "connector.entryHandler.login",
        connectorGetPlayerInfo = "connector.entryHandler.getPlayerInfo",
        leagueSignUp = "league.leagueHandler.signUp",
        lobbyOnPair = "onPair",
        matchSync = "match.matchHandler.sync",
        matchMenuCmd = "match.matchHandler.menuCmd",
        matchInsructionMovieEnd = "match.matchHandler.instructionMovieEnd",
        matchGetInfo = "match.matchHandler.getMatchInfo",
        matchSyncTime = "match.matchHandler.time",

        pushSync = "sync",
        pushStartMatch = "startMatch",
        pushEndMatch = "endMatch",
        pushTriggerMenu = "triggerMenu",
        pushInstructions = "instructions",
        pushInstructionsDone = "instructionsDone",
        pushResumeMatch = "resumeMatch",

        matchHandlerReady = "match.matchHandler.ready",
    },
    
    Sys = {
        numberMax = 1.0e14,
        INT_MIN = -1.0e14,
    },
    
    ResName = {
        pitch = "Pitch/pitch.png",
        pitchBlackPoint = "Pitch/BlackPoint.png",
        pitchRedPoint = "Pitch/RedPoint.png",
        pitchArrow = "Pitch/arrow.png",
        pitchBall = "Pitch/ball.png",
        pitchBlackNumber = {"Pitch/blackNumber1.png",
                            "Pitch/blackNumber2.png",
                            "Pitch/blackNumber3.png",
                            "Pitch/blackNumber4.png",
                            "Pitch/blackNumber5.png",
                            "Pitch/blackNumber6.png",
                            "Pitch/blackNumber7.png",
                            "Pitch/blackNumber8.png",
                            "Pitch/blackNumber9.png",
                            "Pitch/blackNumber10.png",
                            "Pitch/blackNumber11.png",
                            },
        pitchRedNumber = {  "Pitch/redNumber1.png",
                            "Pitch/redNumber2.png",
                            "Pitch/redNumber3.png",
                            "Pitch/redNumber4.png",
                            "Pitch/redNumber5.png",
                            "Pitch/redNumber6.png",
                            "Pitch/redNumber7.png",
                            "Pitch/redNumber8.png",
                            "Pitch/redNumber9.png",
                            "Pitch/redNumber10.png",
                            "Pitch/redNumber11.png",
                        },
    },
    
    PomeloCode = {
        OK = 200, 
        FAIL = 500, 
    
        ENTRY = {
            FA_TOKEN_INVALID =   1001, 
            FA_TOKEN_EXPIRE =    1002, 
            FA_USER_NOT_EXIST =  1003,
            FA_USER_ALREADY_LOGIN =  1004,
            FA_USER_PWD_ERROR =  1005,
        }, 
    
        GATE = {
            FA_NO_SERVER_AVAILABLE = 2001
        }, 
    
        CHAT = {
            FA_CHANNEL_CREATE =      3001, 
            FA_CHANNEL_NOT_EXIST =   3002, 
            FA_UNKNOWN_CONNECTOR =   3003, 
            FA_USER_NOT_ONLINE =     3004 
        },
        
        UNIT_STATE ={
            US_NORMAL =              0,
            US_BUILDING =            1,
            US_READY =               2 
        },
        
    
        GAMEPLAY = {
            FA_GAMEPLAY_NOT_LOGIN =  5001,
            
            HOME ={
                FA_BUILD_NO_MONEY  = 10001,
                FA_BUILD_NO_SPACE  = 10002,
                FA_BUILD_WRONG_NAME  = 10003,
                FA_REMOVE_WRONG_PARAM  = 10004,
                FA_MOVE_NO_SPACE  = 10005
            }
        },
    
        LEAGUE = {
            FA_FORMATION_ERR = 6001
        }
    },
    
    SIDE = {
        LEFT = 0,
        RIGHT = 1,
        NONE = 2
    }
}