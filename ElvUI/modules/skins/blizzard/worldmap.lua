local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.worldmap ~= true then return end

	local WorldMapFrame = _G["WorldMapFrame"]
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

	WorldMapFrameAreaLabel:FontTemplate(nil, 50, "OUTLINE")
	WorldMapFrameAreaLabel:SetShadowOffset(2, -2)
	WorldMapFrameAreaLabel:SetTextColor(0.9, 0.8, 0.6)

	WorldMapFrameAreaDescription:FontTemplate(nil, 40, "OUTLINE")
	WorldMapFrameAreaDescription:SetShadowOffset(2, -2)
end

S:AddCallback("SkinWorldMap", LoadSkin)