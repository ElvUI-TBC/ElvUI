local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local select = select
local find, gsub = string.find, string.gsub

local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.gossip ~= true then return end

	--ItemText Frame
	ItemTextScrollFrame:StripTextures()

	ItemTextFrame:StripTextures(true)
	ItemTextFrame:CreateBackdrop("Transparent")
	ItemTextFrame.backdrop:Point("TOPLEFT", 13, -13)
	ItemTextFrame.backdrop:Point("BOTTOMRIGHT", -32, 74)

	ItemTextPageText:SetTextColor(1, 1, 1)
	ItemTextPageText.SetTextColor = E.noop

	ItemTextPageText:EnableMouseWheel(true)
	ItemTextPageText:SetScript("OnMouseWheel", function(_, value)
		if value > 0 then
			if ItemTextPrevPageButton:IsShown() and ItemTextPrevPageButton:IsEnabled() == 1 then
				ItemTextPrevPage()
			end
		else
			if ItemTextNextPageButton:IsShown() and ItemTextNextPageButton:IsEnabled() == 1 then
				ItemTextNextPage()
			end
		end
	end)

	ItemTextCurrentPage:Point("TOP", -15, -52)

	ItemTextTitleText:ClearAllPoints()
	ItemTextTitleText:Point("TOP", ItemTextCurrentPage, "TOP", 0, 30)

	S:HandleNextPrevButton(ItemTextPrevPageButton)
	ItemTextPrevPageButton:Point("CENTER", ItemTextFrame, "TOPLEFT", 45, -60)

	S:HandleNextPrevButton(ItemTextNextPageButton)
	ItemTextNextPageButton:Point("CENTER", ItemTextFrame, "TOPRIGHT", -80, -60)

	S:HandleScrollBar(ItemTextScrollFrameScrollBar)

	S:HandleCloseButton(ItemTextCloseButton)

	-- Gossip Frame
	GossipFramePortrait:Kill()

	GossipGreetingText:SetTextColor(1, 1, 1)

	GossipFrame:CreateBackdrop("Transparent")
	GossipFrame.backdrop:Point("TOPLEFT", 15, -11)
	GossipFrame.backdrop:Point("BOTTOMRIGHT", -30, 0)

	GossipFrameNpcNameText:ClearAllPoints()
	GossipFrameNpcNameText:Point("TOP", GossipFrame, "TOP", -5, -24)

	GossipFrameGreetingPanel:StripTextures()

	GossipGreetingScrollFrame:Height(402)

	S:HandleButton(GossipFrameGreetingGoodbyeButton)
	GossipFrameGreetingGoodbyeButton:Point("BOTTOMRIGHT", -37, 4)

	S:HandleScrollBar(GossipGreetingScrollFrameScrollBar, 5)

	S:HandleCloseButton(GossipFrameCloseButton)
	GossipFrameCloseButton:Point("CENTER", GossipFrame, "TOPRIGHT", -44, -25)

	for i = 1, NUMGOSSIPBUTTONS do
		local button = _G["GossipTitleButton"..i]
		local obj = select(3, button:GetRegions())

		S:HandleButtonHighlight(button)

		obj:SetTextColor(1, 1, 1)
	end

	hooksecurefunc("GossipFrameUpdate", function()
		for i = 1, NUMGOSSIPBUTTONS do
			local button = _G["GossipTitleButton"..i]

			if button:GetFontString() then
				if button:GetFontString():GetText() and button:GetFontString():GetText():find("|cff000000") then
					button:GetFontString():SetText(gsub(button:GetFontString():GetText(), "|cff000000", "|cffFFFF00"))
				end
			end
		end
	end)
end

S:AddCallback("Gossip", LoadSkin)