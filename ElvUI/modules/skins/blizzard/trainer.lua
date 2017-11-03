local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack
local find = string.find

function S:LoadTrainerSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.trainer ~= true) then return end

	ClassTrainerFrame:SetAttribute("UIPanelLayout-width", E:Scale(710))
	ClassTrainerFrame:SetAttribute("UIPanelLayout-height", E:Scale(470))
	ClassTrainerFrame:Size(710, 470)
	ClassTrainerFrame:StripTextures(true)
	ClassTrainerFrame:CreateBackdrop("Transparent")
	ClassTrainerFrame.backdrop:Point("TOPLEFT", 10, -11)
	ClassTrainerFrame.backdrop:Point("BOTTOMRIGHT", -32, 74)

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

	ClassTrainerSkillIcon:StripTextures()
	ClassTrainerSkillIcon:StyleButton(nil, true)

	hooksecurefunc("ClassTrainer_SetSelection", function()
		local skillIcon = ClassTrainerSkillIcon:GetNormalTexture()

		if skillIcon then
			skillIcon:SetInside()
			skillIcon:SetTexCoord(unpack(E.TexCoords))

			ClassTrainerSkillIcon:SetTemplate("Default")
		end
	end)

	CLASS_TRAINER_SKILLS_DISPLAYED = 19

	hooksecurefunc("ClassTrainer_SetToTradeSkillTrainer", function()
		CLASS_TRAINER_SKILLS_DISPLAYED = 19
	end)

	hooksecurefunc("ClassTrainer_SetToClassTrainer", function()
		CLASS_TRAINER_SKILLS_DISPLAYED = 19
	end)

	for i = 12, 19 do
		CreateFrame("Button", "ClassTrainerSkill" .. i, ClassTrainerFrame, "ClassTrainerSkillButtonTemplate"):Point("TOPLEFT", _G["ClassTrainerSkill" .. i - 1], "BOTTOMLEFT")
	end

	ClassTrainerSkill1:Point("TOPLEFT", 22, -80)

	for i = 1, CLASS_TRAINER_SKILLS_DISPLAYED do
		local skillButton = _G["ClassTrainerSkill" .. i]
		local highlight = _G["ClassTrainerSkill" .. i .. "Highlight"]

		skillButton:SetNormalTexture("")
		skillButton.SetNormalTexture = E.noop

		highlight:SetTexture("")
		highlight.SetTexture = E.noop

		skillButton.Text = skillButton:CreateFontString(nil, "OVERLAY")
		skillButton.Text:FontTemplate(nil, 22)
		skillButton.Text:Point("LEFT", 3, 0)
		skillButton.Text:SetText("+")

		hooksecurefunc(skillButton, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self.Text:SetText("-")
			elseif find(texture, "PlusButton") then
				self.Text:SetText("+")
			else
				self.Text:SetText("")
			end
		end)
	end

	ClassTrainerCollapseAllButton:Point("LEFT", ClassTrainerExpandTabLeft, "RIGHT", -5, 17)

	ClassTrainerCollapseAllButton:SetNormalTexture("")
	ClassTrainerCollapseAllButton.SetNormalTexture = E.noop
	ClassTrainerCollapseAllButton:SetHighlightTexture("")
	ClassTrainerCollapseAllButton.SetHighlightTexture = E.noop
	ClassTrainerCollapseAllButton:SetDisabledTexture("")
	ClassTrainerCollapseAllButton.SetDisabledTexture = E.noop

	ClassTrainerCollapseAllButton.Text = ClassTrainerCollapseAllButton:CreateFontString(nil, "OVERLAY")
	ClassTrainerCollapseAllButton.Text:FontTemplate(nil, 22)
	ClassTrainerCollapseAllButton.Text:Point("LEFT", 3, 1)
	ClassTrainerCollapseAllButton.Text:SetText("+")

	hooksecurefunc(ClassTrainerCollapseAllButton, "SetNormalTexture", function(self, texture)
		if find(texture, "MinusButton") then
			self.Text:SetText("-")
		else
			self.Text:SetText("+")
		end
	end)
end

S:AddCallbackForAddon("Blizzard_TrainerUI", "Trainer", S.LoadTrainerSkin)