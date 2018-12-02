local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule("DataTexts")

local unpack = unpack
local format, join = string.format, string.join
local time = time

local GetGameTime = GetGameTime
local GetNumSavedInstances = GetNumSavedInstances
local GetSavedInstanceInfo = GetSavedInstanceInfo
local SecondsToTime = SecondsToTime
local TIMEMANAGER_TOOLTIP_REALMTIME = TIMEMANAGER_TOOLTIP_REALMTIME

local europeDisplayFormat = join("", "%02d", ":|r%02d")
local instanceFormat = "%s |cffaaaaaa(%s)"
local timeDisplayFormat = ""
local dateDisplayFormat = ""
local enteredFrame = false

local lastPanel

local function OnClick(_, btn)
	if btn == "RightButton" then
		if not IsAddOnLoaded("Blizzard_TimeManager") then LoadAddOn("Blizzard_TimeManager") end

		TimeManagerClockButton_OnClick(TimeManagerClockButton)
	else
		GameTimeFrame:Click()
	end
end

local function OnLeave()
	DT.tooltip:Hide()

	enteredFrame = false
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	if not enteredFrame then
		RequestRaidInfo()

		enteredFrame = true
	end

	local oneraid
	local name, id, reset
	for i = 1, GetNumSavedInstances() do
		name, id, reset = GetSavedInstanceInfo(i)
		if name then
			if not oneraid then
				DT.tooltip:AddLine(L["Saved Instance(s)"])

				oneraid = true
			end

			DT.tooltip:AddDoubleLine(format(instanceFormat, name, id), SecondsToTime(reset, true), 1, 1, 1, 0.8, 0.8, 0.8)
		end

		if DT.tooltip:NumLines() > 0 then
			DT.tooltip:AddLine(" ")
		end
	end

	DT.tooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, format(europeDisplayFormat, GetGameTime()), 1, 1, 1, 0.8, 0.8, 0.8)

	DT.tooltip:Show()
end

local function OnEvent(self, event)
	if event == "UPDATE_INSTANCE_INFO" and enteredFrame then
		OnEnter(self)
	end
end

local int = 5
local function OnUpdate(self, t)
	int = int - t

	if int > 0 then return end

	if enteredFrame then
		OnEnter(self)
	end

	self.text:SetText(BetterDate(E.db.datatexts.timeFormat.." "..E.db.datatexts.dateFormat, time()):gsub(":", timeDisplayFormat):gsub("%s", dateDisplayFormat))

	lastPanel = self
	int = 1
end

local function ValueColorUpdate(hex)
	timeDisplayFormat = join("", hex, ":|r")
	dateDisplayFormat = join("", hex, " ")

	if lastPanel ~= nil then
		OnUpdate(lastPanel, 20000)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Time", {"UPDATE_INSTANCE_INFO"}, OnEvent, OnUpdate, OnClick, OnEnter, OnLeave)