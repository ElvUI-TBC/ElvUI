local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack
local find = string.find

function S:LoadCraftSkin()
	if E.private.skins.blizzard.enable ~= true or not E.private.skins.blizzard.craft ~= true then return end

	CRAFTS_DISPLAYED = 25

	CraftFrame:StripTextures(true)
	CraftFrame:SetAttribute("UIPanelLayout-width", E:Scale(710))
	CraftFrame:SetAttribute("UIPanelLayout-height", E:Scale(508))
	CraftFrame:Size(710, 508)

	CraftFrame:CreateBackdrop("Transparent")
	CraftFrame.backdrop:Point("TOPLEFT", 10, -12)
	CraftFrame.backdrop:Point("BOTTOMRIGHT", -34, 0)

	CraftRankFrame:StripTextures()
	CraftRankFrame:Size(447, 16)
	CraftRankFrame:ClearAllPoints()
	CraftRankFrame:Point("TOP", 10, -45)
	CraftRankFrame:CreateBackdrop()
	CraftRankFrame:SetStatusBarTexture(E["media"].normTex)
	CraftRankFrame:SetStatusBarColor(0.13, 0.35, 0.80)
	E:RegisterStatusBar(CraftRankFrame)

	CraftRankFrameBorder:Kill()

	CraftRankFrameSkillRank:ClearAllPoints()
	CraftRankFrameSkillRank:Point("CENTER", CraftRankFrame, "CENTER", 0, 0)

	S:HandleCheckBox(CraftFrameAvailableFilterCheckButton)
	CraftFrameAvailableFilterCheckButton:Point("TOPLEFT", 122, -65)

	CraftFrameEditBox:ClearAllPoints()
	CraftFrameEditBox:Point("LEFT", CraftFrameAvailableFilterCheckButton, "RIGHT", 100, 0)
	S:HandleEditBox(CraftFrameEditBox)

	CraftExpandButtonFrame:StripTextures()

	CraftCollapseAllButton:SetNormalTexture("")
	CraftCollapseAllButton.SetNormalTexture = E.noop
	CraftCollapseAllButton:SetHighlightTexture("")
	CraftCollapseAllButton.SetHighlightTexture = E.noop
	CraftCollapseAllButton:SetDisabledTexture("")
	CraftCollapseAllButton.SetDisabledTexture = E.noop

	CraftCollapseAllButton.Text = CraftCollapseAllButton:CreateFontString(nil, "OVERLAY")
	CraftCollapseAllButton.Text:FontTemplate(nil, 22)
	CraftCollapseAllButton.Text:Point("LEFT", 3, 0)
	CraftCollapseAllButton.Text:SetText("+")

	hooksecurefunc(CraftCollapseAllButton, "SetNormalTexture", function(self, texture)
		if(find(texture, "MinusButton")) then
			self.Text:SetText("-")
		else
			self.Text:SetText("+")
		end
	end)

	S:HandleDropDownBox(CraftFrameFilterDropDown, 140)
	CraftFrameFilterDropDown:ClearAllPoints()
	CraftFrameFilterDropDown:Point("LEFT", CraftFrameEditBox, "RIGHT", -16, -3)

	for i = 9, 25 do
		CreateFrame("Button", "Craft" .. i, CraftFrame, "CraftButtonTemplate"):Point("TOPLEFT", _G["Craft" .. i - 1], "BOTTOMLEFT")
	end

	for i = 1, CRAFTS_DISPLAYED do
		local skillButton = _G["Craft" .. i]
		skillButton:SetNormalTexture("")
		skillButton.SetNormalTexture = E.noop

		_G["Craft" .. i .. "Highlight"]:SetTexture("")
		_G["Craft" .. i .. "Highlight"].SetTexture = E.noop

		skillButton.Text = skillButton:CreateFontString(nil, "OVERLAY")
		skillButton.Text:FontTemplate(nil, 22)
		skillButton.Text:Point("LEFT", 3, 0)
		skillButton.Text:SetText("+")

		hooksecurefunc(skillButton, "SetNormalTexture", function(self, texture)
			if(find(texture, "MinusButton")) then
				self.Text:SetText("-")
			elseif(find(texture, "PlusButton")) then
				self.Text:SetText("+")
			else
				self.Text:SetText("")
			end
		end)
	end

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

	CraftName:Point("TOPLEFT", 65, -20)

	CraftIcon:Size(47)
	CraftIcon:Point("TOPLEFT", 10, -20)
	CraftIcon:StyleButton(nil, true)
	CraftIcon:SetTemplate("Default")

	for i = 1, MAX_CRAFT_REAGENTS do
		local reagent = _G["CraftReagent" .. i]
		local icon = _G["CraftReagent" .. i .. "IconTexture"]
		local count = _G["CraftReagent" .. i .. "Count"]

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetDrawLayer("OVERLAY")

		icon.backdrop = CreateFrame("Frame", nil, reagent)
		icon.backdrop:SetFrameLevel(reagent:GetFrameLevel() - 1)
		icon.backdrop:SetTemplate("Default")
		icon.backdrop:SetOutside(icon)

		icon:SetParent(icon.backdrop)
		count:SetParent(icon.backdrop)
		count:SetDrawLayer("OVERLAY")
	end

	-- CraftReagentLabel:Point("TOPLEFT", CraftIcon, "BOTTOMLEFT", 0, -10)

	-- CraftDescription:Point("BOTTOMLEFT", CraftIcon, "BOTTOMLEFT", 65, 28)

	CraftReagent1:Point("TOPLEFT", CraftIcon, "BOTTOMLEFT", 0, -30)
	CraftReagent3:Point("TOPLEFT", CraftReagent1, "BOTTOMLEFT", 0, -3)
	CraftReagent5:Point("TOPLEFT", CraftReagent3, "BOTTOMLEFT", 0, -3)
	CraftReagent7:Point("TOPLEFT", CraftReagent6, "BOTTOMLEFT", 0, -3)

	CraftCancelButton:ClearAllPoints()
	CraftCancelButton:Point("TOPRIGHT", CraftDetailScrollFrame, "BOTTOMRIGHT", 23, -3)
	S:HandleButton(CraftCancelButton)

	CraftCreateButton:ClearAllPoints()
	CraftCreateButton:Point("TOPRIGHT", CraftCancelButton, "TOPLEFT", -3, 0)
	S:HandleButton(CraftCreateButton)

	S:HandleCloseButton(CraftFrameCloseButton)

	hooksecurefunc("CraftFrame_SetSelection", function(id)
		if CraftIcon:GetNormalTexture() then
			CraftIcon:SetAlpha(1)
			CraftIcon:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			CraftIcon:GetNormalTexture():SetInside()
		else
			CraftIcon:SetAlpha(0)
		end
		--[[
		local skillLink = GetCraftReagentItemLink(id)
		if(skillLink) then
			CraftRequirements:SetTextColor(1, 0.80, 0.10)
			local quality = select(3, GetItemInfo(skillLink))
			if(quality and quality > 1) then
				CraftIcon:SetBackdropBorderColor(GetItemQualityColor(quality))
				CraftName:SetTextColor(GetItemQualityColor(quality))
			else
				CraftIcon:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				CraftName:SetTextColor(1, 1, 1)
			end
		end

		local numReagents = GetCraftNumReagents(id)
		for i = 1, numReagents, 1 do
			local reagentName, reagentTexture, reagentCount, playerReagentCount = GetCraftReagentInfo(id, i)
			local reagentLink = GetCraftReagentItemLink(id, i)
			local icon = _G["CraftReagent" .. i .. "IconTexture"]
			local name = _G["CraftReagent" .. i .. "Name"]

			if(reagentLink) then
				local quality = select(3, GetItemInfo(reagentLink))
				if(quality and quality > 1) then
					icon.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					if(playerReagentCount < reagentCount) then
						name:SetTextColor(0.5, 0.5, 0.5)
					else
						name:SetTextColor(GetItemQualityColor(quality))
					end
				else
					icon.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				end
			end
		end
		--]]
	end)
end

S:AddCallbackForAddon("Blizzard_CraftUI", "Craft", S.LoadCraftSkin)