local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G

function S:LoadCraftSkin()
	if (E.private.skins.blizzard.enable ~= true or not E.private.skins.blizzard.craft ~= true) then return end

	CraftFrame:StripTextures(true)
	CraftFrame:CreateBackdrop("Transparent")
	CraftFrame.backdrop:Point("TOPLEFT", 10, -12)
	CraftFrame.backdrop:Point("BOTTOMRIGHT", -31, 75)

	CraftDetailScrollChildFrame:StripTextures()

	CraftDetailScrollFrame:SetTemplate("Transparent")
	CraftDetailScrollFrame:Width(300)
	CraftDetailScrollFrame:Height(150)

	S:HandleScrollBar(CraftDetailScrollFrameScrollBar)

	S:HandleButton(CraftCreateButton)
	S:HandleButton(CraftCancelButton)

	S:HandleCloseButton(CraftFrameCloseButton)

end

S:AddCallbackForAddon("Blizzard_CraftUI", "Craft", S.LoadCraftSkin)