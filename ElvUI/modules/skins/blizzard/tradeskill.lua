local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select
local find = string.find

local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetTradeSkillItemLink = GetTradeSkillItemLink
local GetTradeSkillReagentInfo = GetTradeSkillReagentInfo
local GetTradeSkillReagentItemLink = GetTradeSkillReagentItemLink
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tradeskill ~= true then return end

	TRADE_SKILLS_DISPLAYED = 25

	local TradeSkillFrame = _G["TradeSkillFrame"]
	TradeSkillFrame:StripTextures(true)
	TradeSkillFrame:SetAttribute("UIPanelLayout-width", E:Scale(710))
	TradeSkillFrame:SetAttribute("UIPanelLayout-height", E:Scale(508))
	TradeSkillFrame:Size(710, 508)

	TradeSkillFrame:CreateBackdrop("Transparent")
	TradeSkillFrame.backdrop:Point("TOPLEFT", 10, -12)
	TradeSkillFrame.backdrop:Point("BOTTOMRIGHT", -34, 0)

	TradeSkillFrame.bg1 = CreateFrame("Frame", nil, TradeSkillFrame)
	TradeSkillFrame.bg1:SetTemplate("Transparent")
	TradeSkillFrame.bg1:Point("TOPLEFT", 14, -92)
	TradeSkillFrame.bg1:Point("BOTTOMRIGHT", -367, 4)
	TradeSkillFrame.bg1:SetFrameLevel(TradeSkillFrame.bg1:GetFrameLevel() - 1)

	TradeSkillFrame.bg2 = CreateFrame("Frame", nil, TradeSkillFrame)
	TradeSkillFrame.bg2:SetTemplate("Transparent")
	TradeSkillFrame.bg2:Point("TOPLEFT", TradeSkillFrame.bg1, "TOPRIGHT", 3, 0)
	TradeSkillFrame.bg2:Point("BOTTOMRIGHT", TradeSkillFrame, "BOTTOMRIGHT", -38, 4)
	TradeSkillFrame.bg2:SetFrameLevel(TradeSkillFrame.bg2:GetFrameLevel() - 1)

	TradeSkillRankFrameBorder:StripTextures()

	TradeSkillRankFrame:StripTextures()
	TradeSkillRankFrame:Size(447, 16)
	TradeSkillRankFrame:ClearAllPoints()
	TradeSkillRankFrame:Point("TOP", -20, -45)
	TradeSkillRankFrame:CreateBackdrop()
	TradeSkillRankFrame:SetStatusBarTexture(E.media.normTex)
	TradeSkillRankFrame:SetStatusBarColor(0.13, 0.28, 0.85)
	TradeSkillRankFrame.SetStatusBarColor = E.noop
	E:RegisterStatusBar(TradeSkillRankFrame)

	TradeSkillRankFrameSkillRank:ClearAllPoints()
	TradeSkillRankFrameSkillRank:Point("CENTER", TradeSkillRankFrame, "CENTER", 0, 0)

	S:HandleCheckBox(TradeSkillFrameAvailableFilterCheckButton)
	TradeSkillFrameAvailableFilterCheckButton:Point("TOPLEFT", 70, -65)

	TradeSkillFrameEditBox:ClearAllPoints()
	TradeSkillFrameEditBox:Point("LEFT", TradeSkillFrameAvailableFilterCheckButton, "RIGHT", 100, 0)
	S:HandleEditBox(TradeSkillFrameEditBox)

	S:HandleDropDownBox(TradeSkillInvSlotDropDown, 160)
	TradeSkillInvSlotDropDown:ClearAllPoints()
	TradeSkillInvSlotDropDown:Point("LEFT", TradeSkillFrameEditBox, "RIGHT", -16, -3)

	S:HandleDropDownBox(TradeSkillSubClassDropDown, 160)
	TradeSkillSubClassDropDown:ClearAllPoints()
	TradeSkillSubClassDropDown:Point("LEFT", TradeSkillInvSlotDropDown, "RIGHT", -25, 0)

	TradeSkillFrameTitleText:ClearAllPoints()
	TradeSkillFrameTitleText:Point("TOP", TradeSkillRankFrameSkillRank, "TOP", 0, 25)

	for i = 9, 25 do
		CreateFrame("Button", "TradeSkillSkill"..i, TradeSkillFrame, "TradeSkillSkillButtonTemplate"):Point("TOPLEFT", _G["TradeSkillSkill"..i - 1], "BOTTOMLEFT")
	end

	TradeSkillExpandButtonFrame:StripTextures()
	TradeSkillExpandButtonFrame:Point("TOPLEFT", 10, -71)

	TradeSkillCollapseAllButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
	TradeSkillCollapseAllButton.SetNormalTexture = E.noop
	TradeSkillCollapseAllButton:GetNormalTexture():Point("LEFT", 0, 2)
	TradeSkillCollapseAllButton:GetNormalTexture():Size(15)

	TradeSkillCollapseAllButton:SetHighlightTexture("")
	TradeSkillCollapseAllButton.SetHighlightTexture = E.noop

	TradeSkillCollapseAllButton:SetDisabledTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
	TradeSkillCollapseAllButton.SetDisabledTexture = E.noop
	TradeSkillCollapseAllButton:GetDisabledTexture():Point("LEFT", 0, 2)
	TradeSkillCollapseAllButton:GetDisabledTexture():Size(15)
	TradeSkillCollapseAllButton:GetDisabledTexture():SetTexCoord(0.040, 0.465, 0.085, 0.920)
	TradeSkillCollapseAllButton:GetDisabledTexture():SetDesaturated(true)

	hooksecurefunc(TradeSkillCollapseAllButton, "SetNormalTexture", function(self, texture)
		if find(texture, "MinusButton") then
			self:GetNormalTexture():SetTexCoord(0.540, 0.965, 0.085, 0.920)
		else
			self:GetNormalTexture():SetTexCoord(0.040, 0.465, 0.085, 0.920)
		end
	end)

	for i = 1, TRADE_SKILLS_DISPLAYED do
		local button = _G["TradeSkillSkill"..i]
		local highlight = _G["TradeSkillSkill"..i.."Highlight"]

		button:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
		button.SetNormalTexture = E.noop
		button:GetNormalTexture():Size(14)
		button:GetNormalTexture():Point("LEFT", 0, 1)

		highlight:SetTexture("")
		highlight.SetTexture = E.noop

		hooksecurefunc(button, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self:GetNormalTexture():SetTexCoord(0.540, 0.965, 0.085, 0.920)
			elseif find(texture, "PlusButton") then
				self:GetNormalTexture():SetTexCoord(0.040, 0.465, 0.085, 0.920)
			else
				self:GetNormalTexture():SetTexCoord(0, 0, 0, 0)
 			end
		end)
	end

	TradeSkillListScrollFrame:StripTextures()
	TradeSkillListScrollFrame:Size(300, 405)
	TradeSkillListScrollFrame:ClearAllPoints()
	TradeSkillListScrollFrame:Point("TOPLEFT", 17, -95)

	S:HandleScrollBar(TradeSkillListScrollFrameScrollBar)

	TradeSkillDetailScrollFrame:StripTextures()
	TradeSkillDetailScrollFrame:Size(300, 381)
	TradeSkillDetailScrollFrame:ClearAllPoints()
	TradeSkillDetailScrollFrame:Point("TOPRIGHT", TradeSkillFrame, -64, -95)
	TradeSkillDetailScrollFrame.scrollBarHideable = nil

	S:HandleScrollBar(TradeSkillDetailScrollFrameScrollBar)

	TradeSkillDetailScrollChildFrame:StripTextures()
	TradeSkillDetailScrollChildFrame:Size(300, 150)

	TradeSkillSkillName:Point("TOPLEFT", 58, -3)

	TradeSkillSkillIcon:SetTemplate("Default")
	TradeSkillSkillIcon:StyleButton(nil, true)
	TradeSkillSkillIcon:Size(47)
	TradeSkillSkillIcon:Point("TOPLEFT", 6, -3)

	TradeSkillRequirementLabel:SetTextColor(1, 0.80, 0.10)

	for i = 1, MAX_TRADE_SKILL_REAGENTS do
		local reagent = _G["TradeSkillReagent"..i]
		local icon = _G["TradeSkillReagent"..i.."IconTexture"]
		local count = _G["TradeSkillReagent"..i.."Count"]
		local name = _G["TradeSkillReagent"..i.."Name"]
		local nameFrame = _G["TradeSkillReagent"..i.."NameFrame"]

		reagent:SetTemplate("Default")
		reagent:StyleButton()
		reagent:Size(143, 40)

		icon.backdrop = CreateFrame("Frame", nil, reagent)
		icon.backdrop:SetFrameLevel(reagent:GetFrameLevel() - 1)
		icon.backdrop:SetTemplate("Default")
		icon.backdrop:SetOutside(icon)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetDrawLayer("OVERLAY")
		icon:Size(E.PixelMode and 38 or 32)
		icon:Point("TOPLEFT", E.PixelMode and 1 or 4, -(E.PixelMode and 1 or 4))
		icon:SetParent(icon.backdrop)

		count:Point("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -3, 2)
		count:SetParent(icon.backdrop)
		count:SetDrawLayer("OVERLAY")

		name:SetPoint("LEFT", nameFrame, "LEFT", 20, 0)

		nameFrame:Kill()
	end

	TradeSkillReagentLabel:Point("TOPLEFT", TradeSkillSkillIcon, "BOTTOMLEFT", 0, -10)

	TradeSkillReagent1:Point("TOPLEFT", TradeSkillReagentLabel, "BOTTOMLEFT", 1, -3)
	TradeSkillReagent2:Point("LEFT", TradeSkillReagent1, "RIGHT", 3, 0)
	TradeSkillReagent3:Point("TOPLEFT", TradeSkillReagent1, "BOTTOMLEFT", 0, -3)
	TradeSkillReagent4:Point("LEFT", TradeSkillReagent3, "RIGHT", 3, 0)
	TradeSkillReagent5:Point("TOPLEFT", TradeSkillReagent3, "BOTTOMLEFT", 0, -3)
	TradeSkillReagent6:Point("LEFT", TradeSkillReagent5, "RIGHT", 3, 0)
	TradeSkillReagent7:Point("TOPLEFT", TradeSkillReagent5, "BOTTOMLEFT", 0, -3)
	TradeSkillReagent8:Point("LEFT", TradeSkillReagent7, "RIGHT", 3, 0)

	TradeSkillCancelButton:ClearAllPoints()
	TradeSkillCancelButton:Point("TOPRIGHT", TradeSkillDetailScrollFrame, "BOTTOMRIGHT", 23, -3)
	S:HandleButton(TradeSkillCancelButton)

	TradeSkillCreateButton:ClearAllPoints()
	TradeSkillCreateButton:Point("TOPRIGHT", TradeSkillCancelButton, "TOPLEFT", -3, 0)
	S:HandleButton(TradeSkillCreateButton)

	TradeSkillCreateAllButton:ClearAllPoints()
	TradeSkillCreateAllButton:Point("TOPLEFT", TradeSkillDetailScrollFrame, "BOTTOMLEFT", 4, -3)
	S:HandleButton(TradeSkillCreateAllButton)

	S:HandleNextPrevButton(TradeSkillDecrementButton)
	TradeSkillInputBox:Height(16)
	S:HandleEditBox(TradeSkillInputBox)
	S:HandleNextPrevButton(TradeSkillIncrementButton)

	S:HandleCloseButton(TradeSkillFrameCloseButton, TradeSkillFrame.backdrop)

	TradeSkillHighlight:StripTextures()

	TradeSkillHighlightFrame.Left = TradeSkillHighlightFrame:CreateTexture(nil, "ARTWORK")
	TradeSkillHighlightFrame.Left:Size(152, 15)
	TradeSkillHighlightFrame.Left:SetPoint("LEFT", TradeSkillHighlightFrame, "CENTER")
	TradeSkillHighlightFrame.Left:SetTexture(E.media.blankTex)

	TradeSkillHighlightFrame.Right = TradeSkillHighlightFrame:CreateTexture(nil, "ARTWORK")
	TradeSkillHighlightFrame.Right:Size(152, 15)
	TradeSkillHighlightFrame.Right:SetPoint("RIGHT", TradeSkillHighlightFrame, "CENTER")
	TradeSkillHighlightFrame.Right:SetTexture(E.media.blankTex)

	hooksecurefunc(TradeSkillHighlight, "SetVertexColor", function(_, r, g, b)
		TradeSkillHighlightFrame.Left:SetGradientAlpha("Horizontal", r, g, b, 0.35, r, g, b, 0)
		TradeSkillHighlightFrame.Right:SetGradientAlpha("Horizontal", r, g, b, 0, r, g, b, 0.35)
	end)

	hooksecurefunc("TradeSkillFrame_SetSelection", function(id)
		if TradeSkillSkillIcon:GetNormalTexture() then
			TradeSkillReagentLabel:SetAlpha(1)
			TradeSkillSkillIcon:SetAlpha(1)
			TradeSkillSkillIcon:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			TradeSkillSkillIcon:GetNormalTexture():SetInside()
		else
			TradeSkillReagentLabel:SetAlpha(0)
			TradeSkillSkillIcon:SetAlpha(0)
		end

		local skillLink = GetTradeSkillItemLink(id)
		if skillLink then
			local quality = select(3, GetItemInfo(skillLink))
			if quality then
				TradeSkillSkillIcon:SetBackdropBorderColor(GetItemQualityColor(quality))
				TradeSkillSkillName:SetTextColor(GetItemQualityColor(quality))
			else
				TradeSkillSkillIcon:SetBackdropBorderColor(unpack(E.media.bordercolor))
				TradeSkillSkillName:SetTextColor(1, 1, 1)
			end
		end

		local numReagents = GetTradeSkillNumReagents(id)
		for i = 1, numReagents, 1 do
			local _, _, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i)
			local reagentLink = GetTradeSkillReagentItemLink(id, i)
			local reagent = _G["TradeSkillReagent"..i]
			local icon = _G["TradeSkillReagent"..i.."IconTexture"]
			local name = _G["TradeSkillReagent"..i.."Name"]

			if reagentLink then
				local quality = select(3, GetItemInfo(reagentLink))
				if quality then
					icon.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					reagent:SetBackdropBorderColor(GetItemQualityColor(quality))
					if playerReagentCount < reagentCount then
						name:SetTextColor(0.5, 0.5, 0.5)
					else
						name:SetTextColor(GetItemQualityColor(quality))
					end
				else
					reagent:SetBackdropBorderColor(unpack(E.media.bordercolor))
					icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			end
		end
	end)
end

S:AddCallbackForAddon("Blizzard_TradeSkillUI", "TradeSkill", LoadSkin)