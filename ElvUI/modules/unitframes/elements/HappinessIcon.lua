local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule("UnitFrames")

function UF:Construct_HappinessIcon(frame)
	local Happiness = frame.RaisedElementParent:CreateTexture(nil, "ARTWORK")

	Happiness.bg = CreateFrame("Frame", nil, frame);
	Happiness.bg:SetTemplate("Default", nil, nil, self.thinBorders, true)
	Happiness.bg:Point("RIGHT", frame, "LEFT")
	Happiness.bg:Size(36)

	Happiness:SetInside(Happiness.bg)

	return Happiness
end

function UF:Configure_HappinessIcon(frame)
	local Happiness = frame.Happiness

	Happiness.bg:ClearAllPoints()

	if(frame.db.happinessIcon.position == "RIGHT") then
		Happiness.bg:Point("LEFT", frame, "RIGHT", frame.db.happinessIcon.xOffset, frame.db.happinessIcon.yOffset)
	else
		Happiness.bg:Point("RIGHT", frame, "LEFT", frame.db.happinessIcon.xOffset, frame.db.happinessIcon.yOffset)
	end

	Happiness.bg:Size(frame.db.happinessIcon.size)

	if frame.db.happinessIcon.enable and not frame:IsElementEnabled("Happiness") then
		frame:EnableElement("Happiness")
		Happiness.bg:Show()
	elseif not frame.db.happinessIcon.enable and frame:IsElementEnabled("Happiness") then
		frame:DisableElement("Happiness")
		Happiness.bg:Hide()
	end
end