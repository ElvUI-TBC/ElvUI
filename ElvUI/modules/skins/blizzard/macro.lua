local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.macro ~= true then return end

	local MacroFrame = _G["MacroFrame"]
	MacroFrame:StripTextures()
	MacroFrame:CreateBackdrop("Transparent")
	MacroFrame.backdrop:Point("TOPLEFT", 10, -11)
	MacroFrame.backdrop:Point("BOTTOMRIGHT", -32, 71)

	MacroFrame.bg = CreateFrame("Frame", nil, MacroFrame)
	MacroFrame.bg:SetTemplate("Transparent", true)
	MacroFrame.bg:Point("TOPLEFT", MacroButton1, -10, 10)
	MacroFrame.bg:Point("BOTTOMRIGHT", MacroButton18, 10, -10)

	MacroFrameTextBackground:StripTextures()
	MacroFrameTextBackground:CreateBackdrop("Default")
	MacroFrameTextBackground.backdrop:Point("TOPLEFT", 6, -3)
	MacroFrameTextBackground.backdrop:Point("BOTTOMRIGHT", -3, 3)

	local Buttons = {
		"MacroFrameTab1",
		"MacroFrameTab2",
		"MacroDeleteButton",
		"MacroNewButton",
		"MacroExitButton",
		"MacroEditButton",
	}

	for i = 1, #Buttons do
		_G[Buttons[i]]:StripTextures()
		S:HandleButton(_G[Buttons[i]])
	end

	for i = 1, 2 do
		local tab = _G["MacroFrameTab"..i]

		tab:Height(22)

		if i == 1 then
			tab:Point("TOPLEFT", MacroFrame, "TOPLEFT", 60, -39)
		else
			tab:Point("LEFT", MacroFrameTab1, "RIGHT", 4, 0)
		end
	end

	S:HandleCloseButton(MacroFrameCloseButton)

	S:HandleScrollBar(MacroFrameScrollFrameScrollBar)

	MacroEditButton:ClearAllPoints()
	MacroEditButton:Point("BOTTOMLEFT", MacroFrameSelectedMacroButton, "BOTTOMRIGHT", 10, 0)

	MacroFrameSelectedMacroName:Point("TOPLEFT", MacroFrameSelectedMacroBackground, "TOPRIGHT", -4, -10)

	MacroFrameSelectedMacroButton:StripTextures()
	MacroFrameSelectedMacroButton:SetTemplate("Transparent")
	MacroFrameSelectedMacroButton:StyleButton(nil, true)

	MacroFrameSelectedMacroButtonIcon:SetTexCoord(unpack(E.TexCoords))
	MacroFrameSelectedMacroButtonIcon:SetInside()

	MacroFrameCharLimitText:ClearAllPoints()
	MacroFrameCharLimitText:Point("BOTTOM", MacroFrameTextBackground, 0, -9)

	for i = 1, MAX_MACROS do
		local button = _G["MacroButton"..i]
		local icon = _G["MacroButton"..i.."Icon"]

		if button then
			button:StripTextures()
			button:SetTemplate("Default", true)
			button:StyleButton(nil, true)
		end

		if icon then
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetInside()
		end
	end

	-- PopUp Frame
	S:HandleIconSelectionFrame(MacroPopupFrame, NUM_MACRO_ICONS_SHOWN, "MacroPopupButton", "MacroPopup")

	MacroPopupFrame:Point("TOPLEFT", MacroFrame, "TOPRIGHT", -41, 1)

	MacroPopupEditBox:Point("TOPLEFT", 20, -35)

	MacroPopupScrollFrame:CreateBackdrop("Transparent")
	MacroPopupScrollFrame.backdrop:Point("TOPLEFT", 57, 2)
	MacroPopupScrollFrame.backdrop:Point("BOTTOMRIGHT", -9, 4)

	S:HandleScrollBar(MacroPopupScrollFrameScrollBar)
	MacroPopupScrollFrameScrollBar:ClearAllPoints()
	MacroPopupScrollFrameScrollBar:Point("TOPRIGHT", MacroPopupScrollFrame, 12, -14)
	MacroPopupScrollFrameScrollBar:Point("BOTTOMRIGHT", MacroPopupScrollFrame, 0, 20)

	MacroPopupCancelButton:Point("BOTTOMRIGHT", MacroPopupFrame, -26, 13)
end

S:AddCallbackForAddon("Blizzard_MacroUI", "Macro", LoadSkin)