local E, L, V, P, G = unpack(ElvUI)
local AFK = E:NewModule("AFK", "AceEvent-3.0", "AceTimer-3.0")
local CH = E:GetModule("Chat")

local _G = _G
local floor = math.floor
local gsub, format = string.gsub, string.format

local CinematicFrame = CinematicFrame
local CreateFrame = CreateFrame
local GetBattlefieldStatus = GetBattlefieldStatus
local GetGuildInfo = GetGuildInfo
local GetScreenHeight = GetScreenHeight
local GetScreenWidth = GetScreenWidth
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local MoveViewLeftStart = MoveViewLeftStart
local MoveViewLeftStop = MoveViewLeftStop
local Screenshot = Screenshot
local SetCVar = SetCVar
local UnitCastingInfo = UnitCastingInfo
local UnitIsAFK = UnitIsAFK

local MAX_BATTLEFIELD_QUEUES = MAX_BATTLEFIELD_QUEUES
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local AFK_SPEED = 7.35

local ignoreKeys = {
	LALT = true,
	LSHIFT = true,
	RSHIFT = true
}

local printKeys = {
	["PRINTSCREEN"] = true,
}

if E.isMacClient then
	printKeys[_G["KEY_PRINTSCREEN_MAC"]] = true
end

function AFK:UpdateTimer()
	local time = GetTime() - self.startTime
	self.AFKMode.bottom.time:SetFormattedText("%02d:%02d", floor(time / 60), time % 60)
end

local function StopAnimation(self)
	self:SetSequenceTime(0, 0)
	self:SetScript("OnUpdate", nil)
	self:SetScript("OnAnimFinished", nil)
end

local function UpdateAnimation(self, elapsed)
	self.animTime = self.animTime + (elapsed * 1000)
	self:SetSequenceTime(67, self.animTime)

	if self.animTime >= 3000 then
		StopAnimation(self)
	end
end

local function OnAnimFinished(self)
	if self.animTime > 500 then
		StopAnimation(self)
	end
end

local recountVis
local function RecountVisability(save)
	if Recount and Recount.db and Recount.db.profile then
		if save then
			recountVis = Recount.db.profile.MainWindowVis
		else
			Recount.db.profile.MainWindowVis = recountVis
			RecountDB.profiles[Recount.db.keys.profile].MainWindowVis = recountVis
		end
	end
end

local LRC
local function RockConfigFix()
	if not LRC then
		LRC = LibStub("LibRockConfig-1.0", true)
	end
	if LRC then
		if LRC.base and LRC.base:IsShown() then
			LRC.base.addonChooser:Select(LRC.base.addonChooser.value)
		end
	end
end

function AFK:SetAFK(status)
	if status and not self.isAFK then
		if InspectFrame then
			InspectPaperDollFrame:Hide()
		end

		RecountVisability(true)
		UIParent:Hide()
		self.AFKMode:Show()
		RecountVisability()

		E.global.afkEnabled = true
		E.global.afkCameraSpeedYaw = GetCVar("cameraYawMoveSpeed")
		E.global.afkCameraSpeedPitch = GetCVar("cameraPitchMoveSpeed")

		SetCVar("cameraYawMoveSpeed", AFK_SPEED)
		SetCVar("cameraPitchMoveSpeed", E.global.afkCameraSpeedPitch)
		MoveViewLeftStart()

		if IsInGuild() then
			local guildName, guildRankName = GetGuildInfo("player")
			self.AFKMode.bottom.guild:SetFormattedText("%s - %s", guildName, guildRankName)
		else
			self.AFKMode.bottom.guild:SetText(L["No Guild"])
		end

		self.startTime = GetTime()
		self.timer = self:ScheduleRepeatingTimer("UpdateTimer", 1)

		self.AFKMode.chat:RegisterEvent("CHAT_MSG_WHISPER")
		self.AFKMode.chat:RegisterEvent("CHAT_MSG_GUILD")

		self.AFKMode.bottom.model:SetModelScale(1)
		self.AFKMode.bottom.model:RefreshUnit()
		self.AFKMode.bottom.model:SetModelScale(0.8)

		self.AFKMode.bottom.model.animTime = 0
		self.AFKMode.bottom.model:SetScript("OnUpdate", UpdateAnimation)
		self.AFKMode.bottom.model:SetScript("OnAnimFinished", OnAnimFinished)

		self.isAFK = true
	elseif not status and self.isAFK then
		self.AFKMode:Hide()
		UIParent:Show()

		E.global.afkEnabled = nil
		SetCVar("cameraYawMoveSpeed", E.global.afkCameraSpeedYaw)
		SetCVar("cameraPitchMoveSpeed", E.global.afkCameraSpeedPitch)

		MoveViewLeftStop()

		self:CancelTimer(self.timer)
		self.AFKMode.bottom.time:SetText("00:00")

		self.AFKMode.chat:UnregisterAllEvents()
		self.AFKMode.chat:Clear()

		self.isAFK = false

		RockConfigFix()
	end
end

function AFK:OnEvent(event, ...)
	if event == "PLAYER_REGEN_DISABLED" or event == "UPDATE_BATTLEFIELD_STATUS" then
		if event == "UPDATE_BATTLEFIELD_STATUS" then
			local status, _, instanceID
			for i = 1, MAX_BATTLEFIELD_QUEUES do
				status, _, instanceID = GetBattlefieldStatus(i)
				if instanceID ~= 0 then
					status = status
				end
			end
			local status = status
			if status == "confirm" then
				self:SetAFK(false)
			end
		else
			self:SetAFK(false)
		end

		if event == "PLAYER_REGEN_DISABLED" then
			self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
		end

		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	if not E.db.general.afk then return end

	if InCombatLockdown() or CinematicFrame:IsShown() then return end
	if UnitCastingInfo("player") ~= nil then
		--Don't activate afk if player is crafting stuff, check back in 30 seconds
		self:ScheduleTimer("OnEvent", 30)
		return
	end

	self:SetAFK(UnitIsAFK("player"))
end

function AFK:Toggle()
	if E.db.general.afk then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED", "OnEvent")
		self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
		self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", "OnEvent")

		SetCVar("autoClearAFK", "1")
	else
		self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS")

		self:CancelAllTimers()
	end
end

local function OnKeyDown(_, key)
	if ignoreKeys[key] then return end

	if printKeys[key] then
		Screenshot()
	else
		AFK:SetAFK(false)
		AFK:ScheduleTimer("OnEvent", 60)
	end
end

local function Chat_OnMouseWheel(self, delta)
	if delta == 1 and IsShiftKeyDown() then
		self:ScrollToTop()
	elseif delta == -1 and IsShiftKeyDown() then
		self:ScrollToBottom()
	elseif delta == -1 then
		self:ScrollDown()
	else
		self:ScrollUp()
	end
end

local function Chat_OnEvent(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
	local coloredName = CH:GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
	local type = strsub(event, 10)
	local info = ChatTypeInfo[type]

	local playerLink, _
	playerLink = "|Hplayer:"..arg2..":"..arg11..":".."|h"
	local message = arg1
	--Escape any % characters, as it may otherwise cause an "invalid option in format" error in the next step
	message = gsub(message, "%%", "%%%%")

	_, body = pcall(format, _G["CHAT_"..type.."_GET"]..message, playerLink.."["..coloredName.."]".."|h")

	if CH.db.shortChannels then
		body = gsub(body, "|Hchannel:(.-)|h%[(.-)%]|h", CH.ShortChannel)
		body = gsub(body, "^(.-|h) "..L["whispers"], "%1")
		body = gsub(body, "<".._G["AFK"]..">", "[|cffFF0000"..L["AFK"].."|r] ")
		body = gsub(body, "<"..DND..">", "[|cffE7E716"..L["DND"].."|r] ")
	end

	self:AddMessage(body, info.r, info.g, info.b, info.id)
end

function AFK:Initialize()
	if E.global.afkEnabled then
		SetCVar("cameraYawMoveSpeed", E.global.afkCameraSpeedYaw)
		SetCVar("cameraPitchMoveSpeed", E.global.afkCameraSpeedPitch)
		E.global.afkEnabled = nil
	end

	local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass]

	self.AFKMode = CreateFrame("Frame", "ElvUIAFKFrame")
	self.AFKMode:SetFrameLevel(1)
	self.AFKMode:SetScale(UIParent:GetScale())
	self.AFKMode:SetAllPoints(UIParent)
	self.AFKMode:Hide()
	self.AFKMode:EnableKeyboard(true)
	self.AFKMode:SetScript("OnKeyDown", OnKeyDown)

	self.AFKMode.chat = CreateFrame("ScrollingMessageFrame", "AFKChat", self.AFKMode)
	self.AFKMode.chat:Size(500, 200)
	self.AFKMode.chat:Point("TOPLEFT", self.AFKMode, "TOPLEFT", 4, -3)
	self.AFKMode.chat:FontTemplate()
	self.AFKMode.chat:SetJustifyH("LEFT")
	self.AFKMode.chat:SetMaxLines(500)
	self.AFKMode.chat:EnableMouseWheel(true)
	self.AFKMode.chat:SetFading(false)
	self.AFKMode.chat:SetMovable(true)
	self.AFKMode.chat:EnableMouse(true)
	self.AFKMode.chat:SetClampedToScreen(true)
	self.AFKMode.chat:SetClampRectInsets(-4, 3, 3, -4)
	self.AFKMode.chat:RegisterForDrag("LeftButton")
	self.AFKMode.chat:SetScript("OnDragStart", self.AFKMode.chat.StartMoving)
	self.AFKMode.chat:SetScript("OnDragStop", self.AFKMode.chat.StopMovingOrSizing)
	self.AFKMode.chat:SetScript("OnMouseWheel", Chat_OnMouseWheel)
	self.AFKMode.chat:SetScript("OnEvent", Chat_OnEvent)

	self.AFKMode.bottom = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.bottom:SetFrameLevel(0)
	self.AFKMode.bottom:SetTemplate("Transparent")
	self.AFKMode.bottom:Point("BOTTOM", self.AFKMode, "BOTTOM", 0, -E.Border)
	self.AFKMode.bottom:Width(GetScreenWidth() + (E.Border*2))
	self.AFKMode.bottom:Height(GetScreenHeight() * 0.1)

	self.AFKMode.bottom.logo = self.AFKMode:CreateTexture(nil, "OVERLAY")
	self.AFKMode.bottom.logo:Size(320, 150)
	self.AFKMode.bottom.logo:Point("CENTER", self.AFKMode.bottom, "CENTER", 0, 50)
	self.AFKMode.bottom.logo:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\logo")

	self.AFKMode.bottom.faction = self.AFKMode.bottom:CreateTexture(nil, "OVERLAY")
	self.AFKMode.bottom.faction:Point("BOTTOMLEFT", self.AFKMode.bottom, "BOTTOMLEFT", -20, -16)
	self.AFKMode.bottom.faction:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\"..E.myfaction.."-Logo")
	self.AFKMode.bottom.faction:Size(140)

	self.AFKMode.bottom.name = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.name:FontTemplate(nil, 20)
	self.AFKMode.bottom.name:SetFormattedText("%s - %s", E.myname, E.myrealm)
	self.AFKMode.bottom.name:Point("TOPLEFT", self.AFKMode.bottom.faction, "TOPRIGHT", -10, -28)
	self.AFKMode.bottom.name:SetTextColor(classColor.r, classColor.g, classColor.b)

	self.AFKMode.bottom.guild = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.guild:FontTemplate(nil, 20)
	self.AFKMode.bottom.guild:SetText(L["No Guild"])
	self.AFKMode.bottom.guild:Point("TOPLEFT", self.AFKMode.bottom.name, "BOTTOMLEFT", 0, -6)
	self.AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7)

	self.AFKMode.bottom.time = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.time:FontTemplate(nil, 20)
	self.AFKMode.bottom.time:SetText("00:00")
	self.AFKMode.bottom.time:Point("TOPLEFT", self.AFKMode.bottom.guild, "BOTTOMLEFT", 0, -6)
	self.AFKMode.bottom.time:SetTextColor(0.7, 0.7, 0.7)

	self.AFKMode.bottom.model = CreateFrame("PlayerModel", "ElvUIAFKPlayerModel", self.AFKMode.bottom)
	self.AFKMode.bottom.model:Point("BOTTOMRIGHT", self.AFKMode.bottom, "BOTTOMRIGHT", 120, -100)
	self.AFKMode.bottom.model:Size(800)
	self.AFKMode.bottom.model:SetFacing(6)
	self.AFKMode.bottom.model:SetUnit("player")

	self:Toggle()
end

local function InitializeCallback()
	AFK:Initialize()
end

E:RegisterModule(AFK:GetName(), InitializeCallback)