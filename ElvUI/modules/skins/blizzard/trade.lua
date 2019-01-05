local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetTradePlayerItemLink = GetTradePlayerItemLink
local GetTradeTargetItemLink = GetTradeTargetItemLink

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.trade ~= true then return end

	local TradeFrame = _G["TradeFrame"]
	TradeFrame:StripTextures(true)
	TradeFrame:Width(400)
	TradeFrame:CreateBackdrop("Transparent")
	TradeFrame.backdrop:Point("TOPLEFT", 10, -11)
	TradeFrame.backdrop:Point("BOTTOMRIGHT", -28, 48)

	S:HandleCloseButton(TradeFrameCloseButton, TradeFrame.backdrop)

	S:HandleEditBox(TradePlayerInputMoneyFrameGold)
	S:HandleEditBox(TradePlayerInputMoneyFrameSilver)
	S:HandleEditBox(TradePlayerInputMoneyFrameCopper)

	S:HandleButton(TradeFrameTradeButton)
	TradeFrameTradeButton:Point("BOTTOMRIGHT", -120, 55)

	S:HandleButton(TradeFrameCancelButton)

	TradePlayerItem1:Point("TOPLEFT", 24, -104)

	for _, frame in pairs({"TradePlayerItem", "TradeRecipientItem"}) do
		for i = 1, MAX_TRADE_ITEMS do
			local item = _G[frame..i]
			local button = _G[frame..i.."ItemButton"]
			local icon = _G[frame..i.."ItemButtonIconTexture"]
			local name = _G[frame..i.."NameFrame"]

			item:StripTextures()

			button:StripTextures()
			button:SetTemplate("Default", true)
			button:StyleButton()

			button.bg = CreateFrame("Frame", nil, button)
			button.bg:SetTemplate("Default")
			button.bg:Point("TOPLEFT", button, "TOPRIGHT", 4, 0)
			button.bg:Point("BOTTOMRIGHT", name, "BOTTOMRIGHT", -5, 14)
			button.bg:SetFrameLevel(button:GetFrameLevel() - 4)

			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetInside()
		end
	end

	hooksecurefunc("TradeFrame_UpdatePlayerItem", function(id)
		local link = GetTradePlayerItemLink(id)
		local item = _G["TradePlayerItem"..id.."ItemButton"]
		local name = _G["TradePlayerItem"..id.."Name"]

		if link then
			local quality = select(3, GetItemInfo(link))
			if quality then
				item:SetBackdropBorderColor(GetItemQualityColor(quality))
				name:SetTextColor(GetItemQualityColor(quality))
			else
				item:SetBackdropBorderColor(unpack(E.media.bordercolor))
				name:SetTextColor(1, 1, 1)
			end
		else
			item:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	hooksecurefunc("TradeFrame_UpdateTargetItem", function(id)
		local link = GetTradeTargetItemLink(id)
		local item = _G["TradeRecipientItem"..id.."ItemButton"]
		local name = _G["TradeRecipientItem"..id.."Name"]

		if link then
			local quality = select(3, GetItemInfo(link))
			if quality  then
				item:SetBackdropBorderColor(GetItemQualityColor(quality))
				name:SetTextColor(GetItemQualityColor(quality))
			else
				item:SetBackdropBorderColor(unpack(E.media.bordercolor))
				name:SetTextColor(1, 1, 1)
			end
		else
			item:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	local highlights = {
		"TradeHighlightPlayerTop",
		"TradeHighlightPlayerBottom",
		"TradeHighlightPlayerMiddle",
		"TradeHighlightPlayerEnchantTop",
		"TradeHighlightPlayerEnchantBottom",
		"TradeHighlightPlayerEnchantMiddle",
		"TradeHighlightRecipientTop",
		"TradeHighlightRecipientBottom",
		"TradeHighlightRecipientMiddle",
		"TradeHighlightRecipientEnchantTop",
		"TradeHighlightRecipientEnchantBottom",
		"TradeHighlightRecipientEnchantMiddle",
	}
	for i = 1, #highlights do
		_G[highlights[i]]:SetTexture(0, 1, 0, 0.2)
	end
end

S:AddCallback("Trade", LoadSkin)