local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local find = string.find

function S:LoadLFGSkin()
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

	local lfgDropDowns = {
		"TypeDropDown1",
		"NameDropDown1",
		"TypeDropDown2",
		"NameDropDown2",
		"TypeDropDown3",
		"NameDropDown3",
	}

	for i = 1, 6 do
		local ddown = _G["LFGFrame"..lfgDropDowns[i]]
		if ddown then
			S:HandleDropDownBox(ddown, 250)
		end
	end


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

	S:HandleIcon(LookingForGroupIcon)
	S:HandleIcon(LookingForMoreIcon)

	S:HandleEditBox(LFGComment)

	AutoJoinBackground:StripTextures()
	AddMemberBackground:StripTextures()

	S:HandleCheckBox(AutoJoinCheckButton)
	AutoJoinCheckButton:Point("LEFT", -35, 0)

	-- Looking For More
	S:HandleCheckBox(AutoAddMembersCheckButton)
	AutoAddMembersCheckButton:Point("LEFT", -35, 0)

	S:HandleDropDownBox(LFMFrameTypeDropDown, 150)
	S:HandleDropDownBox(LFMFrameNameDropDown, 220)

	for i = 1, 4 do
		_G["LFMFrameColumnHeader" .. i]:StripTextures()
		_G["LFMFrameColumnHeader" .. i]:StyleButton()
		_G["LFMFrameColumnHeader" .. i]:ClearAllPoints()
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
		button:StyleButton()

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

S:AddCallback("LFG", S.LoadLFGSkin)