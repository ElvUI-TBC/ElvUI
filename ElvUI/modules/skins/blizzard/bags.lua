local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local select, unpack = select, unpack

local CreateFrame = CreateFrame
local ContainerIDToInventoryID = ContainerIDToInventoryID
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetInventoryItemLink = GetInventoryItemLink
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local hooksecurefunc = hooksecurefunc
local BANK_CONTAINER = BANK_CONTAINER
local MAX_CONTAINER_ITEMS = MAX_CONTAINER_ITEMS
local NUM_BANKBAGSLOTS = NUM_BANKBAGSLOTS
local NUM_BANKGENERIC_SLOTS = NUM_BANKGENERIC_SLOTS
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES

local ProfessionColors = {
	[0x0001] = {225/255, 142/255, 186/255},	-- Quiver
	[0x0002] = {225/255, 142/255, 186/255},	-- Ammo Pouch
	[0x0004] = {120/255, 66/255, 255/255},	-- Soul Bag
	[0x0008] = {224/255, 187/255, 74/255},	-- Leatherworking
	[0x0020] = {18/255, 181/255, 32/255},	-- Herbs
	[0x0040] = {160/255, 3/255, 168/255},	-- Enchanting
	[0x0080] = {232/255, 118/255, 46/255},	-- Engineering
	[0x0200] = {8/255, 180/255, 207/255},	-- Gems
	[0x0400] = {105/255, 79/255, 7/255},	-- Mining
}

local function LoadSkin()
	if not E.private.skins.blizzard.enable and E.private.skins.blizzard.bags and not E.private.bags.enable then return end

	-- ContainerFrame
	for i = 1, NUM_CONTAINER_FRAMES, 1 do
		local frame = _G["ContainerFrame"..i]
		local closeButton = _G["ContainerFrame"..i.."CloseButton"]

		frame:StripTextures(true)
		frame:CreateBackdrop("Transparent")
		frame.backdrop:Point("TOPLEFT", 9, -4)
		frame.backdrop:Point("BOTTOMRIGHT", -4, 2)

		S:HandleCloseButton(closeButton)

		for k = 1, MAX_CONTAINER_ITEMS, 1 do
			local item = _G["ContainerFrame"..i.."Item"..k]
			local icon = _G["ContainerFrame"..i.."Item"..k.."IconTexture"]
			local cooldown = _G["ContainerFrame"..i.."Item"..k.."Cooldown"]

			item:SetNormalTexture(nil)
			item:SetTemplate("Default", true)
			item:StyleButton()

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))

			local QuestIcon = item:CreateTexture(nil, "OVERLAY")
			QuestIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\bagQuestIcon")
			QuestIcon:SetTexCoord(0, 1, 0, 1)
			QuestIcon:SetInside()
			QuestIcon:Hide()
			item.QuestIcon = QuestIcon

			cooldown.CooldownOverride = "bags"
			E:RegisterCooldown(cooldown)
		end
	end

	hooksecurefunc("ContainerFrame_Update", function(self)
		local id = self:GetID()
		local name = self:GetName()
		local item, link
		local _, iLink, quality, iType
		local _, bagType = GetContainerNumFreeSlots(id)

		for i = 1, self.size, 1 do
			item = _G[name.."Item"..i]
			link = GetContainerItemLink(id, item:GetID())

			item.QuestIcon:Hide()

			if ProfessionColors[bagType] then
				item:SetBackdropBorderColor(unpack(ProfessionColors[bagType]))
				item.ignoreBorderColors = true
			elseif link then
				_, iLink, quality, _, _, iType = GetItemInfo(link)

				if (iType and iType == "Quest") and not GetInvalidQuestItemInfo(iLink) then
					if GetQuestItemSarterInfo(iLink) then
						item.QuestIcon:Show()
						item:SetBackdropBorderColor(1, 1, 0)
					else
						item:SetBackdropBorderColor(1.0, 0.3, 0.3)
					end
					item.ignoreBorderColors = true
				elseif quality then
					item:SetBackdropBorderColor(GetItemQualityColor(quality))
					item.ignoreBorderColors = true
				else
					item:SetBackdropBorderColor(unpack(E["media"].bordercolor))
					item.ignoreBorderColors = true
				end
			else
				item:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				item.ignoreBorderColors = true
			end
		end
	end)

	-- BankFrame
	local BankFrame = _G["BankFrame"]
	BankFrame:StripTextures(true)
	BankFrame:CreateBackdrop("Transparent")
	BankFrame.backdrop:Point("TOPLEFT", 10, -11)
	BankFrame.backdrop:Point("BOTTOMRIGHT", -26, 93)

	S:HandleCloseButton(BankCloseButton)

	for i = 1, NUM_BANKGENERIC_SLOTS, 1 do
		local button = _G["BankFrameItem"..i]
		local icon = _G["BankFrameItem"..i.."IconTexture"]

		button:SetNormalTexture(nil)
		button:SetTemplate("Default", true)
		button:StyleButton()

		icon:SetInside()
		icon:SetTexCoord(unpack(E.TexCoords))

		local QuestIcon = button:CreateTexture(nil, "OVERLAY")
		QuestIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\bagQuestIcon")
		QuestIcon:SetTexCoord(0, 1, 0, 1)
		QuestIcon:SetInside()
		QuestIcon:Hide()
		button.QuestIcon = QuestIcon
	end

	BankFrame.itemBackdrop = CreateFrame("Frame", "BankFrameItemBackdrop", BankFrame)
	BankFrame.itemBackdrop:SetTemplate("Default")
	BankFrame.itemBackdrop:Point("TOPLEFT", BankFrameItem1, "TOPLEFT", -6, 6)
	BankFrame.itemBackdrop:Point("BOTTOMRIGHT", BankFrameItem28, "BOTTOMRIGHT", 6, -6)
	BankFrame.itemBackdrop:SetFrameLevel(BankFrame:GetFrameLevel())

	for i = 1, NUM_BANKBAGSLOTS, 1 do
		local button = _G["BankFrameBag"..i]
		local icon = _G["BankFrameBag"..i.."IconTexture"]

		button:SetNormalTexture(nil)
		button:SetTemplate("Default", true)
		button:StyleButton()

		icon:SetInside()
		icon:SetTexCoord(unpack(E.TexCoords))

		_G["BankFrameBag"..i.."HighlightFrameTexture"]:SetInside()
		_G["BankFrameBag"..i.."HighlightFrameTexture"]:SetTexture(unpack(E["media"].rgbvaluecolor), 0.3)
	end

	BankFrame.bagBackdrop = CreateFrame("Frame", "BankFrameBagBackdrop", BankFrame)
	BankFrame.bagBackdrop:SetTemplate("Default")
	BankFrame.bagBackdrop:Point("TOPLEFT", BankFrameBag1, "TOPLEFT", -6, 6)
	BankFrame.bagBackdrop:Point("BOTTOMRIGHT", BankFrameBag7, "BOTTOMRIGHT", 6, -6)
	BankFrame.bagBackdrop:SetFrameLevel(BankFrame:GetFrameLevel())

	S:HandleButton(BankFramePurchaseButton)

	hooksecurefunc("BankFrameItemButton_Update", function(button)
		local id = button:GetID()
		local link
		local _, iLink, quality, iType

		if button.isBag then
			link = GetInventoryItemLink("player", ContainerIDToInventoryID(id))
		else
			link = GetContainerItemLink(BANK_CONTAINER, id)
			button.QuestIcon:Hide()
		end

		if link then
			_, iLink, quality, _, _, iType = GetItemInfo(link)

			if (iType and iType == "Quest") and not GetInvalidQuestItemInfo(iLink) then
				if GetQuestItemSarterInfo(iLink) then
					button.QuestIcon:Show()
					button:SetBackdropBorderColor(1, 1, 0)
				else
					button:SetBackdropBorderColor(1.0, 0.3, 0.3)
				end
				button.ignoreBorderColors = true
			elseif quality then
				button:SetBackdropBorderColor(GetItemQualityColor(quality))
				button.ignoreBorderColors = true
			else
				button:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				button.ignoreBorderColors = true
			end
		else
			button:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			button.ignoreBorderColors = true
		end
	end)
end

S:AddCallback("SkinBags", LoadSkin)