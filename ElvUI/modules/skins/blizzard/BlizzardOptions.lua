local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local ipairs = ipairs
local find = string.find

local InCombatLockdown = InCombatLockdown

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.BlizzardOptions ~= true then return end

	-- Game Menu Interface/Tabs
	for i = 1, 2 do
		local tab = _G["InterfaceOptionsFrameTab"..i]

		tab:StripTextures()
		S:HandleTab(tab)

		tab.backdrop:SetTemplate("Transparent")
		tab.backdrop:Point("TOPLEFT", 10, E.PixelMode and -4 or -6)
		tab.backdrop:Point("BOTTOMRIGHT", -10, 1)
	end

	InterfaceOptionsFrameTab1:ClearAllPoints()
	InterfaceOptionsFrameTab1:Point("BOTTOMLEFT", InterfaceOptionsFrameCategories, "TOPLEFT", -11, -2)

	-- Game Menu Plus / Minus Buttons
	local maxButtons = (InterfaceOptionsFrameAddOns:GetHeight() - 8) / InterfaceOptionsFrameAddOns.buttonHeight
	for i = 1, maxButtons do
		local buttonToggle = _G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]

		buttonToggle:SetNormalTexture([[Interface\AddOns\ElvUI\media\textures\PlusMinusButton]])
		buttonToggle.SetNormalTexture = E.noop
		buttonToggle:SetPushedTexture([[Interface\AddOns\ElvUI\media\textures\PlusMinusButton]])
		buttonToggle.SetPushedTexture = E.noop
		buttonToggle:SetHighlightTexture("")

		hooksecurefunc(buttonToggle, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self:GetNormalTexture():SetTexCoord(0.540, 0.965, 0.085, 0.920)
				self:GetPushedTexture():SetTexCoord(0.540, 0.965, 0.085, 0.920)
			else
				self:GetNormalTexture():SetTexCoord(0.040, 0.465, 0.085, 0.920)
				self:GetPushedTexture():SetTexCoord(0.040, 0.465, 0.085, 0.920)
			end
		end)
	end

	-- Interface Options Frame
	InterfaceOptionsFrame:SetTemplate("Transparent")
	InterfaceOptionsFrame:SetClampedToScreen(true)
	InterfaceOptionsFrame:SetMovable(true)
	InterfaceOptionsFrame:EnableMouse(true)
	InterfaceOptionsFrame:RegisterForDrag("LeftButton", "RightButton")
	InterfaceOptionsFrame:SetScript("OnDragStart", function(self)
		if InCombatLockdown() then return end

		self:StartMoving()
		self.isMoving = true
	end)
	InterfaceOptionsFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		self.isMoving = false
	end)

	local skins = {
		"OptionsFrame",
		"OptionsFrameDisplay",
		"OptionsFrameBrightness",
		"OptionsFrameWorldAppearance",
		"AudioOptionsFrame",
		"SoundOptionsFramePlayback",
		"SoundOptionsFrameHardware",
		"SoundOptionsFrameVolume",
	}
	for i = 1, #skins do
		_G[skins[i]]:SetTemplate("Transparent")
	end

	OptionsFramePixelShaders:StripTextures()
	OptionsFramePixelShaders:CreateBackdrop("Transparent")
	OptionsFramePixelShaders.backdrop:Point("TOPLEFT", 0, -4)
	OptionsFramePixelShaders.backdrop:Point("BOTTOMRIGHT", -2, -1)

	OptionsFrameMiscellaneous:StripTextures()
	OptionsFrameMiscellaneous:CreateBackdrop("Transparent")
	OptionsFrameMiscellaneous.backdrop:Point("TOPLEFT", 0, -4)

	local BlizzardHeader = {
		"InterfaceOptionsFrame",
		"AudioOptionsFrame",
		"OptionsFrame",
	}
	for i = 1, #BlizzardHeader do
		local title = _G[BlizzardHeader[i].."Header"]
		if title then
			title:SetTexture("")
			title:ClearAllPoints()
			title:Point("TOP", BlizzardHeader[i], 0, 0)
		end
	end

	local BlizzardButtons = {
		"OptionsFrameOkay",
		"OptionsFrameCancel",
		"OptionsFrameDefaults",
		"SoundOptionsFrameOkay",
		"SoundOptionsFrameCancel",
		"SoundOptionsFrameDefaults",
		"InterfaceOptionsFrameDefaults",
		"InterfaceOptionsFrameOkay",
		"InterfaceOptionsFrameCancel",
	}
	for i = 1, #BlizzardButtons do
		local ElvuiButtons = _G[BlizzardButtons[i]]
		if ElvuiButtons then
			S:HandleButton(ElvuiButtons)
		end
	end

	SoundOptionsFrameDefaults:Point("BOTTOMLEFT", 20, 16)
	SoundOptionsFrameCancel:Point("BOTTOMRIGHT", -17, 16)

	local frames = {
		"OptionsFrameCategoryFrame",
		"OptionsFramePanelContainer",
		"OptionsResolutionPanelBrightness",
		"SoundOptionsFrameCategoryFrame",
		"SoundOptionsFramePanelContainer",
		"InterfaceOptionsFrameCategories",
		"InterfaceOptionsFramePanelContainer",
		"InterfaceOptionsFrameAddOns",
		"SoundOptionsSoundPanelPlayback",
		"SoundOptionsSoundPanelVolume",
		"SoundOptionsSoundPanelHardware",
		"OptionsEffectsPanelQuality",
		"OptionsEffectsPanelShaders",
	}
	for i = 1, #frames do
		local SkinFrames = _G[frames[i]]
		if SkinFrames then
			SkinFrames:StripTextures()
			SkinFrames:CreateBackdrop("Transparent")
			if SkinFrames ~= _G["OptionsFramePanelContainer"] and SkinFrames ~= _G["InterfaceOptionsFramePanelContainer"] then
				SkinFrames.backdrop:Point("TOPLEFT",-1,0)
				SkinFrames.backdrop:Point("BOTTOMRIGHT",0,1)
			else
				SkinFrames.backdrop:Point("TOPLEFT", 0, 0)
				SkinFrames.backdrop:Point("BOTTOMRIGHT", 0, 0)
			end
		end
	end

	OptionsFrameCancel:ClearAllPoints()
	OptionsFrameCancel:Point("BOTTOMLEFT", OptionsFrame, "BOTTOMRIGHT", -103, 15)

	OptionsFrameOkay:ClearAllPoints()
	OptionsFrameOkay:Point("RIGHT", OptionsFrameCancel, "LEFT", -4, 0)

	SoundOptionsFrameOkay:ClearAllPoints()
	SoundOptionsFrameOkay:Point("RIGHT", SoundOptionsFrameCancel, "LEFT", -4, 0)

	InterfaceOptionsFrameCancel:ClearAllPoints()
	InterfaceOptionsFrameCancel:Point("TOPRIGHT", InterfaceOptionsFramePanelContainer, "BOTTOMRIGHT", 0,- 6)

	InterfaceOptionsFrameOkay:ClearAllPoints()
	InterfaceOptionsFrameOkay:Point("RIGHT", InterfaceOptionsFrameCancel, "LEFT", -4, 0)

	InterfaceOptionsFrameDefaults:ClearAllPoints()
	InterfaceOptionsFrameDefaults:Point("TOPLEFT", InterfaceOptionsFrameCategories, "BOTTOMLEFT", -1, -5)

	InterfaceOptionsFrameCategoriesList:StripTextures()

	S:HandleScrollBar(InterfaceOptionsFrameCategoriesListScrollBar)

	InterfaceOptionsFrameAddOnsList:StripTextures()

	S:HandleScrollBar(InterfaceOptionsFrameAddOnsListScrollBar)

	OptionsFrameDefaults:ClearAllPoints()
	OptionsFrameDefaults:Point("TOPLEFT", OptionsFrame, "BOTTOMLEFT", 12, 36)

	local interfacecheckbox = {
		"ControlsPanelStickyTargeting",
		"ControlsPanelFixInputLag",
		"ControlsPanelAutoDismount",
		"ControlsPanelAutoClearAFK",
		"ControlsPanelBlockTrades",
		"ControlsPanelLootAtMouse",
		"ControlsPanelAutoLootCorpse",
		"CombatPanelAttackOnAssist",
		"CombatPanelAutoRange",
		"CombatPanelStopAutoAttack",
		"CombatPanelAutoSelfCast",
		"CombatPanelTargetOfTarget",
		"CombatPanelEnemyCastBarsOnPortrait",
		"CombatPanelEnemyCastBarsOnNameplates",
		"DisplayPanelShowCloak",
		"DisplayPanelShowHelm",
		"DisplayPanelDetailedLootInfo",
		"DisplayPanelShowFreeBagSpace",
		"DisplayPanelRotateMinimap",
		"DisplayPanelScreenEdgeFlash",
		"DisplayPanelShowClock",
		"DisplayPanelBuffDurations",
		"QuestsPanelInstantQuestText",
		"QuestsPanelAutoQuestTracking",
		"SocialPanelProfanityFilter",
		"SocialPanelSpamFilter",
		"SocialPanelChatBubbles",
		"SocialPanelPartyChat",
		"SocialPanelChatHoverDelay",
		"SocialPanelGuildMemberAlert",
		"SocialPanelGuildRecruitment",
		"SocialPanelShowChatIcons",
		"SocialPanelSimpleChat",
		"SocialPanelLockChatSettings",
		"ActionBarsPanelLockActionBars",
		"ActionBarsPanelSecureAbilityToggle",
		"ActionBarsPanelAlwaysShowActionBars",
		"ActionBarsPanelBottomLeft",
		"ActionBarsPanelBottomRight",
		"ActionBarsPanelRight",
		"ActionBarsPanelRightTwo",
		"NamesPanelMyName",
		"NamesPanelCompanions",
		"NamesPanelFriendlyPlayerNames",
		"NamesPanelFriendlyPetsMinions",
		"NamesPanelFriendlyCreations",
		"NamesPanelGuilds",
		"NamesPanelNPCNames",
		"NamesPanelTitles",
		"NamesPanelEnemyPlayerNames",
		"NamesPanelEnemyPetsMinions",
		"NamesPanelEnemyCreations",
		"CombatTextPanelTargetDamage",
		"CombatTextPanelPeriodicDamage",
		"CombatTextPanelPetDamage",
		"CombatTextPanelHealing",
		"CombatTextPanelEnableFCT",
		"CombatTextPanelDodgeParryMiss",
		"CombatTextPanelDamageReduction",
		"CombatTextPanelRepChanges",
		"CombatTextPanelReactiveAbilities",
		"CombatTextPanelFriendlyHealerNames",
		"CombatTextPanelCombatState",
		"CombatTextPanelComboPoints",
		"CombatTextPanelLowManaHealth",
		"CombatTextPanelEnergyGains",
		"CombatTextPanelHonorGains",
		"CombatTextPanelAuras",
		"CameraPanelFollowTerrain",
		"CameraPanelHeadBob",
		"CameraPanelWaterCollision",
		"CameraPanelSmartPivot",
		"MousePanelInvertMouse",
		"MousePanelClickToMove",
		"HelpPanelTutorials",
		"HelpPanelLoadingScreenTips",
		"HelpPanelEnhancedTooltips",
		"HelpPanelBeginnerTooltips",
		"HelpPanelShowLuaErrors",
		"StatusTextPanelPlayer",
		"StatusTextPanelPet",
		"StatusTextPanelParty",
		"StatusTextPanelTarget",
		"StatusTextPanelPercentages",
		"StatusTextPanelXP",
		"PartyRaidPanelPartyBackground",
		"PartyRaidPanelPartyInRaid",
		"PartyRaidPanelPartyPets",
		"PartyRaidPanelDispellableDebuffs",
		"PartyRaidPanelCastableBuffs",
		"PartyRaidPanelRaidRange"
	}
	for i = 1, #interfacecheckbox do
		local icheckbox = _G["InterfaceOptions"..interfacecheckbox[i]]
		if icheckbox then
			S:HandleCheckBox(icheckbox)
		end
	end
	local interfacedropdown ={
		"ControlsPanelAutoLootKeyDropDown",
		"CombatPanelTOTDropDown",
		"CombatPanelFocusCastKeyDropDown",
		"CombatPanelSelfCastKeyDropDown",
		"DisplayPanelAggroWarningDisplay",
		"DisplayPanelWorldPVPObjectiveDisplay",
		"SocialPanelChatStyle",
		"SocialPanelTimestamps",
		"CombatTextPanelFCTDropDown",
		"CameraPanelStyleDropDown",
		"MousePanelClickMoveStyleDropDown",
		"LanguagesPanelLocaleDropDown"
	}
	for i = 1, #interfacedropdown do
		local idropdown = _G["InterfaceOptions"..interfacedropdown[i]]
		if idropdown then
			S:HandleDropDownBox(idropdown)
		end
	end

	S:HandleButton(InterfaceOptionsHelpPanelResetTutorials)

	local optioncheckbox = {
		"OptionsFrameCheckButton1",
		"OptionsFrameCheckButton2",
		"OptionsFrameCheckButton3",
		"OptionsFrameCheckButton4",
		"OptionsFrameCheckButton5",
		"OptionsFrameCheckButton6",
		"OptionsFrameCheckButton7",
		"OptionsFrameCheckButton8",
		"OptionsFrameCheckButton9",
		"OptionsFrameCheckButton10",
		"OptionsFrameCheckButton11",
		"OptionsFrameCheckButton12",
		"OptionsFrameCheckButton13",
		"OptionsFrameCheckButton14",
		"OptionsFrameCheckButton15",
		"OptionsFrameCheckButton16",
		"OptionsFrameCheckButton17",
		"OptionsFrameCheckButton18",
		"OptionsFrameCheckButton19",
		"SoundOptionsFrameCheckButton1",
		"SoundOptionsFrameCheckButton2",
		"SoundOptionsFrameCheckButton3",
		"SoundOptionsFrameCheckButton4",
		"SoundOptionsFrameCheckButton5",
		"SoundOptionsFrameCheckButton6",
		"SoundOptionsFrameCheckButton7",
		"SoundOptionsFrameCheckButton8",
		"SoundOptionsFrameCheckButton9",
		"SoundOptionsFrameCheckButton10",
		"SoundOptionsFrameCheckButton11"
	}
	for i = 1, #optioncheckbox do
		local ocheckbox = _G[optioncheckbox[i]]
		if ocheckbox then
			S:HandleCheckBox(ocheckbox)
		end
	end

	SoundOptionsFrameCheckButton1:Point("TOPLEFT", "SoundOptionsFrame", "TOPLEFT", 16, -15)

	local optiondropdown = {
		"OptionsFrameResolutionDropDown",
		"OptionsFrameRefreshDropDown",
		"OptionsFrameMultiSampleDropDown",
		"SoundOptionsOutputDropDown",
	}
	for i = 1, #optiondropdown do
		local odropdown = _G[optiondropdown[i]]
		if odropdown then
			S:HandleDropDownBox(odropdown, i == 3 and 195 or 165)
		end
	end

	S:HandleSliderFrame(InterfaceOptionsCameraPanelMaxDistanceSlider)
	S:HandleSliderFrame(InterfaceOptionsCameraPanelFollowSpeedSlider)
	S:HandleSliderFrame(InterfaceOptionsMousePanelMouseSensitivitySlider)
	S:HandleSliderFrame(InterfaceOptionsMousePanelMouseLookSpeedSlider)

	-- Video Options Sliders
	for i = 1, 11 do
		S:HandleSliderFrame(_G["OptionsFrameSlider"..i])
	end

	-- Sound Options Sliders
	for i = 1, 6 do
		S:HandleSliderFrame(_G["SoundOptionsFrameSlider"..i])
	end

	-- Chat Config
	ChatConfigFrame:StripTextures()
	ChatConfigFrame:SetTemplate("Transparent")
	ChatConfigCategoryFrame:SetTemplate("Transparent")
	ChatConfigBackgroundFrame:SetTemplate("Transparent")

	ChatConfigCombatSettingsFilters:SetTemplate("Transparent")

	ChatConfigCombatSettingsFiltersScrollFrame:StripTextures()

	S:HandleScrollBar(ChatConfigCombatSettingsFiltersScrollFrameScrollBar)
	ChatConfigCombatSettingsFiltersScrollFrameScrollBarBorder:Kill()

	S:HandleButton(ChatConfigCombatSettingsFiltersDeleteButton)
	ChatConfigCombatSettingsFiltersDeleteButton:Point("TOPRIGHT", ChatConfigCombatSettingsFilters, "BOTTOMRIGHT", 0, -1)

	S:HandleButton(ChatConfigCombatSettingsFiltersAddFilterButton)
	ChatConfigCombatSettingsFiltersAddFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)

	S:HandleButton(ChatConfigCombatSettingsFiltersCopyFilterButton)
	ChatConfigCombatSettingsFiltersCopyFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)

	S:HandleNextPrevButton(ChatConfigMoveFilterUpButton, true)
	S:SquareButton_SetIcon(ChatConfigMoveFilterUpButton, "UP")
	ChatConfigMoveFilterUpButton:Size(26)
	ChatConfigMoveFilterUpButton:Point("TOPLEFT", ChatConfigCombatSettingsFilters, "BOTTOMLEFT", 3, -1)
	ChatConfigMoveFilterUpButton:SetHitRectInsets(0, 0, 0, 0)

	S:HandleNextPrevButton(ChatConfigMoveFilterDownButton, true)
	ChatConfigMoveFilterDownButton:Size(26)
	ChatConfigMoveFilterDownButton:Point("LEFT", ChatConfigMoveFilterUpButton, "RIGHT", 1, 0)
	ChatConfigMoveFilterDownButton:SetHitRectInsets(0, 0, 0, 0)

	CombatConfigColorsHighlighting:StripTextures()
	CombatConfigColorsColorizeUnitName:StripTextures()
	CombatConfigColorsColorizeSpellNames:StripTextures()

	CombatConfigColorsColorizeDamageNumber:StripTextures()
	CombatConfigColorsColorizeDamageSchool:StripTextures()
	CombatConfigColorsColorizeEntireLine:StripTextures()

	S:HandleColorSwatch(CombatConfigColorsColorizeSpellNamesColorSwatch)
	S:HandleColorSwatch(CombatConfigColorsColorizeDamageNumberColorSwatch)

	S:HandleEditBox(CombatConfigSettingsNameEditBox)

	S:HandleButton(CombatConfigSettingsSaveButton)

	local combatConfigCheck = {
		"CombatConfigColorsHighlightingLine",
		"CombatConfigColorsHighlightingAbility",
		"CombatConfigColorsHighlightingDamage",
		"CombatConfigColorsHighlightingSchool",
		"CombatConfigColorsColorizeUnitNameCheck",
		"CombatConfigColorsColorizeSpellNamesCheck",
		"CombatConfigColorsColorizeSpellNamesSchoolColoring",
		"CombatConfigColorsColorizeDamageNumberCheck",
		"CombatConfigColorsColorizeDamageNumberSchoolColoring",
		"CombatConfigColorsColorizeDamageSchoolCheck",
		"CombatConfigColorsColorizeEntireLineCheck",
		"CombatConfigFormattingShowTimeStamp",
		"CombatConfigFormattingShowBraces",
		"CombatConfigFormattingUnitNames",
		"CombatConfigFormattingSpellNames",
		"CombatConfigFormattingItemNames",
		"CombatConfigFormattingFullText",
		"CombatConfigSettingsShowQuickButton",
		"CombatConfigSettingsSolo",
		"CombatConfigSettingsParty",
		"CombatConfigSettingsRaid"
	}

	for i = 1, #combatConfigCheck do
		S:HandleCheckBox(_G[combatConfigCheck[i]])
	end

	for i = 1, 5 do
		local tab = _G["CombatConfigTab"..i]
		tab:StripTextures()

		tab:CreateBackdrop("Default", true)
		tab.backdrop:Point("TOPLEFT", 1, -10)
		tab.backdrop:Point("BOTTOMRIGHT", -1, 2)

		tab:HookScript2("OnEnter", S.SetModifiedBackdrop)
		tab:HookScript2("OnLeave", S.SetOriginalBackdrop)
	end

	S:HandleButton(ChatConfigFrameDefaultButton)
	ChatConfigFrameDefaultButton:Point("BOTTOMLEFT", 12, 8)
	ChatConfigFrameDefaultButton:Width(125)

	S:HandleButton(CombatLogDefaultButton)

	S:HandleButton(ChatConfigFrameCancelButton)
	ChatConfigFrameCancelButton:Point("BOTTOMRIGHT", -1, 8)

	S:HandleButton(ChatConfigFrameOkayButton)

	S:SecureHook("ChatConfig_CreateCheckboxes", function(frame, checkBoxTable, checkBoxTemplate)
		local checkBoxNameString = frame:GetName().."CheckBox"
		if checkBoxTemplate == "ChatConfigCheckBoxTemplate" then
			frame:SetTemplate("Transparent")
			for index, _ in ipairs(checkBoxTable) do
				local checkBoxName = checkBoxNameString..index
				local checkbox = _G[checkBoxName]

				if not checkbox.backdrop then
					checkbox:StripTextures()
					checkbox:CreateBackdrop()
					checkbox.backdrop:Point("TOPLEFT", 3, -1)
					checkbox.backdrop:Point("BOTTOMRIGHT", -3, 1)
					checkbox.backdrop:SetFrameLevel(checkbox:GetParent():GetFrameLevel() + 1)

					S:HandleCheckBox(_G[checkBoxName.."Check"])
				end
			end
		elseif (checkBoxTemplate == "ChatConfigCheckBoxWithSwatchTemplate") or (checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate") then
			frame:SetTemplate("Transparent")
			for index, _ in ipairs(checkBoxTable) do
				local checkBoxName = checkBoxNameString..index
				local checkbox = _G[checkBoxName]
				local colorSwatch = _G[checkBoxName.."ColorSwatch"]

				if not checkbox.backdrop then
					checkbox:StripTextures()
					checkbox:CreateBackdrop()
					checkbox.backdrop:Point("TOPLEFT", 3, -1)
					checkbox.backdrop:Point("BOTTOMRIGHT", -3, 1)
					checkbox.backdrop:SetFrameLevel(checkbox:GetParent():GetFrameLevel() + 1)

					S:HandleCheckBox(_G[checkBoxName.."Check"])

					if checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate" then
						S:HandleCheckBox(_G[checkBoxName.."ColorClasses"])
					end

					S:HandleColorSwatch(colorSwatch)
				end
			end
		end
	end)

	S:SecureHook("ChatConfig_CreateTieredCheckboxes", function(frame, checkBoxTable)
		local checkBoxNameString = frame:GetName().."CheckBox"
		for index, value in ipairs(checkBoxTable) do
			local checkBoxName = checkBoxNameString..index

			if _G[checkBoxName] then
				S:HandleCheckBox(_G[checkBoxName])
				if value.subTypes then
					local subCheckBoxNameString = checkBoxName.."_"
					for k, _ in ipairs(value.subTypes) do
						local subCheckBoxName = subCheckBoxNameString..k
						if _G[subCheckBoxName] then
							S:HandleCheckBox(_G[subCheckBoxNameString..k])
						end
					end
				end
			end
		end
	end)

	S:SecureHook("ChatConfig_CreateColorSwatches", function(frame, swatchTable)
		frame:SetTemplate("Transparent")
		local nameString = frame:GetName().."Swatch"
		for index, _ in ipairs(swatchTable) do
			local swatchName = nameString..index
			local swatch = _G[swatchName]
			local colorSwatch = _G[swatchName.."ColorSwatch"]

			if not swatch.backdrop then
				swatch:StripTextures()
				swatch:CreateBackdrop()
				swatch.backdrop:Point("TOPLEFT", 3, -1)
				swatch.backdrop:Point("BOTTOMRIGHT", -3, 1)
				swatch.backdrop:SetFrameLevel(swatch:GetParent():GetFrameLevel() + 1)

				S:HandleColorSwatch(colorSwatch)
			end
		end
	end)

	-- Mac Options
	if E.isMacClient then
		S:HandleButton(GameMenuButtonMacOptions)

		-- Skin main frame and reposition the header
		MacOptionsFrame:SetTemplate("Default", true)
		MacOptionsFrameHeader:SetTexture("")
		MacOptionsFrameHeader:ClearAllPoints()
		MacOptionsFrameHeader:Point("TOP", MacOptionsFrame, 0, 0)

		S:HandleDropDownBox(MacOptionsFrameResolutionDropDown)
		S:HandleDropDownBox(MacOptionsFrameFramerateDropDown)
		S:HandleDropDownBox(MacOptionsFrameCodecDropDown)

		S:HandleSliderFrame(MacOptionsFrameQualitySlider)

		for i = 1, 8 do
			S:HandleCheckBox(_G["MacOptionsFrameCheckButton"..i])
		end

		--Skin internal frames
		MacOptionsFrameMovieRecording:SetTemplate("Default", true)
		MacOptionsITunesRemote:SetTemplate("Default", true)

		--Skin buttons
		S:HandleButton(MacOptionsFrameCancel)
		S:HandleButton(MacOptionsFrameOkay)
		S:HandleButton(MacOptionsButtonKeybindings)
		S:HandleButton(MacOptionsFrameDefaults)
		S:HandleButton(MacOptionsButtonCompress)

		--Reposition and resize buttons
		local tPoint, tRTo, tRP, _, tY = MacOptionsButtonCompress:GetPoint()
		MacOptionsButtonCompress:Width(136)
		MacOptionsButtonCompress:ClearAllPoints()
		MacOptionsButtonCompress:Point(tPoint, tRTo, tRP, 4, tY)

		MacOptionsFrameCancel:Width(96)
		MacOptionsFrameCancel:Height(22)
		tPoint, tRTo, tRP, _, tY = MacOptionsFrameCancel:GetPoint()
		MacOptionsFrameCancel:ClearAllPoints()
		MacOptionsFrameCancel:Point(tPoint, tRTo, tRP, -14, tY)

		MacOptionsFrameOkay:ClearAllPoints()
		MacOptionsFrameOkay:Width(96)
		MacOptionsFrameOkay:Height(22)
		MacOptionsFrameOkay:Point("LEFT",MacOptionsFrameCancel, -99,0)

		MacOptionsButtonKeybindings:ClearAllPoints()
		MacOptionsButtonKeybindings:Width(96)
		MacOptionsButtonKeybindings:Height(22)
		MacOptionsButtonKeybindings:Point("LEFT",MacOptionsFrameOkay, -99,0)

		MacOptionsFrameDefaults:Width(96)
		MacOptionsFrameDefaults:Height(22)

		MacOptionsCompressFrame:SetTemplate("Default", true)

		MacOptionsCompressFrameHeader:SetTexture("")
		MacOptionsCompressFrameHeader:ClearAllPoints()
		MacOptionsCompressFrameHeader:Point("TOP", MacOptionsCompressFrame, 0, 0)

		S:HandleButton(MacOptionsCompressFrameDelete)
		S:HandleButton(MacOptionsCompressFrameSkip)
		S:HandleButton(MacOptionsCompressFrameCompress)

		MacOptionsCancelFrame:SetTemplate("Default", true)

		MacOptionsCancelFrameHeader:SetTexture("")
		MacOptionsCancelFrameHeader:ClearAllPoints()
		MacOptionsCancelFrameHeader:Point("TOP", MacOptionsCancelFrame, 0, 0)

		S:HandleButton(MacOptionsCancelFrameNo)
		S:HandleButton(MacOptionsCancelFrameYes)
	end
end

S:AddCallback("SkinBlizzard", LoadSkin)