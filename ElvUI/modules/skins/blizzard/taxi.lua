local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.taxi ~= true then return end

	local TaxiFrame = _G["TaxiFrame"]
	TaxiFrame:CreateBackdrop("Transparent")
	TaxiFrame.backdrop:Point("TOPLEFT", 11, -12)
	TaxiFrame.backdrop:Point("BOTTOMRIGHT", -34, 75)

	TaxiFrame:StripTextures()

	TaxiPortrait:Kill()

	S:HandleCloseButton(TaxiCloseButton)

	TaxiRouteMap:CreateBackdrop("Default")
end

S:AddCallback("Taxi", LoadSkin)