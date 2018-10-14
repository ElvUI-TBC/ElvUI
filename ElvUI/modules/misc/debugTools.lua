local E, L, V, P, G = unpack(ElvUI)
local D = E:NewModule("DebugTools", "AceEvent-3.0", "AceHook-3.0")

E.DebugTools = D

local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local ScriptErrorsFrame_Update = ScriptErrorsFrame_Update
local InCombatLockdown = InCombatLockdown
local GetCVar = GetCVar
local ScriptErrorsFrame_OnError = ScriptErrorsFrame_OnError
local StaticPopup_Hide = StaticPopup_Hide

function D:ModifyErrorFrame()
	ScriptErrorsFrameScrollFrameText:SetScript("OnEditFocusGained", nil)

	hooksecurefunc("ScriptErrorsFrame_Update", function()
		ScriptErrorsFrameScrollFrameText:HighlightText(0, 0)
	end)

	-- Unhighlight text when focus is hit
	ScriptErrorsFrameScrollFrameText:HookScript("OnEscapePressed", function(self)
		self:HighlightText(0, 0)
	end)

	ScriptErrorsFrame:SetSize(500, 300)
	ScriptErrorsFrameScrollFrame:SetSize(ScriptErrorsFrame:GetWidth() - 45, ScriptErrorsFrame:GetHeight() - 71)

	local BUTTON_WIDTH = 75
	local BUTTON_HEIGHT = 24
	local BUTTON_SPACING = 2

	-- Add a first button
	local firstButton = CreateFrame("Button", nil, ScriptErrorsFrame, "UIPanelButtonTemplate")
	firstButton:Point("BOTTOMRIGHT", ScriptErrorsFrame.previous, "BOTTOMLEFT", -BUTTON_SPACING, 0)
	firstButton:SetText("First")
	firstButton:Height(BUTTON_HEIGHT)
	firstButton:Width(BUTTON_WIDTH)
	firstButton:SetScript("OnClick", function()
		ScriptErrorsFrame.index = 1
		ScriptErrorsFrame_Update()
	end)
	ScriptErrorsFrame.firstButton = firstButton

	-- Also add a Last button for errors
	local lastButton = CreateFrame("Button", nil, ScriptErrorsFrame, "UIPanelButtonTemplate")
	lastButton:Point("BOTTOMLEFT", ScriptErrorsFrame.next, "BOTTOMRIGHT", BUTTON_SPACING, 0)
	lastButton:Height(BUTTON_HEIGHT)
	lastButton:Width(BUTTON_WIDTH)
	lastButton:SetText("Last")
	lastButton:SetScript("OnClick", function()
		ScriptErrorsFrame.index = #(ScriptErrorsFrame.order)
		ScriptErrorsFrame_Update()
	end)
	ScriptErrorsFrame.lastButton = lastButton
end

function D:ScriptErrorsFrame_UpdateButtons()
	local numErrors = #ScriptErrorsFrame.order
	local index = ScriptErrorsFrame.index
	if index == 0 then
		ScriptErrorsFrame.lastButton:Disable()
		ScriptErrorsFrame.firstButton:Disable()
	else
		if numErrors == 1 then
			ScriptErrorsFrame.lastButton:Disable()
			ScriptErrorsFrame.firstButton:Disable()
		else
			ScriptErrorsFrame.lastButton:Enable()
			ScriptErrorsFrame.firstButton:Enable()
		end
	end
end

function D:ScriptErrorsFrame_OnError(_, keepHidden)
	if keepHidden or self.MessagePrinted or not InCombatLockdown() or GetCVar("scriptErrors") ~= "1" then return end

	E:Print(L["|cFFE30000Lua error recieved. You can view the error message when you exit combat."])
	self.MessagePrinted = true
end

function D:PLAYER_REGEN_ENABLED()
	ScriptErrorsFrame:SetParent(UIParent)

	if self.MessagePrinted then
		ScriptErrorsFrame:Show()
		self.MessagePrinted = nil
	end
end

function D:PLAYER_REGEN_DISABLED()
	ScriptErrorsFrame:SetParent(self.HideFrame)
end

function D:TaintError(event, addonName, addonFunc)
	if GetCVar("scriptErrors") ~= "1" or E.db.general.taintLog ~= true then return end

	ScriptErrorsFrame_OnError(L["%s: %s tried to call the protected function '%s'."]:format(event, addonName or "<name>", addonFunc or "<func>"), false)
end

function D:StaticPopup_Show(name)
	if name == "ADDON_ACTION_FORBIDDEN" and E.db.general.taintLog ~= true then
		StaticPopup_Hide(name)
	end
end

function D:ADDON_LOADED(event, addon)
	if addon == "!DebugTools" then
		self:Initialize()
		self:UnregisterEvent("ADDON_LOADED")
	end
end

function D:Initialize()
	if not IsAddOnLoaded("!DebugTools") then
		self:RegisterEvent("ADDON_LOADED")
		return
	end

	self.HideFrame = CreateFrame("Frame")
	self.HideFrame:Hide()

	self:ModifyErrorFrame()
	self:SecureHook("ScriptErrorsFrame_UpdateButtons")
	self:SecureHook("ScriptErrorsFrame_OnError")
	self:SecureHook("StaticPopup_Show")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("ADDON_ACTION_BLOCKED", "TaintError")
	self:RegisterEvent("ADDON_ACTION_FORBIDDEN", "TaintError")
end

local function InitializeCallback()
	D:Initialize()
end

E:RegisterModule(D:GetName(), InitializeCallback)