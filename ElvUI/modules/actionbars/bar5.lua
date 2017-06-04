local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule("ActionBars")

local split = string.split

function AB:CreateBar5()
	local bar = CreateFrame("Frame", "ElvUI_Bar5", E.UIParent, "SecureStateHeaderTemplate")
	local point, anchor, attachTo, x, y = split(",", self["barDefaults"]["bar5"].position)
	local offset = E.Spacing
	bar.buttons = {}

	bar:Point(point, anchor, attachTo, x, y)
	bar.id = "5"
	bar:SetFrameStrata("LOW")
	bar:CreateBackdrop("Default")
	bar.backdrop:SetPoint("TOPLEFT", bar, "TOPLEFT", offset, -offset)
	bar.backdrop:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -offset, offset)

	self:HookScript(bar, "OnEnter", "Bar_OnEnter")
	self:HookScript(bar, "OnLeave", "Bar_OnLeave")

	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local button = _G["MultiBarRightButton" .. i]
		bar.buttons[i] = button

		self:HookScript(button, "OnEnter", "Button_OnEnter")
		self:HookScript(button, "OnLeave", "Button_OnLeave")
	end

	self["handledBars"]["bar5"] = bar
	E:CreateMover(bar, "ElvAB_5", L["Bar "] .. "5", nil, nil, nil, "ALL,ACTIONBARS")
	self:PositionAndSizeBar("bar5")
end