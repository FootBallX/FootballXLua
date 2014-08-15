require "constVar"


local FBPitchGrid = class("FBPitchGrid")

function FBPitchGrid:ctor()

    self.m_position = cc.p(0, 0)
    self.m_score = 0;
    self.m_defenceScore = 0;     -- 用于计算格子带球路线。
    self.m_index = -1;
    self.m_shootAngleScore = 0;
    self.m_shootDistanceScore = 0;
    
    self.m_shootAngle = constVar.Sys.numberMax
--    kmMat3 m_shootLineMat;
    
    self.m_transformedPos = cc.p(0, 0);
    self.m_transformedGoalPos = cc.p(0, 0);

    self.m_drawNode = nil;
end

return FBPitchGrid