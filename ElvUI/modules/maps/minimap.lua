local E, L, V, P, G = unpack(ElvUI)
local M = E:NewModule("Minimap", "AceEvent-3.0")
local LSM = E.LSM
E.Minimap = M

local _G = _G
local match, strsub = string.match, strsub

local CreateFrame = CreateFrame
local EasyMenu = EasyMenu
local GetMinimapZoneText = GetMinimapZoneText
local GetZonePVPInfo = GetZonePVPInfo
local InCombatLockdown = InCombatLockdown
local IsShiftKeyDown = IsShiftKeyDown
local Minimap_OnClick = Minimap_OnClick
local ToggleBattlefieldMinimap = ToggleBattlefieldMinimap
local ToggleCharacter = ToggleCharacter
local ToggleDropDownMenu = ToggleDropDownMenu
local ToggleFriendsFrame = ToggleFriendsFrame
local ToggleHelpFrame = ToggleHelpFrame
local ToggleLFGParentFrame = ToggleLFGParentFrame
local ToggleQuestLog = ToggleQuestLog
local ToggleSpellBook = ToggleSpellBook
local ToggleTalentFrame = ToggleTalentFrame
local ToggleTimeManager = ToggleTimeManager
local BATTLEFIELD_MINIMAP = BATTLEFIELD_MINIMAP
local CHARACTER_BUTTON = CHARACTER_BUTTON
local HELP_BUTTON = HELP_BUTTON
local LFG_TITLE = LFG_TITLE
local MINIMAP_LABEL = MINIMAP_LABEL
local PLAYER_V_PLAYER = PLAYER_V_PLAYER
local QUEST_LOG = QUEST_LOG
local SOCIAL_BUTTON = SOCIAL_BUTTON
local SPELLBOOK_ABILITIES_BUTTON = SPELLBOOK_ABILITIES_BUTTON
local TALENTS_BUTTON = TALENTS_BUTTON
local TIMEMANAGER_TITLE = TIMEMANAGER_TITLE

local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", E.UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{text = CHARACTER_BUTTON,
	func = function() ToggleCharacter("PaperDollFrame") end},
	{text = SPELLBOOK_ABILITIES_BUTTON,
	func = function() ToggleSpellBook(BOOKTYPE_SPELL) end},
	{text = TALENTS_BUTTON,
	func = ToggleTalentFrame},
	{text = QUEST_LOG,
	func = function() ToggleQuestLog() end},
	{text = SOCIAL_BUTTON,
	func = function() ToggleFriendsFrame() end},
	{text = L["Farm Mode"],
	func = FarmMode},
	{text = BATTLEFIELD_MINIMAP,
	func = ToggleBattlefieldMinimap},
	{text = TIMEMANAGER_TITLE,
	func = ToggleTimeManager},
	{text = PLAYER_V_PLAYER,
	func = function() ToggleCharacter("PVPFrame") end},
	{text = LFG_TITLE,
	func = function() ToggleLFGParentFrame() end},
	{text = HELP_BUTTON,
	func = ToggleHelpFrame},
}

function M:GetLocTextColor()
	local pvpType = GetZonePVPInfo()
	if pvpType == "sanctuary" then
		return 0.035, 0.58, 0.84
	elseif pvpType == "arena" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "friendly" then
		return 0.05, 0.85, 0.03
	elseif pvpType == "hostile" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "contested" then
		return 0.9, 0.85, 0.05
	else
		return 0.84, 0.03, 0.03
	end
end

function M:ADDON_LOADED(_, addon)
	if addon == "Blizzard_TimeManager" then
		TimeManagerClockButton:Kill()
	end
end

function M:Minimap_OnMouseUp(btn)
	local position = self:GetPoint()
	if btn == "MiddleButton" or (btn == "RightButton" and IsShiftKeyDown()) then
		if position:match("LEFT") then
			EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
		else
			EasyMenu(menuList, menuFrame, "cursor", -160, 0, "MENU", 2)
		end
	elseif btn == "RightButton" then
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "cursor")
	else
		Minimap_OnClick(self)
	end
end

function M:Minimap_OnMouseWheel(d)
	local zoomLevel = Minimap:GetZoom()
	if d > 0 and zoomLevel < 5 then
		Minimap:SetZoom(zoomLevel + 1)
	elseif d < 0 and zoomLevel > 0 then
		Minimap:SetZoom(zoomLevel - 1)
	end
end

function M:Update_ZoneText()
	if E.db.general.minimap.locationText == "HIDE" or not E.private.general.minimap.enable then return end
	Minimap.location:SetText(strsub(GetMinimapZoneText(), 1, 46))
	Minimap.location:SetTextColor(self:GetLocTextColor())
	Minimap.location:FontTemplate(LSM:Fetch("font", E.db.general.minimap.locationFont), E.db.general.minimap.locationFontSize, E.db.general.minimap.locationFontOutline)
end

function M:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UpdateSettings()
end

local isResetting
local function ResetZoom()
	Minimap:SetZoom(0)
	MinimapZoomIn:Enable()
	MinimapZoomOut:Disable()
	isResetting = false
end
local function SetupZoomReset(_, zoomLevel)
	if E.db.general.minimap.resetZoom.enable and not isResetting then
		isResetting = true
		E:Delay(E.db.general.minimap.resetZoom.time, ResetZoom)
	else
		E.private.general.minimap.zoomLevel = zoomLevel
	end
end
hooksecurefunc(Minimap, "SetZoom", SetupZoomReset)

function M:MINIMAP_UPDATE_ZOOM()
	if E.private.general.minimap.zoomLevel ~= Minimap:GetZoom() then
		Minimap:SetZoom(E.private.general.minimap.zoomLevel)
	end
end

function M:UpdateSettings()
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end

	E.MinimapSize = E.private.general.minimap.enable and E.db.general.minimap.size or 140
	E.MinimapWidth = E.MinimapSize
	E.MinimapHeight = E.MinimapSize

	if E.db.general.reminder.enable then
		E.RBRWidth = (E.MinimapHeight + ((E.Border - E.Spacing*3) * 5) + E.Border*3) / 7
	else
		E.RBRWidth = 0
	end

	if E.private.general.minimap.enable then
		Minimap:SetScale(E.MinimapSize / 140)
	end

	if LeftMiniPanel and RightMiniPanel then
		if E.db.datatexts.minimapPanels and E.private.general.minimap.enable then
			LeftMiniPanel:Show()
			RightMiniPanel:Show()
		else
			LeftMiniPanel:Hide()
			RightMiniPanel:Hide()
		end
	end

	if BottomMiniPanel then
		if E.db.datatexts.minimapBottom and E.private.general.minimap.enable then
			BottomMiniPanel:Show()
		else
			BottomMiniPanel:Hide()
		end
	end

	if BottomLeftMiniPanel then
		if E.db.datatexts.minimapBottomLeft and E.private.general.minimap.enable then
			BottomLeftMiniPanel:Show()
		else
			BottomLeftMiniPanel:Hide()
		end
	end

	if BottomRightMiniPanel then
		if E.db.datatexts.minimapBottomRight and E.private.general.minimap.enable then
			BottomRightMiniPanel:Show()
		else
			BottomRightMiniPanel:Hide()
		end
	end

	if TopMiniPanel then
		if E.db.datatexts.minimapTop and E.private.general.minimap.enable then
			TopMiniPanel:Show()
		else
			TopMiniPanel:Hide()
		end
	end

	if TopLeftMiniPanel then
		if E.db.datatexts.minimapTopLeft and E.private.general.minimap.enable then
			TopLeftMiniPanel:Show()
		else
			TopLeftMiniPanel:Hide()
		end
	end

	if TopRightMiniPanel then
		if E.db.datatexts.minimapTopRight and E.private.general.minimap.enable then
			TopRightMiniPanel:Show()
		else
			TopRightMiniPanel:Hide()
		end
	end

	if MMHolder then
		MMHolder:Width((E.MinimapWidth + E.Border + E.Spacing*3) + E.RBRWidth)

		if E.db.datatexts.minimapPanels then
			MMHolder:Height(E.MinimapHeight + (LeftMiniPanel and (LeftMiniPanel:GetHeight() + E.Border) or 24) + E.Spacing*3)
		else
			MMHolder:Height(E.MinimapHeight + E.Border + E.Spacing*3)
		end
	end

	if Minimap.location then
		Minimap.location:SetWidth(E.MinimapSize)

		if E.db.general.minimap.locationText ~= "SHOW" or not E.private.general.minimap.enable then
			Minimap.location:Hide()
		else
			Minimap.location:Show()
		end
	end

	if MinimapMover then
		MinimapMover:Size(MMHolder:GetSize())
	end

	if GameTimeFrame then
		if E.private.general.minimap.hideCalendar then
			GameTimeFrame:Hide()
		else
			local pos = E.db.general.minimap.icons.calendar.position or "TOPRIGHT"
			local scale = E.db.general.minimap.icons.calendar.scale or 1
			GameTimeFrame:ClearAllPoints()
			GameTimeFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.calendar.xOffset or 0, E.db.general.minimap.icons.calendar.yOffset or 0)
			GameTimeFrame:SetScale(scale)
			GameTimeFrame:Show()
		end
	end

	if MiniMapMailFrame then
		local pos = E.db.general.minimap.icons.mail.position or "TOPRIGHT"
		local scale = E.db.general.minimap.icons.mail.scale or 1
		MiniMapMailFrame:ClearAllPoints()
		MiniMapMailFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.mail.xOffset or 3, E.db.general.minimap.icons.mail.yOffset or 4)
		MiniMapMailFrame:SetScale(scale)
	end

	if MiniMapMeetingStoneFrame then
		local pos = E.db.general.minimap.icons.lfgEye.position or "BOTTOMRIGHT"
		local scale = E.db.general.minimap.icons.lfgEye.scale or 1
		MiniMapMeetingStoneFrame:ClearAllPoints()
		MiniMapMeetingStoneFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.lfgEye.xOffset or 3, E.db.general.minimap.icons.lfgEye.yOffset or 0)
		MiniMapMeetingStoneFrame:SetScale(scale)
	end

	if MiniMapBattlefieldFrame then
		local pos = E.db.general.minimap.icons.battlefield.position or "BOTTOMRIGHT"
		local scale = E.db.general.minimap.icons.battlefield.scale or 1
		MiniMapBattlefieldFrame:ClearAllPoints()
		MiniMapBattlefieldFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.battlefield.xOffset or 3, E.db.general.minimap.icons.battlefield.yOffset or 0)
		MiniMapBattlefieldFrame:SetScale(scale)
	end

	if ElvConfigToggle then
		if E.db.general.reminder.enable and E.db.datatexts.minimapPanels and E.private.general.minimap.enable then
			ElvConfigToggle:Show()
			ElvConfigToggle:Width(E.RBRWidth)
		else
			ElvConfigToggle:Hide()
		end
	end

	if ElvUI_ReminderBuffs then
		E:GetModule("ReminderBuffs"):UpdateSettings()
	end
end

local function MinimapPostDrag()
	MinimapCluster:ClearAllPoints()
	MinimapCluster:SetAllPoints(Minimap)
	MinimapBackdrop:ClearAllPoints()
	MinimapBackdrop:SetAllPoints(Minimap)
end

function M:Initialize()
	menuFrame:SetTemplate("Transparent", true)

	self:UpdateSettings()

	if not E.private.general.minimap.enable then
		Minimap:SetMaskTexture("Textures\\MinimapMask")
		return
	end

	function GetMinimapShape()
		return "SQUARE"
	end

	local mmholder = CreateFrame("Frame", "MMHolder", UIParent)
	mmholder:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -3, -3)
	mmholder:Width((E.MinimapWidth + 29) + E.RBRWidth)
	mmholder:Height(E.MinimapHeight + 53)
	Minimap:ClearAllPoints()
	if E.db.general.reminder.position == "LEFT" then
		Minimap:Point("TOPRIGHT", mmholder, "TOPRIGHT", -E.Border, -E.Border)
	else
		Minimap:Point("TOPLEFT", mmholder, "TOPLEFT", E.Border, -E.Border)
	end
	Minimap:SetMaskTexture("Interface\\ChatFrame\\ChatFrameBackground")
	Minimap.backdrop = CreateFrame("Frame", nil, UIParent)
	Minimap.backdrop:SetOutside(Minimap)
	Minimap.backdrop:SetFrameStrata(Minimap:GetFrameStrata())
	Minimap.backdrop:SetFrameLevel(Minimap:GetFrameLevel() - 1)
	Minimap.backdrop:SetTemplate("Default")
	Minimap:SetFrameLevel(Minimap:GetFrameLevel())
	Minimap:HookScript2("OnEnter", function(self)
		if E.db.general.minimap.locationText ~= "MOUSEOVER" or not E.private.general.minimap.enable then return end
		self.location:Show()
	end)

	Minimap:HookScript2("OnLeave", function(self)
		if E.db.general.minimap.locationText ~= "MOUSEOVER" or not E.private.general.minimap.enable then return end
		self.location:Hide()
	end)

	Minimap.location = Minimap:CreateFontString(nil, "OVERLAY")
	Minimap.location:FontTemplate(nil, nil, "OUTLINE")
	Minimap.location:Point("TOP", Minimap, "TOP", 0, -2)
	Minimap.location:SetJustifyH("CENTER")
	Minimap.location:SetJustifyV("MIDDLE")
	if E.db.general.minimap.locationText ~= "SHOW" or not E.private.general.minimap.enable then
		Minimap.location:Hide()
	end

	MinimapBorder:Hide()
	MinimapBorderTop:Hide()

	MinimapToggleButton:Hide()

	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()

	MiniMapVoiceChatFrame:Hide()

	MinimapNorthTag:Kill()

	MinimapZoneTextButton:Hide()

	MiniMapTracking:Kill()

	MiniMapMailBorder:Hide()
	MiniMapMailIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\mail")

	MiniMapBattlefieldBorder:Hide()

	MiniMapWorldMapButton:Hide()

	if TimeManagerClockButton then
		TimeManagerClockButton:Kill()
	end

	E:CreateMover(MMHolder, "MinimapMover", MINIMAP_LABEL, nil, nil, MinimapPostDrag, nil, nil, "maps,minimap")

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", M.Minimap_OnMouseWheel)
	Minimap:SetScript("OnMouseUp", M.Minimap_OnMouseUp)

	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_INDOORS", "Update_ZoneText")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update_ZoneText")
	self:RegisterEvent("MINIMAP_UPDATE_ZOOM")
	self:RegisterEvent("ADDON_LOADED")

	local fm = CreateFrame("Minimap", "FarmModeMap", E.UIParent)
	fm:Size(E.db.farmSize)
	fm:Point("TOP", E.UIParent, "TOP", 0, -120)
	fm:SetClampedToScreen(true)
	fm:CreateBackdrop("Default")
	fm:EnableMouseWheel(true)
	fm:SetScript("OnMouseWheel", M.Minimap_OnMouseWheel)
	fm:SetScript("OnMouseUp", M.Minimap_OnMouseUp)
	fm:RegisterForDrag("LeftButton", "RightButton")
	fm:SetMovable(true)
	fm:SetScript("OnDragStart", function(self) self:StartMoving() end)
	fm:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	fm:Hide()

	FarmModeMap:SetScript("OnShow", function()
		if AurasMover and not E:HasMoverBeenMoved("AurasMover") then
			AurasMover:ClearAllPoints()
			AurasMover:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -3, -3)
		end

		MinimapCluster:ClearAllPoints()
		MinimapCluster:SetAllPoints(FarmModeMap)
	end)

	FarmModeMap:SetScript("OnHide", function()
		if AurasMover and not E:HasMoverBeenMoved("AurasMover") then
			E:ResetMovers(L["Auras Frame"])
		end

		MinimapCluster:ClearAllPoints()
		MinimapCluster:SetAllPoints(Minimap)
	end)

	UIParent:HookScript("OnShow", function()
		if not FarmModeMap.enabled then
			FarmModeMap:Hide()
		end
	end)
end

local function InitializeCallback()
	M:Initialize()
end

E:RegisterInitialModule(M:GetName(), InitializeCallback)