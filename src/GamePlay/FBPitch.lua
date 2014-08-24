require "Cocos2d"
require "Cocos2dConstants"
require "Common"
require "GamePlay.MatchDefs"


local HDVector = require "Utils.HDVector"
local MD = MatchDefs;

local FBPitch = class("FBPitch")


function FBPitch:ctor()
    self.m_width = 0;
    self.m_height = 0;
    self.m_Goals = {{}, {}}
    self.m_penaltyArea = {{}, {}}
    
    self.m_gridWidth = 30;
    self.m_gridHeight = 15;
    
    self.m_grids = {}
    HDVector.extend(self.m_grids)
    self.m_GridsOfSide = {HDVector.extend({}), HDVector.extend({})}
    self.m_GridsInPenaltyArea = {HDVector.extend({}), HDVector.extend({})}
    self.m_GridsOutsidePenaltyArea = {HDVector.extend({}), HDVector.extend({})}
    
    self.m_pitchScale = 0.0;
end


function FBPitch:transformBySide(pos, side)
    if (side == MD.SIDE.RIGHT) then
        if (type(pos) == 'number') then
            pos = self.m_width - pos;
        else
            pos.x = self.m_width - pos.x;
        end
    end
    
    return pos;
end

function FBPitch:transToScreen(pos)
    return cc.p(pos.x * self.m_pitchScale, pos.y * self.m_pitchScale)
end
    
function FBPitch:init(ww, hh)

    self.m_width = 1000;
    self.m_height = 650;
    
    self.m_pitchScale = ww / self.m_width;
    
    local a = cc.rect(0, 175, 150, 300);
    self.m_penaltyArea[1] = 12;
    self.m_penaltyArea[MD.SIDE.LEFT] = cc.rect(0,175,150,300);
    self.m_penaltyArea[MD.SIDE.RIGHT] = cc.rect(850, 175, 150, 300);
    self.m_Goals[MD.SIDE.LEFT] = cc.p(0, 170)
    self.m_Goals[MD.SIDE.RIGHT] = cc.p(1000, 170)
    
    local gw = self.m_gridWidth - 2;
    local gh = self.m_gridHeight - 2;
    
    local midW = gw / 2.0 - 0.5;
    
    local gpw = self.m_width / self.m_gridWidth;
    local gph = self.m_height / self.m_gridHeight;
    
    for  y = 1, gh do
        for x = 1, gw do
            local index = (x - 1) + gw * (y - 1) + 1;       -- lua index from 1, so i have to +1
            local grid = require("GamePlay.FBPitchGrid").new()
            self.m_grids:push_back(grid)
            grid.m_position.x = (1.5 + x - 1) * gpw
            grid.m_position.y = (1.5 + y - 1) * gph;
            grid.m_index = index;
            
            if (x < midW) then
                local side = MD.SIDE.LEFT;
                local goalGate = self.m_Goals[side];
                goalGate.y = self.m_height * 0.5;
                
                self.m_GridsOfSide[side]:push_back(index);
                if cc.rectContainsPoint(self.m_penaltyArea[side], grid.m_position) then
--                        MD:computeGridShootAngleAndMat(goalGate, &grid);
                    self.m_GridsInPenaltyArea[side]:push_back(index);
                else
                    self.m_GridsOutsidePenaltyArea[side]:push_back(index);
                end
            
            elseif (x > midW) then
                local side = MD.SIDE.RIGHT;
                local goalGate = self.m_Goals[side];
                goalGate.y = self.m_height * 0.5;
                
                self.m_GridsOfSide[side]:push_back(index);
                if (cc.rectContainsPoint(self.m_penaltyArea[side], grid.m_position)) then
--                        FBDefs::computeGridShootAngleAndMat(goalGate, &grid);
                    self.m_GridsInPenaltyArea[side]:push_back(index);
                else
                    self.m_GridsOutsidePenaltyArea[side]:push_back(index);
                end
            end
        end
    end

    
    return true;
end

function FBPitch:setGridScore(index, s) 
    self.m_grids[index].m_score = s
end


function FBPitch:increaseGridScore(index, s)
    self.m_grids[index].m_score = self.m_grids[index].m_score + s
end
    
function FBPitch:setGridDefenceScore(index, s)
    self.m_grids[index].m_defenceScore = s
end


function FBPitch:increaseGridDefenceScore(index, s)
    self.m_grids[index].m_defenceScore = self.m_grids[index].m_defenceScore + s
end
    
function FBPitch:getGridScore(index)
    return self.m_grids[index].m_score
end

function FBPitch:getGridsInPenaltyAreaBySide(side)
    return self.m_GridsInPenaltyArea[side]
end

function FBPitch:getGridsOutsidePenaltyAreaBySide(side)
    return self.m_GridsOutsidePenaltyArea[side]
end
    
function FBPitch:getGridsAroundPosition(pos)
    local out_grids = {}
    HDVector.extend(out_grids)
    
    local gw = self.m_gridWidth - 2;
    local gh = self.m_gridHeight - 2;
    
    local gpw = self.m_width / self.m_gridWidth;
    local gph = self.m_height / self.m_gridHeight;
    
    local origX = (pos.x / gpw) - 1;
    local origY = (pos.y / gph) - 1;
    
    local function func(x, y)
        if (x >= 0 and x < gw and y >= 0 and y < gh) then
            out_grids:push_back(x + gw * y);
        end
    end
    
    for i = -2, 2 do
        for j = -2, 2 do
            func(origX + i, origY + j);
        end
    end

    return out_grids
end
    
function FBPitch:getBestSupportPosition(side)
    self:calcBestShootPosition(side);
    
    local pt = cc.p(0, 0);
    
    local otherSide = self:getOtherSide(side);
    local grids = self:getGridsInPenaltyAreaBySide(otherSide);
    
    table.sort(grids, function(a, b)
        return self.m_grids[a].m_score > self.m_grids[b].m_score;
    end)
    
    local r = math.random(0xffffffff) % math.min(#grids, 5);

    local g = self.m_grids[grids[r]];
    return g.m_position;
end

function FBPitch:getBestAssistantDeffendingPosition(targetPos, side)
    local gp = getGoalPos(side);
    gp = gp - targetPos;
    gp = cc.pNormalize(gp);
    
    return cc.pAdd(targetPos, cc.pMul(gp, MD.ASSIST_DEFEND_DIST))
end


function FBPitch:setGridDrawNode(index, node)
    self.m_grids[index].m_drawNode = node;
end
    
function FBPitch:getGridDrawNode(index)
    return self.m_grids[index].m_drawNode;
end

    
function FBPitch:calcBestShootPosition(side)
    local goalGate = self.m_Goals[side];
    goalGate.y = self.m_height * 0.5;
    
    local vs = self:getGridsInPenaltyAreaBySide(side);
    local team = g_matchManager:getTeam(side);
    local players = team:getTeamMembers();
    
    for i = 1, #vs do
        local grid = getGrid(vs[i]);
        self:setGridScore(x, 0);
        
        if (not self:isOffside(grid.m_position, side)) then
            self:increaseGridScore(x, grid.m_shootAngleScore);
--            if ( not MD.isPlayersOnTheWayToGoal(players, grid)) then
--                self:increaseGridScore(x, 10);
--            end
        else
            self:increaseGridScore(x, -1000);
        end
    end
end


function FBPitch:isOffside(pos, side)
    local offsidePos = g_matchManager:getTeam(side):getLastPosOfPlayer();
    if (side == MD.SIDE.LEFT) then
        if (pos.x < offsidePos) then
            return true;
        end
    elseif (side == MD.SIDE.RIGHT) then
        if (pos.x > offsidePos) then
            return true;
        end
    end
    
    return false;
end


function FBPitch:isInPenaltyArea(pos, side)
    return cc.rectContainsPoint(self.m_penaltyArea[side], pos)
end

    
function FBPitch:getOtherSide(side)
    if (side == MD.SIDE.LEFT) then
        return MD.SIDE.RIGHT
    elseif (side == MD.SIDE.RIGHT) then
        return MD.SIDE.LEFT
    end

    return MD.SIDE.NONE;
end

    
function FBPitch:getGoalPos(side)
    local pt = self.m_Goals[side];
    pt.y = 0.5 * self.m_height;
    return pt;
end
    
function FBPitch:getPitchWidth()
    return self.m_width; 
end


function FBPitch:getPitchHeight()
    return self.m_height; 
end


function FBPitch:getGridWidth()
    return self.m_gridWidth;
end


function FBPitch:getGridHeight()
    return self.m_gridHeight; 
end


function FBPitch:getGrids()
    return self.m_grids;
end


function FBPitch:getGrid(index)
    return self.m_grids[index];
end


return FBPitch