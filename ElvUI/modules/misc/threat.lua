local E, L, V, P, G = unpack(ElvUI)
local THREAT = E:NewModule("Threat", "AceEvent-3.0")
local ThreatLib = LibStub("Threat-2.0", true)
local LSM = E.LSM

local pairs, select = pairs, select
local twipe = table.wipe

local CreateFrame = CreateFrame
local GetNumPartyMembers, GetNumRaidMembers = GetNumPartyMembers, GetNumRaidMembers
local GetThreatStatus = GetThreatStatus
local GetThreatStatusColor = GetThreatStatusColor
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitReaction = UnitReaction
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UNKNOWN = UNKNOWN

E.Threat = THREAT
local threatList = {}

local DT -- used to hold the DT module when we need it

function THREAT:UpdatePosition()
	if self.db.position == "RIGHTCHAT" then
		self.bar:SetInside(RightChatDataPanel)
		self.bar:SetParent(RightChatDataPanel)
	else
		self.bar:SetInside(LeftChatDataPanel)
		self.bar:SetParent(LeftChatDataPanel)
	end
	local fontTemplate = LSM:Fetch("font", self.db.textfont)
	self.bar.text:FontTemplate(fontTemplate, self.db.textSize, self.db.textOutline)
	self.bar:SetFrameStrata("MEDIUM")
end

function THREAT:GetLargestThreatOnList(percent)
	local largestValue, largestUnit = 0, nil
	for unit, threatPercent in pairs(threatList) do
		if threatPercent > largestValue then
			largestValue = threatPercent
			largestUnit = unit
		end
	end

	return (percent - largestValue), largestUnit
end

function THREAT:GetColor(unit)
	local unitReaction = UnitReaction(unit, "player")
	local _, unitClass = UnitClass(unit)
	if UnitIsPlayer(unit) then
		local class = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[unitClass] or RAID_CLASS_COLORS[unitClass]
		if not class then return 194, 194, 194 end
		return class.r * 255, class.g * 255, class.b * 255
	elseif unitReaction then
		local reaction = ElvUF.colors.reaction[unitReaction]
		return reaction[1] * 255, reaction[2] * 255, reaction[3] * 255
	else
		return 194, 194, 194
	end
end

function THREAT:Update(event, srcGuid, dstGuid)
	if DT and DT.ShowingBGStats then
		if self.bar:IsShown() then
			self.bar:Hide()
		end

		return
	end

	local targetGUID = UnitGUID("target")
	if not targetGUID then
		self.bar:Hide()
		return
	end

	if event == "ThreatUpdated" and targetGUID ~= dstGuid then return end

	local isInParty, isInRaid, petExists = GetNumPartyMembers(), GetNumRaidMembers(), HasPetUI()
	local current, max = ThreatLib:GetThreat(self.playerGUID, targetGUID), ThreatLib:GetMaxThreatOnTarget(targetGUID)
	local status, percent = GetThreatStatus(current, max)

	if percent and percent > 0 and (isInParty > 0 or petExists == 1) then
		local name = UnitName("target")
		self.bar:Show()
		if percent == 100 then
			if petExists == 1 then
				threatList["pet"] = select(2, GetThreatStatus(ThreatLib:GetThreat(UnitGUID("pet"), targetGUID), max))
			end

			if isInRaid > 0 then
				for i = 1, 40 do
					if UnitExists("raid"..i) and not UnitIsUnit("raid"..i, "player") then
						threatList["raid"..i] = select(2, GetThreatStatus(ThreatLib:GetThreat(UnitGUID("raid"..i), targetGUID), max))
					end
				end
			else
				for i = 1, 4 do
					if UnitExists("party"..i) then
						threatList["party"..i] = select(2, GetThreatStatus(ThreatLib:GetThreat(UnitGUID("party"..i), targetGUID), max))
					end
				end
			end

			local leadPercent, largestUnit = self:GetLargestThreatOnList(percent)
			if leadPercent > 0 and largestUnit ~= nil then
				local r, g, b = self:GetColor(largestUnit)
				self.bar.text:SetFormattedText(L["ABOVE_THREAT_FORMAT"], name, percent, leadPercent, r, g, b, UnitName(largestUnit) or UNKNOWN)

				if E.Role == "Tank" then
					self.bar:SetStatusBarColor(0, 0.839, 0)
					self.bar:SetValue(leadPercent)
				else
					self.bar:SetStatusBarColor(GetThreatStatusColor(status))
					self.bar:SetValue(percent)
				end
			else
				self.bar:SetStatusBarColor(GetThreatStatusColor(status))
				self.bar.text:SetFormattedText("%s: %.0f%%", name, percent)
				self.bar:SetValue(percent)
			end
		else
			self.bar:SetStatusBarColor(GetThreatStatusColor(status))
			self.bar.text:SetFormattedText("%s: %.0f%%", name, percent)
			self.bar:SetValue(percent)
		end

		twipe(threatList)
	else
		self.bar:Hide()
	end
end

function THREAT:GetLibStatus()
	if ThreatLib then
		return true
	else
		return false
	end
end

function THREAT:ToggleEnable()
	if not ThreatLib then
		return self.bar:Hide()
	end

	if self.db.enable then
		ThreatLib.RegisterCallback(self, "ThreatUpdated", "Update")

		self:RegisterEvent("PLAYER_TARGET_CHANGED", "Update")
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", "Update")
		self:RegisterEvent("RAID_ROSTER_UPDATE", "Update")
		self:RegisterEvent("UNIT_PET", "Update")
		self:RegisterEvent("PLAYER_PET_CHANGED", "Update")

		self:Update()
	else
		self.bar:Hide()

		ThreatLib.UnregisterAllCallbacks(self)

		self:UnregisterEvent("PLAYER_TARGET_CHANGED")
		self:UnregisterEvent("PARTY_MEMBERS_CHANGED")
		self:UnregisterEvent("RAID_ROSTER_UPDATE")
		self:UnregisterEvent("UNIT_PET")
		self:UnregisterEvent("PLAYER_PET_CHANGED")
	end
end

function THREAT:PLAYER_ENTERING_WORLD()
	ThreatLib = LibStub("Threat-2.0", true)

	self:ToggleEnable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function THREAT:Initialize()
	DT = E:GetModule("DataTexts")

	self.db = E.db.general.threat
	self.playerGUID = UnitGUID("player")

	self.bar = CreateFrame("StatusBar", "ElvUI_ThreatBar", E.UIParent)
	self.bar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(self.bar)
	self.bar:SetMinMaxValues(0, 100)
	self.bar:CreateBackdrop("Default")

	self.bar.text = self.bar:CreateFontString(nil, "OVERLAY")
	self.bar.text:FontTemplate(self.db.textfont, self.db.textSize, self.db.textOutline)
	self.bar.text:Point("CENTER", self.bar, "CENTER")

	self:UpdatePosition()
	self:ToggleEnable()

	if not ThreatLib then
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
	end
end

local function InitializeCallback()
	THREAT:Initialize()
end

E:RegisterModule(THREAT:GetName(), InitializeCallback)