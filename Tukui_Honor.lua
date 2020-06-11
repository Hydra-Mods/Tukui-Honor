local T, C, L = Tukui:unpack()

local DataText = T["DataTexts"]
local floor = floor
local UnitHonor = UnitHonor
local UnitHonorMax = UnitHonorMax
local UnitHonorLevel = UnitHonorLevel
local Honor = HONOR

local OnEnter = function(self)
	GameTooltip:SetOwner(self:GetTooltipAnchor())
	
	local Honor = UnitHonor("player")
	local MaxHonor = UnitHonorMax("player")
	local HonorLevel = UnitHonorLevel("player")
	local NextRewardLevel = C_PvP.GetNextHonorLevelForReward(HonorLevel)
	local RewardInfo = C_PvP.GetHonorRewardInfo(NextRewardLevel)
	local Percent = floor((Honor / MaxHonor * 100 + 0.05) * 10) / 10
	local Remaining = MaxHonor - Honor
	local RemainingPercent = floor((Remaining / MaxHonor * 100 + 0.05) * 10) / 10
	local Kills = GetPVPLifetimeStats()
	
	GameTooltip:AddLine(format(HONOR_LEVEL_TOOLTIP, HonorLevel))
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Current honor")
	GameTooltip:AddDoubleLine(format("%s / %s", T.Comma(Honor), T.Comma(MaxHonor)), format("%s%%", Percent), 1, 1, 1, 1, 1, 1)
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Remaining honor")
	GameTooltip:AddDoubleLine(format("%s", T.Comma(Remaining)), format("%s%%", RemainingPercent), 1, 1, 1, 1, 1, 1)
	
	if (Kills > 0) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(HONORABLE_KILLS)
		GameTooltip:AddLine(T.Comma(Kills), 1, 1, 1)
	end
	
	if RewardInfo then
		local RewardText = select(11, GetAchievementInfo(RewardInfo.achievementRewardedID))
		
		if RewardText:match("%S") then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(PVP_PRESTIGE_RANK_UP_NEXT_MAX_LEVEL_REWARD:format(NextRewardLevel))
			GameTooltip:AddLine(RewardText, 1, 1, 1)
		end
	end
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local OnMouseUp = function()
	PVEFrame_ToggleFrame("PVPUIFrame", "HonorFrame")
end

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	self.Text:SetFormattedText("%s%s:|r %s%s / %s|r", DataText.NameColor, Honor, DataText.ValueColor, UnitHonor("player"), UnitHonorMax("player"))
end

local Enable = function(self)
	self:RegisterUnitEvent("HONOR_XP_UPDATE", "player")
	self:RegisterEvent("HONOR_LEVEL_UPDATE")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update(nil, "player")
end

local Disable = function(self)
	self:UnregisterEvent("HONOR_XP_UPDATE")
	self:UnregisterEvent("HONOR_LEVEL_UPDATE")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

DataText:Register(Honor, Enable, Disable, Update)