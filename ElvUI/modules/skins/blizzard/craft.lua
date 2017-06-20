local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack
local find = string.find

function S:LoadCraftSkin()
	if (E.private.skins.blizzard.enable ~= true or not E.private.skins.blizzard.craft ~= true) then return end

	CraftFrame:CreateBackdrop("Transparent")
	CraftFrame.backdrop:Point("TOPLEFT", 10, -11)
	CraftFrame.backdrop:Point("BOTTOMRIGHT", -32, 74)

	CraftFrame:StripTextures(true)

	CraftExpandButtonFrame:StripTextures()
	CraftDetailScrollChildFrame:StripTextures()

	S:HandleDropDownBox(CraftFrameFilterDropDown)

	CraftListScrollFrame:StripTextures()
	S:HandleScrollBar(CraftListScrollFrameScrollBar)

	CraftDetailScrollFrame:StripTextures()
	S:HandleScrollBar(CraftDetailScrollFrameScrollBar)

	CraftIcon:StripTextures()

	S:HandleButton(CraftCreateButton)
	S:HandleButton(CraftCancelButton)

	S:HandleCloseButton(CraftFrameCloseButton)

	hooksecurefunc("CraftFrame_SetSelection", function()
		local craftIcon = CraftIcon:GetNormalTexture()
		if(craftIcon) then
			craftIcon:SetInside()
			craftIcon:SetTexCoord(unpack(E.TexCoords))

			CraftIcon:SetTemplate("Default")
		end
	end)

	for i = 1, CRAFTS_DISPLAYED do
		local craftButton = _G["Craft" .. i]
		craftButton:SetNormalTexture("")
		craftButton.SetNormalTexture = E.noop

		_G["Craft" .. i .. "Highlight"]:SetTexture("")
		_G["Craft" .. i .. "Highlight"].SetTexture = E.noop

		craftButton.Text = craftButton:CreateFontString(nil, "OVERLAY")
		craftButton.Text:FontTemplate(nil, 22)
		craftButton.Text:Point("LEFT", 3, 0)
		craftButton.Text:SetText("+")

		hooksecurefunc(craftButton, "SetNormalTexture", function(self, texture)
			if(find(texture, "UI-MinusButton-Up")) then
				self.Text:SetText("-")
			elseif(find(texture, "UI-PlusButton-Up")) then
				self.Text:SetText("+")
			else
				self.Text:SetText("")
			end
		end)
	end

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
		if(find(texture, "UI-MinusButton-Up")) then
			self.Text:SetText("-")
		else
			self.Text:SetText("+")
		end
	end)
end

S:AddCallbackForAddon("Blizzard_CraftUI", "Craft", S.LoadCraftSkin)