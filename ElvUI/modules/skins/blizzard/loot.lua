local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select

local GetLootRollItemInfo = GetLootRollItemInfo
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local IsFishingLoot = IsFishingLoot
local UnitIsDead = UnitIsDead
local UnitIsFriend = UnitIsFriend
local UnitName = UnitName
local LOOTFRAME_NUMBUTTONS = LOOTFRAME_NUMBUTTONS
local NUM_GROUP_LOOT_FRAMES = NUM_GROUP_LOOT_FRAMES
local LOOT, ITEMS = LOOT, ITEMS

local function LoadSkin()
	if E.private.general.loot then return end
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.loot ~= true then return end

	local LootFrame = _G["LootFrame"]
	LootFrame:StripTextures()

	LootFrame:CreateBackdrop("Transparent")
	LootFrame.backdrop:Point("TOPLEFT", 14, -14)
	LootFrame.backdrop:Point("BOTTOMRIGHT", -78, 5)

	LootFramePortraitOverlay:SetParent(E.HiddenFrame)

	S:HandleNextPrevButton(LootFrameUpButton)
	S:SquareButton_SetIcon(LootFrameUpButton, "UP")
	LootFrameUpButton:Point("BOTTOMLEFT", 25, 20)

	S:HandleNextPrevButton(LootFrameDownButton)
	S:SquareButton_SetIcon(LootFrameDownButton, "DOWN")
	LootFrameDownButton:Point("BOTTOMLEFT", 145, 20)

	LootFrame:EnableMouseWheel(true)
	LootFrame:SetScript("OnMouseWheel", function(_, value)
		if value > 0 then
			if LootFrameUpButton:IsShown() and LootFrameUpButton:IsEnabled() == 1 then
				LootFrame_PageUp()
			end
		else
			if LootFrameDownButton:IsShown() and LootFrameDownButton:IsEnabled() == 1 then
				LootFrame_PageDown()
			end
		end
	end)

	S:HandleCloseButton(LootCloseButton)
	LootCloseButton:Point("CENTER", LootFrame, "TOPRIGHT", -90, -26)

	for i = 1, LootFrame:GetNumRegions() do
		local region = select(i, LootFrame:GetRegions())
		if region:IsObjectType("FontString") then
			if region:GetText() == ITEMS then
				LootFrame.Title = region
			end
		end
	end

	LootFrame.Title:ClearAllPoints()
	LootFrame.Title:Point("TOPLEFT", LootFrame.backdrop, "TOPLEFT", 4, -4)
	LootFrame.Title:SetJustifyH("LEFT")

	LootFrame:HookScript("OnShow", function(self)
		if IsFishingLoot() then
			self.Title:SetText(L["Fishy Loot"])
		elseif not UnitIsFriend("player", "target") and UnitIsDead("target") then
			self.Title:SetText(UnitName("target"))
		else
			self.Title:SetText(LOOT)
		end
	end)

	for i = 1, LOOTFRAME_NUMBUTTONS do
		local button = _G["LootButton"..i]
		local nameFrame = _G["LootButton"..i.."NameFrame"]

		S:HandleItemButton(button, true)

		button.bg = CreateFrame("Frame", nil, button)
		button.bg:SetTemplate("Default")
		button.bg:Point("TOPLEFT", 40, 0)
		button.bg:Point("BOTTOMRIGHT", 110, 0)
		button.bg:SetFrameLevel(button.bg:GetFrameLevel() - 1)

		nameFrame:Hide()

		local QuestIcon = button:CreateTexture(nil, "OVERLAY")
		QuestIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\bagQuestIcon")
		QuestIcon:SetTexCoord(0, 1, 0, 1)
		QuestIcon:SetInside()
		QuestIcon:Hide()
		button.QuestIcon = QuestIcon
	end

	hooksecurefunc("LootFrame_Update", function()
		local numLootItems = LootFrame.numLootItems
		local numLootToShow = LOOTFRAME_NUMBUTTONS
		if numLootItems > LOOTFRAME_NUMBUTTONS then
			numLootToShow = numLootToShow - 1
		end
		local button, slot
		local itemLink
		local _, quality
		local isQuestItem, isQuestStarter, isQuestActive, invalidQuestItem

		for index = 1, LOOTFRAME_NUMBUTTONS do
			button = _G["LootButton"..index]
			slot = (numLootToShow * (LootFrame.page - 1)) + index

			if slot <= numLootItems then
				button.QuestIcon:Hide()
				if LootSlotIsItem(slot) and index <= numLootToShow then
					itemLink = GetLootSlotLink(slot)

					if itemLink then
						quality = select(3, GetItemInfo(itemLink))
						isQuestItem, isQuestStarter, isQuestActive, invalidQuestItem = GetQuestItemStarterInfo(itemLink)

						if isQuestStarter and isQuestActive then
							button.QuestIcon:Show()
							button.backdrop:SetBackdropBorderColor(E.db.bags.colors.items.questStarter.r, E.db.bags.colors.items.questStarter.g, E.db.bags.colors.items.questStarter.b)
						elseif (isQuestItem and not invalidQuestItem) or (isQuestStarter and not isQuestActive) then
							button.backdrop:SetBackdropBorderColor(E.db.bags.colors.items.questItem.r, E.db.bags.colors.items.questItem.g, E.db.bags.colors.items.questItem.b)
						elseif quality then
							button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
						else
							button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
						end
					else
						button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
					end
				else
					button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			end
		end
	end)
end

local function LoadSkin2()
	if E.private.general.lootRoll then return end
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lootRoll then return end

	local function OnShow(self)
		self:SetTemplate("Transparent")

		local cornerTexture = _G[self:GetName().."Corner"]
		cornerTexture:SetTexture()

		local iconFrame = _G[self:GetName().."IconFrame"]
		local _, _, _, quality = GetLootRollItemInfo(self.rollID)
		iconFrame:SetBackdropBorderColor(GetItemQualityColor(quality))
	end

	for i = 1, NUM_GROUP_LOOT_FRAMES do
		local frame = _G["GroupLootFrame"..i]
		local frameName = frame:GetName()
		local iconFrame = _G[frameName.."IconFrame"]
		local icon = _G[frameName.."IconFrameIcon"]
		local statusBar = _G[frameName.."Timer"]
		local decoration = _G[frameName.."Decoration"]
		local pass = _G[frameName.."PassButton"]

		frame:SetParent(UIParent)
		frame:StripTextures()

		iconFrame:SetTemplate("Default")

		icon:SetInside()
		icon:SetTexCoord(unpack(E.TexCoords))

		statusBar:StripTextures()
		statusBar:CreateBackdrop("Default")
		statusBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(statusBar)

		decoration:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon")
		decoration:Size(130)
		decoration:Point("TOPLEFT", -37, 20)

		S:HandleCloseButton(pass, frame)

		_G["GroupLootFrame"..i]:HookScript("OnShow", OnShow)
	end
end

S:AddCallback("Loot", LoadSkin)
S:AddCallback("LootRoll", LoadSkin2)