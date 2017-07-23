local ns = oUF
local oUF = ns.oUF

local GetPetHappiness = GetPetHappiness
local HasPetUI = HasPetUI

local Update = function(self, event, unit)
	if(not unit or self.unit ~= unit) then return end
	local happ = self.Happiness
	if not happ then return end

	if(happ.PreUpdate) then happ:PreUpdate(unit) end

	local happiness, damagePercentage = GetPetHappiness()
	local _, hunterPet = HasPetUI()

	happ:SetMinMaxValues(0, 125)
	happ:SetValue(damagePercentage)

	if(not (happiness or hunterPet)) then
		return happ:Hide()
	end

	happ:Show()

	if damagePercentage == 75 then
		happ:SetStatusBarColor(1, 0, 0)
	elseif damagePercentage == 100 then
		happ:SetStatusBarColor(1, 1, 0)
	elseif damagePercentage == 125 then
		happ:SetStatusBarColor(0, 1, 0)
	end

	if(happ.PostUpdate) then
		return happ:PostUpdate(unit, happiness)
	end
end

local Path = function(self, ...)
	return (self.Happiness.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local Enable = function(self)
	local happiness = self.Happiness
	if(happiness) then
		happiness.__owner = self
		happiness.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_HAPPINESS", Path)

		if(happiness:IsObjectType'StatusBar' and not happiness:GetStatusBarTexture()) then
			happiness:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		return true
	end
end

local Disable = function(self)
	local happiness = self.Happiness
	if(happiness) then
		happiness:Hide()
		self:UnregisterEvent("UNIT_HAPPINESS", Path)
	end
end

oUF:AddElement("Happiness", Path, Enable, Disable)