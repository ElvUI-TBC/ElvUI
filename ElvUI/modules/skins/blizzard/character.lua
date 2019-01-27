local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local select, unpack, pairs = select, unpack, pairs
local find = string.find

local GetInventoryItemQuality = GetInventoryItemQuality
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventorySlotInfo = GetInventorySlotInfo
local GetItemQualityColor = GetItemQualityColor
local GetPetHappiness = GetPetHappiness
local HasPetUI = HasPetUI
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset
local MAX_ARENA_TEAMS = MAX_ARENA_TEAMS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.character ~= true then return end

	CharacterFrame:StripTextures(true)
	CharacterFrame:CreateBackdrop("Transparent")
	CharacterFrame.backdrop:Point("TOPLEFT", 10, -12)
	CharacterFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:HandleCloseButton(CharacterFrameCloseButton)
	CharacterFrameCloseButton:ClearAllPoints()
	CharacterFrameCloseButton:Point("CENTER", CharacterFrame, "TOPRIGHT", -45, -25)

	for i = 1, 5 do
		local tab = _G["CharacterFrameTab"..i]

		S:HandleTab(tab)
	end

	-- Character Frame
	PaperDollFrame:StripTextures()

	CharacterModelFrame:Point("TOPLEFT", 65, -76)
	CharacterModelFrame:Height(195)

	PlayerTitleDropDown:Point("TOP", CharacterLevelText, "BOTTOM", 0, -2)
	S:HandleDropDownBox(PlayerTitleDropDown, 210)

	S:HandleRotateButton(CharacterModelFrameRotateLeftButton)
	CharacterModelFrameRotateLeftButton:ClearAllPoints()
	CharacterModelFrameRotateLeftButton:Point("TOPLEFT", 3, -3)

	S:HandleRotateButton(CharacterModelFrameRotateRightButton)
	CharacterModelFrameRotateRightButton:ClearAllPoints()
	CharacterModelFrameRotateRightButton:Point("TOPLEFT", CharacterModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)

	CharacterAttributesFrame:StripTextures()

	local function FixWidth(self)
		UIDropDownMenu_SetWidth(90, self)
	end

	S:HandleDropDownBox(PlayerStatFrameLeftDropDown)
	PlayerStatFrameLeftDropDown:HookScript("OnShow", FixWidth)
	S:SquareButton_SetIcon(PlayerStatFrameLeftDropDownButton, "DOWN")

	S:HandleDropDownBox(PlayerStatFrameRightDropDown)
	PlayerStatFrameRightDropDown:HookScript("OnShow", FixWidth)

	CharacterResistanceFrame:Point("TOPRIGHT", PaperDollFrame, "TOPLEFT", 297, -80)

	local function HandleResistanceFrame(frameName)
		for i = 1, 5 do
			local frame = _G[frameName..i]

			frame:Size(26)
			frame:SetTemplate("Default")

			if i ~= 1 then
				frame:ClearAllPoints()
				frame:Point("TOP", _G[frameName..i - 1], "BOTTOM", 0, -(E.Border + E.Spacing) - 1)
			end

			select(1, _G[frameName..i]:GetRegions()):SetInside()
			select(1, _G[frameName..i]:GetRegions()):SetDrawLayer("ARTWORK")
			select(2, _G[frameName..i]:GetRegions()):SetDrawLayer("OVERLAY")
		end
	end

	HandleResistanceFrame("MagicResFrame")

	select(1, MagicResFrame1:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.25, 0.3203125)
	select(1, MagicResFrame2:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.0234375, 0.09375)
	select(1, MagicResFrame3:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.13671875, 0.20703125)
	select(1, MagicResFrame4:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.36328125, 0.43359375)
	select(1, MagicResFrame5:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.4765625, 0.546875)

	local slots = {
		"HeadSlot",
		"NeckSlot",
		"ShoulderSlot",
		"BackSlot",
		"ChestSlot",
		"ShirtSlot",
		"TabardSlot",
		"WristSlot",
		"HandsSlot",
		"WaistSlot",
		"LegsSlot",
		"FeetSlot",
		"Finger0Slot",
		"Finger1Slot",
		"Trinket0Slot",
		"Trinket1Slot",
		"MainHandSlot",
		"SecondaryHandSlot",
		"RangedSlot",
		"AmmoSlot"
	}

	for _, i in pairs(slots) do
		local slot = _G["Character"..i]
		local icon = _G["Character"..i.."IconTexture"]
		local cooldown = _G["Character"..i.."Cooldown"]

		slot:StripTextures()
		slot:StyleButton(false)
		slot:SetTemplate("Default", true, true)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		E:RegisterCooldown(cooldown)
	end

	local function ColorItemBorder(_, event, unit)
		if event == "UNIT_INVENTORY_CHANGED" and unit ~= "player" then return end

		for _, i in pairs(slots) do
			local slot = _G["Character"..i]
			local slotID = GetInventorySlotInfo(i)
			local itemID = GetInventoryItemTexture("player", slotID)

			if itemID then
				local rarity = GetInventoryItemQuality("player", slotID)

				if rarity then
					slot:SetBackdropBorderColor(GetItemQualityColor(rarity))
				else
					slot:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			else
				slot:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end

	local checkItemBorderColor = CreateFrame("Frame")
	checkItemBorderColor:RegisterEvent("UNIT_INVENTORY_CHANGED")
	checkItemBorderColor:SetScript("OnEvent", ColorItemBorder)
	CharacterFrame:HookScript("OnShow", ColorItemBorder)
	ColorItemBorder()

	-- Pet Frame
	PetPaperDollFrame:StripTextures()

	S:HandleButton(PetPaperDollCloseButton)

	S:HandleRotateButton(PetModelFrameRotateLeftButton)
	PetModelFrameRotateLeftButton:ClearAllPoints()
	PetModelFrameRotateLeftButton:Point("TOPLEFT", 3, -3)

	S:HandleRotateButton(PetModelFrameRotateRightButton)
	PetModelFrameRotateRightButton:ClearAllPoints()
	PetModelFrameRotateRightButton:Point("TOPLEFT", PetModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)

	PetAttributesFrame:StripTextures()

	HandleResistanceFrame("PetMagicResFrame")

	select(1, PetMagicResFrame1:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.25, 0.3203125)
	select(1, PetMagicResFrame2:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.0234375, 0.09375)
	select(1, PetMagicResFrame3:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.13671875, 0.20703125)
	select(1, PetMagicResFrame4:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.36328125, 0.43359375)
	select(1, PetMagicResFrame5:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.4765625, 0.546875)

	PetPaperDollFrameExpBar:StripTextures()
	PetPaperDollFrameExpBar:CreateBackdrop("Default")
	PetPaperDollFrameExpBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(PetPaperDollFrameExpBar)

	local function updHappiness(self)
		local happiness = GetPetHappiness()
		local _, isHunterPet = HasPetUI()
		if not happiness or not isHunterPet then return end

		local texture = self:GetRegions()
		if happiness == 1 then
			texture:SetTexCoord(0.41, 0.53, 0.06, 0.30)
		elseif happiness == 2 then
			texture:SetTexCoord(0.22, 0.345, 0.06, 0.30)
		elseif happiness == 3 then
			texture:SetTexCoord(0.04, 0.15, 0.06, 0.30)
		end
	end

	PetPaperDollPetInfo:CreateBackdrop("Default")
	PetPaperDollPetInfo:Point("TOPLEFT", PetModelFrameRotateLeftButton, "BOTTOMLEFT", 9, -3)
	PetPaperDollPetInfo:GetRegions():SetTexCoord(0.04, 0.15, 0.06, 0.30)
	PetPaperDollPetInfo:SetFrameLevel(PetModelFrame:GetFrameLevel() + 2)
	PetPaperDollPetInfo:Size(24)

	updHappiness(PetPaperDollPetInfo)
	PetPaperDollPetInfo:RegisterEvent("UNIT_HAPPINESS")
	PetPaperDollPetInfo:SetScript("OnEvent", updHappiness)
	PetPaperDollPetInfo:SetScript("OnShow", updHappiness)

	-- Reputation Frame
	ReputationFrame:StripTextures()

	for i = 1, NUM_FACTIONS_DISPLAYED do
		local bar = _G["ReputationBar"..i]
		local header = _G["ReputationHeader"..i]
		local name = _G["ReputationBar"..i.."FactionName"]
		local war = _G["ReputationBar"..i.."AtWarCheck"]

		bar:StripTextures()
		bar:CreateBackdrop("Default")
		bar:SetStatusBarTexture(E.media.normTex)
		bar:Size(108, 13)
		E:RegisterStatusBar(bar)

		if i == 1 then
			bar:Point("TOPLEFT", 190, -86)
		end

		name:Point("LEFT", bar, "LEFT", -150, 0)
		name:Width(140)
		name.SetWidth = E.noop

		header:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
		header.SetNormalTexture = E.noop
		header:GetNormalTexture():Size(14)
		header:SetHighlightTexture(nil)
		header:Point("TOPLEFT", bar, "TOPLEFT", -175, 0)

		war:StripTextures()
		war:Point("LEFT", bar, "RIGHT", 0, 0)

		war.icon = war:CreateTexture(nil, "OVERLAY")
		war.icon:Point("LEFT", 3, -6)
		war.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-SwordCheck")
	end

	hooksecurefunc("ReputationFrame_Update", function()
		local numFactions = GetNumFactions()
		local offset = FauxScrollFrame_GetOffset(ReputationListScrollFrame)
		local index, header

		for i = 1, NUM_FACTIONS_DISPLAYED, 1 do
			header = _G["ReputationHeader"..i]
			index = offset + i

			if index <= numFactions then
				if header.isCollapsed then
					header:GetNormalTexture():SetTexCoord(0.040, 0.465, 0.085, 0.920)
				else
					header:GetNormalTexture():SetTexCoord(0.540, 0.965, 0.085, 0.920)
				end
			end
		end
	end)

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

	-- Skill Frame
	SkillFrame:StripTextures()

	SkillFrameExpandButtonFrame:DisableDrawLayer("BACKGROUND")

	SkillFrameCollapseAllButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
	SkillFrameCollapseAllButton.SetNormalTexture = E.noop
	SkillFrameCollapseAllButton:GetNormalTexture():Size(15)
	SkillFrameCollapseAllButton:Point("LEFT", SkillFrameExpandTabLeft, "RIGHT", -40, -3)

	SkillFrameCollapseAllButton:SetHighlightTexture(nil)

	hooksecurefunc(SkillFrameCollapseAllButton, "SetNormalTexture", function(self, texture)
		if find(texture, "MinusButton") then
			self:GetNormalTexture():SetTexCoord(0.545, 0.975, 0.085, 0.925)
		else
			self:GetNormalTexture():SetTexCoord(0.045, 0.475, 0.085, 0.925)
		end
	end)

	S:HandleButton(SkillFrameCancelButton)

	for i = 1, SKILLS_TO_DISPLAY do
		local bar = _G["SkillRankFrame"..i]
		local label = _G["SkillTypeLabel"..i]
		local border = _G["SkillRankFrame"..i.."Border"]
		local background = _G["SkillRankFrame"..i.."Background"]

		bar:CreateBackdrop("Default")
		bar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(bar)

		border:StripTextures()
		background:SetTexture(nil)

		label:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
		label.SetNormalTexture = E.noop
		label:GetNormalTexture():Size(14)
		label:SetHighlightTexture(nil)

		hooksecurefunc(label, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self:GetNormalTexture():SetTexCoord(0.545, 0.975, 0.085, 0.925)
			else
				self:GetNormalTexture():SetTexCoord(0.045, 0.475, 0.085, 0.925)
			end
		end)
	end

	SkillListScrollFrame:StripTextures()
	S:HandleScrollBar(SkillListScrollFrameScrollBar)

	SkillDetailScrollFrame:StripTextures()
	S:HandleScrollBar(SkillDetailScrollFrameScrollBar)

	SkillDetailStatusBar:StripTextures()
	SkillDetailStatusBar:CreateBackdrop("Default")
	SkillDetailStatusBar:SetParent(SkillDetailScrollFrame)
	SkillDetailStatusBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(SkillDetailStatusBar)

	S:HandleNextPrevButton(SkillDetailStatusBarUnlearnButton)
	S:SquareButton_SetIcon(SkillDetailStatusBarUnlearnButton, "DELETE")
	SkillDetailStatusBarUnlearnButton:Size(24)
	SkillDetailStatusBarUnlearnButton:Point("LEFT", SkillDetailStatusBarBorder, "RIGHT", 5, 0)
	SkillDetailStatusBarUnlearnButton:SetHitRectInsets(0, 0, 0, 0)

	-- PvP Frame
	PVPFrame:StripTextures(true)

	for i = 1, MAX_ARENA_TEAMS do
		local pvpTeam = _G["PVPTeam"..i]

		pvpTeam:StripTextures()
		pvpTeam:CreateBackdrop("Default")
		pvpTeam.backdrop:Point("TOPLEFT", 9, -4)
		pvpTeam.backdrop:Point("BOTTOMRIGHT", -24, 3)

		pvpTeam:HookScript("OnEnter", S.SetModifiedBackdrop)
		pvpTeam:HookScript("OnLeave", S.SetOriginalBackdrop)

		_G["PVPTeam"..i.."Highlight"]:Kill()
	end

	PVPTeamDetails:StripTextures()
	PVPTeamDetails:SetTemplate("Transparent")
	PVPTeamDetails:Point("TOPLEFT", PVPFrame, "TOPRIGHT", -30, -12)

	S:HandleNextPrevButton(PVPFrameToggleButton)
	PVPFrameToggleButton:Point("BOTTOMRIGHT", PVPFrame, "BOTTOMRIGHT", -48, 81)
	PVPFrameToggleButton:Size(14)

	for i = 1, 5 do
		local header = _G["PVPTeamDetailsFrameColumnHeader"..i]

		header:StripTextures()
		header:StyleButton()
	end

	for i = 1, 10 do
		local button = _G["PVPTeamDetailsButton"..i]

		button:Width(335)
		S:HandleButtonHighlight(button)
	end

	S:HandleButton(PVPTeamDetailsAddTeamMember)

	S:HandleNextPrevButton(PVPTeamDetailsToggleButton)

	S:HandleCloseButton(PVPTeamDetailsCloseButton)
end

S:AddCallback("Character", LoadSkin)