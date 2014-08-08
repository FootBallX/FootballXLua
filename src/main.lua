
require "Cocos2d"

-- cclog
local cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local function netHandler(event, msg)
    cclog("--------------111")
    cclog(event)
    cclog("111-------------")
end


local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    
    cc.FileUtils:getInstance():addSearchPath("src")
    cc.FileUtils:getInstance():addSearchPath("res")
    cc.FileUtils:getInstance():addSearchPath("res/Assets")
    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(480, 320, 0)
    
--    PomeloClient:getInstance():registerScriptHandler(netHandler);
--    PomeloClient:getInstance():connectA("127.0.0.1", 3017);

    --create scene 
    local scene = require("loginLayer")
    local gameScene = scene.create()
    
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(gameScene)
    else
        cc.Director:getInstance():runWithScene(gameScene)
    end

end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
