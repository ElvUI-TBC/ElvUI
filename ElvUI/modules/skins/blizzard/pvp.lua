local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local MAX_ARENA_TEAMS = MAX_ARENA_TEAMS

function S:LoadPVPSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.pvp ~= true) then return end

	BattlefieldFrame:StripTextures(true)
	BattlefieldFrame:CreateBackdrop("Transparent")
	BattlefieldFrame.backdrop:Point("TOPLEFT", 10, -12)
	BattlefieldFrame.backdrop:Point("BOTTOMRIGHT", -32, 73)

	BattlefieldListScrollFrame:StripTextures()
	S:HandleScrollBar(BattlefieldListScrollFrameScrollBar)

	S:HandleButton(BattlefieldFrameCancelButton)
	S:HandleButton(BattlefieldFrameJoinButton)
	BattlefieldFrameGroupJoinButton:Point("RIGHT", BattlefieldFrameJoinButton, "LEFT", -2, 0)
	S:HandleButton(BattlefieldFrameGroupJoinButton)

	S:HandleCloseButton(BattlefieldFrameCloseButton)

	BattlefieldFrameZoneDescription:SetTextColor(1, 1, 1)

	PVPFrame:StripTextures(true)

	for i = 1, MAX_ARENA_TEAMS do
		local pvpTeam = _G["PVPTeam" .. i]
		pvpTeam:StripTextures()
		pvpTeam:CreateBackdrop("Default")
		pvpTeam.backdrop:Point("TOPLEFT", 9, -4)
		pvpTeam.backdrop:Point("BOTTOMRIGHT", -24, 3)

		pvpTeam:HookScript("OnEnter", S.SetModifiedBackdrop)
		pvpTeam:HookScript("OnLeave", S.SetOriginalBackdrop)

		_G["PVPTeam" .. i .. "Highlight"]:Kill()
	end

	PVPTeamDetails:StripTextures()
	PVPTeamDetails:SetTemplate("Transparent")

	S:HandleNextPrevButton(PVPFrameToggleButton)
	PVPFrameToggleButton.icon:Size(12)
	PVPFrameToggleButton:Size(14)

	S:HandleCloseButton(PVPTeamDetailsCloseButton)

	for i = 1, 5 do
		_G["PVPTeamDetailsFrameColumnHeader" .. i]:StripTextures()
	end

	S:HandleButton(PVPTeamDetailsAddTeamMember)

	S:HandleNextPrevButton(PVPTeamDetailsToggleButton)
end

S:AddCallback("PvP", S.LoadPVPSkin)