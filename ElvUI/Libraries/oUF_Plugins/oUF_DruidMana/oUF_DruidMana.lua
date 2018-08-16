if(select(2, UnitClass("player")) ~= "DRUID") then return; end

local ns = oUF
local oUF = ns.oUF

local LDM = LibStub("LibDruidMana-1.0")

local function UpdateColor(element, cur, max)
	local parent = element.__owner

	local r, g, b, t
	if(element.colorClass) then
		t = parent.colors.class['DRUID']
	elseif(element.colorSmooth) then
		r, g, b = parent.ColorGradient(cur, max, unpack(element.smoothGradient or parent.colors.smooth))
	elseif(element.colorPower) then
		t = parent.colors.power[0]
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		element:SetStatusBarColor(r, g, b)

		local bg = element.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end
end

local function Update(self, event, unit, currMana, maxMana)
	if(unit ~= 'player') then return end

	local element = self.DruidAltMana
	if(element.PreUpdate) then element:PreUpdate(unit) end

	local cur, max = currMana, maxMana
	if not (cur and max) then
		cur, max = LDM:GetCurrentMana(), LDM:GetMaximumMana()
	end

	element:SetMinMaxValues(0, max)
	element:SetValue(cur)

	element:UpdateColor(cur, max)

	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, max, event)
	end
end

local function Path(self, ...)
	return (self.DruidAltMana.Override or Update) (self, ...)
end

local function ElementEnable(self)
	self:RegisterEvent("UNIT_MANA", Path)
	self:RegisterEvent("UNIT_MAXMANA", Path)

	self.DruidAltMana:Show()

	if self.DruidAltMana.PostUpdateVisibility then
		self.DruidAltMana:PostUpdateVisibility(true, not self.DruidAltMana.isEnabled)
	end

	self.DruidAltMana.isEnabled = true

	Path(self, 'ElementEnable', 'player', UnitPowerType("player", 0))
end

local function ElementDisable(self)
	self:UnregisterEvent("UNIT_MANA", Path)
	self:UnregisterEvent("UNIT_MAXMANA", Path)

	self.DruidAltMana:Hide()

	if self.DruidAltMana.PostUpdateVisibility then
		self.DruidAltMana:PostUpdateVisibility(false, self.DruidAltMana.isEnabled)
	end

	self.DruidAltMana.isEnabled = nil

	Path(self, 'ElementDisable', 'player', UnitPowerType("player", 0))
end

local function Visibility(self, event, unit)
	local shouldEnable

	if UnitPowerType("player") ~= 0 then
		shouldEnable = true
	end

	if(shouldEnable) then
		ElementEnable(self)
	else
		ElementDisable(self)
	end
end

local function VisibilityPath(self, ...)
	return (self.DruidAltMana.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.DruidAltMana
	if(element and unit == 'player') then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		LDM:AddListener(function(currMana, maxMana)
			Update(self, "Listener", "player", currMana, maxMana)
		end, "oUF_DruidMana")

		self:RegisterEvent('PLAYER_LOGIN', VisibilityPath) -- need?
		self:RegisterEvent('PLAYER_ENTERING_WORLD', VisibilityPath)
		self:RegisterEvent('UPDATE_SHAPESHIFT_FORM', VisibilityPath) -- need?
		self:RegisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if(not element.UpdateColor) then
			element.UpdateColor = UpdateColor
		end

		return true
	end
end

local function Disable(self)
	local element = self.DruidAltMana
	if(element) then
		ElementDisable(self)
		LDM:RemoveListener("oUF_DruidMana")

		self:UnregisterEvent('PLAYER_LOGIN', VisibilityPath) -- need?
		self:UnregisterEvent('PLAYER_ENTERING_WORLD', VisibilityPath)
		self:UnregisterEvent('UPDATE_SHAPESHIFT_FORM', VisibilityPath) -- need?
		self:UnregisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
	end
end

oUF:AddElement("DruidAltMana", VisibilityPath, Enable, Disable)