local E, L, V, P, G, _ = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G

function S:LoadTutorialSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tutorial ~= true then return end

	for i = 1, TutorialFrame:GetNumChildren() do
		local child = select(i, TutorialFrame:GetChildren())
		if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
			S:HandleCloseButton(child)
			child:Point("TOPRIGHT", TutorialFrame, "TOPRIGHT", 2, 4)
		end
	end

	for i = 1, MAX_TUTORIAL_ALERTS do
		local TutorialFrameAlertButton = _G["TutorialFrameAlertButton"..i]
		local TutorialFrameAlertButtonIcon = TutorialFrameAlertButton:GetNormalTexture()

		TutorialFrameAlertButton:StripTextures()
		TutorialFrameAlertButton:CreateBackdrop("Default", true)
		TutorialFrameAlertButton:Width(35)
		TutorialFrameAlertButton:Height(45)
		S:HandleItemButton(TutorialFrameAlertButton)

		TutorialFrameAlertButtonIcon:SetTexture("Interface\\TutorialFrame\\TutorialFrameAlert")
		TutorialFrameAlertButtonIcon:ClearAllPoints()
		TutorialFrameAlertButtonIcon:Point("TOPLEFT", TutorialFrameAlertButton, "TOPLEFT", 0, 0)
		TutorialFrameAlertButtonIcon:Point("BOTTOMRIGHT", TutorialFrameAlertButton, "BOTTOMRIGHT", 0, 0)
		TutorialFrameAlertButtonIcon:SetTexCoord(0.07, 0.43, 0.15, 0.55)
		-- TutorialFrameAlertButtonIcon:SetTexCoord(unpack(E.TexCoords))
	end

	TutorialFrame:StripTextures()
	TutorialFrame:SetTemplate("Transparent")

	S:HandleCheckBox(TutorialFrameCheckButton)

	S:HandleButton(TutorialFrameOkayButton)
end

S:AddCallback("Tutorial", S.LoadTutorialSkin)