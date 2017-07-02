local ns = oUF
local oUF = ns.oUF
assert(oUF, "oUF_HealComm3 was unable to locate oUF install")

local healComm = LibStub("LibHealComm-3.0")
local LMH = LibStub("LibMobHealth-4.0")

local join = string.join
local select = select
local GetTime = GetTime
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsConnected = UnitIsConnected
local UnitName = UnitName

local playerName = UnitName("player")
local playerIsCasting = false
local playerHeals = 0
local playerTarget = ""

local function Update(self, ...)
	if self.db and not self.db.healPrediction then return end
	local unit = self.unit
	local healCommBar = self.HealCommBar
	healCommBar.parent = self

	if not unit or UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit) then
		if healCommBar.myBar then
			healCommBar.myBar:Hide()
		end

		if healCommBar.otherBar then
			healCommBar.otherBar:Hide()
		end
		return
	end

	local health, maxHealth = LMH:GetUnitCurrentHP(unit), LMH:GetUnitMaxHP(unit)

	local myIncomingHeal = 0
	local allIncomingHeal = select(2, healComm:UnitIncomingHealGet(unit, GetTime())) or 0
	local healModifier = healComm:UnitHealModifierGet(unit)

	if healModifier ~= 1 then
		myIncomingHeal = myIncomingHeal * healModifier
		allIncomingHeal = allIncomingHeal * healModifier
	end

	if playerIsCasting then
		local name, realm = UnitName(unit)
		if realm then
			name = join("-", name, realm)
		end

		for i = 1, select("#", playerTarget) do
			local target = select(i, playerTarget)
			if target == name then
				myIncomingHeal = playerHeals
				allIncomingHeal = allIncomingHeal + myIncomingHeal
			end
		end
	end

	if health + allIncomingHeal > maxHealth * healCommBar.maxOverflow then
		allIncomingHeal = maxHealth * healCommBar.maxOverflow - health
	end

	if allIncomingHeal < myIncomingHeal then
		myIncomingHeal = allIncomingHeal
		allIncomingHeal = 0
	else
		allIncomingHeal = allIncomingHeal - myIncomingHeal
	end

	if healCommBar.myBar then
		healCommBar.myBar:SetMinMaxValues(0, maxHealth)
		healCommBar.myBar:SetValue(myIncomingHeal)
		healCommBar.myBar:Show()
	end

	if healCommBar.otherBar then
		healCommBar.otherBar:SetMinMaxValues(0, maxHealth)
		healCommBar.otherBar:SetValue(allIncomingHeal)
		healCommBar.otherBar:Show()
	end

	if healCommBar.PostUpdate then
		return healCommBar:PostUpdate(unit, myIncomingHeal, allIncomingHeal)
	end
end

local function Path(self, ...)
	return (self.HealCommBar.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function MultiUpdate(...)
	for i = 1, select("#", ...) do
		for _, frame in ipairs(oUF.objects) do
			if frame.unit and frame.HealCommBar then
				local name, realm = UnitName(frame.unit)
				if realm then
					name = join("-", name, realm)
				end

				if name == select(i, ...) then
					Path(frame)
				end
			end
		end
	end
end

local function HealComm_Heal_Update(event, healerName, healSize, endTime, ...)
	if event == "HealComm_DirectHealStart" and healerName == playerName then
		playerIsCasting = true
		playerHeals = healSize
		playerTarget = ...
	elseif event == "HealComm_DirectHealStop" and healerName == playerName then
		playerIsCasting = false
	end

	MultiUpdate(...)
end

local function HealComm_Modified(event, unit)
	MultiUpdate(unit)
end

local function Enable(self)
	local healCommBar = self.HealCommBar
	if healCommBar then
		healCommBar.__owner = self
		healCommBar.ForceUpdate = ForceUpdate

		if not healCommBar.maxOverflow then
			healCommBar.maxOverflow = 1.05
		end

		self:RegisterEvent("UNIT_HEALTH", Path)
		self:RegisterEvent("UNIT_MAXHEALTH", Path)

		return true
	end
end

local function Disable(self)
	local healCommBar = self.HealCommBar
	if healCommBar then
		self:UnregisterEvent("UNIT_HEALTH", Path)
		self:UnregisterEvent("UNIT_MAXHEALTH", Path)

		if healCommBar.myBar then
			healCommBar.myBar:Hide()
		end

		if healCommBar.otherBar then
			healCommBar.otherBar:Hide()
		end
	end
end

oUF:AddElement("HealComm3", Path, Enable, Disable)

healComm.RegisterCallback("HealComm3", "HealComm_DirectHealStart", HealComm_Heal_Update)
healComm.RegisterCallback("HealComm3", "HealComm_DirectHealUpdate", HealComm_Heal_Update)
healComm.RegisterCallback("HealComm3", "HealComm_DirectHealStop", HealComm_Heal_Update)
healComm.RegisterCallback("HealComm3", "HealComm_HealModifierUpdate", HealComm_Modified)