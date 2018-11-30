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

local function LoadSkin()
	if not E.private.skins.blizzard.enable and E.private.skins.blizzard.bags and not E.private.bags.enable then return end

	local ProfessionColors = {
		[0x0001] = {E.db.bags.colors.profession.quiver.r, E.db.bags.colors.profession.quiver.g, E.db.bags.colors.profession.quiver.b},
		[0x0002] = {E.db.bags.colors.profession.ammoPouch.r, E.db.bags.colors.profession.ammoPouch.g, E.db.bags.colors.profession.ammoPouch.b},
		[0x0004] = {E.db.bags.colors.profession.soulBag.r, E.db.bags.colors.profession.soulBag.g, E.db.bags.colors.profession.soulBag.b},
		[0x0008] = {E.db.bags.colors.profession.leatherworking.r, E.db.bags.colors.profession.leatherworking.g, E.db.bags.colors.profession.leatherworking.b},
		[0x0020] = {E.db.bags.colors.profession.herbs.r, E.db.bags.colors.profession.herbs.g, E.db.bags.colors.profession.herbs.b},
		[0x0040] = {E.db.bags.colors.profession.enchanting.r, E.db.bags.colors.profession.enchanting.g, E.db.bags.colors.profession.enchanting.b},
		[0x0080] = {E.db.bags.colors.profession.engineering.r, E.db.bags.colors.profession.engineering.g, E.db.bags.colors.profession.engineering.b},
		[0x0200] = {E.db.bags.colors.profession.gems.r, E.db.bags.colors.profession.gems.g, E.db.bags.colors.profession.gems.b},
		[0x0400] = {E.db.bags.colors.profession.mining.r, E.db.bags.colors.profession.mining.g, E.db.bags.colors.profession.mining.b}
	}

	local QuestColors = {
		["questStarter"] = {E.db.bags.colors.items.questStarter.r, E.db.bags.colors.items.questStarter.g, E.db.bags.colors.items.questStarter.b},
		["questItem"] =	{E.db.bags.colors.items.questItem.r, E.db.bags.colors.items.questItem.g, E.db.bags.colors.items.questItem.b}
	}

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
					if GetQuestItemStarterInfo(iLink) then
						item.QuestIcon:Show()
						item:SetBackdropBorderColor(unpack(QuestColors.questStarter))
					else
						item:SetBackdropBorderColor(unpack(QuestColors.questItem))
					end
					item.ignoreBorderColors = true
				elseif quality then
					item:SetBackdropBorderColor(GetItemQualityColor(quality))
					item.ignoreBorderColors = true
				else
					item:SetBackdropBorderColor(unpack(E.media.bordercolor))
					item.ignoreBorderColors = true
				end
			else
				item:SetBackdropBorderColor(unpack(E.media.bordercolor))
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
		_G["BankFrameBag"..i.."HighlightFrameTexture"]:SetTexture(unpack(E.media.rgbvaluecolor), 0.3)
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
				if GetQuestItemStarterInfo(iLink) then
					button.QuestIcon:Show()
					button:SetBackdropBorderColor(unpack(QuestColors.questStarter))
				else
					button:SetBackdropBorderColor(unpack(QuestColors.questItem))
				end
				button.ignoreBorderColors = true
			elseif quality then
				button:SetBackdropBorderColor(GetItemQualityColor(quality))
				button.ignoreBorderColors = true
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				button.ignoreBorderColors = true
			end
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			button.ignoreBorderColors = true
		end
	end)
end

S:AddCallback("SkinBags", LoadSkin)