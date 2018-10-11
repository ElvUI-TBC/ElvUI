local E, L, V, P, G = unpack(ElvUI)
local mod = E:GetModule("NamePlates")

local unpack = unpack

local GetComboPoints = GetComboPoints
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

function mod:UpdateElement_CPoints(frame)
	if not frame.UnitType then return end
	if frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "FRIENDLY_NPC" then return end
	if self.db.units[frame.UnitType].comboPoints.enable ~= true then return end

	local numPoints
	if UnitExists("target") and frame.isTarget then
		numPoints = GetComboPoints("player", "target")
	end

	if numPoints and numPoints > 0 then
		frame.CPoints:Show()
		for i = 1, MAX_COMBO_POINTS do
			if i <= numPoints then
				frame.CPoints[i]:Show()
			else
				frame.CPoints[i]:Hide()
			end
		end
	else
		frame.CPoints:Hide()
	end
end

function mod:ConfigureElement_CPoints(frame)
	if not frame.UnitType then return end
	if frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "FRIENDLY_NPC" then return end

	local comboPoints = frame.CPoints

	comboPoints:ClearAllPoints()
	comboPoints:Point("CENTER", frame.HealthBar, "BOTTOM", self.db.units[frame.UnitType].comboPoints.xOffset, self.db.units[frame.UnitType].comboPoints.yOffset)
	
	for i = 1, MAX_COMBO_POINTS do
		comboPoints[i]:SetVertexColor(unpack(E:GetColorTable(self.db.comboBar.colors[i])))
	end
end

function mod:ConstructElement_CPoints(parent)
	local comboBar = CreateFrame("Frame", "$parentComboPoints", parent.HealthBar)
	comboBar:Point("CENTER", parent.HealthBar, "BOTTOM")
	comboBar:SetSize(68, 1)
	comboBar:Hide()

	for i = 1, MAX_COMBO_POINTS do
		comboBar[i] = comboBar:CreateTexture(nil, "OVERLAY")
		comboBar[i]:SetTexture([[Interface\AddOns\ElvUI\media\textures\bubbleTex.tga]])
		comboBar[i]:SetSize(12, 12)

		if i == 1 then
			comboBar[i]:Point("LEFT", comboBar, "TOPLEFT")
		else
			comboBar[i]:Point("LEFT", comboBar[i - 1], "RIGHT", 2, 0)
		end
	end

	return comboBar
end