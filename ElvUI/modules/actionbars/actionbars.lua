local E, L, V, P, G = unpack(ElvUI)
local AB = E:NewModule("ActionBars", "AceHook-3.0", "AceEvent-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local _G = _G
local gsub = string.gsub

local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitAffectingCombat = UnitAffectingCombat
local UnitExists = UnitExists
local InCombatLockdown = InCombatLockdown

AB["handledbuttons"] = {}

function AB:CreateActionBars()
	self:CreateBar1()
	self:CreateBar2()
	self:CreateBar3()
	self:CreateBar4()
	self:CreateBar5()
	self:CreateBarPet()
	self:CreateBarShapeShift()

	if ( E.myclass == "SHAMAN" ) then
	--	self:CreateTotemBar()
	end
end

function AB:PLAYER_REGEN_ENABLED()
	self:UpdateButtonSettings()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

function AB:PositionAndSizeBar()
	self:PositionAndSizeBar1()
	self:PositionAndSizeBar2()
	self:PositionAndSizeBar3()
	self:PositionAndSizeBar4()
	self:PositionAndSizeBar5()
end

function AB:UpdateButtonSettings()
	if InCombatLockdown() then self:RegisterEvent("PLAYER_REGEN_ENABLED") return end
	for button, _ in pairs(self["handledbuttons"]) do
		if button then
			self:StyleButton(button, button.noBackdrop)
		else
			self["handledbuttons"][button] = nil
		end
	end

	self:PositionAndSizeBar()
	self:PositionAndSizeBarPet()
	self:PositionAndSizeBarShapeShift()
end

function AB:GetPage(bar, defaultPage, condition)
	local page = self.db[bar]["paging"][E.myclass]
	if not condition then condition = "" end
	if not page then page = "" end
	if page then
		condition = condition.." "..page
	end
	condition = condition.." "..defaultPage
	return condition
end

function AB:StyleButton(button, noBackdrop)
	local name = button:GetName()
	local icon = _G[name.."Icon"]
	local count = _G[name.."Count"]
	local flash = _G[name.."Flash"]
	local hotkey = _G[name.."HotKey"]
	local border = _G[name.."Border"]
	local macroName = _G[name.."Name"]
	local normal = _G[name.."NormalTexture"]
	local normal2 = button:GetNormalTexture()
	local buttonCooldown = _G[name.."Cooldown"]

	if flash then flash:SetTexture(nil) end
	if normal then normal:SetTexture(nil) normal:Hide() normal:SetAlpha(0) end
	if normal2 then normal2:SetTexture(nil) normal2:Hide() normal2:SetAlpha(0) end
	if border then border:Kill() end

	if not button.noBackdrop then
		button.noBackdrop = noBackdrop
	end

	if count then
		count:ClearAllPoints()
		count:SetPoint("BOTTOMRIGHT", 0, 2)
		count:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	end

	if macroName then
		if self.db.macrotext then
			macroName:Show()
			macroName:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
			macroName:ClearAllPoints()
			macroName:Point("BOTTOM", 2, 2)
			macroName:SetJustifyH("CENTER")
		else
			macroName:Hide()
		end
	end

	if not button.noBackdrop and not button.backdrop then
		button:CreateBackdrop("Default", true)
		button.backdrop:SetAllPoints()
	end

	if icon then
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
	end

	if self.db.hotkeytext then
		hotkey:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	end

	self:FixKeybindText(button)
	button:StyleButton()

	if(not self.handledbuttons[button]) then
		E:RegisterCooldown(buttonCooldown)

		self.handledbuttons[button] = true
	end
end

function AB:Bar_OnEnter(bar)
	if(bar:GetParent() == self.fadeParent) then
		if(not self.fadeParent.mouseLock) then
			E:UIFrameFadeIn(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1);
		end
	elseif(bar.mouseover) then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
	end
end

function AB:Bar_OnLeave(bar)
	if(bar:GetParent() == self.fadeParent) then
		if(not self.fadeParent.mouseLock) then
			E:UIFrameFadeOut(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1 - self.db.globalFadeAlpha);
		end
	elseif(bar.mouseover) then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0);
	end
end

function AB:Button_OnEnter(button)
	local bar = button:GetParent();
	if(bar:GetParent() == self.fadeParent) then
		if(not self.fadeParent.mouseLock) then
			E:UIFrameFadeIn(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1);
		end
	elseif(bar.mouseover) then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha);
	end
end

function AB:Button_OnLeave(button)
	local bar = button:GetParent();
	if(bar:GetParent() == self.fadeParent) then
		if(not self.fadeParent.mouseLock) then
			E:UIFrameFadeOut(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1 - self.db.globalFadeAlpha);
		end
	elseif(bar.mouseover) then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0);
	end
end

function AB:FadeParent_OnEvent(event, unit)
	if((event == "UNIT_SPELLCAST_START"
	or event == "UNIT_SPELLCAST_STOP"
	or event == "UNIT_SPELLCAST_CHANNEL_START"
	or event == "UNIT_SPELLCAST_CHANNEL_STOP"
	or event == "UNIT_HEALTH") and unit ~= "player") then return; end

	local cur, max = UnitHealth("player"), UnitHealthMax("player");
	local cast, channel = UnitCastingInfo("player"), UnitChannelInfo("player");
	local target, focus = UnitExists("target"), UnitExists("focus");
	local combat = UnitAffectingCombat("player");
	if((cast or channel) or (cur ~= max) or (target or focus) or combat) then
		self.mouseLock = true
		E:UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
	else
		self.mouseLock = false
		E:UIFrameFadeOut(self, 0.2, self:GetAlpha(), 1 - AB.db.globalFadeAlpha)
	end
end

function AB:DisableBlizzard()
	MainMenuBar:SetScale(0.00001)
	MainMenuBar:EnableMouse(false)
	PetActionBarFrame:EnableMouse(false)
	ShapeshiftBarFrame:EnableMouse(false)

	local elements = {
		MainMenuBar,
		MainMenuBarArtFrame,
		BonusActionBarFrame,
		PetActionBarFrame,
		ShapeshiftBarFrame,
		ShapeshiftBarLeft,
		ShapeshiftBarMiddle,
		ShapeshiftBarRight,
	}
	for _, element in pairs(elements) do
		if element:GetObjectType() == "Frame" then
			element:UnregisterAllEvents()

			if element == MainMenuBarArtFrame then
				element:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
			end
		end

		if element ~= MainMenuBar then
			element:Hide()
		end
		element:SetAlpha(0)
	end
	elements = nil

	local uiManagedFrames = {
		"MultiBarLeft",
		"MultiBarRight",
		"MultiBarBottomLeft",
		"MultiBarBottomRight",
		"ShapeshiftBarFrame",
		"PETACTIONBAR_YPOS",
	}
	for _, frame in pairs(uiManagedFrames) do
		UIPARENT_MANAGED_FRAME_POSITIONS[frame] = nil
	end
	uiManagedFrames = nil

	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
	end
end

function AB:FixKeybindText(button)
	local hotkey = _G[button:GetName().."HotKey"]
	local text = hotkey:GetText()

	if text then
		text = gsub(text, "SHIFT%-", L["KEY_SHIFT"])
		text = gsub(text, "ALT%-", L["KEY_ALT"])
		text = gsub(text, "CTRL%-", L["KEY_CTRL"])
		text = gsub(text, "BUTTON", L["KEY_MOUSEBUTTON"])
		text = gsub(text, "MOUSEWHEELUP", L["KEY_MOUSEWHEELUP"])
		text = gsub(text, "MOUSEWHEELDOWN", L["KEY_MOUSEWHEELDOWN"])
		text = gsub(text, "NUMPAD", L["KEY_NUMPAD"])
		text = gsub(text, "PAGEUP", L["KEY_PAGEUP"])
		text = gsub(text, "PAGEDOWN", L["KEY_PAGEDOWN"])
		text = gsub(text, "SPACE", L["KEY_SPACE"])
		text = gsub(text, "INSERT", L["KEY_INSERT"])
		text = gsub(text, "HOME", L["KEY_HOME"])
		text = gsub(text, "DELETE", L["KEY_DELETE"])
		text = gsub(text, "NMULTIPLY", "*")
		text = gsub(text, "NMINUS", "N-")
		text = gsub(text, "NPLUS", "N+")

		if hotkey:GetText() == _G["RANGE_INDICATOR"] then
			hotkey:SetText("")
		else
			hotkey:SetText(text)
		end
	end

	if self.db.hotkeytext == true then
		hotkey:Show()
	else
		hotkey:Hide()
	end

	hotkey:ClearAllPoints()
	hotkey:Point("TOPRIGHT", 0, -3)
end

function AB:ActionButton_Update()
	self:StyleButton(this);
end

function AB:Initialize()
	self.db = E.db.actionbar
	if E.private.actionbar.enable ~= true then return end
	E.ActionBars = AB

	self.fadeParent = CreateFrame("Frame", "Elv_ABFade", UIParent);
	self.fadeParent:SetAlpha(1 - self.db.globalFadeAlpha);
	self.fadeParent:RegisterEvent("PLAYER_REGEN_DISABLED");
	self.fadeParent:RegisterEvent("PLAYER_REGEN_ENABLED");
	self.fadeParent:RegisterEvent("PLAYER_TARGET_CHANGED");
	self.fadeParent:RegisterEvent("UNIT_SPELLCAST_START");
	self.fadeParent:RegisterEvent("UNIT_SPELLCAST_STOP");
	self.fadeParent:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
	self.fadeParent:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
	self.fadeParent:RegisterEvent("UNIT_HEALTH");
	self.fadeParent:RegisterEvent("PLAYER_FOCUS_CHANGED");
	self.fadeParent:SetScript("OnEvent", self.FadeParent_OnEvent);

	self:DisableBlizzard()

	self:SetupMicroBar()
	self:CreateActionBars()

	self:UpdateButtonSettings()
	--self:LoadKeyBinder()

	self:SecureHook("ActionButton_Update")
	self:SecureHook("PetActionBar_Update", "UpdatePet")
end

E:RegisterModule(AB:GetName())