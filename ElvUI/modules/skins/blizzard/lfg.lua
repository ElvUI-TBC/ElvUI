local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local pairs, select, unpack = pairs, select, unpack

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfg ~= true then return end

	LFGParentFrame:StripTextures(true)
	LFGParentFrame:CreateBackdrop("Transparent")
	LFGParentFrame.backdrop:Point("TOPLEFT", 10, -12)
	LFGParentFrame.backdrop:Point("BOTTOMRIGHT", -31, 75)

	local lfgButtons = {
		"LFGWizardFrameLFGButton",
		"LFGWizardFrameLFMButton",
		"LFGFrameClearAllButton",
		"LFGFrameDoneButton",
		"LFMFrameSearchButton",
		"LFMFrameSendMessageButton",
		"LFMFrameGroupInviteButton"
	}

	for _, button in pairs(lfgButtons) do
		_G[button]:StripTextures()
		S:HandleButton(_G[button])
	end

	LFMFrameGroupInviteButton:Point("BOTTOMRIGHT", -40, 85)
	LFGFrameDoneButton:Point("BOTTOMRIGHT", -40, 85)

	for i = 1, 2 do
		local tab = _G["LFGParentFrameTab"..i]

		S:HandleTab(tab)
	end

	for i = 1, LFGParentFrame:GetNumChildren() do
		local child = select(i, LFGParentFrame:GetChildren())

		if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
			S:HandleCloseButton(child)
		end
	end

	for i = 1, 3 do
		local dropdownType = _G["LFGFrameTypeDropDown"..i]
		local dropdownName = _G["LFGFrameNameDropDown"..i]
		local searchBg = _G["LFGSearchBg"..i]
		local searchIcon = _G["LFGSearchIcon"..i]

		S:HandleDropDownBox(dropdownType, 250)
		S:HandleDropDownBox(dropdownName, 250)

		S:HandleIcon(searchBg)
		searchBg:SetTexCoord(0.14, 0.78, 0.1, 0.74)
		searchBg:SetDrawLayer("ARTWORK")
		searchBg:Size(47)
		searchBg:ClearAllPoints()
		searchBg:Point("LEFT", dropdownType, "RIGHT", 10, -10)

		searchIcon:SetAllPoints(searchBg)
		searchIcon:SetTexCoord(0.05, 0.77, 0.05, 0.68)
		searchIcon:SetDrawLayer("ARTWORK")
	end

	S:HandleIcon(LookingForGroupIcon)
	LookingForGroupIcon:SetDrawLayer("ARTWORK")

	S:HandleIcon(LookingForMoreIcon)
	LookingForMoreIcon:SetDrawLayer("ARTWORK")

	S:HandleEditBox(LFGComment)
	LFGComment:Size(323, 19)
	LFGComment:Point("BOTTOMLEFT", LFGParentFrame, "BOTTOMLEFT", 20, 110)
	LFGComment.SetPoint = E.noop

	AutoJoinBackground:StripTextures()
	AddMemberBackground:StripTextures()

	S:HandleCheckBox(AutoJoinCheckButton)
	AutoJoinCheckButton:Point("LEFT", -35, 0)

	-- Looking For More
	S:HandleCheckBox(AutoAddMembersCheckButton)
	AutoAddMembersCheckButton:Point("LEFT", -35, 0)

	S:HandleDropDownBox(LFMFrameTypeDropDown, 155)
	LFMFrameTypeDropDown:Point("TOPLEFT", 0, -80)
	LFMFrameTypeDropDownText:ClearAllPoints()
	LFMFrameTypeDropDownText:Point("RIGHT", LFMFrameTypeDropDownButton, "LEFT", -20, 0)

	S:HandleDropDownBox(LFMFrameNameDropDown, 220)
	LFMFrameNameDropDown:Point("LEFT", LFMFrameTypeDropDown, "RIGHT", -25, 0)

	for i = 1, 4 do
		_G["LFMFrameColumnHeader"..i]:StripTextures()
		_G["LFMFrameColumnHeader"..i]:StyleButton()
		_G["LFMFrameColumnHeader"..i]:ClearAllPoints()
	end

	LFMFrameColumnHeader3:Point("TOPLEFT", 25, -110)

	LFMFrameColumnHeader4:Point("LEFT", LFMFrameColumnHeader3, "RIGHT", -2, -0)
	LFMFrameColumnHeader4:Width(48)

	LFMFrameColumnHeader1:Point("LEFT", LFMFrameColumnHeader4, "RIGHT", -2, -0)
	LFMFrameColumnHeader1:Width(105)

	LFMFrameColumnHeader2:Point("LEFT", LFMFrameColumnHeader1, "RIGHT", -2, -0)
	LFMFrameColumnHeader2:Width(127)

	for i = 1, 14 do
		local button = _G["LFMFrameButton"..i]
		local name = _G["LFMFrameButton"..i.."Name"]
		local level = _G["LFMFrameButton"..i.."Level"]
		local class = _G["LFMFrameButton"..i.."Class"]
		local zone = _G["LFMFrameButton"..i.."Zone"]

		button.icon = button:CreateTexture("$parentIcon", "ARTWORK")
		button.icon:Point("LEFT", 35, 0)
		button.icon:Size(15)
		button.icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")

		button:CreateBackdrop("Default", true)
		button.backdrop:SetAllPoints(button.icon)
		S:HandleButtonHighlight(button)

		level:ClearAllPoints()
		level:Point("TOPLEFT", 0, -1)

		name:Size(100, 14)
		name:ClearAllPoints()
		name:Point("LEFT", 76, 0)

		class:Hide()
	end

	hooksecurefunc("LFMFrame_Update", function()
		local selectedLFMType = UIDropDownMenu_GetSelectedID(LFMFrameTypeDropDown)
		local selectedLFMName = UIDropDownMenu_GetSelectedID(LFMFrameNameDropDown)
		local numResults, totalCount = GetNumLFGResults(selectedLFMType, selectedLFMName)
		local scrollOffset = FauxScrollFrame_GetOffset(LFMListScrollFrame)
		local resultIndex
		local _, level, zone, classFileName
		local button, classTextColor, levelTextColor
		local playerZone = GetRealZoneText()

		for i = 1, LFGS_TO_DISPLAY, 1 do
			resultIndex = scrollOffset + i
			button = _G["LFMFrameButton"..i]

			if resultIndex <= numResults then
				_, level, zone, _, _, _, _, _, _, _, classFileName = GetLFGResults(selectedLFMType, selectedLFMName, resultIndex)
				classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classFileName] or RAID_CLASS_COLORS[classFileName]
				levelTextColor = GetQuestDifficultyColor(level)

				if classFileName then
					_G["LFMFrameButton"..i.."Name"]:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
					_G["LFMFrameButton"..i.."Level"]:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b)

					if zone == playerZone then
						_G["LFMFrameButton"..i.."Zone"]:SetTextColor(0, 1, 0)
					end

					button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]))
				end
			end
		end
	end)
end

S:AddCallback("LFG", LoadSkin)