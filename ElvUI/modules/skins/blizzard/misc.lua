local E, L, V, P, G, _ = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack
local find = string.find

local UnitIsUnit = UnitIsUnit

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.misc ~= true then return end
	-- Blizzard frame we want to reskin
	local skins = {
		"GameMenuFrame",
		"InterfaceOptionsFrame",
		"OptionsFrame",
		"OptionsFrameDisplay",
		"OptionsFrameBrightness",
		"OptionsFrameWorldAppearance",
		"OptionsFramePixelShaders",
		"OptionsFrameMiscellaneous",
		"AudioOptionsFrame",
		"SoundOptionsFramePlayback",
		"SoundOptionsFrameHardware",
		"SoundOptionsFrameVolume",
		"ReadyCheckFrame",
		"StackSplitFrame",
	}

	ReadyCheckFrame:StripTextures()
	ReadyCheckPortrait:Kill()

	local ticketBG = select(2, TicketStatusFrame:GetChildren())
	ticketBG:SetTemplate("Transparent")

	for i = 1, #skins do
		_G[skins[i]]:SetTemplate("Transparent")
	end

	local ChatMenus = {
		"ChatMenu",
		"EmoteMenu",
		"LanguageMenu",
		"VoiceMacroMenu",
	}

	for i = 1, #ChatMenus do
		if _G[ChatMenus[i]] == _G["ChatMenu"] then
			_G[ChatMenus[i]]:HookScript("OnShow", function(self) self:SetTemplate("Transparent", true) self:SetBackdropColor(unpack(E["media"].backdropfadecolor)) self:ClearAllPoints() self:Point("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 30) end)
		else
			_G[ChatMenus[i]]:HookScript("OnShow", function(self) self:SetTemplate("Transparent", true) self:SetBackdropColor(unpack(E["media"].backdropfadecolor)) end)
		end
	end

	local r, g, b = 0.8, 0.8, 0.8
	local function StyleButton(f)
		local width, height = (f:GetWidth() * .6), f:GetHeight()

		local leftGrad = f:CreateTexture(nil, "HIGHLIGHT")
		leftGrad:Size(width, height)
		leftGrad:Point("LEFT", f, "CENTER")
		leftGrad:SetTexture(E.media.blankTex)
		leftGrad:SetGradientAlpha("Horizontal", r, g, b, 0.35, r, g, b, 0)

		local rightGrad = f:CreateTexture(nil, "HIGHLIGHT")
		rightGrad:Size(width, height)
		rightGrad:Point("RIGHT", f, "CENTER")
		rightGrad:SetTexture(E.media.blankTex)
		rightGrad:SetGradientAlpha("Horizontal", r, g, b, 0, r, g, b, 0.35)
	end

	for i = 1, 32 do
		StyleButton(_G["ChatMenuButton"..i])
		StyleButton(_G["EmoteMenuButton"..i])
		StyleButton(_G["LanguageMenuButton"..i])
		StyleButton(_G["VoiceMacroMenuButton"..i])
	end

	-- Static Popups
	for i = 1, 4 do
		local staticPopup = _G["StaticPopup"..i]
		local itemFrame = _G["StaticPopup"..i.."ItemFrame"]
		local itemFrameBox = _G["StaticPopup"..i.."EditBox"]
		local itemFrameTexture = _G["StaticPopup"..i.."ItemFrameIconTexture"]
		local itemFrameNormal = _G["StaticPopup"..i.."ItemFrameNormalTexture"]
		local itemFrameName = _G["StaticPopup"..i.."ItemFrameNameFrame"]
		local closeButton = _G["StaticPopup"..i.."CloseButton"]
		local wideBox = _G["StaticPopup"..i.."WideEditBox"]

		staticPopup:SetTemplate("Transparent")

		S:HandleEditBox(itemFrameBox)
		itemFrameBox.backdrop:Point("TOPLEFT", -2, -4)
		itemFrameBox.backdrop:Point("BOTTOMRIGHT", 2, 4)

		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameGold"])
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameSilver"])
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameCopper"])

		for k = 1, itemFrameBox:GetNumRegions() do
			local region = select(k, itemFrameBox:GetRegions())
			if(region and region:GetObjectType() == "Texture") then
				if region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Left" or region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Right" then
					region:Kill()
				end
			end
		end

		closeButton:StripTextures()
		S:HandleCloseButton(closeButton)

		itemFrame:GetNormalTexture():Kill()
		itemFrame:SetTemplate()
		itemFrame:StyleButton()

		itemFrameTexture:SetTexCoord(unpack(E.TexCoords))
		itemFrameTexture:SetInside()

		itemFrameNormal:SetAlpha(0)
		itemFrameName:Kill()

		select(8, wideBox:GetRegions()):Hide()
		S:HandleEditBox(wideBox)
		wideBox:Height(22)

		for j = 1, 3 do
			S:HandleButton(_G["StaticPopup"..i.."Button"..j])
		end
	end

	-- reskin all esc/menu buttons
	local BlizzardMenuButtons = {
		"Options",
		"SoundOptions",
		"UIOptions",
		"Keybindings",
		"Macros",
		"Logout",
		"Quit",
		"Continue",
	}

	for i = 1, #BlizzardMenuButtons do
		local ElvuiMenuButtons = _G["GameMenuButton"..BlizzardMenuButtons[i]]
		if ElvuiMenuButtons then
			S:HandleButton(ElvuiMenuButtons)
		end
	end

	-- hide header textures and move text/buttons.
	local BlizzardHeader = {
		"GameMenuFrame",
		"InterfaceOptionsFrame",
		"AudioOptionsFrame",
		"OptionsFrame",
	}

	for i = 1, #BlizzardHeader do
		local title = _G[BlizzardHeader[i].."Header"]
		if title then
			title:SetTexture("")
			title:ClearAllPoints()
			if title == _G["GameMenuFrameHeader"] then
				title:Point("TOP", GameMenuFrame, 0, 7)
			else
				title:Point("TOP", BlizzardHeader[i], 0, 0)
			end
		end
	end

	-- here we reskin all "normal" buttons
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
		"ReadyCheckFrameYesButton",
		"ReadyCheckFrameNoButton",
		"StackSplitOkayButton",
		"StackSplitCancelButton",
		"RolePollPopupAcceptButton"
	}

	for i = 1, #BlizzardButtons do
		local ElvuiButtons = _G[BlizzardButtons[i]]
		if ElvuiButtons then
			S:HandleButton(ElvuiButtons)
		end
	end

	-- if a button position is not really where we want, we move it here
	OptionsFrameCancel:ClearAllPoints()
	OptionsFrameCancel:Point("BOTTOMLEFT",OptionsFrame,"BOTTOMRIGHT",-105,15)
	OptionsFrameOkay:ClearAllPoints()
	OptionsFrameOkay:Point("RIGHT",OptionsFrameCancel,"LEFT",-4,0)
	SoundOptionsFrameOkay:ClearAllPoints()
	SoundOptionsFrameOkay:Point("RIGHT",SoundOptionsFrameCancel,"LEFT",-4,0)
	InterfaceOptionsFrameOkay:ClearAllPoints()
	InterfaceOptionsFrameOkay:Point("RIGHT",InterfaceOptionsFrameCancel,"LEFT", -4,0)
	ReadyCheckFrameYesButton:Point("RIGHT", ReadyCheckFrame, "CENTER", -1, 0)
	ReadyCheckFrameNoButton:Point("LEFT", ReadyCheckFrameYesButton, "RIGHT", 3, 0)
	ReadyCheckFrameText:Point("TOP", ReadyCheckFrame, "TOP", 0, -18)

	-- others
	ZoneTextFrame:ClearAllPoints()
	ZoneTextFrame:Point("TOP", UIParent, 0, -128)

	CoinPickupFrame:StripTextures()
	CoinPickupFrame:SetTemplate("Transparent")

	S:HandleButton(CoinPickupOkayButton)
	S:HandleButton(CoinPickupCancelButton)

	ReadyCheckFrame:HookScript("OnShow", function(self) if UnitIsUnit("player", self.initiator) then self:Hide() end end) -- bug fix, don't show it if initiator
	StackSplitFrame:GetRegions():Hide()

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

	-- Declension frame
	if GetLocale() == "ruRU" then
		DeclensionFrame:SetTemplate("Transparent")

		S:HandleNextPrevButton(DeclensionFrameSetPrev)
		S:HandleNextPrevButton(DeclensionFrameSetNext)
		S:HandleButton(DeclensionFrameOkayButton)
		S:HandleButton(DeclensionFrameCancelButton)

		for i = 1, RUSSIAN_DECLENSION_PATTERNS do
			local editBox = _G["DeclensionFrameDeclension"..i.."Edit"]
			if editBox then
				editBox:StripTextures()
				S:HandleEditBox(editBox)
			end
		end
	end

	-- mac menu/option panel, made by affli.
	if IsMacClient() then
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

	if GetLocale() == "koKR" then
		S:HandleButton(GameMenuButtonRatings)

		RatingMenuFrame:SetTemplate("Transparent")
		RatingMenuFrameHeader:Kill()
		S:HandleButton(RatingMenuButtonOkay)
	end

	OpacityFrame:StripTextures()
	OpacityFrame:SetTemplate("Transparent")

	S:HandleSliderFrame(OpacityFrameSlider)

	--Chat Config
	ChatConfigFrame:StripTextures()
	ChatConfigFrame:SetTemplate("Transparent")
	ChatConfigCategoryFrame:SetTemplate("Transparent")
	ChatConfigBackgroundFrame:SetTemplate("Transparent")

	ChatConfigCombatSettingsFilters:SetTemplate("Transparent")

	ChatConfigCombatSettingsFiltersScrollFrame:StripTextures()
	S:HandleScrollBar(ChatConfigCombatSettingsFiltersScrollFrameScrollBar)

	S:HandleButton(ChatConfigCombatSettingsFiltersDeleteButton)
	S:HandleButton(ChatConfigCombatSettingsFiltersAddFilterButton)
	ChatConfigCombatSettingsFiltersAddFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)
	S:HandleButton(ChatConfigCombatSettingsFiltersCopyFilterButton)
	ChatConfigCombatSettingsFiltersCopyFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)

	S:HandleNextPrevButton(ChatConfigMoveFilterUpButton, true)
	S:SquareButton_SetIcon(ChatConfigMoveFilterUpButton, "UP")
	ChatConfigMoveFilterUpButton:Size(26)
	ChatConfigMoveFilterUpButton:Point("TOPLEFT", ChatConfigCombatSettingsFilters, "BOTTOMLEFT", 3, -1)
	S:HandleNextPrevButton(ChatConfigMoveFilterDownButton, true)
	ChatConfigMoveFilterDownButton:Size(26)
	ChatConfigMoveFilterDownButton:Point("LEFT", ChatConfigMoveFilterUpButton, "RIGHT", 1, 0)

	CombatConfigColorsHighlighting:StripTextures()
	CombatConfigColorsColorizeUnitName:StripTextures()
	CombatConfigColorsColorizeSpellNames:StripTextures()

	CombatConfigColorsColorizeDamageNumber:StripTextures()
	CombatConfigColorsColorizeDamageSchool:StripTextures()
	CombatConfigColorsColorizeEntireLine:StripTextures()

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

		tab:HookScript("OnEnter", S.SetModifiedBackdrop)
		tab:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	S:HandleButton(ChatConfigFrameDefaultButton)
	S:HandleButton(CombatLogDefaultButton)
	S:HandleButton(ChatConfigFrameCancelButton)
	S:HandleButton(ChatConfigFrameOkayButton)

	S:SecureHook("ChatConfig_CreateCheckboxes", function(frame, checkBoxTable, checkBoxTemplate)
		local checkBoxNameString = frame:GetName().."CheckBox"
		if(checkBoxTemplate == "ChatConfigCheckBoxTemplate") then
			frame:SetTemplate("Transparent")
			for index, _ in ipairs(checkBoxTable) do
				local checkBoxName = checkBoxNameString..index
				local checkbox = _G[checkBoxName]
				if(not checkbox.backdrop) then
					checkbox:StripTextures()
					checkbox:CreateBackdrop()
					checkbox.backdrop:Point("TOPLEFT", 3, -1)
					checkbox.backdrop:Point("BOTTOMRIGHT", -3, 1)
					checkbox.backdrop:SetFrameLevel(checkbox:GetParent():GetFrameLevel() + 1)

					S:HandleCheckBox(_G[checkBoxName.."Check"])
				end
			end
		elseif(checkBoxTemplate == "ChatConfigCheckBoxWithSwatchTemplate") or (checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate") then
			frame:SetTemplate("Transparent")
			for index, _ in ipairs(checkBoxTable) do
				local checkBoxName = checkBoxNameString..index
				local checkbox = _G[checkBoxName]
				if(not checkbox.backdrop) then
					checkbox:StripTextures()

					checkbox:CreateBackdrop()
					checkbox.backdrop:Point("TOPLEFT", 3, -1)
					checkbox.backdrop:Point("BOTTOMRIGHT", -3, 1)
					checkbox.backdrop:SetFrameLevel(checkbox:GetParent():GetFrameLevel() + 1)

					S:HandleCheckBox(_G[checkBoxName.."Check"])

					if(checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate") then
						S:HandleCheckBox(_G[checkBoxName.."ColorClasses"])
					end
				end
			end
		end
	end)

	S:SecureHook("ChatConfig_CreateTieredCheckboxes", function(frame, checkBoxTable)
		local checkBoxNameString = frame:GetName().."CheckBox"
		for index, value in ipairs(checkBoxTable) do
			local checkBoxName = checkBoxNameString..index
			if(_G[checkBoxName]) then
				S:HandleCheckBox(_G[checkBoxName])
				if(value.subTypes) then
					local subCheckBoxNameString = checkBoxName.."_"
					for k, _ in ipairs(value.subTypes) do
						local subCheckBoxName = subCheckBoxNameString..k
						if(_G[subCheckBoxName]) then
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
			if(not swatch.backdrop) then
				swatch:StripTextures()

				swatch:CreateBackdrop()
				swatch.backdrop:Point("TOPLEFT", 3, -1)
				swatch.backdrop:Point("BOTTOMRIGHT", -3, 1)
				swatch.backdrop:SetFrameLevel(swatch:GetParent():GetFrameLevel() + 1)
			end
		end
	end)

	--DROPDOWN MENU
	hooksecurefunc("UIDropDownMenu_Initialize", function()
		for i = 1, UIDROPDOWNMENU_MAXLEVELS do
			_G["DropDownList"..i.."Backdrop"]:SetTemplate("Transparent")
			_G["DropDownList"..i.."MenuBackdrop"]:SetTemplate("Transparent")
			for j = 1, UIDROPDOWNMENU_MAXBUTTONS do
				_G["DropDownList"..i.."Button"..j]:SetFrameLevel(_G["DropDownList"..i.."Backdrop"]:GetFrameLevel() + 1)
				_G["DropDownList"..i.."Button"..j.."Highlight"]:SetTexture(1, 1, 1, 0.3)
			end
		end
	end)

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
	local interfacetab = {
		"InterfaceOptionsFrameTab1",
		"InterfaceOptionsFrameTab2",
	}
	for i = 1, #interfacetab do
		local itab = _G[interfacetab[i]]
		if(itab) then
			itab:StripTextures()
			S:HandleTab(itab)
			itab.backdrop:SetTemplate("Transparent")
			itab.backdrop:Point("TOPLEFT", 10, E.PixelMode and -4 or -6)
			itab.backdrop:Point("BOTTOMRIGHT", -10, 1)
		end
	end

	local maxButtons = (InterfaceOptionsFrameAddOns:GetHeight() - 8) / InterfaceOptionsFrameAddOns.buttonHeight
	for i = 1, maxButtons do
		local buttonToggle = _G["InterfaceOptionsFrameAddOnsButton" .. i .. "Toggle"]
		buttonToggle:SetNormalTexture("")
		buttonToggle.SetNormalTexture = E.noop
		buttonToggle:SetPushedTexture("")
		buttonToggle.SetPushedTexture = E.noop
		buttonToggle:SetHighlightTexture(nil)

		buttonToggle.Text = buttonToggle:CreateFontString(nil, "OVERLAY")
		buttonToggle.Text:FontTemplate(nil, 22)
		buttonToggle.Text:Point("CENTER")
		buttonToggle.Text:SetText("+")

		hooksecurefunc(buttonToggle, "SetNormalTexture", function(self, texture)
			if(find(texture, "MinusButton")) then
				self.Text:SetText("-")
			else
				self.Text:SetText("+")
			end
		end)
	end

	InterfaceOptionsFrameTab1:ClearAllPoints()
	InterfaceOptionsFrameTab1:Point("BOTTOMLEFT", InterfaceOptionsFrameCategories, "TOPLEFT", -11, -2)
	InterfaceOptionsFrameDefaults:ClearAllPoints()
	InterfaceOptionsFrameDefaults:Point("TOPLEFT", InterfaceOptionsFrameCategories, "BOTTOMLEFT", -1, -5)
	InterfaceOptionsFrameCancel:ClearAllPoints()
	InterfaceOptionsFrameCancel:Point("TOPRIGHT",InterfaceOptionsFramePanelContainer,"BOTTOMRIGHT",0,-6)
	InterfaceOptionsFrameCategoriesList:StripTextures()
	S:HandleScrollBar(InterfaceOptionsFrameCategoriesListScrollBar)
	InterfaceOptionsFrameAddOnsList:StripTextures()
	S:HandleScrollBar(InterfaceOptionsFrameAddOnsListScrollBar)
	OptionsFrameDefaults:ClearAllPoints()
	OptionsFrameDefaults:Point("TOPLEFT", OptionsFrame, "BOTTOMLEFT", 15, 36)

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

end

S:AddCallback("SkinMisc", LoadSkin)