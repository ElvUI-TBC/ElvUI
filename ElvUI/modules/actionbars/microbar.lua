local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule("ActionBars")

local _G = _G
local unpack = unpack
local gsub, match = string.gsub, string.match

local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver

local microBar = CreateFrame("Frame", "ElvUI_MicroBar", E.UIParent)
microBar:SetFrameStrata("BACKGROUND")

local MICRO_BUTTONS = {
	"CharacterMicroButton",
	"SpellbookMicroButton",
	"TalentMicroButton",
	"QuestLogMicroButton",
	"SocialsMicroButton",
	"LFGMicroButton",
	"MainMenuMicroButton",
	"HelpMicroButton"
}

local function onEnterBar()
	if AB.db.microbar.mouseover then
		E:UIFrameFadeIn(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), AB.db.microbar.alpha)
	end
end

local function onLeaveBar()
	if AB.db.microbar.mouseover then
		E:UIFrameFadeOut(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), 0)
	end
end

local function onEnterButton(button)
	if AB.db.microbar.mouseover then
		E:UIFrameFadeIn(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), AB.db.microbar.alpha)
	end

	if button.backdrop then
		button.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	end
end

local function onLeaveButton(button)
	if AB.db.microbar.mouseover then
		E:UIFrameFadeOut(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), 0)
	end

	if button.backdrop then
		button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

function AB:HandleMicroButton(button)
	local pushed = button:GetPushedTexture()
	local normal = button:GetNormalTexture()
	local disabled = button:GetDisabledTexture()

	local f = CreateFrame("Frame", nil, button)
	f:SetFrameLevel(button:GetFrameLevel() - 1)
	f:SetTemplate("Default", true)
	f:SetOutside(button)
	button.backdrop = f

	button:SetParent(ElvUI_MicroBar)
	button:GetHighlightTexture():Kill()
	button:HookScript2("OnEnter", onEnterButton)
	button:HookScript2("OnLeave", onLeaveButton)
	button:SetHitRectInsets(0, 0, 0, 0)
	button:Show()

	pushed:SetTexCoord(0.17, 0.87, 0.5, 0.908)
	pushed:SetInside(f)

	normal:SetTexCoord(0.17, 0.87, 0.5, 0.908)
	normal:SetInside(f)

	if disabled then
		disabled:SetTexCoord(0.17, 0.87, 0.5, 0.908)
		disabled:SetInside(f)
	end
end

function AB:UpdateMicroPositionDimensions()
	if not ElvUI_MicroBar then return end

	local numRows = 1
	local prevButton = ElvUI_MicroBar
	local offset = E:Scale(E.PixelMode and 1 or 3)
	local spacing = E:Scale(offset + self.db.microbar.buttonSpacing)

	for i = 1, #MICRO_BUTTONS do
		local button = _G[MICRO_BUTTONS[i]]
		local lastColumnButton = i - self.db.microbar.buttonsPerRow
		lastColumnButton = _G[MICRO_BUTTONS[lastColumnButton]]

		button:Size(self.db.microbar.buttonSize, self.db.microbar.buttonSize * 1.4)
		button:ClearAllPoints()

		if prevButton == ElvUI_MicroBar then
			button:Point("TOPLEFT", prevButton, "TOPLEFT", offset, -offset)
		elseif (i - 1) % self.db.microbar.buttonsPerRow == 0 then
			button:Point("TOP", lastColumnButton, "BOTTOM", 0, -spacing)
			numRows = numRows + 1
		else
			button:Point("LEFT", prevButton, "RIGHT", spacing, 0)
		end

		prevButton = button
	end

	if AB.db.microbar.mouseover and not MouseIsOver(ElvUI_MicroBar) then
		ElvUI_MicroBar:SetAlpha(0)
	else
		ElvUI_MicroBar:SetAlpha(self.db.microbar.alpha)
	end

	AB.MicroWidth = (((_G["CharacterMicroButton"]:GetWidth() + spacing) * self.db.microbar.buttonsPerRow) - spacing) + (offset * 2)
	AB.MicroHeight = (((_G["CharacterMicroButton"]:GetHeight() + spacing) * numRows) - spacing) + (offset * 2)
	ElvUI_MicroBar:Size(AB.MicroWidth, AB.MicroHeight)

	local visibility = self.db.microbar.visibility
	if visibility and visibility:match("[\n\r]") then
		visibility = visibility:gsub("[\n\r]", "")
	end

	RegisterStateDriver(ElvUI_MicroBar, "visibility", (self.db.microbar.enabled and visibility) or "hide")

	if ElvUI_MicroBar.mover then
		if self.db.microbar.enabled then
			E:EnableMover(ElvUI_MicroBar.mover:GetName())
		else
			E:DisableMover(ElvUI_MicroBar.mover:GetName())
		end
	end
end

function AB:SetupMicroBar()
	ElvUI_MicroBar:Point("TOPLEFT", E.UIParent, "TOPLEFT", 4, -48)
	ElvUI_MicroBar:EnableMouse(true)
	ElvUI_MicroBar:SetScript("OnEnter", onEnterBar)
	ElvUI_MicroBar:SetScript("OnLeave", onLeaveBar)

	for i = 1, #MICRO_BUTTONS do
		self:HandleMicroButton(_G[MICRO_BUTTONS[i]])
	end

	MicroButtonPortrait:SetInside(CharacterMicroButton.backdrop)

	self:UpdateMicroPositionDimensions()

	MainMenuBarPerformanceBarFrame:Kill()

	E:CreateMover(ElvUI_MicroBar, 'MicrobarMover', L["Micro Bar"], nil, nil, nil, "ALL,ACTIONBARS", nil, "actionbar,microbar")
end