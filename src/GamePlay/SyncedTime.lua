require "Utils/HDVector"

local SyncedTime = class("SyncedTime")

function SyncedTime:ctor()
    self.m_serverTime = 0;
    
    self.m_isSyncing = false;
    self.m_syncCountMax = 10;
    self.m_syncCount = 0;
    
    self.m_pings = {}
    HDVector.extend(self.m_pings)
    
    self.m_startSyncTime = constVar.Sys.numberMax
end
    -- public
    
function SyncedTime:init()
    local function netHandler(event, msg)
        if (event == constVar.Event.matchSyncTime) then
            local msgJson = json.decode(msg)
            self.m_serverTime = msgJson.sTime;
            local lct = msgJson.cTime;
            local ct = self:getClientTime();
            local ping = (ct - lct) * 0.5;
            self.m_pings.push_back(ping);
            
            self.m_syncCount = self.m_syncCount - 1;
            
            if self.m_syncCount > 0 then
                self.m_startSyncTime = 0.25;
            else
                self.m_isSyncing = false;
                local sum = 0
                for i = 1, #self.m_pings do
                    sum = sum + self.m_pings[i]
                end
                self.m_serverTime = self.m_serverTime + sum / #self.m_pings;
            end
        end
    end
    
    pomelo:registerScriptHandler(netHandler)
end

function SyncedTime:update(dt)
    local delta = dt * 1000.0;
    self.m_serverTime = self.m_serverTime + delta;
    
    if (self.m_isSyncing and self.m_startSyncTime < 0) then
        self:syncTime();
        self.m_startSyncTime = constVar.Sys.numberMax;
    end
    
    self.m_startSyncTime = self.m_startSyncTime - dt;
end

function SyncedTime:startSyncTime()
    self.m_isSyncing = true;
    self.m_syncCount = self.m_syncCountMax;
    self.m_pings.clear();
    
    self.m_startSyncTime = 0.0;
end

function SyncedTime:isSyncing()
    return self.m_isSyncing;
end

function SyncedTime:getTime()
    return self.m_serverTime;
end
    
    -- protected
function SyncedTime:syncTime()
    local msg = {
        cTime = getClientTime()
    }

    pomelo:request(constVar.Event.matchSyncTime, json_encode(msg))
end


function SyncedTime:getClientTime()
    return math.floor(os.clock() * 1000 + 0.5)
end


return SyncedTime