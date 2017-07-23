local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule("UnitFrames")

function UF:Construct_Happiness(frame)
	local Happiness = CreateFrame("Statusbar", nil, frame)

	UF["statusbars"][Happiness] = true
	Happiness:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
	Happiness:SetOrientation("VERTICAL")
	Happiness:SetFrameStrata("LOW")

	return Happiness
end

function UF:Configure_Happiness(frame)
	local Happiness = frame.Happiness
	local db = frame.db

	if db.happiness.enable then
		if not frame:IsElementEnabled("Happiness") then
			frame:EnableElement("Happiness")
		end

		Happiness:ClearAllPoints()
		if not frame.USE_MINI_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED and not frame.USE_POWERBAR_OFFSET then
			if frame.ORIENTATION == "RIGHT" then
				Happiness:Point("BOTTOMRIGHT", frame.Power, "BOTTOMLEFT", -frame.BORDER*2 + (frame.BORDER - frame.SPACING*3), 0)
				Happiness:Point("TOPLEFT", frame.Health, "TOPLEFT", -db.happiness.width, 0)
			else
				Happiness:Point("BOTTOMLEFT", frame.Power, "BOTTOMRIGHT", frame.BORDER*2 + (-frame.BORDER + frame.SPACING*3), 0)
				Happiness:Point("TOPRIGHT", frame.Health, "TOPRIGHT", db.happiness.width, 0)
			end
		else
			if frame.ORIENTATION == "RIGHT" then
				Happiness:Point("BOTTOMRIGHT", frame.Health, "BOTTOMLEFT", -frame.BORDER*2 + (frame.BORDER - frame.SPACING*3), 0)
				Happiness:Point("TOPLEFT", frame.Health, "TOPLEFT", -db.happiness.width, 0)
			else
				Happiness:Point("BOTTOMLEFT", frame.Health, "BOTTOMRIGHT", frame.BORDER*2 + (-frame.BORDER + frame.SPACING*3), 0)
				Happiness:Point("TOPRIGHT", frame.Health, "TOPRIGHT", db.happiness.width, 0)
			end
		end
	elseif frame:IsElementEnabled("Happiness") then
		frame:DisableElement("Happiness")
	end
end