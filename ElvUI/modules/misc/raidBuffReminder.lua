local E, L, V, P, G = unpack(ElvUI)
local RB = E:NewModule("ReminderBuffs", "AceEvent-3.0")
local LSM = E.LSM

local ipairs, unpack = ipairs, unpack

local GetPlayerBuff = GetPlayerBuff
local GetPlayerBuffName = GetPlayerBuffName
local GetPlayerBuffTexture = GetPlayerBuffTexture
local GetPlayerBuffTimeLeft = GetPlayerBuffTimeLeft
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local UnitBuff = UnitBuff

local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY

E.ReminderBuffs = RB

RB.Spell1Buffs = {
	28521,	-- Flask of Blinding Light
	28518,	-- Flask of Fortification
	28519,	-- Flask of Mighty Restoration
	28540,	-- Flask of Pure Death
	28520,	-- Flask of Relentless Assault
	42735,	-- Flask of Chromatic Wonder
	46839,	-- Shattrath Flask of Blinding Light
	41607,	-- Shattrath Flask of Fortification
	41605,	-- Shattrath Flask of Mighty Restoration
	46837,	-- Shattrath Flask of Pure Death
	41608,	-- Shattrath Flask of Relentless Assault
	41611,	-- Shattrath Flask of Supreme Power
	17629,	-- Flask of Chromatic Resistance
	17628,	-- Flask of Supreme Power
	17626,	-- Flask of the Titans
	17627,	-- Flask of Distilled Wisdom

	33721,	-- Adept's Elixir
	28509,	-- Elixir of Major Mageblood
	45373,	-- Bloodberry Elixir
	28502,	-- Elixir of Major Defense
	39627,	-- Elixir of Draenic Wisdom
	33726,	-- Elixir of Mastery
	28491,	-- Elixir of Healing Power
	39625,	-- Elixir of Major Fortitude
	28497,	-- Elixir of Mighty Agility
	11406,	-- Elixir of Demonslaying
}

RB.Spell2Buffs = {
	43706,	-- 23 Spellcrit (Skullfish Soup Buff)
	33257,	-- 30 Stamina
	33256,	-- 20 Strength
	33259,	-- 40 AP
	33261,	-- 20 Agility
	33263,	-- 23 Spelldmg
	33265,	-- 8 MP5
	33268,	-- 44 Addheal
	35272,	-- 20 Stamina
	33254,	-- 20 Stamina
	43764,	-- 20 Meleehit
	45619,	-- 8 Spellresist
}

RB.Spell3Buffs = {
	26991,	-- Gift of the Wild
	26990,	-- Mark of the Wild
}

RB.Spell4Buffs = {
	25898,	-- Greater Blessing of Kings
	20217,	-- Blessing of Kings
}

RB.CasterSpell5Buffs = {
	27127,	-- Arcane Brilliance
	27126,	-- Arcane Intellect
}

RB.MeleeSpell5Buffs = {
	25392,	-- Prayer of Fortitude
	25389,	-- Power Word: Fortitude
	469,	-- Commanding Shout
}

RB.CasterSpell6Buffs = {
	27143,	-- Greater Blessing of Wisdom
	27142,	-- Blessing of Wisdom
	25569,	-- Mana Spring
}

RB.MeleeSpell6Buffs = {
	27141,	-- Greater Blessing of Might
	27140,	-- Blessing of Might
	2048,	-- Battle Shout
}

RB.DamagerSpell7Buffs = {
	1038,	-- Blessing of Salvation
	25895,	-- Greater Blessing of Salvation
}

RB.TankSpell7Buffs = {
	27168,	-- Blessing of Sanctuary
	27169,	-- Greater Blessing of Sanctuary
}

function RB:CheckFilterForActiveBuff(filter)
	local spellName, buffIndex, untilCancelled

	for _, spellID in ipairs(filter) do
		spellName = GetSpellInfo(spellID)

		if spellName then
			for i = 1, BUFF_MAX_DISPLAY do
				buffIndex, untilCancelled = GetPlayerBuff(i)

				if buffIndex ~= 0 then
					if spellName == GetPlayerBuffName(buffIndex) then
						return true, buffIndex, GetPlayerBuffTexture(buffIndex), untilCancelled, GetPlayerBuffTimeLeft(buffIndex), GetPlayerBuffName(buffIndex), spellID
					end
				end
			end
		end
	end

	return false
end

function RB:GetDurationForBuffName(buffName)
	local _, name, duration
	for i = 1, BUFF_MAX_DISPLAY do
		name, _, _, _, duration = UnitBuff("player", i)
		if name == buffName and duration then
			return duration
		end
	end
	return nil
end

function RB:Button_OnUpdate(elapsed)
	local timeLeft = GetPlayerBuffTimeLeft(self.index)

	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	if timeLeft <= 0 then
		self.timer:SetText("")
		self:SetScript("OnUpdate", nil)
		return
	end

	local timerValue, formatID
	timerValue, formatID, self.nextUpdate = E:GetTimeInfo(timeLeft, 4)
	self.timer:SetFormattedText(("%s%s|r"):format(E.TimeColors[formatID], E.TimeFormats[formatID][1]), timerValue)
end

function RB:Update()
	for i = 1, 7 do
		local button = self.frame[i]
		local hasBuff, index, texture, untilCancelled, timeLeft, buffName, spellID = self:CheckFilterForActiveBuff(self["Spell"..i.."Buffs"])

		if hasBuff then
			button.index = index
			button.t:SetTexture(texture)

			if (untilCancelled == 1 or not timeLeft) or not E.db.general.reminder.durations then
				button.t:SetAlpha(E.db.general.reminder.reverse and 1 or 0.3)
				button:SetScript("OnUpdate", nil)
				button.timer:SetText(nil)
				CooldownFrame_SetTimer(button.cd, 0, 0, 0)
			else
				button.nextUpdate = 0
				button.t:SetAlpha(1)

				local duration = self:GetDurationForBuffName(buffName) or ElvCharacterDB.ReminderDuration[spellID]
				if duration then
					CooldownFrame_SetTimer(button.cd, GetTime() - (duration - timeLeft), duration, 1)
					ElvCharacterDB.ReminderDuration[spellID] = duration
				else
					CooldownFrame_SetTimer(button.cd, 0, 0, 0)
				end
				button:SetScript("OnUpdate", self.Button_OnUpdate)
			end
		else
			button.index = nil
			CooldownFrame_SetTimer(button.cd, 0, 0, 0)
			button.t:SetAlpha(E.db.general.reminder.reverse and 0.3 or 1)
			button:SetScript("OnUpdate", nil)
			button.timer:SetText(nil)
			button.t:SetTexture(self.DefaultIcons[i])
		end
	end
end

function RB:CreateButton()
	local button = CreateFrame("Button", nil, ElvUI_ReminderBuffs)
	button:SetTemplate("Default")

	button.t = button:CreateTexture(nil, "OVERLAY")
	button.t:SetTexCoord(unpack(E.TexCoords))
	button.t:SetInside()
	button.t:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

	button.timer = button:CreateFontString(nil, "OVERLAY")
	button.timer:SetPoint("CENTER")

	button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	button.cd:SetInside()
	button.cd.noOCC = true
	button.cd.noCooldownCount = true

	return button
end

function RB:UpdateSettings(isCallback)
	local font = LSM:Fetch("font", E.db.general.reminder.font)

	local frame = self.frame
	frame:Width(E.RBRWidth)

	self:UpdateDefaultIcons()

	for i = 1, 7 do
		local button = self.frame[i]
		button:SetSize(E.RBRWidth)

		button:ClearAllPoints()
		if i == 1 then
			button:Point("TOP", ElvUI_ReminderBuffs, "TOP", 0, 0)
		elseif i == 7 then
			button:Point("BOTTOM", ElvUI_ReminderBuffs, "BOTTOM", 0, 0)
		else
			button:Point("TOP", frame[i - 1], "BOTTOM", 0, E.Border - E.Spacing*3)
		end

		if E.db.general.reminder.durations then
			button.cd:SetAlpha(1)
		else
			button.cd:SetAlpha(0)
		end

		button.timer:FontTemplate(font, E.db.general.reminder.fontSize, E.db.general.reminder.fontOutline)
		button.cd:SetReverse(E.db.general.reminder.reverse)
		button.timer:SetParent(button.cd)
	end

	if not isCallback then
		if E.db.general.reminder.enable then
			RB:Enable()
		else
			RB:Disable()
		end
	else
		self:Update()
	end
end

function RB:UpdatePosition()
	Minimap:ClearAllPoints()
	ElvConfigToggle:ClearAllPoints()
	ElvUI_ReminderBuffs:ClearAllPoints()

	if E.db.general.reminder.position == "LEFT" then
		Minimap:Point("TOPRIGHT", MMHolder, "TOPRIGHT")
		ElvConfigToggle:SetPoint("TOPRIGHT", LeftMiniPanel, "TOPLEFT", E.Border - E.Spacing*3, 0)
		ElvConfigToggle:SetPoint("BOTTOMRIGHT", LeftMiniPanel, "BOTTOMLEFT", E.Border - E.Spacing*3, 0)
		ElvUI_ReminderBuffs:SetPoint("TOPRIGHT", Minimap.backdrop, "TOPLEFT", E.Border - E.Spacing*3, 0)
		ElvUI_ReminderBuffs:SetPoint("BOTTOMRIGHT", Minimap.backdrop, "BOTTOMLEFT", E.Border - E.Spacing*3, 0)
	else
		Minimap:Point("TOPLEFT", MMHolder, "TOPLEFT")
		ElvConfigToggle:SetPoint("TOPLEFT", RightMiniPanel, "TOPRIGHT", -E.Border + E.Spacing*3, 0)
		ElvConfigToggle:SetPoint("BOTTOMLEFT", RightMiniPanel, "BOTTOMRIGHT", -E.Border + E.Spacing*3, 0)
		ElvUI_ReminderBuffs:SetPoint("TOPLEFT", Minimap.backdrop, "TOPRIGHT", -E.Border + E.Spacing*3, 0)
		ElvUI_ReminderBuffs:SetPoint("BOTTOMLEFT", Minimap.backdrop, "BOTTOMRIGHT", -E.Border + E.Spacing*3, 0)
	end
end

function RB:UpdateDefaultIcons()
	self.DefaultIcons = {
		[1] = "Interface\\Icons\\INV_Potion_97",
		[2] = "Interface\\Icons\\Spell_Misc_Food",
		[3] = "Interface\\Icons\\Spell_Nature_Regeneration",
		[4] = "Interface\\Icons\\Spell_Magic_GreaterBlessingofKings",
		[5] = (E.Role == "Caster" and "Interface\\Icons\\Spell_Holy_MagicalSentry") or "Interface\\Icons\\Spell_Holy_WordFortitude",
		[6] = (E.Role == "Caster" and "Interface\\Icons\\Spell_Holy_GreaterBlessingofWisdom") or "Interface\\Icons\\Ability_Warrior_BattleShout",
		[7] = (E.Role == "Tank" and "Interface\\Icons\\Spell_Holy_GreaterBlessingofSanctuary") or "Interface\\Icons\\Spell_Holy_GreaterBlessingofSalvation"
	}

	self.Spell5Buffs = E.Role == "Caster" and self.CasterSpell5Buffs or self.MeleeSpell5Buffs
	self.Spell6Buffs = E.Role == "Caster" and self.CasterSpell6Buffs or self.MeleeSpell6Buffs
	self.Spell7Buffs = E.Role == "Tank" and self.TankSpell7Buffs or self.DamagerSpell7Buffs
end

function RB:Enable()
	ElvUI_ReminderBuffs:Show()
	self:RegisterEvent("PLAYER_AURAS_CHANGED", "Update")
	E.RegisterCallback(self, "RoleChanged", "UpdateSettings")
	self:Update()
end

function RB:Disable()
	ElvUI_ReminderBuffs:Hide()
	self:UnregisterEvent("PLAYER_AURAS_CHANGED")
	E.UnregisterCallback(self, "RoleChanged", "UpdateSettings")
end

function RB:Initialize()
	if not E.private.general.minimap.enable then return end

	self.db = E.db.general.reminder

	if not ElvCharacterDB.ReminderDuration then
		ElvCharacterDB.ReminderDuration = {}
	end

	local frame = CreateFrame("Frame", "ElvUI_ReminderBuffs", Minimap.backdrop)
	frame:Width(E.RBRWidth)
	self.frame = frame

	self:UpdatePosition()

	for i = 1, 7 do
		frame[i] = self:CreateButton()
	end

	self:UpdateSettings()
end

local function InitializeCallback()
	RB:Initialize()
end

E:RegisterModule(RB:GetName(), InitializeCallback)