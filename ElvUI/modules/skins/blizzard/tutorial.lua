local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G

local MAX_TUTORIAL_ALERTS = MAX_TUTORIAL_ALERTS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tutorial ~= true then return end

	for i = 1, MAX_TUTORIAL_ALERTS do
		local button = _G["TutorialFrameAlertButton"..i]
		local icon = button:GetNormalTexture()

		button:Size(35, 45)
		button:SetTemplate("Default", true)
		button:StyleButton(nil, true)

		icon:SetInside()
		icon:SetTexCoord(0.09, 0.40, 0.11, 0.56)
	end

	TutorialFrame:SetTemplate("Transparent")

	S:HandleCheckBox(TutorialFrameCheckButton)

	S:HandleButton(TutorialFrameOkayButton)
end

S:AddCallback("Tutorial", LoadSkin)