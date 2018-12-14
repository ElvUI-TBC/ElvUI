local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local pairs, unpack = pairs, unpack

local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.auctionhouse ~= true then return end

	local AuctionFrame = _G["AuctionFrame"]
	AuctionFrame:StripTextures(true)
	AuctionFrame:CreateBackdrop("Transparent")
	AuctionFrame.backdrop:Point("TOPLEFT", 10, -10)
	AuctionFrame.backdrop:Point("BOTTOMRIGHT", 0, 10)
	AuctionFrame:Height(455)

	local Buttons = {
		BrowseSearchButton,
		BrowseResetButton,
		BrowseBidButton,
		BrowseBuyoutButton,
		BrowseCloseButton,
		BidBidButton,
		BidBuyoutButton,
		BidCloseButton,
		AuctionsCreateAuctionButton,
		AuctionsCancelAuctionButton,
		AuctionsCloseButton
	}

	local CheckBoxes = {
		IsUsableCheckButton,
		ShowOnPlayerCheckButton
	}

	local EditBoxes = {
		BrowseName,
		BrowseMinLevel,
		BrowseMaxLevel,
		BrowseBidPriceGold,
		BrowseBidPriceSilver,
		BrowseBidPriceCopper,
		BidBidPriceGold,
		BidBidPriceSilver,
		BidBidPriceCopper,
		AuctionsStackSizeEntry,
		AuctionsNumStacksEntry,
		StartPriceGold,
		StartPriceSilver,
		StartPriceCopper,
		BuyoutPriceGold,
		BuyoutPriceSilver,
		BuyoutPriceCopper
	}

	local SortTabs = {
		BrowseQualitySort,
		BrowseLevelSort,
		BrowseDurationSort,
		BrowseHighBidderSort,
		BrowseCurrentBidSort,
		BidQualitySort,
		BidLevelSort,
		BidDurationSort,
		BidBuyoutSort,
		BidStatusSort,
		BidBidSort,
		AuctionsQualitySort,
		AuctionsDurationSort,
		AuctionsHighBidderSort,
		AuctionsBidSort
	}

	for _, Button in pairs(Buttons) do
		S:HandleButton(Button, true)
	end

	for _, CheckBox in pairs(CheckBoxes) do
		S:HandleCheckBox(CheckBox)
	end

	for _, EditBox in pairs(EditBoxes) do
		S:HandleEditBox(EditBox)
		EditBox:SetTextInsets(1, 1, -1, 1)
	end

	for i = 1, AuctionFrame.numTabs do
		local tab = _G["AuctionFrameTab"..i]

		S:HandleTab(tab)

		if i == 1 then
			tab:ClearAllPoints()
			tab:Point("BOTTOMLEFT", AuctionFrame, "BOTTOMLEFT", 25, -20)
			tab.SetPoint = E.noop
		end
	end

	for _, Tab in pairs(SortTabs) do
		Tab:StripTextures()
		Tab:SetNormalTexture([[Interface\Buttons\UI-SortArrow]])
		Tab:StyleButton()
	end

	for i = 1, NUM_FILTERS_TO_DISPLAY do
		local tab = _G["AuctionFilterButton"..i]

		tab:StripTextures()
		S:HandleButtonHighlight(tab)
	end

	S:HandleCloseButton(AuctionFrameCloseButton)

	-- DressUpFrame
	AuctionDressUpFrame:StripTextures()
	AuctionDressUpFrame:CreateBackdrop("Transparent")
	AuctionDressUpFrame.backdrop:Point("TOPLEFT", 0, 10)
	AuctionDressUpFrame.backdrop:Point("BOTTOMRIGHT", -5, 3)
	AuctionDressUpFrame:Point("TOPLEFT", AuctionFrame, "TOPRIGHT", 1, -28)

	AuctionDressUpModel:CreateBackdrop()
	AuctionDressUpModel.backdrop:SetOutside(AuctionDressUpBackgroundTop, nil, nil, AuctionDressUpBackgroundBot)

	SetAuctionDressUpBackground()
	AuctionDressUpBackgroundTop:SetDesaturated(true)
	AuctionDressUpBackgroundBot:SetDesaturated(true)

	S:HandleRotateButton(AuctionDressUpModelRotateLeftButton)
	AuctionDressUpModelRotateLeftButton:Point("TOPLEFT", AuctionDressUpFrame, 8, -17)

	S:HandleRotateButton(AuctionDressUpModelRotateRightButton)
	AuctionDressUpModelRotateRightButton:Point("TOPLEFT", AuctionDressUpModelRotateLeftButton, "TOPRIGHT", 3, 0)

	S:HandleButton(AuctionDressUpFrameResetButton)

	S:HandleCloseButton(AuctionDressUpFrameCloseButton, AuctionDressUpFrame.backdrop)

	-- Browse Frame
	BrowseTitle:Point("TOP", 25, -18)

	BrowseFilterScrollFrame:StripTextures()
	BrowseScrollFrame:StripTextures()

	S:HandleDropDownBox(BrowseDropDown)

	S:HandleScrollBar(BrowseFilterScrollFrameScrollBar)
	BrowseFilterScrollFrameScrollBar:ClearAllPoints()
	BrowseFilterScrollFrameScrollBar:Point("TOPRIGHT", BrowseFilterScrollFrame, "TOPRIGHT", 22, -17)
	BrowseFilterScrollFrameScrollBar:Point("BOTTOMRIGHT", BrowseFilterScrollFrame, "BOTTOMRIGHT", 0, 16)

	S:HandleScrollBar(BrowseScrollFrameScrollBar)
	BrowseScrollFrameScrollBar:ClearAllPoints()
	BrowseScrollFrameScrollBar:Point("TOPRIGHT", BrowseScrollFrame, "TOPRIGHT", 23, -17)
	BrowseScrollFrameScrollBar:Point("BOTTOMRIGHT", BrowseScrollFrame, "BOTTOMRIGHT", 0, 17)

	BrowseCloseButton:Point("BOTTOMRIGHT", 66, 8)
	BrowseBuyoutButton:Point("RIGHT", BrowseCloseButton, "LEFT", -4, 0)
	BrowseBidButton:Point("RIGHT", BrowseBuyoutButton, "LEFT", -4, 0)

	BrowseBidPrice:Point("BOTTOM", -15, 14)
	BrowseBidText:Point("BOTTOMRIGHT", AuctionFrameBrowse, "BOTTOM", -116, 12)

	BrowseBidPriceGold:Point("TOPLEFT", 0, -3)
	BrowseBidPriceSilver:Width(35)
	BrowseBidPriceCopper:Width(35)

	BrowseMaxLevel:Point("LEFT", BrowseMinLevel, "RIGHT", 8, 0)
	BrowseLevelText:Point("BOTTOMLEFT", AuctionFrameBrowse, "TOPLEFT", 195, -48)

	BrowseName:Width(164)
	BrowseName:Point("TOPLEFT", AuctionFrameBrowse, "TOPLEFT", 20, -54)
	BrowseNameText:Point("TOPLEFT", BrowseName, "TOPLEFT", 0, 16)

	BrowseResetButton:Width(82)
	BrowseResetButton:Point("TOPLEFT", AuctionFrameBrowse, "TOPLEFT", 20, -74)

	BrowseSearchButton:ClearAllPoints()
	BrowseSearchButton:Point("TOPRIGHT", AuctionFrameBrowse, "TOPRIGHT", 25, -30)

	S:HandleNextPrevButton(BrowseNextPageButton)
	BrowseNextPageButton:ClearAllPoints()
	BrowseNextPageButton:Point("BOTTOMLEFT", BrowseSearchButton, "BOTTOMRIGHT", 10, -27)

	S:HandleNextPrevButton(BrowsePrevPageButton)
	BrowsePrevPageButton:ClearAllPoints()
	BrowsePrevPageButton:Point("BOTTOMRIGHT", BrowseSearchButton, "BOTTOMLEFT", -10, -27)

	IsUsableCheckButton:ClearAllPoints()
	IsUsableCheckButton:Point("RIGHT", BrowseIsUsableText, "LEFT", 2, 0)
	BrowseIsUsableText:Point("TOPLEFT", 440, -40)

	ShowOnPlayerCheckButton:ClearAllPoints()
	ShowOnPlayerCheckButton:Point("RIGHT", BrowseShowOnCharacterText, "LEFT", 2, 0)

	BrowseShowOnCharacterText:Point("TOPLEFT", 440, -60)

	-- Bid Frame
	BidTitle:Point("TOP", 25, -18)

	BidScrollFrame:StripTextures()
	BidScrollFrame:Height(332)

	S:HandleScrollBar(BidScrollFrameScrollBar)
	BidScrollFrameScrollBar:ClearAllPoints()
	BidScrollFrameScrollBar:Point("TOPRIGHT", BidScrollFrame, "TOPRIGHT", 23, -17)
	BidScrollFrameScrollBar:Point("BOTTOMRIGHT", BidScrollFrame, "BOTTOMRIGHT", 0, 12)

	BidCloseButton:Point("BOTTOMRIGHT", 66, 8)
	BidBuyoutButton:Point("RIGHT", BidCloseButton, "LEFT", -4, 0)
	BidBidButton:Point("RIGHT", BidBuyoutButton, "LEFT", -4, 0)

	BidBidPrice:Point("BOTTOM", -15, 14)
	BidBidText:Point("BOTTOMRIGHT", AuctionFrameBid, "BOTTOM", -115, 12)

	BidBidPriceGold:Point("TOPLEFT", 0, -3)
	BidBidPriceSilver:Width(35)
	BidBidPriceCopper:Width(35)

	-- Auctions Frame
	AuctionsTitle:Point("TOP", 25, -18)

	AuctionsScrollFrame:StripTextures()

	S:HandleScrollBar(AuctionsScrollFrameScrollBar)
	AuctionsScrollFrameScrollBar:ClearAllPoints()
	AuctionsScrollFrameScrollBar:Point("TOPRIGHT", AuctionsScrollFrame, "TOPRIGHT", 23, -19)
	AuctionsScrollFrameScrollBar:Point("BOTTOMRIGHT", AuctionsScrollFrame, "BOTTOMRIGHT", 0, 17)

	AuctionsCloseButton:Point("BOTTOMRIGHT", 66, 8)
	AuctionsCancelAuctionButton:Point("RIGHT", AuctionsCloseButton, "LEFT", -4, 0)
	AuctionsCreateAuctionButton:Point("BOTTOMLEFT", 18, 38)

	AuctionsItemButton:StripTextures()
	AuctionsItemButton:SetTemplate("Default", true)
	AuctionsItemButton:StyleButton(nil, true)

	StartPriceSilver:Width(35)
	StartPriceCopper:Width(35)

	BuyoutPriceSilver:Width(35)
	BuyoutPriceCopper:Width(35)

	AuctionsItemButton:HookScript2("OnEvent", function(self, event)
		if event == "NEW_AUCTION_UPDATE" and self:GetNormalTexture() then
			self:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			self:GetNormalTexture():SetInside()

			local _, _, _, quality = GetAuctionSellItemInfo()
			if quality then
				self:SetBackdropBorderColor(GetItemQualityColor(quality))
				AuctionsItemButtonName:SetTextColor(GetItemQualityColor(quality))
			else
				self:SetBackdropBorderColor(unpack(E.media.bordercolor))
				AuctionsItemButtonName:SetTextColor(1, 1, 1)
			end
		else
			self:SetBackdropBorderColor(unpack(E.media.bordercolor))
			AuctionsItemButtonName:SetTextColor(1, 1, 1)
		end
	end)

	for Frame, NumButtons in pairs({["Browse"] = NUM_BROWSE_TO_DISPLAY, ["Auctions"] = NUM_AUCTIONS_TO_DISPLAY, ["Bid"] = NUM_BIDS_TO_DISPLAY}) do
		for i = 1, NumButtons do
			local Button = _G[Frame.."Button"..i]
			local ItemButton = _G[Frame.."Button"..i.."Item"]
			local Texture = _G[Frame.."Button"..i.."ItemIconTexture"]
			local Name = _G[Frame.."Button"..i.."Name"]

			if Button then
				Button:StripTextures()
				S:HandleButtonHighlight(Button)
			end

			if ItemButton then
				ItemButton:SetTemplate()
				ItemButton:StyleButton()
				ItemButton:GetNormalTexture():SetTexture("")
				ItemButton:Point("TOPLEFT", 0, -1)
				ItemButton:Size(34)

				Texture:SetTexCoord(unpack(E.TexCoords))
				Texture:SetInside()

				hooksecurefunc(Name, "SetVertexColor", function(_, r, g, b) ItemButton:SetBackdropBorderColor(r, g, b) end)
				hooksecurefunc(Name, "Hide", function() ItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)
			end
		end
	end

	-- Custom Backdrops
	for _, Frame in pairs({AuctionFrameBrowse, AuctionFrameAuctions}) do
		Frame.LeftBackground = CreateFrame("Frame", nil, Frame)
		Frame.LeftBackground:SetTemplate("Transparent")
		Frame.LeftBackground:SetFrameLevel(Frame:GetFrameLevel() - 2)

		Frame.RightBackground = CreateFrame("Frame", nil, Frame)
		Frame.RightBackground:SetTemplate("Transparent")
		Frame.RightBackground:SetFrameLevel(Frame:GetFrameLevel() - 2)
	end

	AuctionFrameAuctions.LeftBackground:Point("TOPLEFT", 15, -72)
	AuctionFrameAuctions.LeftBackground:Point("BOTTOMRIGHT", -545, 34)

	AuctionFrameAuctions.RightBackground:Point("TOPLEFT", AuctionFrameAuctions.LeftBackground, "TOPRIGHT", 3, 0)
	AuctionFrameAuctions.RightBackground:Point("BOTTOMRIGHT", AuctionFrame, -8, 42)

	AuctionFrameBrowse.LeftBackground:Point("TOPLEFT", 20, -103)
	AuctionFrameBrowse.LeftBackground:Point("BOTTOMRIGHT", -575, 34)

	AuctionFrameBrowse.RightBackground:Point("TOPLEFT", AuctionFrameBrowse.LeftBackground, "TOPRIGHT", 4, 0)
	AuctionFrameBrowse.RightBackground:Point("BOTTOMRIGHT", AuctionFrame, "BOTTOMRIGHT", -8, 42)

	AuctionFrameBid.Background = CreateFrame("Frame", nil, AuctionFrameBid)
	AuctionFrameBid.Background:SetTemplate("Transparent")
	AuctionFrameBid.Background:Point("TOPLEFT", 22, -72)
	AuctionFrameBid.Background:Point("BOTTOMRIGHT", 66, 34)
	AuctionFrameBid.Background:SetFrameLevel(AuctionFrameBid:GetFrameLevel() - 2)
end

S:AddCallbackForAddon("Blizzard_AuctionUI", "AuctionHouse", LoadSkin)