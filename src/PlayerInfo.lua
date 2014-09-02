require "GamePlay.MatchDefs"

local PlayerInfo = class("PlayerInfo");

local MD = MatchDefs;


g_PlayerInfo = PlayerInfo.new();

function PlayerInfo:ctor()
	self.m_uid = 0;
	self.m_level = 0;
	self.m_money = 0;
	self.m_nickname = "";
	self.m_side = MD.SIDE.None;
end

