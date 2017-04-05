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

<<<<<<< HEAD
	S:HandleButton(BattlefieldFrameCancelButton)
	S:HandleButton(BattlefieldFrameJoinButton)
	BattlefieldFrameGroupJoinButton:Point("RIGHT", BattlefieldFrameJoinButton, "LEFT", -2, 0)
	S:HandleButton(BattlefieldFrameGroupJoinButton)

	S:HandleCloseButton(BattlefieldFrameCloseButton)

--[[
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

	S:HandleCloseButton(PVPTeamDetailsCloseButton)

	for i = 1, 5 do
		_G["PVPTeamDetailsFrameColumnHeader" .. i]:StripTextures()
	end

	S:HandleButton(PVPTeamDetailsAddTeamMember)

	S:HandleNextPrevButton(PVPTeamDetailsToggleButton)
]]
=======
	-- BattlefieldFrameInfoScrollFrameChildFrameDescription:SetTextColor(1, 1, 1)
	-- BattlefieldFrameInfoScrollFrameChildFrameRewardsInfoDescription:SetTextColor(1, 1, 1)

	S:HandleButton(BattlefieldFrameCancelButton)
	S:HandleButton(BattlefieldFrameJoinButton)
	BattlefieldFrameGroupJoinButton:Point("RIGHT", BattlefieldFrameJoinButton, "LEFT", -2, 0)
	S:HandleButton(BattlefieldFrameGroupJoinButton)

	S:HandleCloseButton(BattlefieldFrameCloseButton)

	-- PVPBattlegroundFrame:StripTextures(true)

	-- PVPBattlegroundFrameTypeScrollFrame:StripTextures()
	-- S:HandleScrollBar(PVPBattlegroundFrameTypeScrollFrameScrollBar)

	-- S:HandleButton(PVPBattlegroundFrameCancelButton)

	-- PVPBattlegroundFrameInfoScrollFrame:StripTextures()
	-- S:HandleScrollBar(PVPBattlegroundFrameInfoScrollFrameScrollBar)

	-- PVPBattlegroundFrameInfoScrollFrameChildFrameDescription:SetTextColor(1, 1, 1)
	-- PVPBattlegroundFrameInfoScrollFrameChildFrameRewardsInfo.description:SetTextColor(1, 1, 1)

	-- S:HandleButton(PVPBattlegroundFrameJoinButton)
	-- PVPBattlegroundFrameGroupJoinButton:Point("RIGHT", PVPBattlegroundFrameJoinButton, "LEFT", -2, 0)
	-- S:HandleButton(PVPBattlegroundFrameGroupJoinButton)

	-- PVPParentFrame:CreateBackdrop("Transparent")
	-- PVPParentFrame.backdrop:Point("TOPLEFT", 12, -13)
	-- PVPParentFrame.backdrop:Point("BOTTOMRIGHT", -30, 76)

	-- S:HandleCloseButton(PVPParentFrameCloseButton)

	-- PVPFrame:StripTextures(true)

	-- for i = 1, MAX_ARENA_TEAMS do
	-- 	local pvpTeam = _G["PVPTeam" .. i]
	-- 	pvpTeam:StripTextures()
	-- 	pvpTeam:CreateBackdrop("Default")
	-- 	pvpTeam.backdrop:Point("TOPLEFT", 9, -4)
	-- 	pvpTeam.backdrop:Point("BOTTOMRIGHT", -24, 3)

	-- 	pvpTeam:HookScript("OnEnter", S.SetModifiedBackdrop)
	-- 	pvpTeam:HookScript("OnLeave", S.SetOriginalBackdrop)

	-- 	_G["PVPTeam" .. i .. "Highlight"]:Kill()
	-- end

	-- PVPTeamDetails:StripTextures()
	-- PVPTeamDetails:SetTemplate("Transparent")

	-- S:HandleCloseButton(PVPTeamDetailsCloseButton)

	-- for i = 1, 5 do
	-- 	_G["PVPTeamDetailsFrameColumnHeader" .. i]:StripTextures()
	-- end

	-- S:HandleButton(PVPTeamDetailsAddTeamMember)

	-- S:HandleNextPrevButton(PVPTeamDetailsToggleButton)

	-- for i = 1, 2 do
	-- 	S:HandleTab(_G["PVPParentFrameTab" .. i])
	-- end
>>>>>>> master
end

S:AddCallback("PvP", S.LoadPVPSkin)