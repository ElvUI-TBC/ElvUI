local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack
local find = string.find

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.trainer ~= true then return end

	ClassTrainerFrame:SetAttribute("UIPanelLayout-width", E:Scale(710))
	ClassTrainerFrame:SetAttribute("UIPanelLayout-height", E:Scale(470))
	ClassTrainerFrame:Size(710, 470)
	ClassTrainerFrame:StripTextures(true)
	ClassTrainerFrame:CreateBackdrop("Transparent")
	ClassTrainerFrame.backdrop:Point("TOPLEFT", 15, -11)
	ClassTrainerFrame.backdrop:Point("BOTTOMRIGHT", -35, 74)

	ClassTrainerListScrollFrame:StripTextures()
	ClassTrainerListScrollFrame:Size(300)
	ClassTrainerListScrollFrame.SetHeight = E.noop
	ClassTrainerListScrollFrame:ClearAllPoints()
	ClassTrainerListScrollFrame:Point("TOPLEFT", 17, -85)

	ClassTrainerDetailScrollFrame:StripTextures()
	ClassTrainerDetailScrollFrame:Size(295, 280)
	ClassTrainerDetailScrollFrame.SetHeight = E.noop
	ClassTrainerDetailScrollFrame:ClearAllPoints()
	ClassTrainerDetailScrollFrame:Point("TOPRIGHT", ClassTrainerFrame, -64, -85)
	ClassTrainerDetailScrollFrame.scrollBarHideable = nil

	ClassTrainerFrame.bg1 = CreateFrame("Frame", nil, ClassTrainerFrame)
	ClassTrainerFrame.bg1:SetTemplate("Transparent")
	ClassTrainerFrame.bg1:Point("TOPLEFT", 18, -77)
	ClassTrainerFrame.bg1:Point("BOTTOMRIGHT", -367, 77)
	ClassTrainerFrame.bg1:SetFrameLevel(ClassTrainerFrame.bg1:GetFrameLevel() - 1)

	ClassTrainerFrame.bg2 = CreateFrame("Frame", nil, ClassTrainerFrame)
	ClassTrainerFrame.bg2:SetTemplate("Transparent")
	ClassTrainerFrame.bg2:Point("TOPLEFT", ClassTrainerFrame.bg1, "TOPRIGHT", 1, 0)
	ClassTrainerFrame.bg2:Point("BOTTOMRIGHT", ClassTrainerFrame, "BOTTOMRIGHT", -38, 77)
	ClassTrainerFrame.bg2:SetFrameLevel(ClassTrainerFrame.bg2:GetFrameLevel() - 1)

	ClassTrainerDetailScrollChildFrame:StripTextures()
	ClassTrainerDetailScrollChildFrame:Size(300, 150)

	ClassTrainerExpandButtonFrame:StripTextures()

	S:HandleDropDownBox(ClassTrainerFrameFilterDropDown)
	ClassTrainerFrameFilterDropDown:Point("TOPRIGHT", -55, -40)

	S:HandleScrollBar(ClassTrainerListScrollFrameScrollBar)
	S:HandleScrollBar(ClassTrainerDetailScrollFrameScrollBar)

	ClassTrainerCancelButton:ClearAllPoints()
	ClassTrainerCancelButton:Point("TOPRIGHT", ClassTrainerDetailScrollFrame, "BOTTOMRIGHT", 23, -3)
	S:HandleButton(ClassTrainerCancelButton)

	ClassTrainerTrainButton:ClearAllPoints()
	ClassTrainerTrainButton:Point("TOPRIGHT", ClassTrainerCancelButton, "TOPLEFT", -3, 0)
	S:HandleButton(ClassTrainerTrainButton)

	ClassTrainerMoneyFrame:ClearAllPoints()
	ClassTrainerMoneyFrame:Point("BOTTOMLEFT", ClassTrainerFrame, "BOTTOMRIGHT", -180, 107)

	S:HandleCloseButton(ClassTrainerFrameCloseButton)

	ClassTrainerSkillName:Point("TOPLEFT", 55, -3)

	ClassTrainerSkillIcon:StripTextures()
	ClassTrainerSkillIcon:SetTemplate("Default")
	ClassTrainerSkillIcon:StyleButton(nil, true)
	ClassTrainerSkillIcon:Size(47)
	ClassTrainerSkillIcon:Point("TOPLEFT", 2, 0)

	ClassTrainerSkillHighlight:StripTextures()

	ClassTrainerSkillHighlightFrame.Left = ClassTrainerSkillHighlightFrame:CreateTexture(nil, "ARTWORK")
	ClassTrainerSkillHighlightFrame.Left:Size(152, 15)
	ClassTrainerSkillHighlightFrame.Left:SetPoint("LEFT", ClassTrainerSkillHighlightFrame, "CENTER")
	ClassTrainerSkillHighlightFrame.Left:SetTexture(E.media.blankTex)

	ClassTrainerSkillHighlightFrame.Right = ClassTrainerSkillHighlightFrame:CreateTexture(nil, "ARTWORK")
	ClassTrainerSkillHighlightFrame.Right:Size(152, 15)
	ClassTrainerSkillHighlightFrame.Right:SetPoint("RIGHT", ClassTrainerSkillHighlightFrame, "CENTER")
	ClassTrainerSkillHighlightFrame.Right:SetTexture(E.media.blankTex)

	hooksecurefunc("ClassTrainer_SetSelection", function(id)
		if not id then return; end -- We are often called without an id (nothing to skin in that case).

		local skillIcon = ClassTrainerSkillIcon:GetNormalTexture()

		if skillIcon and not skillIcon.isSkinned then
			skillIcon:SetInside()
			skillIcon:SetTexCoord(unpack(E.TexCoords))

			skillIcon.isSkinned = true
		end

		local _, _, serviceType = GetTrainerServiceInfo(id)
		local r, g, b
		if serviceType == "available" then
			r, g, b = 0, 1, 0
		elseif serviceType == "used" then
			r, g, b = 0.5, 0.5, 0.5
		elseif serviceType == "unavailable" then
			r, g, b = 1, 0, 0
		end
		ClassTrainerSkillHighlightFrame.Left:SetGradientAlpha("Horizontal", r, g, b, 0.35, r, g, b, 0)
		ClassTrainerSkillHighlightFrame.Right:SetGradientAlpha("Horizontal", r, g, b, 0, r, g, b, 0.35)
	end)

	CLASS_TRAINER_SKILLS_DISPLAYED = 19

	hooksecurefunc("ClassTrainer_SetToTradeSkillTrainer", function()
		CLASS_TRAINER_SKILLS_DISPLAYED = 19
	end)

	hooksecurefunc("ClassTrainer_SetToClassTrainer", function()
		CLASS_TRAINER_SKILLS_DISPLAYED = 19
	end)

	for i = 12, 19 do
		CreateFrame("Button", "ClassTrainerSkill"..i, ClassTrainerFrame, "ClassTrainerSkillButtonTemplate"):Point("TOPLEFT", _G["ClassTrainerSkill"..i - 1], "BOTTOMLEFT")
	end

	ClassTrainerSkill1:Point("TOPLEFT", 22, -80)

	for i = 1, CLASS_TRAINER_SKILLS_DISPLAYED do
		local skillButton = _G["ClassTrainerSkill"..i]
		local highlight = _G["ClassTrainerSkill"..i.."Highlight"]

		skillButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
		skillButton.SetNormalTexture = E.noop
		skillButton:GetNormalTexture():Size(13)

		highlight:SetTexture("")
		highlight.SetTexture = E.noop

		hooksecurefunc(skillButton, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self:GetNormalTexture():SetTexCoord(0.545, 0.975, 0.085, 0.925)
			elseif find(texture, "PlusButton") then
				self:GetNormalTexture():SetTexCoord(0.045, 0.475, 0.085, 0.925)
			else
				self:GetNormalTexture():SetTexCoord(0, 0, 0, 0)
			end
		end)
	end

	ClassTrainerCollapseAllButton:Point("LEFT", ClassTrainerExpandTabLeft, "RIGHT", -8, 18)

	ClassTrainerCollapseAllButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
	ClassTrainerCollapseAllButton.SetNormalTexture = E.noop
	ClassTrainerCollapseAllButton:GetNormalTexture():Point("LEFT", 3, 2)
	ClassTrainerCollapseAllButton:GetNormalTexture():Size(15)

	ClassTrainerCollapseAllButton:SetHighlightTexture("")
	ClassTrainerCollapseAllButton.SetHighlightTexture = E.noop

	ClassTrainerCollapseAllButton:SetDisabledTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
	ClassTrainerCollapseAllButton.SetDisabledTexture = E.noop
	ClassTrainerCollapseAllButton:GetDisabledTexture():Point("LEFT", 3, 2)
	ClassTrainerCollapseAllButton:GetDisabledTexture():Size(15)
	ClassTrainerCollapseAllButton:GetDisabledTexture():SetTexCoord(0.045, 0.475, 0.085, 0.925)
	ClassTrainerCollapseAllButton:GetDisabledTexture():SetDesaturated(true)

	hooksecurefunc(ClassTrainerCollapseAllButton, "SetNormalTexture", function(self, texture)
		if find(texture, "MinusButton") then
			self:GetNormalTexture():SetTexCoord(0.545, 0.975, 0.085, 0.925)
		else
			self:GetNormalTexture():SetTexCoord(0.045, 0.475, 0.085, 0.925)
		end
	end)
end

S:AddCallbackForAddon("Blizzard_TrainerUI", "Trainer", LoadSkin)