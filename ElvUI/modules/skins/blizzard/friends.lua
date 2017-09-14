local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local hooksecurefunc = hooksecurefunc
local GetWhoInfo = GetWhoInfo
local GetGuildRosterInfo = GetGuildRosterInfo
local GUILDMEMBERS_TO_DISPLAY = GUILDMEMBERS_TO_DISPLAY
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS

function S:LoadFriendsSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.friends ~= true then return end

	-- Friends Frame
	FriendsFrame:StripTextures(true)
	FriendsFrame:CreateBackdrop("Transparent")
	FriendsFrame.backdrop:Point("TOPLEFT", 10, -12)
	FriendsFrame.backdrop:Point("BOTTOMRIGHT", -33, 76)

	S:HandleCloseButton(FriendsFrameCloseButton)

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

	local r, g, b = 0.8, 0.8, 0.8
	local function StyleButton(f, scale, scale2)
		f:SetHighlightTexture(nil)
		local width, height = (f:GetWidth() * (scale or 0.5)), (f:GetHeight() * (scale2 or 0.9))

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

	for i = 1, 10 do
		StyleButton(_G["FriendsFrameFriendButton"..i])
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
	for i = 1, 2 do
		local Tab = _G["IgnoreFrameToggleTab"..i]
		Tab:StripTextures()
		Tab:CreateBackdrop("Default", true)
		Tab.backdrop:Point("TOPLEFT", 3, -7)
		Tab.backdrop:Point("BOTTOMRIGHT", -2, -1)

		Tab:HookScript("OnEnter", S.SetModifiedBackdrop)
		Tab:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	S:HandleButton(FriendsFrameIgnorePlayerButton)
	S:HandleButton(FriendsFrameStopIgnoreButton)

	for i = 1, 20 do
		StyleButton(_G["FriendsFrameIgnoreButton"..i])
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
		_G["WhoFrameColumnHeader" .. i]:StripTextures()
		_G["WhoFrameColumnHeader" .. i]:StyleButton()
	end

	S:HandleDropDownBox(WhoFrameDropDown)

	for i = 1, 17 do
		local button = _G["WhoFrameButton" .. i]
		local level = _G["WhoFrameButton" .. i .. "Level"]
		local name = _G["WhoFrameButton" .. i .. "Name"]

		button.icon = button:CreateTexture("$parentIcon", "ARTWORK")
		button.icon:Point("LEFT", 45, 0)
		button.icon:Size(15)
		button.icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")

		button:CreateBackdrop("Default", true)
		button.backdrop:SetAllPoints(button.icon)
		StyleButton(button)

		level:ClearAllPoints()
		level:Point("TOPLEFT", 12, -2)

		name:Size(100, 14)
		name:ClearAllPoints()
		name:Point("LEFT", 85, 0)

		_G["WhoFrameButton" .. i .. "Class"]:Hide()
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
		local playerZone = GetRealZoneText()
		local playerGuild = GetGuildInfo("player")
		local playerRace = UnitRace("player")

		for i = 1, WHOS_TO_DISPLAY, 1 do
			local index = whoOffset + i
			local button = _G["WhoFrameButton"..i]
			local nameText = _G["WhoFrameButton"..i.."Name"]
			local levelText = _G["WhoFrameButton"..i.."Level"]
			local classText = _G["WhoFrameButton"..i.."Class"]
			local variableText = _G["WhoFrameButton"..i.."Variable"]

			local _, guild, level, race, _, zone, classFileName = GetWhoInfo(index)

			local classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classFileName] or RAID_CLASS_COLORS[classFileName]
			local levelTextColor = GetQuestDifficultyColor(level)

			if classFileName then
				button.icon:Show()
				button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]))

				nameText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
				levelText:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b)

				if zone == playerZone then
					zone = "|cff00ff00"..zone
				end
				if guild == playerGuild then
					guild = "|cff00ff00"..guild
				end
				if race == playerRace then
					race = "|cff00ff00"..race
				end

				local columnTable = {zone, guild, race}

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
		local name = _G["GuildFrameButton" .. i .. "Name"]
		local level = _G["GuildFrameButton" .. i .. "Level"]

		button.icon = button:CreateTexture("$parentIcon", "ARTWORK")
		button.icon:Point("LEFT", 48, 0)
		button.icon:Size(15)
		button.icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")

		button:CreateBackdrop("Default", true)
		button.backdrop:SetAllPoints(button.icon)
		StyleButton(button)

		level:ClearAllPoints()
		level:Point("TOPLEFT", 10, -1)

		name:Size(100, 14)
		name:ClearAllPoints()
		name:Point("LEFT", 85, 0)

		_G["GuildFrameButton" .. i .. "Class"]:Hide()

		StyleButton(_G["GuildFrameGuildStatusButton" .. i])

		_G["GuildFrameGuildStatusButton" .. i .. "Name"]:Point("TOPLEFT", 14, 0)
	end

	hooksecurefunc("GuildStatus_Update", function()
		local _, level, zone, online, classFileName
		local button, buttonText, classTextColor, levelTextColor
		local playerZone = GetRealZoneText()

		if(FriendsFrame.playerStatusFrame) then
			for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
				button = _G["GuildFrameButton" .. i]
				_, _, _, level, _, zone, _, _, online, _, classFileName = GetGuildRosterInfo(button.guildIndex)
				if classFileName then
					if online then
						classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classFileName] or RAID_CLASS_COLORS[classFileName]
						levelTextColor = GetQuestDifficultyColor(level)

						buttonText = _G["GuildFrameButton" .. i .. "Name"]
						buttonText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
						buttonText = _G["GuildFrameButton" .. i .. "Level"]
						buttonText:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b)
						buttonText = _G["GuildFrameButton" .. i .. "Zone"]
						if zone == playerZone then
							buttonText:SetTextColor(0, 1, 0)
						end
					end
					button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]))
				end
			end
		else
			local classFileName
			for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
				button = _G["GuildFrameGuildStatusButton" .. i]
				_, _, _, _, _, _, _, _, online, _, classFileName = GetGuildRosterInfo(button.guildIndex)
				if classFileName then
					if online then
						classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classFileName] or RAID_CLASS_COLORS[classFileName]
						_G["GuildFrameGuildStatusButton" .. i .. "Name"]:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
						_G["GuildFrameGuildStatusButton" .. i .. "Online"]:SetTextColor(1.0, 1.0, 1.0)
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

	S:HandleCloseButton(GuildMemberDetailCloseButton)

	S:HandleButton(GuildMemberRemoveButton)
	GuildMemberRemoveButton:Point("BOTTOMLEFT", 8, 7)
	S:HandleButton(GuildMemberGroupInviteButton)
	GuildMemberGroupInviteButton:Point("LEFT", GuildMemberRemoveButton, "RIGHT", 3, 0)

	S:HandleNextPrevButton(GuildFramePromoteButton, true)
	S:HandleNextPrevButton(GuildFrameDemoteButton, true)
	GuildFrameDemoteButton:Point("LEFT", GuildFramePromoteButton, "RIGHT", 2, 0)

	GuildMemberNoteBackground:SetTemplate("Default")
	GuildMemberOfficerNoteBackground:SetTemplate("Default")

	-- Info Frame
	GuildInfoFrame:StripTextures()
	GuildInfoFrame:CreateBackdrop("Transparent")
	GuildInfoFrame.backdrop:Point("TOPLEFT", 3, -6)
	GuildInfoFrame.backdrop:Point("BOTTOMRIGHT", -2, 3)

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

	S:HandleDropDownBox(GuildControlPopupFrameDropDown, 185)
	GuildControlPopupFrameDropDownButton:Size(16)

	local function SkinPlusMinus(f, minus)
		f:SetNormalTexture("")
		f.SetNormalTexture = E.noop
		f:SetPushedTexture("")
		f.SetPushedTexture = E.noop
		f:SetHighlightTexture("")
		f.SetHighlightTexture = E.noop
		f:SetDisabledTexture("")
		f.SetDisabledTexture = E.noop

		f.Text = f:CreateFontString(nil, "OVERLAY")
		f.Text:FontTemplate(nil, 22)
		f.Text:Point("LEFT", 5, 0)
		if minus then
			f.Text:SetText("-")
		else
			f.Text:SetText("+")
		end
	end

	GuildControlPopupFrameAddRankButton:Point("LEFT", GuildControlPopupFrameDropDown, "RIGHT", -8, 3)
	SkinPlusMinus(GuildControlPopupFrameAddRankButton)
	SkinPlusMinus(GuildControlPopupFrameRemoveRankButton, true)

	S:HandleEditBox(GuildControlPopupFrameEditBox)
	GuildControlPopupFrameEditBox.backdrop:Point("TOPLEFT", 0, -5)
	GuildControlPopupFrameEditBox.backdrop:Point("BOTTOMRIGHT", 0, 5)

	for i = 1, 17 do
		local Checkbox = _G["GuildControlPopupFrameCheckbox"..i]
		if Checkbox then
			S:HandleCheckBox(Checkbox)
		end
	end

	S:HandleEditBox(GuildControlWithdrawGoldEditBox)
	GuildControlWithdrawGoldEditBox.backdrop:Point("TOPLEFT", 0, -5)
	GuildControlWithdrawGoldEditBox.backdrop:Point("BOTTOMRIGHT", 0, 5)

	for i = 1, MAX_GUILDBANK_TABS do
		local tab = _G["GuildBankTabPermissionsTab" .. i]

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
		_G["ChannelButton"..i]:StripTextures()
		StyleButton(_G["ChannelButton"..i], 0.55)

		_G["ChannelButton"..i.."Collapsed"]:SetTextColor(1, 1, 1)
	end

	for i = 1, 22 do
		StyleButton(_G["ChannelMemberButton"..i], 0.55)
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

S:AddCallback("Friends", S.LoadFriendsSkin)