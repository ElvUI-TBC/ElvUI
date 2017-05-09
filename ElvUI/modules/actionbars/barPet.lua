local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule("ActionBars")

local _G = _G
local ceil = math.ceil

local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local GetBindingKey = GetBindingKey
local PetHasActionBar = PetHasActionBar
local GetPetActionInfo = GetPetActionInfo
local IsPetAttackActive = IsPetAttackActive
local PetActionButton_StartFlash = PetActionButton_StartFlash
local PetActionButton_StopFlash = PetActionButton_StopFlash
local GetPetActionsUsable = GetPetActionsUsable
local SetDesaturation = SetDesaturation
local PetActionBar_ShowGrid = PetActionBar_ShowGrid
local PetActionBar_UpdateCooldowns = PetActionBar_UpdateCooldowns
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS

local bar = CreateFrame("Frame", "ElvUI_BarPet", E.UIParent, "SecureStateHeaderTemplate")

function AB:UpdatePet()
	local petActionButton, petActionName, petActionIcon, petAutoCastableTexture, petAutoCastModel
	local petActionsUsable = GetPetActionsUsable()
	for i = 1, NUM_PET_ACTION_SLOTS, 1 do
		local buttonName = "PetActionButton"..i
		local petActionButton = _G[buttonName]
		local petActionIcon = _G[buttonName.."Icon"]
		local petAutoCastableTexture = _G[buttonName.."AutoCastable"]
		local petAutoCastModel = _G[buttonName.."AutoCast"]
		local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)

		if not isToken then
			petActionIcon:SetTexture(texture)
			petActionButton.tooltipName = name
		else
			petActionIcon:SetTexture(_G[texture])
			petActionButton.tooltipName = _G[name]
		end

		petActionButton.isToken = isToken
		petActionButton.tooltipSubtext = subtext

		if isActive and name ~= "PET_ACTION_FOLLOW" then
			petActionButton:SetChecked(1)
			if IsPetAttackActive(i) then
				PetActionButton_StartFlash(button)
			end
		else
			petActionButton:SetChecked(0)
			if IsPetAttackActive(i) then
				PetActionButton_StopFlash(button)
			end
		end

		if autoCastAllowed then
			petAutoCastableTexture:Show()
		else
			petAutoCastableTexture:Hide()
		end

		if autoCastEnabled then
			petAutoCastModel:Show()
		else
			petAutoCastModel:Hide()
		end

		petActionButton:SetAlpha(1)

		if texture then
			if petActionsUsable then
				SetDesaturation(petActionIcon, nil)
			else
				SetDesaturation(petActionIcon, 1)
			end
			petActionIcon:Show()
		else
			petActionIcon:Hide()
		end

		if not PetHasActionBar() and texture and name ~= "PET_ACTION_FOLLOW" then
			PetActionButton_StopFlash(petActionButton)
			SetDesaturation(icon, 1)
			button:SetChecked(0)
		end
	end
end

function AB:PositionAndSizeBarPet()
	local spacing = E:Scale(self.db["barPet"].buttonspacing)
	local buttonsPerRow = self.db["barPet"].buttonsPerRow
	local numButtons = self.db["barPet"].buttons
	local size = E:Scale(self.db["barPet"].buttonsize)
	local point = self.db["barPet"].point
	local numColumns = ceil(numButtons / buttonsPerRow)
	local widthMult = self.db["barPet"].widthMult
	local heightMult = self.db["barPet"].heightMult

	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons
	end

	if numColumns < 1 then
		numColumns = 1
	end

	if self.db["barPet"].backdrop == true then
		bar.backdrop:Show()
	else
		bar.backdrop:Hide()

		widthMult = 1
		heightMult = 1
	end

	bar:Width(spacing + ((size * (buttonsPerRow * widthMult)) + ((spacing * (buttonsPerRow - 1)) * widthMult) + (spacing * widthMult)))
	bar:Height(spacing + ((size * (numColumns * heightMult)) + ((spacing * (numColumns - 1)) * heightMult) + (spacing * heightMult)))
	bar.mover:SetSize(bar:GetSize())

	if self.db["barPet"].enabled then
		bar:Show()
		bar:SetScale(1)
		bar:SetAlpha(self.db["barPet"].alpha)

		E:EnableMover(bar.mover:GetName())

		RegisterStateDriver(bar, "visibility", self.db["barPet"].visibility);
	else
		bar:Hide()
		bar:SetScale(0.000001)
		bar:SetAlpha(0)

		E:DisableMover(bar.mover:GetName())

		UnregisterStateDriver(bar, "visibility")
	end

	local horizontalGrowth, verticalGrowth
	if point == "TOPLEFT" or point == "TOPRIGHT" then
		verticalGrowth = "DOWN"
	else
		verticalGrowth = "UP"
	end

	if point == "BOTTOMLEFT" or point == "TOPLEFT" then
		horizontalGrowth = "RIGHT"
	else
		horizontalGrowth = "LEFT"
	end

	bar.mouseover = self.db["barPet"].mouseover
	if bar.mouseover then
		bar:SetAlpha(0)
	else
		bar:SetAlpha(self.db["barPet"].alpha)
	end

	bar.globalfade = self.db["barPet"].inheritGlobalFade
	if bar.globalfade then
		bar:SetParent(self.fadeParent);
	else
		bar:SetParent(E.UIParent);
	end

	local button, lastButton, lastColumnButton
	for i=1, NUM_PET_ACTION_SLOTS do
		button = _G["PetActionButton"..i]
		lastButton = _G["PetActionButton"..i-1]
		lastColumnButton = _G["PetActionButton"..i-buttonsPerRow]
		button:SetParent(bar)
		button:ClearAllPoints()
		button:Size(size)
		button:SetAttribute("showgrid", 1)

		if self.db["barPet"].mouseover == true then
			bar:SetAlpha(0)
			if not self.hooks[bar] then
				self:HookScript(bar, "OnEnter", "Bar_OnEnter")
				self:HookScript(bar, "OnLeave", "Bar_OnLeave")
			end

			if not self.hooks[button] then
				self:HookScript(button, "OnEnter", "Button_OnEnter")
				self:HookScript(button, "OnLeave", "Button_OnLeave")
			end
		else
			bar:SetAlpha(self.db["barPet"].alpha)
			if self.hooks[bar] then
				self:Unhook(bar, "OnEnter")
				self:Unhook(bar, "OnLeave")
			end

			if self.hooks[button] then
				self:Unhook(button, "OnEnter")
				self:Unhook(button, "OnLeave")
			end
		end

		if i == 1 then
			local x, y
			if point == "BOTTOMLEFT" then
				x, y = spacing, spacing
			elseif point == "TOPRIGHT" then
				x, y = -spacing, -spacing
			elseif point == "TOPLEFT" then
				x, y = spacing, -spacing
			else
				x, y = -spacing, spacing
			end

			button:Point(point, bar, point, x, y)
		elseif (i - 1) % buttonsPerRow == 0 then
			local x = 0
			local y = -spacing
			local buttonPoint, anchorPoint = "TOP", "BOTTOM"
			if verticalGrowth == "UP" then
				y = spacing
				buttonPoint = "BOTTOM"
				anchorPoint = "TOP"
			end
			button:Point(buttonPoint, lastColumnButton, anchorPoint, x, y)
		else
			local x = spacing
			local y = 0
			local buttonPoint, anchorPoint = "LEFT", "RIGHT"
			if horizontalGrowth == "LEFT" then
				x = -spacing
				buttonPoint = "RIGHT"
				anchorPoint = "LEFT"
			end

			button:Point(buttonPoint, lastButton, anchorPoint, x, y)
		end

		if i > numButtons then
			button:SetScale(0.000001)
			button:SetAlpha(0)
		else
			button:SetScale(1)
			button:SetAlpha(1)
		end

		self:StyleButton(button)
	end
end

function AB:UpdatePetBindings()
	for i=1, NUM_PET_ACTION_SLOTS do
		if self.db.hotkeytext then
			local key = GetBindingKey("BONUSACTIONBUTTON"..i)
			_G["PetActionButton"..i.."HotKey"]:Show()
			_G["PetActionButton"..i.."HotKey"]:SetText(key)
			self:FixKeybindText(_G["PetActionButton"..i])
		else
			_G["PetActionButton"..i.."HotKey"]:Hide()
		end
	end
end

function AB:CreateBarPet()
	bar:CreateBackdrop("Default")
	bar.backdrop:SetAllPoints()
	if self.db["bar4"].enabled then
		bar:Point("RIGHT", ElvUI_Bar4, "LEFT", -4, 0)
	else
		bar:Point("RIGHT", E.UIParent, "RIGHT", -4, 0)
	end

	bar:SetAttribute("_onstate-show", [[
		if newstate == "hide" then
			self:Hide()
		else
			self:Show()
		end
	]])

	PetActionBarFrame.showgrid = 1
	PetActionBar_ShowGrid()

	self:RegisterEvent("SPELLS_CHANGED", "UpdatePet")
	self:RegisterEvent("PLAYER_CONTROL_GAINED", "UpdatePet")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdatePet")
	self:RegisterEvent("PLAYER_CONTROL_LOST", "UpdatePet")
	self:RegisterEvent("PET_BAR_UPDATE", "UpdatePet")
	self:RegisterEvent("UNIT_PET", "UpdatePet")
	self:RegisterEvent("UNIT_FLAGS", "UpdatePet")
	self:RegisterEvent("UNIT_AURA", "UpdatePet")
	self:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED", "UpdatePet")
	self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN", PetActionBar_UpdateCooldowns)

	E:CreateMover(bar, "ElvBar_Pet", L["Pet Bar"], nil, nil, nil,"ALL,ACTIONBARS")

	self:PositionAndSizeBarPet()
	self:UpdatePetBindings()
end