local E, L, V, P, G = unpack(ElvUI)
local mod = E:GetModule("NamePlates")
local LSM = LibStub("LibSharedMedia-3.0")

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
	if self.db.units[frame.UnitType].healthbar.enable or (frame.isTarget and self.db.alwaysShowTargetHealth) then
		comboPoints:SetParent(frame.HealthBar)
		comboPoints:Point("CENTER", frame.HealthBar, "BOTTOM", self.db.units[frame.UnitType].comboPoints.xOffset, self.db.units[frame.UnitType].comboPoints.yOffset)
	else
		comboPoints:SetParent(frame)
		comboPoints:Point("CENTER", frame, "TOP", self.db.units[frame.UnitType].comboPoints.xOffset, self.db.units[frame.UnitType].comboPoints.yOffset)
	end

	for i = 1, MAX_COMBO_POINTS do
		comboPoints[i]:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
		comboPoints[i]:SetStatusBarColor(unpack(E:GetColorTable(self.db.comboBar.colors[i])))

		if i == 3 then
			comboPoints[i]:Point("CENTER", comboPoints, "CENTER")
		elseif i == 1 or i == 2 then
			comboPoints[i]:Point("RIGHT", comboPoints[i + 1], "LEFT", -self.db.units[frame.UnitType].comboPoints.spacing, 0)
		else
			comboPoints[i]:Point("LEFT", comboPoints[i - 1], "RIGHT", self.db.units[frame.UnitType].comboPoints.spacing, 0)
		end

		comboPoints[i]:Width(self.db.units[frame.UnitType].comboPoints.width)
		comboPoints[i]:Height(self.db.units[frame.UnitType].comboPoints.height)
	end
end

function mod:ConstructElement_CPoints(parent)
	local comboBar = CreateFrame("Frame", "$parentComboPoints", parent.HealthBar)
	comboBar:SetSize(68, 1)
	comboBar:Hide()

	local noscalemult = E.mult * UIParent:GetScale()
	for i = 1, MAX_COMBO_POINTS do
		comboBar[i] = CreateFrame("StatusBar", nil, comboBar)
		comboBar[i]:CreateBackdrop("Default")
		comboBar[i].backdrop:SetPoint("TOPLEFT", comboBar[i], -noscalemult, noscalemult)
		comboBar[i].backdrop:SetPoint("BOTTOMRIGHT", comboBar[i], noscalemult, -noscalemult)
	end

	return comboBar
end