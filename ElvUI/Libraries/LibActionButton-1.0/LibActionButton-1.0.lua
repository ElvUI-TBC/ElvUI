--[[
Copyright (c) 2010-2016, Hendrik "nevcairiel" Leppkes <h.leppkes@gmail.com>

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.
    * Neither the name of the developer nor the names of its contributors
      may be used to endorse or promote products derived from this software without
      specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]
local MAJOR_VERSION = "LibActionButton-1.0"
local MINOR_VERSION = 66

if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib, oldversion = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local _G = _G
local type, error, tostring, tonumber, assert, select = type, error, tostring, tonumber, assert, select
local setmetatable, wipe, unpack, pairs, next = setmetatable, wipe, unpack, pairs, next
local match, format = string.match, format

local KeyBound = LibStub("LibKeyBound-1.0", true)
local CBH = LibStub("CallbackHandler-1.0")

lib.eventFrame = lib.eventFrame or CreateFrame("Frame")
lib.eventFrame:UnregisterAllEvents()

lib.buttonRegistry = lib.buttonRegistry or {}
lib.activeButtons = lib.activeButtons or {}

lib.callbacks = lib.callbacks or CBH:New(lib)

local Generic = CreateFrame("CheckButton")
local Generic_MT = {__index = Generic}

local ButtonRegistry, ActiveButtons = lib.buttonRegistry, lib.activeButtons

local Update, UpdateButtonState, UpdateUsable, UpdateCount, UpdateCooldown, UpdateTooltip
local StartFlash, StopFlash, UpdateFlash, UpdateHotkeys, UpdateRangeTimer
local ShowGrid, HideGrid, UpdateGrid
local UpdateRange -- Sezz: new method

local InitializeEventHandler, OnEvent, ForAllButtons, OnUpdate

local DefaultConfig = {
	outOfRangeColoring = "button",
	tooltip = "enabled",
	showGrid = false,
	useColoring = true,
	colors = {
		range = { 0.8, 0.1, 0.1 },
		mana = { 0.5, 0.5, 1.0 },
		usable = { 1.0, 1.0, 1.0 },
		notUsable = { 0.4, 0.4, 0.4 }
	},
	hideElements = {
		macro = false,
		hotkey = false,
		equipped = false,
	},
	keyBoundTarget = false,
	clickOnDown = false,
}

--- Create a new action button.
-- @param id Internal id of the button (not used by LibActionButton-1.0, only for tracking inside the calling addon)
-- @param name Name of the button frame to be created (not used by LibActionButton-1.0 aside from naming the frame)
-- @param header Header that drives these action buttons (if any)
function lib:CreateButton(id, name, header, config)
	if type(name) ~= "string" then
		error("Usage: CreateButton(id, name. header): Buttons must have a valid name!", 2)
	end
	if not header then
		error("Usage: CreateButton(id, name, header): Buttons without a secure header are not yet supported!", 2)
	end

	if not KeyBound then
		KeyBound = LibStub("LibKeyBound-1.0", true)
	end

	local button = setmetatable(CreateFrame("CheckButton", name, header, "SecureActionButtonTemplate, ActionButtonTemplate"), Generic_MT)
	button:RegisterForDrag("LeftButton", "RightButton")
	button:RegisterForClicks("AnyUp")

	-- Frame Scripts
	button:SetScript("OnAttributeChanged", Generic.ButtonContentsChanged)
	button:SetScript("OnDragStart", Generic.OnDragStart)
	button:SetScript("OnReceiveDrag", Generic.OnReceiveDrag)
	button:SetScript("PostClick", Generic.PostClick)
	button:SetScript("OnEnter", Generic.OnEnter)
	button:SetScript("OnLeave", Generic.OnLeave)

	button.id = id
	button.header = header
	-- Mapping of state -> action
	button.state_actions = {}

	-- Store the LAB Version that created this button for debugging
	button.__LAB_Version = MINOR_VERSION

	header:SetAttribute("addchild", button)

	local absid = (header.id - 1) * 12 + id
	button.action = absid
	button:SetAttribute("type", "action")
	button:SetAttribute("action", absid)
	button:SetAttribute("checkselfcast", true)
	button:SetAttribute("useparent-unit", true)
	button:SetAttribute("useparent-statebutton", true)

	-- Store all sub frames on the button object for easier access
	button.icon               = _G[name .. "Icon"]
	button.flash              = _G[name .. "Flash"]
	button.hotkey             = _G[name .. "HotKey"]
	button.count              = _G[name .. "Count"]
	button.actionName         = _G[name .. "Name"]
	button.border             = _G[name .. "Border"]
	button.cooldown           = _G[name .. "Cooldown"]
	button.normalTexture      = _G[name .. "NormalTexture"]

	-- adjust hotkey style for better readability
	button.hotkey:SetFont(button.hotkey:GetFont(), 13, "OUTLINE")
	button.hotkey:SetVertexColor(0.75, 0.75, 0.75)

	-- Store the button in the registry, needed for event and OnUpdate handling
	if not next(ButtonRegistry) then
		InitializeEventHandler()
	end
	ButtonRegistry[button] = true

	button:UpdateConfig(config)

	-- run an initial update
	button:UpdateAction()
	UpdateHotkeys(button)

	lib.callbacks:Fire("OnButtonCreated", button)

	return button
end

-----------------------------------------------------------
--- utility

function lib:GetAllButtons()
	local buttons = {}
	for button in next, ButtonRegistry do
		buttons[button] = true
	end
	return buttons
end

function Generic:ClearSetPoint(...)
	self:ClearAllPoints()
	self:SetPoint(...)
end

-----------------------------------------------------------
--- state management

function Generic:ClearStates()
	wipe(self.state_actions)
end

function Generic:SetState(state, action)
	self.state_actions[state] = action
	self.action = action

	self:UpdateState(state)
end

function Generic:UpdateState(state)
	local state = tonumber(state or self:GetAttribute("state-parent"))
	local action = self.state_actions[state]

	self:SetAttribute(("*type-S%d"):format(state), "action")
	self:SetAttribute(("*type-S%dRight"):format(state), "action")
	self:SetAttribute(("*action-S%d"):format(state), action)
	self:SetAttribute(("*action-S%dRight"):format(state), action)

	self:UpdateAction()
end

function Generic:GetAction()
	return SecureButton_GetModifiedAttribute(self, "action", SecureStateChild_GetEffectiveButton(self)) or 0
end

function Generic:UpdateAllStates()
	for state in pairs(self.state_actions) do
		self:UpdateState(state)
	end
end

function Generic:ButtonContentsChanged(att, value)
	if att == "state-parent" and self.config then
		self:UpdateAction()
	end
end

-----------------------------------------------------------
--- frame scripts

function Generic:OnUpdate()
	if not LOCK_ACTIONBAR == "1" then return; end

	local isDragKeyDown
	if GetModifiedClick("PICKUPACTION") == "ALT" then
		isDragKeyDown = IsAltKeyDown()
	elseif GetModifiedClick("PICKUPACTION") == "CTRL" then
		isDragKeyDown = IsControlKeyDown()
	elseif GetModifiedClick("PICKUPACTION") == "SHIFT" then
		isDragKeyDown = IsShiftKeyDown()
	end

	if isDragKeyDown and (self.clickState == "AnyDown" or self.clickState == nil) then
		self.clickState = "AnyUp"
		self:RegisterForClicks(self.clickState)
	elseif self.clickState == "AnyUp" and not isDragKeyDown then
		self.clickState = "AnyDown"
		self:RegisterForClicks(self.clickState)
	end
end

function Generic:OnEnter()
	if self.config.tooltip ~= "disabled" and (self.config.tooltip ~= "nocombat" or not InCombatLockdown()) then
		UpdateTooltip(self)
	end
	if KeyBound then
		KeyBound:Set(self)
	end

	if self.config.clickOnDown then
		self:SetScript("OnUpdate", Generic.OnUpdate)
	end
end

function Generic:OnLeave()
	GameTooltip:Hide()
	self:SetScript("OnUpdate", nil)
end

function Generic:OnDragStart()
	if InCombatLockdown() then return end
	if self:GetAttribute("buttonlock") and not IsModifiedClick("PICKUPACTION") then return false end

	PickupAction(self.action)
	UpdateButtonState(self)
end

function Generic:OnReceiveDrag()
	if InCombatLockdown() then return end
	PlaceAction(self.action)
	UpdateButtonState(self)
end

function Generic:PostClick()
	UpdateButtonState(self)
end

local function formatHelper(input)
	if type(input) == "string" then
		return format("%q", input)
	else
		return tostring(input)
	end
end

-----------------------------------------------------------
--- configuration

local function merge(target, source, default)
	for k,v in pairs(default) do
		if type(v) ~= "table" then
			if source and source[k] ~= nil then
				target[k] = source[k]
			else
				target[k] = v
			end
		else
			if type(target[k]) ~= "table" then target[k] = {} else wipe(target[k]) end
			merge(target[k], type(source) == "table" and source[k], v)
		end
	end
	return target
end

function Generic:UpdateConfig(config)
	if config and type(config) ~= "table" then
		error("LibActionButton-1.0: UpdateConfig requires a valid configuration!", 2)
	end

	self.config = {}
	-- merge the two configs
	merge(self.config, config, DefaultConfig)

	if self.config.hideElements.macro then
		self.actionName:Hide()
	else
		self.actionName:Show()
	end
	UpdateHotkeys(self)
	UpdateGrid(self)
	Update(self, true)
	self:RegisterForClicks(self.config.clickOnDown and "AnyDown" or "AnyUp")
end

-----------------------------------------------------------
--- event handler

function ForAllButtons(method, onlyWithAction)
	assert(type(method) == "function")
	for button in next, (onlyWithAction and ActiveButtons or ButtonRegistry) do
		method(button)
	end
end

function InitializeEventHandler()
	lib.eventFrame:SetScript("OnEvent", OnEvent)
	lib.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	lib.eventFrame:RegisterEvent("ACTIONBAR_SHOWGRID")
	lib.eventFrame:RegisterEvent("ACTIONBAR_HIDEGRID")
	lib.eventFrame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
	lib.eventFrame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	lib.eventFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	lib.eventFrame:RegisterEvent("UPDATE_BINDINGS")
	lib.eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")

	lib.eventFrame:RegisterEvent("ACTIONBAR_UPDATE_STATE")
	lib.eventFrame:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
	lib.eventFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	lib.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	lib.eventFrame:RegisterEvent("CRAFT_SHOW")
	lib.eventFrame:RegisterEvent("CRAFT_CLOSE")
	lib.eventFrame:RegisterEvent("TRADE_SKILL_SHOW")
	lib.eventFrame:RegisterEvent("TRADE_SKILL_CLOSE")
	lib.eventFrame:RegisterEvent("PLAYER_ENTER_COMBAT")
	lib.eventFrame:RegisterEvent("PLAYER_LEAVE_COMBAT")
	lib.eventFrame:RegisterEvent("START_AUTOREPEAT_SPELL")
	lib.eventFrame:RegisterEvent("STOP_AUTOREPEAT_SPELL")
	lib.eventFrame:RegisterEvent("COMPANION_UPDATE")
	lib.eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
	lib.eventFrame:RegisterEvent("LEARNED_SPELL_IN_TAB")

	lib.eventFrame:Show()
	lib.eventFrame:SetScript("OnUpdate", OnUpdate)
end

function OnEvent(frame, event, arg1, ...)
	if (event == "UNIT_INVENTORY_CHANGED" and arg1 == "player") or event == "LEARNED_SPELL_IN_TAB" then
		local tooltipOwner = GameTooltip:GetOwner()
		if ButtonRegistry[tooltipOwner] then
			tooltipOwner:SetTooltip()
		end
	elseif event == "ACTIONBAR_SLOT_CHANGED" then
		for button in next, ButtonRegistry do
			if arg1 == 0 or arg1 == tonumber(button.action) then
				Update(button)
			end
		end
	elseif event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_SHAPESHIFT_FORM" then
		ForAllButtons(Update)
	elseif event == "ACTIONBAR_PAGE_CHANGED" or event == "UPDATE_BONUS_ACTIONBAR" then

	elseif event == "ACTIONBAR_SHOWGRID" then
		ShowGrid()
	elseif event == "ACTIONBAR_HIDEGRID" then
		HideGrid()
	elseif event == "UPDATE_BINDINGS" then
		ForAllButtons(UpdateHotkeys)
	elseif event == "PLAYER_TARGET_CHANGED" then
		UpdateRangeTimer()
	elseif event == "ACTIONBAR_UPDATE_STATE" then
		ForAllButtons(UpdateButtonState, true)
	elseif event == "ACTIONBAR_UPDATE_USABLE" then
		for button in next, ActiveButtons do
			UpdateUsable(button)
		end
	elseif event == "ACTIONBAR_UPDATE_COOLDOWN" then
		for button in next, ButtonRegistry do
			UpdateCooldown(button)
			if GameTooltip:GetOwner() == button then
				UpdateTooltip(button)
			end
		end
	elseif event == "CRAFT_SHOW" or event == "CRAFT_CLOSE" or event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" then
		ForAllButtons(UpdateButtonState, true)
	elseif event == "PLAYER_ENTER_COMBAT" then
		for button in next, ActiveButtons do
			if button:IsAttack() then
				StartFlash(button)
			end
		end
	elseif event == "PLAYER_LEAVE_COMBAT" then
		for button in next, ActiveButtons do
			if button:IsAttack() then
				StopFlash(button)
			end
		end
	elseif event == "START_AUTOREPEAT_SPELL" then
		for button in next, ActiveButtons do
			if button:IsAutoRepeat() then
				StartFlash(button)
			end
		end
	elseif event == "STOP_AUTOREPEAT_SPELL" then
		for button in next, ActiveButtons do
			if button.flashing == 1 and not button:IsAttack() then
				StopFlash(button)
			end
		end
	end
end

local flashTime = 0
local rangeTimer = -1
function OnUpdate(_, elapsed)
	flashTime = flashTime - elapsed
	rangeTimer = rangeTimer - elapsed
	-- Run the loop only when there is something to update
	if rangeTimer <= 0 or flashTime <= 0 then
		for button in next, ActiveButtons do
			-- Flashing
			if button.flashing == 1 and flashTime <= 0 then
				if button.flash:IsShown() then
					button.flash:Hide()
				else
					button.flash:Show()
				end
			end

			-- Range
			if rangeTimer <= 0 then
				UpdateRange(button) -- Sezz
			end
		end

		-- Update values
		if flashTime <= 0 then
			flashTime = flashTime + ATTACK_BUTTON_FLASH_TIME
		end
		if rangeTimer <= 0 then
			rangeTimer = TOOLTIP_UPDATE_TIME
		end
	end
end

local gridCounter = 0
function ShowGrid()
	gridCounter = gridCounter + 1
	if gridCounter >= 1 then
		for button in next, ButtonRegistry do
			if button:IsShown() then
				button:SetAlpha(1.0)
			end
		end
	end
end

function HideGrid()
	if gridCounter > 0 then
		gridCounter = gridCounter - 1
	end
	if gridCounter == 0 then
		for button in next, ButtonRegistry do
			if button:IsShown() and not button:HasAction() and not button.config.showGrid then
				button:SetAlpha(0.0)
			end
		end
	end
end

function UpdateGrid(self)
	if self.config.showGrid then
		self:SetAlpha(1.0)
	elseif gridCounter == 0 and self:IsShown() and not self:HasAction() then
		self:SetAlpha(0.0)
	end
end

function UpdateRange(self, force) -- Sezz: moved from OnUpdate
	local inRange = self:IsInRange()
	local oldRange = self.outOfRange
	self.outOfRange = (inRange == false)
	if force or (oldRange ~= self.outOfRange) then
		if self.config.outOfRangeColoring == "button" then
			UpdateUsable(self)
		elseif self.config.outOfRangeColoring == "hotkey" then
			local hotkey = self.hotkey
			if hotkey:GetText() == RANGE_INDICATOR then
				if inRange == false then
					hotkey:Show()
				else
					hotkey:Hide()
				end
			end

			if inRange == false then
				hotkey:SetVertexColor(unpack(self.config.colors.range))
			else
				hotkey:SetVertexColor(unpack(self.config.colors.usable))
			end
		end
	end
end

-----------------------------------------------------------
--- KeyBound integration

function Generic:GetBindingAction()
	return self.config.keyBoundTarget or "CLICK "..self:GetName()..":LeftButton"
end

function Generic:GetHotkey()
	local name = "CLICK "..self:GetName()..":LeftButton"
	local key = GetBindingKey(self.config.keyBoundTarget or name)
	if not key and self.config.keyBoundTarget then
		key = GetBindingKey(name)
	end
	if key then
		return KeyBound and KeyBound:ToShortKey(key) or key
	end
end

local function getKeys(binding, keys)
	keys = keys or ""
	for i = 1, select("#", GetBindingKey(binding)) do
		local hotKey = select(i, GetBindingKey(binding))
		if keys ~= "" then
			keys = keys .. ", "
		end
		keys = keys .. GetBindingText(hotKey)
	end
	return keys
end

function Generic:GetBindings()
	local keys

	if self.config.keyBoundTarget then
		keys = getKeys(self.config.keyBoundTarget)
	end

	keys = getKeys("CLICK "..self:GetName()..":LeftButton", keys)

	return keys
end

function Generic:SetKey(key)
	if self.config.keyBoundTarget then
		SetBinding(key, self.config.keyBoundTarget)
	else
		SetBindingClick(key, self:GetName(), "LeftButton")
	end
	lib.callbacks:Fire("OnKeybindingChanged", self, key)
end

local function clearBindings(binding)
	while GetBindingKey(binding) do
		SetBinding(GetBindingKey(binding), nil)
	end
end

function Generic:ClearBindings()
	if self.config.keyBoundTarget then
		clearBindings(self.config.keyBoundTarget)
	end
	clearBindings("CLICK "..self:GetName()..":LeftButton")
	lib.callbacks:Fire("OnKeybindingChanged", self, nil)
end

-----------------------------------------------------------
--- button management

function Generic:UpdateAction(force)
	local action = self:GetAction()
	if action ~= self.action or force then
		self.action = action
		Update(self)
	end
end

function Update(self, fromUpdateConfig)
	if self:HasAction() then
		ActiveButtons[self] = true

		self:SetAlpha(1.0)
		UpdateUsable(self)
		UpdateCooldown(self)
		UpdateFlash(self)
	else
		ActiveButtons[self] = nil

		if not self.config then
			--print(self:GetName())
		end

		if gridCounter == 0 and not self.config.showGrid then
			self:SetAlpha(0.0)
		end
		self.cooldown:Hide()
		self:SetChecked(0)
	end

	-- Add a green border if button is an equipped item
	if self:IsEquipped() and not self.config.hideElements.equipped then
		self.border:SetVertexColor(0, 1.0, 0, 0.35)
		self.border:Show()
	else
		self.border:Hide()
	end

	-- Update Action Text
	if not self:IsConsumableOrStackable() then
		self.actionName:SetText(self:GetActionText())
	else
		self.actionName:SetText("")
	end

	-- Update icon and hotkey
	local texture = self:GetTexture()
	if texture then
		self.icon:SetTexture(texture)
		self.icon:Show()
		self.rangeTimer = - 1
		self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
	else
		self.icon:Hide()
		self.cooldown:Hide()
		self.rangeTimer = nil
		self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot")
	end

	self:UpdateLocal()

	UpdateRange(self, fromUpdateConfig) -- Sezz: update range check on state change

	UpdateCount(self)

	UpdateButtonState(self)

	if GameTooltip:GetOwner() == self then
		UpdateTooltip(self)
	end

	lib.callbacks:Fire("OnButtonUpdate", self)
end

function Generic:UpdateLocal()
-- dummy function the other button types can override for special updating
end

function UpdateButtonState(self)
	if self:IsCurrentlyActive() or self:IsAutoRepeat() then
		self:SetChecked(1)
	else
		self:SetChecked(0)
	end
	lib.callbacks:Fire("OnButtonState", self)
end

function UpdateUsable(self)
	if self.config.useColoring then
		if self.config.outOfRangeColoring == "button" and self.outOfRange then
			self.icon:SetVertexColor(unpack(self.config.colors.range))
		else
			local isUsable, notEnoughMana = self:IsUsable()
			if isUsable then
				self.icon:SetVertexColor(unpack(self.config.colors.usable))
				--self.NormalTexture:SetVertexColor(1.0, 1.0, 1.0)
			elseif notEnoughMana then
				self.icon:SetVertexColor(unpack(self.config.colors.mana))
				--self.NormalTexture:SetVertexColor(0.5, 0.5, 1.0)
			else
				self.icon:SetVertexColor(unpack(self.config.colors.notUsable))
				--self.NormalTexture:SetVertexColor(1.0, 1.0, 1.0)
			end
 		end
	else
		self.icon:SetVertexColor(unpack(self.config.colors.usable))
 	end
	lib.callbacks:Fire("OnButtonUsable", self)
end

function UpdateCount(self)
	if not self:HasAction() then
		self.count:SetText("")
		return
	end

	if self:IsConsumableOrStackable() then
		local count = self:GetCount()
		if count > (self.maxDisplayCount or 9999) then
			self.count:SetText("*")
		else
			self.count:SetText(count)
		end
	else
		self.count:SetText("")
	end
end

function UpdateCooldown(self)
	local start, duration, enable = self:GetCooldown()
	CooldownFrame_SetTimer(self.cooldown, start, duration, enable)

	lib.callbacks:Fire("OnCooldownUpdate", self, start, duration, enable)
end

function StartFlash(self)
	self.flashing = 1
	flashTime = 0
	UpdateButtonState(self)
end

function StopFlash(self)
	self.flashing = 0
	self.flash:Hide()
	UpdateButtonState(self)
end

function UpdateFlash(self)
	if (self:IsAttack() and self:IsCurrentlyActive()) or self:IsAutoRepeat() then
		StartFlash(self)
	else
		StopFlash(self)
	end
end

function UpdateTooltip(self)
	if (GetCVar("UberTooltips") == "1") then
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	end
	if self:SetTooltip() then
		self.UpdateTooltip = UpdateTooltip
	else
		self.UpdateTooltip = nil
	end
end

function UpdateHotkeys(self)
	local key = self:GetHotkey()
	if not key or key == "" or self.config.hideElements.hotkey then
		self.hotkey:SetText(RANGE_INDICATOR)
		self.hotkey:SetPoint("TOPRIGHT", 0, -3)
		self.hotkey:Hide()
	else
		self.hotkey:SetText(key)
		self.hotkey:SetPoint("TOPRIGHT", 0, -3)
		self.hotkey:Show()
	end

	if self.postKeybind then
		self.postKeybind(nil, self)
	end
end

function UpdateRangeTimer()
	rangeTimer = -1
end

local function GetSpellIdByName(spellName)
	if not spellName then return end
	local spellLink = GetSpellLink(spellName)
	if spellLink then
		return tonumber(spellLink:match("spell:(%d+)"))
	end
	return nil
end

-----------------------------------------------------------
--- WoW API mapping
--- Generic Button
Generic.HasAction               = function(self) return HasAction(self.action) end
Generic.GetActionText           = function(self) return GetActionText(self.action) end
Generic.GetTexture              = function(self) return GetActionTexture(self.action) end
Generic.GetCount                = function(self) return GetActionCount(self.action) end
Generic.GetCooldown             = function(self) return GetActionCooldown(self.action) end
Generic.IsAttack                = function(self) return IsAttackAction(self.action) end
Generic.IsEquipped              = function(self) return IsEquippedAction(self.action) end
Generic.IsCurrentlyActive       = function(self) return IsCurrentAction(self.action) end
Generic.IsAutoRepeat            = function(self) return IsAutoRepeatAction(self.action) end
Generic.IsUsable                = function(self) return IsUsableAction(self.action) end
Generic.IsConsumableOrStackable = function(self) return IsConsumableAction(self.action) or IsStackableAction(self.action) end
Generic.IsUnitInRange           = function(self, unit) return IsActionInRange(self.action, unit) end
Generic.SetTooltip              = function(self) return GameTooltip:SetAction(self.action) end
Generic.GetSpellId              = function(self)
	local actionType, id, subType, globalID = GetActionInfo(self.action)
	if actionType == "spell" then
		return globalID
	elseif actionType == "macro" then
		return GetSpellIdByName(GetMacroSpell(id))
	end
end
Generic.IsInRange               = function(self)
	local unit = self:GetAttribute("unit")
	if unit == "player" then
		unit = nil
	end
	local val = self:IsUnitInRange(unit)
	-- map 1/0 to true false, since the return values are inconsistent between actions and spells
	if val == 1 then val = true elseif val == 0 then val = false end
	return val
end