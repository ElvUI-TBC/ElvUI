local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local hooksecurefunc = hooksecurefunc
local GetWhoInfo = GetWhoInfo
local GetGuildRosterInfo = GetGuildRosterInfo
local GUILDMEMBERS_TO_DISPLAY = GUILDMEMBERS_TO_DISPLAY
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.friends ~= true then return end

	-- Friends Frame
	FriendsFrame:StripTextures(true)
	FriendsFrame:CreateBackdrop("Transparent")
	FriendsFrame.backdrop:Point("TOPLEFT", 10, -12)
	FriendsFrame.backdrop:Point("BOTTOMRIGHT", -33, 76)

	S:HandleCloseButton(FriendsFrameCloseButton, FriendsFrame.backdrop)

	for i = 1, 5 do
		S:HandleTab(_G["FriendsFrameTab"..i])
	end

	-- Friends List Frame
	for i = 1, 3 do
		local Tab = _G["FriendsFrameToggleTab"..i]
		Tab:StripTextures()
		Tab:CreateBackdrop("Default", true)
		Tab.backdrop:Point("TOPLEFT", 3, -7)
		Tab.backdrop:Point("BOTTOMRIGHT", -2, -1)

		Tab:HookScript2("OnEnter", S.SetModifiedBackdrop)
		Tab:HookScript2("OnLeave", S.SetOriginalBackdrop)
	end

	for i = 1, 10 do
		S:HandleButtonHighlight(_G["FriendsFrameFriendButton"..i])
	end

	FriendsFrameFriendsScrollFrame:StripTextures()

	S:HandleScrollBar(FriendsFrameFriendsScrollFrameScrollBar)

	S:HandleButton(FriendsFrameAddFriendButton)
	FriendsFrameAddFriendButton:Point("BOTTOMLEFT", 17, 102)

	S:HandleButton(FriendsFrameSendMessageButton)

	S:HandleButton(FriendsFrameRemoveFriendButton)
	FriendsFrameRemoveFriendButton:Point("TOP", FriendsFrameAddFriendButton, "BOTTOM", 0, -2)

	S:HandleButton(FriendsFrameGroupInviteButton)
	FriendsFrameGroupInviteButton:Point("TOP", FriendsFrameSendMessageButton, "BOTTOM", 0, -2)

	-- Ignore List Frame
	FriendsFrameIgnoreScrollFrame:StripTextures()

	S:HandleScrollBar(FriendsFrameIgnoreScrollFrameScrollBar)

	for i = 1, 2 do
		local Tab = _G["IgnoreFrameToggleTab"..i]
		Tab:StripTextures()
		Tab:CreateBackdrop("Default", true)
		Tab.backdrop:Point("TOPLEFT", 3, -7)
		Tab.backdrop:Point("BOTTOMRIGHT", -2, -1)

		Tab:HookScript2("OnEnter", S.SetModifiedBackdrop)
		Tab:HookScript2("OnLeave", S.SetOriginalBackdrop)
	end

	S:HandleButton(FriendsFrameIgnorePlayerButton)
	S:HandleButton(FriendsFrameStopIgnoreButton)

	for i = 1, 20 do
		S:HandleButtonHighlight(_G["FriendsFrameIgnoreButton"..i])
	end

	-- Who Frame
	WhoFrameColumnHeader3:ClearAllPoints()
	WhoFrameColumnHeader3:Point("TOPLEFT", 20, -70)

	WhoFrameColumnHeader4:ClearAllPoints()
	WhoFrameColumnHeader4:Point("LEFT", WhoFrameColumnHeader3, "RIGHT", -2, -0)
	WhoFrameColumnHeader4:Width(48)

	WhoFrameColumnHeader1:ClearAllPoints()
	WhoFrameColumnHeader1:Point("LEFT", WhoFrameColumnHeader4, "RIGHT", -2, -0)
	WhoFrameColumnHeader1:Width(105)

	WhoFrameColumnHeader2:ClearAllPoints()
	WhoFrameColumnHeader2:Point("LEFT", WhoFrameColumnHeader1, "RIGHT", -2, -0)

	for i = 1, 4 do
		_G["WhoFrameColumnHeader"..i]:StripTextures()
		_G["WhoFrameColumnHeader"..i]:StyleButton()
	end

	S:HandleDropDownBox(WhoFrameDropDown)

	for i = 1, 17 do
		local button = _G["WhoFrameButton"..i]
		local level = _G["WhoFrameButton"..i.."Level"]
		local name = _G["WhoFrameButton"..i.."Name"]

		button.icon = button:CreateTexture("$parentIcon", "ARTWORK")
		button.icon:Point("LEFT", 45, 0)
		button.icon:Size(15)
		button.icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")

		button:CreateBackdrop("Default", true)
		button.backdrop:SetAllPoints(button.icon)
		S:HandleButtonHighlight(button)

		level:ClearAllPoints()
		level:Point("TOPLEFT", 12, -2)

		name:Size(100, 14)
		name:ClearAllPoints()
		name:Point("LEFT", 85, 0)

		_G["WhoFrameButton"..i.."Class"]:Hide()
	end

	WhoListScrollFrame:StripTextures()

	S:HandleScrollBar(WhoListScrollFrameScrollBar)

	S:HandleEditBox(WhoFrameEditBox)
	WhoFrameEditBox:Point("BOTTOMLEFT", 17, 108)
	WhoFrameEditBox:Size(326, 18)

	S:HandleButton(WhoFrameWhoButton)
	WhoFrameWhoButton:ClearAllPoints()
	WhoFrameWhoButton:Point("BOTTOMLEFT", 16, 82)

	S:HandleButton(WhoFrameAddFriendButton)
	WhoFrameAddFriendButton:Point("LEFT", WhoFrameWhoButton, "RIGHT", 3, 0)
	WhoFrameAddFriendButton:Point("RIGHT", WhoFrameGroupInviteButton, "LEFT", -3, 0)

	S:HandleButton(WhoFrameGroupInviteButton)

	hooksecurefunc("WhoList_Update", function()
		local whoOffset = FauxScrollFrame_GetOffset(WhoListScrollFrame)
		local button, nameText, levelText, classText, variableText
		local _, guild, level, race, zone, classFileName
		local classTextColor, levelTextColor
		local index, columnTable

		local playerZone = GetRealZoneText()
		local playerGuild = GetGuildInfo("player")

		for i = 1, WHOS_TO_DISPLAY, 1 do
			index = whoOffset + i
			button = _G["WhoFrameButton"..i]
			nameText = _G["WhoFrameButton"..i.."Name"]
			levelText = _G["WhoFrameButton"..i.."Level"]
			classText = _G["WhoFrameButton"..i.."Class"]
			variableText = _G["WhoFrameButton"..i.."Variable"]

			_, guild, level, race, _, zone, classFileName = GetWhoInfo(index)

			classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classFileName] or RAID_CLASS_COLORS[classFileName]
			levelTextColor = GetQuestDifficultyColor(level)

			if classFileName then
				button.icon:Show()
				button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]))

				nameText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
				levelText:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b)

				if zone == playerZone then zone = "|cff00ff00"..zone end
				if guild == playerGuild then guild = "|cff00ff00"..guild end
				if race == E.myrace then race = "|cff00ff00"..race end

				columnTable = {zone, guild, race}

				variableText:SetText(columnTable[UIDropDownMenu_GetSelectedID(WhoFrameDropDown)])
			else
				button.icon:Hide()
			end
		end
	end)

	-- Guild Frame
	GuildFrameColumnHeader3:ClearAllPoints()
	GuildFrameColumnHeader3:Point("TOPLEFT", 20, -70)

	GuildFrameColumnHeader4:ClearAllPoints()
	GuildFrameColumnHeader4:Point("LEFT", GuildFrameColumnHeader3, "RIGHT", -2, -0)
	GuildFrameColumnHeader4:Width(48)

	GuildFrameColumnHeader1:ClearAllPoints()
	GuildFrameColumnHeader1:Point("LEFT", GuildFrameColumnHeader4, "RIGHT", -2, -0)
	GuildFrameColumnHeader1:Width(105)

	GuildFrameColumnHeader2:ClearAllPoints()
	GuildFrameColumnHeader2:Point("LEFT", GuildFrameColumnHeader1, "RIGHT", -2, -0)
	GuildFrameColumnHeader2:Width(127)

	for i = 1, GUILDMEMBERS_TO_DISPLAY do
		local button = _G["GuildFrameButton"..i]
		local name = _G["GuildFrameButton"..i.."Name"]
		local level = _G["GuildFrameButton"..i.."Level"]

		button.icon = button:CreateTexture("$parentIcon", "ARTWORK")
		button.icon:Point("LEFT", 48, 0)
		button.icon:Size(15)
		button.icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")

		button:CreateBackdrop("Default", true)
		button.backdrop:SetAllPoints(button.icon)
		S:HandleButtonHighlight(button)

		level:ClearAllPoints()
		level:Point("TOPLEFT", 10, -1)

		name:Size(100, 14)
		name:ClearAllPoints()
		name:Point("LEFT", 85, 0)

		_G["GuildFrameButton"..i.."Class"]:Hide()

		S:HandleButtonHighlight(_G["GuildFrameGuildStatusButton"..i])

		_G["GuildFrameGuildStatusButton"..i.."Name"]:Point("TOPLEFT", 14, 0)
	end

	hooksecurefunc("GuildStatus_Update", function()
		local _, level, zone, online, classFileName
		local button, buttonText, classTextColor, levelTextColor
		local playerZone = GetRealZoneText()

		if FriendsFrame.playerStatusFrame then
			for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
				button = _G["GuildFrameButton"..i]
				_, _, _, level, _, zone, _, _, online, _, classFileName = GetGuildRosterInfo(button.guildIndex)

				if classFileName then
					if online then
						classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classFileName] or RAID_CLASS_COLORS[classFileName]
						levelTextColor = GetQuestDifficultyColor(level)

						buttonText = _G["GuildFrameButton"..i.."Name"]
						buttonText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
						buttonText = _G["GuildFrameButton"..i.."Level"]
						buttonText:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b)
						buttonText = _G["GuildFrameButton"..i.."Zone"]

						if zone == playerZone then
							buttonText:SetTextColor(0, 1, 0)
						end
					end

					button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]))
				end
			end
		else
			for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
				button = _G["GuildFrameGuildStatusButton"..i]
				_, _, _, _, _, _, _, _, online, _, classFileName = GetGuildRosterInfo(button.guildIndex)

				if classFileName then
					if online then
						classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classFileName] or RAID_CLASS_COLORS[classFileName]
						_G["GuildFrameGuildStatusButton"..i.."Name"]:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
						_G["GuildFrameGuildStatusButton"..i.."Online"]:SetTextColor(1.0, 1.0, 1.0)
					end
				end
			end
		end
	end)

	GuildFrameLFGFrame:StripTextures()
	GuildFrameLFGFrame:SetTemplate("Transparent")

	S:HandleCheckBox(GuildFrameLFGButton)

	for i = 1, 4 do
		_G["GuildFrameColumnHeader"..i]:StripTextures()
		_G["GuildFrameColumnHeader"..i]:StyleButton()
		_G["GuildFrameGuildStatusColumnHeader"..i]:StripTextures()
		_G["GuildFrameGuildStatusColumnHeader"..i]:StyleButton()
	end

	GuildListScrollFrame:StripTextures()
	S:HandleScrollBar(GuildListScrollFrameScrollBar)

	S:HandleNextPrevButton(GuildFrameGuildListToggleButton)

	S:HandleButton(GuildFrameGuildInformationButton)
	S:HandleButton(GuildFrameAddMemberButton)
	S:HandleButton(GuildFrameControlButton)

	-- Member Detail Frame
	GuildMemberDetailFrame:StripTextures()
	GuildMemberDetailFrame:CreateBackdrop("Transparent")
	GuildMemberDetailFrame:Point("TOPLEFT", GuildFrame, "TOPRIGHT", -31, -13)

	S:HandleCloseButton(GuildMemberDetailCloseButton, GuildMemberDetailFrame.backdrop)

	S:HandleButton(GuildMemberRemoveButton)
	GuildMemberRemoveButton:Point("BOTTOMLEFT", 3, 3)

	S:HandleButton(GuildMemberGroupInviteButton)
	GuildMemberGroupInviteButton:Point("LEFT", GuildMemberRemoveButton, "RIGHT", 13, 0)

	S:HandleNextPrevButton(GuildFramePromoteButton, true)
	GuildFramePromoteButton:SetHitRectInsets(0, 0, 0, 0)

	S:HandleNextPrevButton(GuildFrameDemoteButton, true)
	GuildFrameDemoteButton:SetHitRectInsets(0, 0, 0, 0)
	GuildFrameDemoteButton:Point("LEFT", GuildFramePromoteButton, "RIGHT", 2, 0)

	GuildMemberNoteBackground:StripTextures()
	GuildMemberNoteBackground:CreateBackdrop("Default")
	GuildMemberNoteBackground.backdrop:Point("TOPLEFT", 0, -2)
	GuildMemberNoteBackground.backdrop:Point("BOTTOMRIGHT", 0, -1)

	GuildMemberOfficerNoteBackground:StripTextures()
	GuildMemberOfficerNoteBackground:CreateBackdrop("Default")
	GuildMemberOfficerNoteBackground.backdrop:Point("TOPLEFT", 0, -2)
	GuildMemberOfficerNoteBackground.backdrop:Point("BOTTOMRIGHT", 0, -1)

	GuildFrameNotesLabel:Point("TOPLEFT", GuildFrame, "TOPLEFT", 23, -340)
	GuildFrameNotesText:Point("TOPLEFT", GuildFrameNotesLabel, "BOTTOMLEFT", 0, -6)

	GuildMOTDEditButton:CreateBackdrop("Default")
	GuildMOTDEditButton.backdrop:Point("TOPLEFT", -7, 3)
	GuildMOTDEditButton.backdrop:Point("BOTTOMRIGHT", 7, -2)
	GuildMOTDEditButton:SetHitRectInsets(-7, -7, -3, -2)

	-- Info Frame
	GuildInfoFrame:StripTextures()
	GuildInfoFrame:CreateBackdrop("Transparent")
	GuildInfoFrame.backdrop:Point("TOPLEFT", 3, -6)
	GuildInfoFrame.backdrop:Point("BOTTOMRIGHT", -2, 3)
	GuildInfoFrame:Point("TOPLEFT", GuildControlPopupFrame, "TOPLEFT", 2, 0)

	GuildInfoTextBackground:SetTemplate("Default")
	S:HandleScrollBar(GuildInfoFrameScrollFrameScrollBar)

	S:HandleCloseButton(GuildInfoCloseButton)

	S:HandleButton(GuildInfoSaveButton)
	GuildInfoSaveButton:Point("BOTTOMLEFT", 104, 11)

	S:HandleButton(GuildInfoCancelButton)
	GuildInfoCancelButton:Point("LEFT", GuildInfoSaveButton, "RIGHT", 3, 0)

	S:HandleButton(GuildInfoGuildEventButton)
	GuildInfoGuildEventButton:Point("RIGHT", GuildInfoSaveButton, "LEFT", -28, 0)

	-- GuildEventLog Frame
	GuildEventLogFrame:StripTextures()
	GuildEventLogFrame:CreateBackdrop("Transparent")
	GuildEventLogFrame.backdrop:Point("TOPLEFT", 3, -6)
	GuildEventLogFrame.backdrop:Point("BOTTOMRIGHT", -2, 5)
	GuildEventLogFrame:Point("TOPLEFT", GuildControlPopupFrame, "TOPLEFT", 2, 0)

	GuildEventFrame:SetTemplate("Default")

	S:HandleScrollBar(GuildEventLogScrollFrameScrollBar)
	S:HandleCloseButton(GuildEventLogCloseButton)

	GuildEventLogCancelButton:Point("BOTTOMRIGHT", -9, 9)
	S:HandleButton(GuildEventLogCancelButton)

	-- Control Frame
	GuildControlPopupFrame:StripTextures()
	GuildControlPopupFrame:CreateBackdrop("Transparent")
	GuildControlPopupFrame.backdrop:Point("TOPLEFT", 3, -6)
	GuildControlPopupFrame.backdrop:Point("BOTTOMRIGHT", -27, 27)
	GuildControlPopupFrame:Point("TOPLEFT", GuildFrame, "TOPRIGHT", -35, -6)

	S:HandleDropDownBox(GuildControlPopupFrameDropDown, 185)
	GuildControlPopupFrameDropDownButton:Width(18)

	local function SkinPlusMinus(button, minus)
		button:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
		button.SetNormalTexture = E.noop

		button:SetPushedTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
		button.SetPushedTexture = E.noop

		button:SetHighlightTexture("")
		button.SetHighlightTexture = E.noop

		button:SetDisabledTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
		button.SetDisabledTexture = E.noop
		button:GetDisabledTexture():SetDesaturated(true)

		if minus then
			button:GetNormalTexture():SetTexCoord(0.540, 0.965, 0.085, 0.920)
			button:GetPushedTexture():SetTexCoord(0.540, 0.965, 0.085, 0.920)
			button:GetDisabledTexture():SetTexCoord(0.540, 0.965, 0.085, 0.920)
		else
			button:GetNormalTexture():SetTexCoord(0.040, 0.465, 0.085, 0.920)
			button:GetPushedTexture():SetTexCoord(0.040, 0.465, 0.085, 0.920)
			button:GetDisabledTexture():SetTexCoord(0.040, 0.465, 0.085, 0.920)
		end
	end

	SkinPlusMinus(GuildControlPopupFrameAddRankButton)
	GuildControlPopupFrameAddRankButton:Point("LEFT", GuildControlPopupFrameDropDown, "RIGHT", -5, 3)

	SkinPlusMinus(GuildControlPopupFrameRemoveRankButton, true)
	GuildControlPopupFrameRemoveRankButton:Point("LEFT", GuildControlPopupFrameAddRankButton, "RIGHT", 4, 0)

	S:HandleEditBox(GuildControlPopupFrameEditBox)
	GuildControlPopupFrameEditBox.backdrop:Point("TOPLEFT", 0, -5)
	GuildControlPopupFrameEditBox.backdrop:Point("BOTTOMRIGHT", 0, 5)

	for i = 1, 17 do
		local checkbox = _G["GuildControlPopupFrameCheckbox"..i]
		if checkbox then
			S:HandleCheckBox(checkbox)
		end
	end

	S:HandleEditBox(GuildControlWithdrawGoldEditBox)
	GuildControlWithdrawGoldEditBox.backdrop:Point("TOPLEFT", 0, -5)
	GuildControlWithdrawGoldEditBox.backdrop:Point("BOTTOMRIGHT", 0, 5)

	for i = 1, MAX_GUILDBANK_TABS do
		local tab = _G["GuildBankTabPermissionsTab"..i]

		tab:StripTextures()
		tab:CreateBackdrop("Default")
		tab.backdrop:Point("TOPLEFT", 3, -10)
		tab.backdrop:Point("BOTTOMRIGHT", -2, 4)
	end

	GuildControlPopupFrameTabPermissions:SetTemplate("Default")

	S:HandleCheckBox(GuildControlTabPermissionsViewTab)
	S:HandleCheckBox(GuildControlTabPermissionsDepositItems)
	S:HandleCheckBox(GuildControlTabPermissionsUpdateText)

	S:HandleEditBox(GuildControlWithdrawItemsEditBox)
	GuildControlWithdrawItemsEditBox.backdrop:Point("TOPLEFT", 0, -5)
	GuildControlWithdrawItemsEditBox.backdrop:Point("BOTTOMRIGHT", 0, 5)

	S:HandleButton(GuildControlPopupAcceptButton)
	S:HandleButton(GuildControlPopupFrameCancelButton)

	-- Channel Frame
	ChannelFrameVerticalBar:Kill()

	S:HandleCheckBox(ChannelFrameAutoJoinParty)
	S:HandleCheckBox(ChannelFrameAutoJoinBattleground)

	S:HandleButton(ChannelFrameNewButton)

	ChannelListScrollFrame:StripTextures()
	S:HandleScrollBar(ChannelListScrollFrameScrollBar)

	for i = 1, MAX_DISPLAY_CHANNEL_BUTTONS do
		local button = _G["ChannelButton"..i]
		local collapsed = _G["ChannelButton"..i.."Collapsed"]

		button:StripTextures()
		S:HandleButtonHighlight(button)

		collapsed:SetTextColor(1, 1, 1)
		collapsed:FontTemplate(nil, 22)
	end

	for i = 1, 22 do
		S:HandleButtonHighlight(_G["ChannelMemberButton"..i])
	end

	ChannelRosterScrollFrame:StripTextures()
	S:HandleScrollBar(ChannelRosterScrollFrameScrollBar)

	ChannelFrameDaughterFrame:StripTextures()
	ChannelFrameDaughterFrame:SetTemplate("Transparent")

	S:HandleEditBox(ChannelFrameDaughterFrameChannelName)
	S:HandleEditBox(ChannelFrameDaughterFrameChannelPassword)

	S:HandleCloseButton(ChannelFrameDaughterFrameDetailCloseButton)

	S:HandleButton(ChannelFrameDaughterFrameCancelButton)
	S:HandleButton(ChannelFrameDaughterFrameOkayButton)

	-- Raid Frame
	S:HandleButton(RaidFrameConvertToRaidButton)
	S:HandleButton(RaidFrameRaidInfoButton)

	-- Raid Info Frame
	RaidInfoFrame:StripTextures(true)
	RaidInfoFrame:SetTemplate("Transparent")

	RaidInfoFrame:SetScript("OnShow", function()
		if GetNumRaidMembers() > 0 then
			RaidInfoFrame:Point("TOPLEFT", RaidFrame, "TOPRIGHT", -14, -12)
		else
			RaidInfoFrame:Point("TOPLEFT", RaidFrame, "TOPRIGHT", -34, -12)
		end
	end)

	S:HandleCloseButton(RaidInfoCloseButton, RaidInfoFrame)

	RaidInfoScrollFrame:StripTextures()
	S:HandleScrollBar(RaidInfoScrollFrameScrollBar)
end

S:AddCallback("Friends", LoadSkin)