local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

function S:LoadWorldMapSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.worldmap ~= true then return end

	WorldMapFrame:StripTextures()
	WorldMapPositioningGuide:CreateBackdrop("Transparent")

	S:HandleDropDownBox(WorldMapZoneMinimapDropDown, 190)
	S:HandleDropDownBox(WorldMapContinentDropDown, 170)
	S:HandleDropDownBox(WorldMapZoneDropDown, 170)

	WorldMapZoneDropDown:Point("LEFT", WorldMapContinentDropDown, "RIGHT", -24, 0)
	WorldMapZoomOutButton:Point("LEFT", WorldMapZoneDropDown, "RIGHT", -4, 3)

	S:HandleButton(WorldMapZoomOutButton)

	S:HandleCloseButton(WorldMapFrameCloseButton)

	WorldMapDetailFrame:CreateBackdrop("Default")
end

S:AddCallback("SkinWorldMap", S.LoadWorldMapSkin)