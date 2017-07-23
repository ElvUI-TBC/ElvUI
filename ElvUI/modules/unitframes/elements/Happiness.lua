local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule("UnitFrames")

function UF:Construct_Happiness(frame)
	local Happiness = CreateFrame("Statusbar", nil, frame)

	UF["statusbars"][Happiness] = true
	Happiness:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
	Happiness:SetOrientation("VERTICAL")
	Happiness.PostUpdate = UF.PostUpdateHappiness
	Happiness:SetFrameStrata("LOW")

	return Happiness
end

function UF:Configure_Happiness(frame)
	if not frame.VARIABLES_SET then return end

	local Happiness = frame.Happiness
	local db = frame.db

	frame.HAPPINESS_WIDTH = Happiness and frame.HAPPINESS_SHOWN and (db.happiness.width + (frame.BORDER*2)) or 0;

	if db.happiness.enable then
		if not frame:IsElementEnabled("Happiness") then
			frame:EnableElement("Happiness")
		end

		Happiness:ClearAllPoints()
		if not frame.USE_MINI_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED and not frame.USE_POWERBAR_OFFSET then
			if frame.ORIENTATION == "RIGHT" then
				Happiness:Point("BOTTOMRIGHT", frame.Power, "BOTTOMLEFT", -frame.BORDER*2 + (frame.BORDER - frame.SPACING*3), 0)
				Happiness:Point("TOPLEFT", frame.Health, "TOPLEFT", -frame.HAPPINESS_WIDTH, 0)
			else
				Happiness:Point("BOTTOMLEFT", frame.Power, "BOTTOMRIGHT", frame.BORDER*2 + (-frame.BORDER + frame.SPACING*3), 0)
				Happiness:Point("TOPRIGHT", frame.Health, "TOPRIGHT", frame.HAPPINESS_WIDTH, 0)
			end
		else
			if frame.ORIENTATION == "RIGHT" then
				Happiness:Point("BOTTOMRIGHT", frame.Health, "BOTTOMLEFT", -frame.BORDER*2 + (frame.BORDER - frame.SPACING*3), 0)
				Happiness:Point("TOPLEFT", frame.Health, "TOPLEFT", -frame.HAPPINESS_WIDTH, 0)
			else
				Happiness:Point("BOTTOMLEFT", frame.Health, "BOTTOMRIGHT", frame.BORDER*2 + (-frame.BORDER + frame.SPACING*3), 0)
				Happiness:Point("TOPRIGHT", frame.Health, "TOPRIGHT", frame.HAPPINESS_WIDTH, 0)
			end
		end
	elseif frame:IsElementEnabled("Happiness") then
		frame:DisableElement("Happiness")
	end
end

function UF:PostUpdateHappiness(unit, happiness, damagePercentage)
	local frame = self:GetParent()
	local db = frame.db

	if happiness and damagePercentage > 0 then
		if frame.db.happiness.autoHide and damagePercentage == 125 then
			self:Hide()
		else
 			self:Show()
		end
 	else
 		self:Hide()
	end

	local stateChanged = false
	local isShown = self:IsShown()

	if (frame.HAPPINESS_SHOWN and not isShown) or (not frame.HAPPINESS_SHOWN and isShown) then
		stateChanged = true
	end

	frame.HAPPINESS_SHOWN = isShown

	if stateChanged then
		UF:Configure_Happiness(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame)
		--UF:Configure_InfoPanel(frame, true)
	end
end