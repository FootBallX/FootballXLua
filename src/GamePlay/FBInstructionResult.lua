require "Cocos2d"
require "Cocos2dConstants"
require "Common"
require "GamePlay.MatchDefs"


local HDVector = require "Utils.HDVector"
local MD = MatchDefs;


local FBInstructionResult = class("FBInstructionResult");

FBInstructionResult.Animation = class("Animation");
FBInstructionResult.InsStructure = class("InsStructure");

function FBInstructionResult.Animation:ctor(a, d)
	self.aniId = a;		--             int aniId;',
    self.delay = d;		--             float delay;',
end

function FBInstructionResult.InsStructure:ctor(s, p, i, r)
	self.side = s;		--         int side;',
    self.playerNumber = p;		--         int playerNumber;',
    self.ins = i;		--         int ins;',
    self.result = r;	--         int result;',
    self.animations = {}; HDVector.extend(self.animations); --         vector<Animation> animations;',
end

function FBInstructionResult:ctor()
	self.instructions = {}; HDVector.extend(self.instructions); --     vector<InsStructure> instructions;',
    self.ballSide = 0; --     int ballSide;',
    self.playerNumber = 0; --     int playerNumber;',
    self.ballPosX = 0; --     float ballPosX;',
    self.ballPosY = 0; --     float ballPosY;'
end


function FBInstructionResult:pushIns(s, p, i, r)
	self:push_back(FBInstructionResult.InsStructure.new(s, p, i, r));
end

function FBInstructionResult:pushAnim(a, d)
	self.animations:push_back(FBInstructionResult.Animation.new(a, d));
end


return FBInstructionResult;