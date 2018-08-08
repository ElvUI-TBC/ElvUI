local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.battlefield ~= true then return end

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
end

S:AddCallback("Battlefield", LoadSkin)