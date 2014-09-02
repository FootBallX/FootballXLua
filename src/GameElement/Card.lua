require "GamePlay.MatchDefs"

local Card = class("Card");

local MD = MatchDefs;

function Card:ctor()
	self.m_cardID = -1; --     int m_cardID = -1;',
	self.m_icon = ""; --     char m_icon[FBDefs::MAX_CARD_ICON_LEN] = {0};',
	self.m_quality = 0; --     int m_quality;',
	self.m_strength = 0; --     float m_strength = 0.f;',
	self.m_speed = 0; --     float m_speed = 0.f;',
	self.m_dribbleSkill = 0; --     float m_dribbleSkill = 0.f;',
	self.m_passSkill = 0; --     float m_passSkill = 0.f;',
	self.m_shootSkill = 0; --     float m_shootSkill = 0.f;',
	self.m_defenceSkill = 0; --     float m_defenceSkill = 0.f;',
	self.m_attackSkill = 0; --     float m_attackSkill = 0.f;      // goalkeeper only',
	self.m_groundSkill = 0; --     float m_groundSkill = 0.f;',
	self.m_airSkill = 0; --     float m_airSkill = 0.f;'
end


return Card;