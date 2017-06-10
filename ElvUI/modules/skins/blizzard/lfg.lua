local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local find = string.find

function S:LoadLFGSkin()
	if (E.private.skins.blizzard.enable ~= true or not E.private.skins.blizzard.lfg ~= true) then return end

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

	S:HandleDropDownBox(LFMFrameTypeDropDown, 150)
	S:HandleDropDownBox(LFMFrameNameDropDown, 220)

	for i = 1, 2 do
		local tab = _G["LFGParentFrameTab"..i]
		S:HandleTab(tab)
	end

	for i = 1, 4 do
		_G["LFMFrameColumnHeader" .. i]:StripTextures()
		_G["LFMFrameColumnHeader" .. i]:StyleButton()
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
	S:HandleCheckBox(AutoJoinCheckButton)
	AddMemberBackground:StripTextures()
	S:HandleCheckBox(AutoAddMembersCheckButton)

end

S:AddCallback("LFG", S.LoadLFGSkin)