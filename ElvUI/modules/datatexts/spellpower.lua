local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule("DataTexts")

local join = string.join

local GetSpellBonusDamage = GetSpellBonusDamage
local GetSpellBonusHealing = GetSpellBonusHealing

local displayNumberString = ""
local lastPanel

local function OnEvent(self)
	local holySchool = 2
	local minModifier = GetSpellBonusDamage(holySchool)
	local bonusHealing = GetSpellBonusHealing()
	local bonusDamage

	for i = (holySchool + 1), MAX_SPELL_SCHOOLS do
		bonusDamage = GetSpellBonusDamage(i)
		minModifier = max(minModifier, bonusDamage)
	end

	if E:GetPlayerRole() == "HEALER" then
		self.text:SetFormattedText(displayNumberString, L["HP"], bonusHealing)
	else
		self.text:SetFormattedText(displayNumberString, L["SP"], minModifier)
	end

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", "%s: ", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Spell/Heal Power", {"PLAYER_DAMAGE_DONE_MODS"}, OnEvent, nil, nil, nil, nil, L["Spell/Heal Power"])