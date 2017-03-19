local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

function S:LoadWorldMapSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.worldmap ~= true then return end

	WorldMapFrame:StripTextures()
	WorldMapPositioningGuide:CreateBackdrop("Transparent")

	S:HandleDropDownBox(WorldMapContinentDropDown)
	S:HandleDropDownBox(WorldMapZoneDropDown)
	S:HandleDropDownBox(WorldMapZoneMinimapDropDown)

	S:HandleButton(WorldMapZoomOutButton)

	S:HandleCloseButton(WorldMapFrameCloseButton)

	WorldMapDetailFrame:CreateBackdrop("Default")
end

S:AddCallback("WorldMap", S.LoadWorldMapSkin)