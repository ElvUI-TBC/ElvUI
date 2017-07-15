local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local find = string.find

local GetInventoryItemQuality = GetInventoryItemQuality
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventorySlotInfo = GetInventorySlotInfo
local GetItemQualityColor = GetItemQualityColor
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset

function S:LoadCharacterSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.character ~= true then return end

	CharacterFrame:StripTextures(true)
	CharacterFrame:CreateBackdrop("Transparent")
	CharacterFrame.backdrop:Point("TOPLEFT", 12, -12)
	CharacterFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:HandleCloseButton(CharacterFrameCloseButton)
	CharacterFrameCloseButton:ClearAllPoints()
	CharacterFrameCloseButton:Point("CENTER", CharacterFrame, "TOPRIGHT", -45, -25)

	for i = 1, 5 do
		local tab = _G["CharacterFrameTab"..i]
		S:HandleTab(tab)
	end

	-- PaperDollFrame
	PaperDollFrame:StripTextures()

	CharacterModelFrame:Point("TOPLEFT", 65, -60)

	PlayerTitleDropDown:Point("TOP", CharacterLevelText, "BOTTOM", 0, -2)
	S:HandleDropDownBox(PlayerTitleDropDown, 210)

	S:HandleRotateButton(CharacterModelFrameRotateLeftButton)
	CharacterModelFrameRotateLeftButton:ClearAllPoints()
	CharacterModelFrameRotateLeftButton:Point("TOPLEFT", 3, -3)
	S:HandleRotateButton(CharacterModelFrameRotateRightButton)
	CharacterModelFrameRotateRightButton:ClearAllPoints()
	CharacterModelFrameRotateRightButton:Point("TOPLEFT", CharacterModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)

	CharacterAttributesFrame:StripTextures()
	S:HandleDropDownBox(PlayerStatFrameLeftDropDown)
	S:HandleDropDownBox(PlayerStatFrameRightDropDown)

	local function FixWidth(self)
		UIDropDownMenu_SetWidth(90, self)
	end

	PlayerStatFrameLeftDropDown:HookScript("OnShow", FixWidth)
	PlayerStatFrameRightDropDown:HookScript("OnShow", FixWidth)

	CharacterResistanceFrame:CreateBackdrop("Default")
	CharacterResistanceFrame.backdrop:SetOutside(MagicResFrame1, nil, nil, MagicResFrame5)

	for i = 1, 5 do
		local frame = _G["MagicResFrame"..i]
		frame:Size(24)
	end

	select(1, MagicResFrame1:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.25, 0.3203125)
	select(1, MagicResFrame2:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.0234375, 0.09375)
	select(1, MagicResFrame3:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.13671875, 0.20703125)
	select(1, MagicResFrame4:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.36328125, 0.43359375)
	select(1, MagicResFrame5:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.4765625, 0.546875)

	local slots = {"HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "ShirtSlot", "TabardSlot", "WristSlot",
		"HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot",
		"MainHandSlot", "SecondaryHandSlot", "RangedSlot", "AmmoSlot"
	}

	for _, slot in pairs(slots) do
		local icon = _G["Character"..slot.."IconTexture"]
		local cooldown = _G["Character"..slot.."Cooldown"]

		slot = _G["Character"..slot]
		slot:StripTextures()
		slot:StyleButton(false)
		slot:SetTemplate("Default", true, true)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		if(cooldown) then
			E:RegisterCooldown(cooldown)
		end
	end

	local function ColorItemBorder(_, event, unit)
		if event == "UNIT_INVENTORY_CHANGED" and unit ~= "player" then return end

		for _, slot in pairs(slots) do
			local target = _G["Character"..slot]
			local slotId, _, _ = GetInventorySlotInfo(slot)
			local itemId = GetInventoryItemTexture("player", slotId)
			if itemId then
				local rarity = GetInventoryItemQuality("player", slotId)
				if rarity and rarity > 1 then
					target:SetBackdropBorderColor(GetItemQualityColor(rarity))
				else
					target:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			else
				target:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end

	local checkItemBorderColor = CreateFrame("Frame")
	checkItemBorderColor:RegisterEvent("UNIT_INVENTORY_CHANGED")
	checkItemBorderColor:SetScript("OnEvent", ColorItemBorder)
	CharacterFrame:HookScript("OnShow", ColorItemBorder)
	ColorItemBorder()

	-- PetPaperDollFrame
	PetPaperDollFrame:StripTextures()

	S:HandleButton(PetPaperDollCloseButton)

	S:HandleRotateButton(PetModelFrameRotateLeftButton)
	PetModelFrameRotateLeftButton:ClearAllPoints()
	PetModelFrameRotateLeftButton:Point("TOPLEFT", 3, -3)
	S:HandleRotateButton(PetModelFrameRotateRightButton)
	PetModelFrameRotateRightButton:ClearAllPoints()
	PetModelFrameRotateRightButton:Point("TOPLEFT", PetModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)

	PetAttributesFrame:StripTextures()

	PetResistanceFrame:CreateBackdrop("Default")
	PetResistanceFrame.backdrop:SetOutside(PetMagicResFrame1, nil, nil, PetMagicResFrame5)

	for i = 1, 5 do
		local frame = _G["PetMagicResFrame"..i]
		frame:Size(24)
	end

	select(1, PetMagicResFrame1:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.25, 0.3203125)
	select(1, PetMagicResFrame2:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.0234375, 0.09375)
	select(1, PetMagicResFrame3:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.13671875, 0.20703125)
	select(1, PetMagicResFrame4:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.36328125, 0.43359375)
	select(1, PetMagicResFrame5:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.4765625, 0.546875)

	PetPaperDollFrameExpBar:StripTextures()
	PetPaperDollFrameExpBar:SetStatusBarTexture(E["media"].normTex)
	E:RegisterStatusBar(PetPaperDollFrameExpBar);
	PetPaperDollFrameExpBar:CreateBackdrop("Default")

	local function updHappiness(self)
		local happiness = GetPetHappiness();
		local _, isHunterPet = HasPetUI();
		if(not happiness or not isHunterPet) then
			return;
		end
		local texture = self:GetRegions();
		if(happiness == 1) then
			texture:SetTexCoord(0.41, 0.53, 0.06, 0.30);
		elseif(happiness == 2) then
			texture:SetTexCoord(0.22, 0.345, 0.06, 0.30);
		elseif(happiness == 3) then
			texture:SetTexCoord(0.04, 0.15, 0.06, 0.30);
		end
	end

	PetPaperDollPetInfo:Point("TOPLEFT", PetModelFrameRotateLeftButton, "BOTTOMLEFT", 9, -3);
	PetPaperDollPetInfo:GetRegions():SetTexCoord(0.04, 0.15, 0.06, 0.30);
	PetPaperDollPetInfo:SetFrameLevel(PetModelFrame:GetFrameLevel() + 2);
	PetPaperDollPetInfo:CreateBackdrop("Default");
	PetPaperDollPetInfo:Size(24, 24);
	updHappiness(PetPaperDollPetInfo);

	PetPaperDollPetInfo:RegisterEvent("UNIT_HAPPINESS");
	PetPaperDollPetInfo:SetScript("OnEvent", updHappiness);
	PetPaperDollPetInfo:SetScript("OnShow", updHappiness);

	-- SkillFrame
	SkillFrame:StripTextures()

	SkillFrameExpandButtonFrame:DisableDrawLayer("BACKGROUND")

	SkillFrameCollapseAllButton:Point("LEFT", SkillFrameExpandTabLeft, "RIGHT", -40, -3)
	SkillFrameCollapseAllButton:SetNormalTexture("")
	SkillFrameCollapseAllButton.SetNormalTexture = E.noop
	SkillFrameCollapseAllButton:SetHighlightTexture(nil)

	SkillFrameCollapseAllButton.Text = SkillFrameCollapseAllButton:CreateFontString(nil, "OVERLAY")
	SkillFrameCollapseAllButton.Text:FontTemplate(nil, 22)
	SkillFrameCollapseAllButton.Text:Point("CENTER", -10, 0)
	SkillFrameCollapseAllButton.Text:SetText("+")

	hooksecurefunc(SkillFrameCollapseAllButton, "SetNormalTexture", function(self, texture)
		if find(texture, "MinusButton") then
			self.Text:SetText("-")
		else
			self.Text:SetText("+")
		end
	end)

	S:HandleButton(SkillFrameCancelButton)

	for i = 1, SKILLS_TO_DISPLAY do
		local bar = _G["SkillRankFrame"..i]
		bar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(bar)
		bar:CreateBackdrop("Default")

		_G["SkillRankFrame"..i.."Border"]:StripTextures()
		_G["SkillRankFrame"..i.."Background"]:SetTexture(nil)

		local label = _G["SkillTypeLabel"..i]
		label:SetNormalTexture("")
		label.SetNormalTexture = E.noop
		label:SetHighlightTexture(nil)

		label.Text = label:CreateFontString(nil, "OVERLAY")
		label.Text:FontTemplate(nil, 22)
		label.Text:Point("LEFT", 3, 0)
		label.Text:SetText("+")

		hooksecurefunc(label, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self.Text:SetText("-")
			else
				self.Text:SetText("+")
			end
		end)
	end

	SkillListScrollFrame:StripTextures()
	S:HandleScrollBar(SkillListScrollFrameScrollBar)

	SkillDetailScrollFrame:StripTextures()
	S:HandleScrollBar(SkillDetailScrollFrameScrollBar)

	SkillDetailStatusBar:StripTextures()
	SkillDetailStatusBar:SetParent(SkillDetailScrollFrame)
	SkillDetailStatusBar:CreateBackdrop("Default")
	SkillDetailStatusBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(SkillDetailStatusBar)

	SkillDetailStatusBarUnlearnButton:StripTextures()
	SkillDetailStatusBarUnlearnButton:Point("LEFT", SkillDetailStatusBarBorder, "RIGHT", -2, -5)
	SkillDetailStatusBarUnlearnButton:Size(36)
	
	SkillDetailStatusBarUnlearnButton.Text = SkillDetailStatusBarUnlearnButton:CreateFontString(nil, "OVERLAY")
	SkillDetailStatusBarUnlearnButton.Text:FontTemplate()
	SkillDetailStatusBarUnlearnButton.Text:Point("LEFT", 7, 5)
	SkillDetailStatusBarUnlearnButton.Text:SetText("|TInterface\\Buttons\\UI-GroupLoot-Pass-Up:34:34|t")

	-- Reputation Frame
	ReputationFrame:StripTextures()

	for i = 1, NUM_FACTIONS_DISPLAYED do
		local bar = _G["ReputationBar"..i]
		local header = _G["ReputationHeader"..i]
		local factionName = _G["ReputationBar"..i.."FactionName"]
		local warCheck = _G["ReputationBar"..i.."AtWarCheck"]

		bar:StripTextures()
		bar:CreateBackdrop("Default")
		bar:SetStatusBarTexture(E.media.normTex)
		bar:Size(108, 13)
		E:RegisterStatusBar(bar)

		factionName:Point("LEFT", bar, "LEFT", -150, 0)
		factionName:Width(140)
		factionName.SetWidth = E.noop

		warCheck:StripTextures()
		warCheck:Point("LEFT", bar, "RIGHT", 0, 0)

		warCheck.Text = warCheck:CreateFontString(nil, "OVERLAY")
		warCheck.Text:FontTemplate()
		warCheck.Text:Point("LEFT", 3, -6)
		warCheck.Text:SetText("|TInterface\\Buttons\\UI-CheckBox-SwordCheck:45:45|t")

		header:StripTextures(true)
		header:SetNormalTexture(nil)
		header.SetNormalTexture = E.noop
		header:Point("TOPLEFT", bar, "TOPLEFT", -175, 0)

		header.Text = header:CreateFontString(nil, "OVERLAY")
		header.Text:FontTemplate(nil, 22)
		header.Text:Point("LEFT", 3, 0)
		header.Text:SetText("+")
	end

	ReputationBar1:Point("TOPLEFT", 190, -86)

	local function UpdateFaction()
		local offset = FauxScrollFrame_GetOffset(ReputationListScrollFrame)
		local index, header
		local numFactions = GetNumFactions()
		for i = 1, NUM_FACTIONS_DISPLAYED, 1 do
			header = _G["ReputationHeader"..i]
			index = offset + i
			if index <= numFactions then
				if header.isCollapsed then
					header.Text:SetText("+")
				else
					header.Text:SetText("-")
				end
			end
		end
	end
	hooksecurefunc("ReputationFrame_Update", UpdateFaction)

	ReputationFrameStandingLabel:Point("TOPLEFT", 223, -59)
	ReputationFrameFactionLabel:Point("TOPLEFT", 55, -59)

	ReputationListScrollFrame:StripTextures()
	S:HandleScrollBar(ReputationListScrollFrameScrollBar)

	ReputationDetailFrame:StripTextures()
	ReputationDetailFrame:SetTemplate("Transparent")
	ReputationDetailFrame:Point("TOPLEFT", ReputationFrame, "TOPRIGHT", -31, -12)

	S:HandleCloseButton(ReputationDetailCloseButton)
	ReputationDetailCloseButton:Point("TOPRIGHT", 2, 2)

	S:HandleCheckBox(ReputationDetailAtWarCheckBox)
	S:HandleCheckBox(ReputationDetailInactiveCheckBox)
	S:HandleCheckBox(ReputationDetailMainScreenCheckBox)
end

S:AddCallback("Character", S.LoadCharacterSkin)