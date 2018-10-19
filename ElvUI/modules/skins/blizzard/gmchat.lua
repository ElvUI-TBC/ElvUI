local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gmchat then return end

	GMSurveyFrame:StripTextures()
	GMSurveyFrame:CreateBackdrop("Transparent")
	GMSurveyFrame.backdrop:Point("TOPLEFT", 4, 4)
	GMSurveyFrame.backdrop:Point("BOTTOMRIGHT", -44, 10)

	GMSurveyHeader:StripTextures()
	S:HandleCloseButton(GMSurveyCloseButton, GMSurveyFrame.backdrop)

	GMSurveyScrollFrame:StripTextures()
	S:HandleScrollBar(GMSurveyCommentScrollFrameScrollBar)

	GMSurveyCancelButton:Point("BOTTOMLEFT", 19, 18)
	S:HandleButton(GMSurveyCancelButton)

	GMSurveySubmitButton:Point("BOTTOMRIGHT", -57, 18)
	S:HandleButton(GMSurveySubmitButton)

	for i = 1, 7 do
		local frame = _G["GMSurveyQuestion"..i ]
		frame:StripTextures()
		frame:SetTemplate("Transparent")
	end

	GMSurveyCommentFrame:StripTextures()
	GMSurveyCommentFrame:SetTemplate("Transparent")
end

S:AddCallbackForAddon("Blizzard_GMSurveyUI", "GMSurveyFrame", LoadSkin)