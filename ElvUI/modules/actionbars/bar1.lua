local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule("ActionBars")

local split = string.split

function AB:CreateBar1()
	local bar = CreateFrame("Frame", "ElvUI_Bar1", E.UIParent, "SecureStateHeaderTemplate")
	local point, anchor, attachTo, x, y = split(",", self["barDefaults"]["bar1"].position)
	local offset = E.Spacing
	bar.buttons = {}

	bar:Point(point, anchor, attachTo, x, y)
	bar.id = "1"
	bar:SetFrameStrata("LOW")
	bar:CreateBackdrop("Default")
	bar.backdrop:SetPoint("TOPLEFT", bar, "TOPLEFT", offset, -offset)
	bar.backdrop:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -offset, offset)

	self:HookScript(bar, "OnEnter", "Bar_OnEnter")
	self:HookScript(bar, "OnLeave", "Bar_OnLeave")

	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local button = _G["ActionButton" .. i]
		bar.buttons[i] = button
		button:SetParent(bar)

		self:HookScript(button, "OnEnter", "Button_OnEnter")
		self:HookScript(button, "OnLeave", "Button_OnLeave")
	end

	self["handledBars"]["bar1"] = bar
	E:CreateMover(bar, "ElvAB_1", L["Bar "] .. "1", nil, nil, nil, "ALL,ACTIONBARS")
	self:PositionAndSizeBar("bar1")
end