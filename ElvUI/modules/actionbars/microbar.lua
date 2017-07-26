local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule("ActionBars")

local _G = _G
local CreateFrame = CreateFrame

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

local function Button_OnEnter()
	if AB.db.microbar.mouseover then
		E:UIFrameFadeIn(microBar, .2, microBar:GetAlpha(), AB.db.microbar.alpha)
	end
end

local function Button_OnLeave()
	if AB.db.microbar.mouseover then
		E:UIFrameFadeOut(microBar, .2, microBar:GetAlpha(), 0)
	end
end

function AB:HandleMicroButton(button)
	local pushed = button:GetPushedTexture()
	local normal = button:GetNormalTexture()
	local disabled = button:GetDisabledTexture()

	button:SetParent(microBar)
	button:Show()

	button:GetHighlightTexture():Kill()
	button:HookScript2("OnEnter", Button_OnEnter)
	button:HookScript2("OnLeave", Button_OnLeave)

	local f = CreateFrame("Frame", nil, button)
	f:SetFrameLevel(1)
	f:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 2, 0)
	f:SetPoint("TOPRIGHT", button, "TOPRIGHT", -2, -28)
	f:SetTemplate("Default", true)
	button.backdrop = f

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
	local numRows = 1
	local button, prevButton, lastColumnButton
	for i = 1, #MICRO_BUTTONS do
		button = _G[MICRO_BUTTONS[i]]
		prevButton = _G[MICRO_BUTTONS[i-1]] or microBar
		lastColumnButton = _G[MICRO_BUTTONS[i-self.db.microbar.buttonsPerRow]]

		button:ClearAllPoints()
		if prevButton == microBar then
			button:SetPoint("TOPLEFT", prevButton, "TOPLEFT", -(2 + E.Border), 28 - E.Border)
		elseif (i - 1) % self.db.microbar.buttonsPerRow == 0 then
			button:Point("TOP", lastColumnButton, "BOTTOM", 0, 28 - self.db.microbar.yOffset)
			numRows = numRows + 1
		else
			button:Point("LEFT", prevButton, "RIGHT", - 4 + self.db.microbar.xOffset, 0)
		end
	end

	if self.db.microbar.mouseover then
		microBar:SetAlpha(0)
	else
		microBar:SetAlpha(self.db.microbar.alpha)
	end

	microBar:Width(((CharacterMicroButton:GetWidth() - 4) * self.db.microbar.buttonsPerRow) + (self.db.microbar.xOffset * (self.db.microbar.buttonsPerRow - 1)) + E.Border * 2)
	microBar:Height(((CharacterMicroButton:GetHeight() - 28) * numRows) + (self.db.microbar.yOffset * (numRows - 1)) + E.Border * 2)

	if self.db.microbar.enabled then
		microBar:Show()
		if microBar.mover then
			E:EnableMover(microBar.mover:GetName())
		end
	else
		microBar:Hide()
		if microBar.mover then
			E:DisableMover(microBar.mover:GetName())
		end
	end
end

function AB:SetupMicroBar()
	microBar:Point("TOPLEFT", 4, -48)

	for i = 1, #MICRO_BUTTONS do
		self:HandleMicroButton(_G[MICRO_BUTTONS[i]])
	end

	MicroButtonPortrait:SetInside(CharacterMicroButton.backdrop)

	self:UpdateMicroPositionDimensions()

	E:CreateMover(microBar, "MicrobarMover", L["Micro Bar"], nil, nil, nil, "ALL,ACTIONBARS")
end