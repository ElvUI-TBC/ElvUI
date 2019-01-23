local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select
local find = string.find

local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetCraftItemLink = GetCraftItemLink
local GetCraftReagentInfo = GetCraftReagentInfo
local GetCraftReagentItemLink = GetCraftReagentItemLink
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tradeskill ~= true then return end

	CRAFTS_DISPLAYED = 25

	CraftFrame:StripTextures(true)
	CraftFrame:SetAttribute("UIPanelLayout-width", E:Scale(710))
	CraftFrame:SetAttribute("UIPanelLayout-height", E:Scale(508))
	CraftFrame:Size(710, 508)

	CraftFrame:CreateBackdrop("Transparent")
	CraftFrame.backdrop:Point("TOPLEFT", 10, -12)
	CraftFrame.backdrop:Point("BOTTOMRIGHT", -34, 0)

	CraftFrame.bg1 = CreateFrame("Frame", nil, CraftFrame)
	CraftFrame.bg1:SetTemplate("Transparent")
	CraftFrame.bg1:Point("TOPLEFT", 14, -92)
	CraftFrame.bg1:Point("BOTTOMRIGHT", -367, 4)
	CraftFrame.bg1:SetFrameLevel(CraftFrame.bg1:GetFrameLevel() - 1)

	CraftFrame.bg2 = CreateFrame("Frame", nil, CraftFrame)
	CraftFrame.bg2:SetTemplate("Transparent")
	CraftFrame.bg2:Point("TOPLEFT", CraftFrame.bg1, "TOPRIGHT", 3, 0)
	CraftFrame.bg2:Point("BOTTOMRIGHT", CraftFrame, "BOTTOMRIGHT", -38, 4)
	CraftFrame.bg2:SetFrameLevel(CraftFrame.bg2:GetFrameLevel() - 1)

	CraftRankFrameBorder:StripTextures()

	CraftRankFrame:StripTextures()
	CraftRankFrame:Size(447, 16)
	CraftRankFrame:ClearAllPoints()
	CraftRankFrame:Point("TOP", -20, -45)
	CraftRankFrame:CreateBackdrop()
	CraftRankFrame:SetStatusBarTexture(E.media.normTex)
	CraftRankFrame:SetStatusBarColor(0.13, 0.28, 0.85)
	CraftRankFrame.SetStatusBarColor = E.noop
	E:RegisterStatusBar(CraftRankFrame)

	CraftRankFrameSkillRank:ClearAllPoints()
	CraftRankFrameSkillRank:Point("CENTER", CraftRankFrame, "CENTER", 0, 0)

	S:HandleCheckBox(CraftFrameAvailableFilterCheckButton)
	CraftFrameAvailableFilterCheckButton:Point("TOPLEFT", 107, -65)

	CraftFrameEditBox:ClearAllPoints()
	CraftFrameEditBox:Point("LEFT", CraftFrameAvailableFilterCheckButton, "RIGHT", 165, 0)
	S:HandleEditBox(CraftFrameEditBox)

	S:HandleDropDownBox(CraftFrameFilterDropDown, 160)
	CraftFrameFilterDropDown:ClearAllPoints()
	CraftFrameFilterDropDown:Point("LEFT", CraftFrameEditBox, "RIGHT", -16, -3)

	CraftExpandButtonFrame:StripTextures()

	CraftCollapseAllButton:Point("LEFT", CraftExpandTabLeft, "RIGHT", -8, 5)
	CraftCollapseAllButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
	CraftCollapseAllButton.SetNormalTexture = E.noop
	CraftCollapseAllButton:GetNormalTexture():Point("LEFT", 0, 2)
	CraftCollapseAllButton:GetNormalTexture():Size(15)

	CraftCollapseAllButton:SetHighlightTexture("")
	CraftCollapseAllButton.SetHighlightTexture = E.noop

	CraftCollapseAllButton:SetDisabledTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
	CraftCollapseAllButton.SetDisabledTexture = E.noop
	CraftCollapseAllButton:GetDisabledTexture():Point("LEFT", 0, 2)
	CraftCollapseAllButton:GetDisabledTexture():Size(15)
	CraftCollapseAllButton:GetDisabledTexture():SetTexCoord(0.045, 0.475, 0.085, 0.925)
	CraftCollapseAllButton:GetDisabledTexture():SetDesaturated(true)

	hooksecurefunc(CraftCollapseAllButton, "SetNormalTexture", function(self, texture)
		if find(texture, "MinusButton") then
			self:GetNormalTexture():SetTexCoord(0.545, 0.975, 0.085, 0.925)
		else
			self:GetNormalTexture():SetTexCoord(0.045, 0.475, 0.085, 0.925)
		end
	end)

	CraftFrameTitleText:ClearAllPoints()
	CraftFrameTitleText:Point("TOP", CraftRankFrame, "TOP", 0, 25)

	for i = 9, 25 do
		CreateFrame("Button", "Craft"..i, CraftFrame, "CraftButtonTemplate"):Point("TOPLEFT", _G["Craft"..i - 1], "BOTTOMLEFT")
	end

	for i = 1, CRAFTS_DISPLAYED do
		local button = _G["Craft"..i]
		local highlight = _G["Craft"..i.."Highlight"]

		button:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
		button.SetNormalTexture = E.noop
		button:GetNormalTexture():Size(14)
		button:GetNormalTexture():Point("LEFT", 4, 1)

		highlight:SetTexture("")
		highlight.SetTexture = E.noop

		hooksecurefunc(button, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self:GetNormalTexture():SetTexCoord(0.545, 0.975, 0.085, 0.925)
			elseif find(texture, "PlusButton") then
				self:GetNormalTexture():SetTexCoord(0.045, 0.475, 0.085, 0.925)
			else
				self:GetNormalTexture():SetTexCoord(0, 0, 0, 0)
			end
		end)
	end

	CraftFramePointsText:ClearAllPoints()
	CraftFramePointsText:Point("BOTTOM", CraftFrame, "BOTTOM", 84, 13)

	CraftListScrollFrame:StripTextures()
	CraftListScrollFrame:Size(300, 405)
	CraftListScrollFrame:ClearAllPoints()
	CraftListScrollFrame:Point("TOPLEFT", 17, -95)

	S:HandleScrollBar(CraftListScrollFrameScrollBar)

	CraftDetailScrollFrame:StripTextures()
	CraftDetailScrollFrame:Size(300, 381)
	CraftDetailScrollFrame:ClearAllPoints()
	CraftDetailScrollFrame:Point("TOPRIGHT", CraftFrame, -64, -95)
	CraftDetailScrollFrame.scrollBarHideable = nil

	S:HandleScrollBar(CraftDetailScrollFrameScrollBar)

	CraftDetailScrollChildFrame:StripTextures()
	CraftDetailScrollChildFrame:Size(300, 150)

	CraftName:Point("TOPLEFT", 58, -3)

	CraftIcon:SetTemplate("Default")
	CraftIcon:StyleButton(nil, true)
	CraftIcon:Size(47)
	CraftIcon:Point("TOPLEFT", 6, -3)

	CraftCancelButton:ClearAllPoints()
	CraftCancelButton:Point("TOPRIGHT", CraftDetailScrollFrame, "BOTTOMRIGHT", 23, -3)
	S:HandleButton(CraftCancelButton)

	CraftCreateButton:ClearAllPoints()
	CraftCreateButton:Point("TOPRIGHT", CraftCancelButton, "TOPLEFT", -3, 0)
	S:HandleButton(CraftCreateButton)

	S:HandleCloseButton(CraftFrameCloseButton, CraftFrame.backdrop)

	CraftRequirements:SetTextColor(1, 0.80, 0.10)

	for i = 1, MAX_CRAFT_REAGENTS do
		local reagent = _G["CraftReagent"..i]
		local icon = _G["CraftReagent"..i.."IconTexture"]
		local count = _G["CraftReagent"..i.."Count"]
		local name = _G["CraftReagent"..i.."Name"]
		local nameFrame = _G["CraftReagent"..i.."NameFrame"]

		reagent:SetTemplate("Default")
		reagent:StyleButton(nil, true)
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

		count:SetParent(icon.backdrop)
		count:SetDrawLayer("OVERLAY")

		name:Point("LEFT", nameFrame, "LEFT", 20, 0)

		nameFrame:Kill()
	end

	CraftDescription:Point("TOPLEFT", CraftDetailScrollChildFrame, "TOPLEFT", 5, -75)

	CraftReagent1:Point("TOPLEFT", CraftReagentLabel, "BOTTOMLEFT", 1, -3)
	CraftReagent2:Point("LEFT", CraftReagent1, "RIGHT", 3, 0)
	CraftReagent3:Point("TOPLEFT", CraftReagent1, "BOTTOMLEFT", 0, -3)
	CraftReagent4:Point("LEFT", CraftReagent3, "RIGHT", 3, 0)
	CraftReagent5:Point("TOPLEFT", CraftReagent3, "BOTTOMLEFT", 0, -3)
	CraftReagent6:Point("LEFT", CraftReagent5, "RIGHT", 3, 0)
	CraftReagent7:Point("TOPLEFT", CraftReagent5, "BOTTOMLEFT", 0, -3)
	CraftReagent8:Point("LEFT", CraftReagent7, "RIGHT", 3, 0)

	CraftHighlight:StripTextures()

	CraftHighlightFrame.Left = CraftHighlightFrame:CreateTexture(nil, "ARTWORK")
	CraftHighlightFrame.Left:Size(152, 15)
	CraftHighlightFrame.Left:SetPoint("LEFT", CraftHighlightFrame, "CENTER")
	CraftHighlightFrame.Left:SetTexture(E.media.blankTex)

	CraftHighlightFrame.Right = CraftHighlightFrame:CreateTexture(nil, "ARTWORK")
	CraftHighlightFrame.Right:Size(152, 15)
	CraftHighlightFrame.Right:SetPoint("RIGHT", CraftHighlightFrame, "CENTER")
	CraftHighlightFrame.Right:SetTexture(E.media.blankTex)

	hooksecurefunc(CraftHighlight, "SetVertexColor", function(_, r, g, b)
		CraftHighlightFrame.Left:SetGradientAlpha("Horizontal", r, g, b, 0.35, r, g, b, 0)
		CraftHighlightFrame.Right:SetGradientAlpha("Horizontal", r, g, b, 0, r, g, b, 0.35)
	end)

	hooksecurefunc("CraftFrame_SetSelection", function(id)
		if CraftIcon:GetNormalTexture() then
			CraftReagentLabel:SetAlpha(1)
			CraftIcon:SetAlpha(1)
			CraftIcon:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			CraftIcon:GetNormalTexture():SetInside()
		else
			CraftReagentLabel:SetAlpha(0)
			CraftIcon:SetAlpha(0)
		end

		local skillLink = GetCraftItemLink(id, 1)
		if skillLink then
			local quality = select(3, GetItemInfo(skillLink))
			if quality then
				CraftIcon:SetBackdropBorderColor(GetItemQualityColor(quality))
				CraftName:SetTextColor(GetItemQualityColor(quality))
			else
				CraftIcon:SetBackdropBorderColor(unpack(E.media.bordercolor))
				CraftName:SetTextColor(1, 1, 1)
			end
		end

		local numReagents = GetCraftNumReagents(id)
		for i = 1, numReagents, 1 do
			local _, _, reagentCount, playerReagentCount = GetCraftReagentInfo(id, i)
			local reagentLink = GetCraftReagentItemLink(id, i)
			local reagent = _G["CraftReagent"..i]
			local icon = _G["CraftReagent"..i.."IconTexture"]
			local name = _G["CraftReagent"..i.."Name"]

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

S:AddCallbackForAddon("Blizzard_CraftUI", "Craft", LoadSkin)