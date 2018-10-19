local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.arena ~= true then return end

	ArenaFrame:CreateBackdrop("Transparent")
	ArenaFrame.backdrop:Point("TOPLEFT", 11, -12)
	ArenaFrame.backdrop:Point("BOTTOMRIGHT", -34, 74)

	ArenaFrame:StripTextures(true)

	ArenaFrameZoneDescription:SetTextColor(1, 1, 1)

	S:HandleButton(ArenaFrameCancelButton)
	S:HandleButton(ArenaFrameJoinButton)

	S:HandleButton(ArenaFrameGroupJoinButton)
	ArenaFrameGroupJoinButton:Point("RIGHT", ArenaFrameJoinButton, "LEFT", -2, 0)

	for i = 1, 6 do
		local button = _G["ArenaZone"..i]

		S:HandleButtonHighlight(button)
	end

	S:HandleCloseButton(ArenaFrameCloseButton)
end

S:AddCallback("Arena", LoadSkin)