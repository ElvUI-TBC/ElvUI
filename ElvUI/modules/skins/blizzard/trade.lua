local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select

local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetTradePlayerItemLink = GetTradePlayerItemLink
local GetTradeTargetItemLink = GetTradeTargetItemLink

function S:LoadTradeSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.trade ~= true) then return end

	TradeFrame:StripTextures(true)
	TradeFrame:Width(400)
	TradeFrame:CreateBackdrop("Transparent")
	TradeFrame.backdrop:Point("TOPLEFT", 10, -11)
	TradeFrame.backdrop:Point("BOTTOMRIGHT", -28, 48)

	S:HandleCloseButton(TradeFrameCloseButton, TradeFrame.backdrop)

	S:HandleEditBox(TradePlayerInputMoneyFrameGold)
	S:HandleEditBox(TradePlayerInputMoneyFrameSilver)
	S:HandleEditBox(TradePlayerInputMoneyFrameCopper)

	for i = 1, MAX_TRADE_ITEMS do
		local player = _G["TradePlayerItem" .. i]
		local recipient = _G["TradeRecipientItem" .. i]
		local playerButton = _G["TradePlayerItem" .. i .. "ItemButton"]
		local playerButtonIcon = _G["TradePlayerItem" .. i .. "ItemButtonIconTexture"]
		local recipientButton = _G["TradeRecipientItem" .. i .. "ItemButton"]
		local recipientButtonIcon = _G["TradeRecipientItem" .. i .. "ItemButtonIconTexture"]
		local playerNameFrame = _G["TradePlayerItem"..i.."NameFrame"]
		local recipientNameFrame = _G["TradeRecipientItem"..i.."NameFrame"]

		player:StripTextures()
		recipient:StripTextures()

		playerButton:StripTextures()
		playerButton:StyleButton()
		playerButton:SetTemplate("Default", true)

		playerButtonIcon:SetInside()
		playerButtonIcon:SetTexCoord(unpack(E.TexCoords))

		recipientButton:StripTextures()
		recipientButton:StyleButton()
		recipientButton:SetTemplate("Default", true)

		recipientButtonIcon:SetInside()
		recipientButtonIcon:SetTexCoord(unpack(E.TexCoords))

		playerButton.bg = CreateFrame("Frame", nil, playerButton)
		playerButton.bg:SetTemplate("Default")
		playerButton.bg:Point("TOPLEFT", playerButton, "TOPRIGHT", 4, 0)
		playerButton.bg:Point("BOTTOMRIGHT", playerNameFrame, "BOTTOMRIGHT", -5, 14)
		playerButton.bg:SetFrameLevel(playerButton:GetFrameLevel() - 4)

		recipientButton.bg = CreateFrame("Frame", nil, recipientButton)
		recipientButton.bg:SetTemplate("Default")
		recipientButton.bg:Point("TOPLEFT", recipientButton, "TOPRIGHT", 4, 0)
		recipientButton.bg:Point("BOTTOMRIGHT", recipientNameFrame, "BOTTOMRIGHT", -5, 14)
		recipientButton.bg:SetFrameLevel(recipientButton:GetFrameLevel() - 4)
	end

	TradePlayerItem1:Point("TOPLEFT", 24, -104)

	TradeHighlightPlayerTop:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerBottom:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerMiddle:SetTexture(0, 1, 0, 0.2)

	TradeHighlightPlayerEnchantTop:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerEnchantBottom:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerEnchantMiddle:SetTexture(0, 1, 0, 0.2)

	TradeHighlightRecipientTop:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientBottom:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientMiddle:SetTexture(0, 1, 0, 0.2)

	TradeHighlightRecipientEnchantTop:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientEnchantBottom:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientEnchantMiddle:SetTexture(0, 1, 0, 0.2)

	S:HandleButton(TradeFrameTradeButton)
	TradeFrameTradeButton:Point("BOTTOMRIGHT", -120, 55)

	S:HandleButton(TradeFrameCancelButton)

	hooksecurefunc("TradeFrame_UpdatePlayerItem", function(id)
		local link = GetTradePlayerItemLink(id)
		local tradeItemButton = _G["TradePlayerItem" .. id .. "ItemButton"]
		local tradeItemName = _G["TradePlayerItem" .. id .. "Name"]
		if(link) then
			local quality = select(3, GetItemInfo(link))
			if quality then
				tradeItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
				tradeItemName:SetTextColor(GetItemQualityColor(quality))
			end
		else
			tradeItemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor))
		end
	end)

	hooksecurefunc("TradeFrame_UpdateTargetItem", function(id)
		local link = GetTradeTargetItemLink(id)
		local tradeItemButton = _G["TradeRecipientItem" .. id .. "ItemButton"]
		local tradeItemName = _G["TradeRecipientItem" .. id .. "Name"]
		if(link) then
			local quality = select(3, GetItemInfo(link))
			if quality  then
				tradeItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
				tradeItemName:SetTextColor(GetItemQualityColor(quality))
			end
		else
			tradeItemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor))
		end
	end)
end

S:AddCallback("Trade", S.LoadTradeSkin)