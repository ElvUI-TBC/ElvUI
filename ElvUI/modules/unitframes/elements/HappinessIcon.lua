local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule("UnitFrames")

function UF:Construct_HappinessIcon(frame)
	local Happiness = frame.RaisedElementParent:CreateTexture(nil, "ARTWORK")

	Happiness:Size(36)
	--Happiness:Point("CENTER", frame, "CENTER")
	Happiness:Point("RIGHT", frame, "LEFT")

	return Happiness
end

function UF:Configure_HappinessIcon(frame)
	local Happiness = frame.Happiness

	Happiness:ClearAllPoints()
	--Happiness:Point(frame.db.happinessIcon.anchorPoint, frame.Health, frame.db.happinessIcon.anchorPoint, frame.db.happinessIcon.xOffset, frame.db.happinessIcon.yOffset)
	if(frame.db.happinessIcon.position == "RIGHT") then
		Happiness:Point("LEFT", frame, "RIGHT", frame.db.happinessIcon.xOffset, frame.db.happinessIcon.yOffset)
	else
		Happiness:Point("RIGHT", frame, "LEFT", frame.db.happinessIcon.xOffset, frame.db.happinessIcon.yOffset)
	end

	Happiness:Size(frame.db.happinessIcon.size)

	if frame.db.happinessIcon.enable and not frame:IsElementEnabled("Happiness") then
		frame:EnableElement("Happiness")
	elseif not frame.db.happinessIcon.enable and frame:IsElementEnabled("Happiness") then
		frame:DisableElement("Happiness")
		Happiness:Hide()
	end
end