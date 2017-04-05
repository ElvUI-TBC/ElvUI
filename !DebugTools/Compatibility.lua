--Cache global variables
local format, match = string.format, string.match
local tinsert, tsort, twipe = table.insert, table.sort, table.wipe
local fmod = math.fmod
local pairs = pairs
local tostring = tostring
--WoW API
local GetTime = GetTime

DEBUG_FRAMESTACK = "Frame Stack"
EVENTS_LABEL = "Events"
RELOADUI = "Reload UI"

local eventList = {}

local function EventHandler_OnEvent()
	tinsert(eventList, GetTime())
end

local eventHandler = CreateFrame("Frame", "EventHandler", UIParent)
eventHandler:SetScript("OnEvent", EventHandler_OnEvent)

function GetCurrentEventID()
	return #eventList
end

function GetEventTime(eventID)
	return eventList[eventID]
end

function EventHandler_Enable()
	eventHandler:RegisterAllEvents()
end

function EventHandler_Disable()
	eventHandler:UnregisterAllEvents()
	twipe(eventList)
end

local strataLevels = {
	["UNKNOWN"] = 1,
	["BACKGROUND"] = 2,
	["LOW"] = 3,
	["MEDIUM"] = 4,
	["HIGH"] = 5,
	["DIALOG"] = 6,
	["FULLSCREEN"] = 7,
	["FULLSCREEN_DIALOG"] = 8,
	["TOOLTIP"] = 9,
}

local colorSpecs = {
	"|cff6699ff",
	"|cff88dddd"
}

local activeColorSpecs = {
	"|cffff9966",
	"|cffdddd88"
}

local hiddenColorSpecs = {
	"|cff666666",
	"|cff888888"
}

local frameStackStrata = {}
local frameStackLevels = {}
local frameStackActive = {}
local frameStackList = {}

local function FrameStackSort(b, a)
	local sa = strataLevels[frameStackStrata[a]] or -1
	local sb = strataLevels[frameStackStrata[b]] or -1
	if sa < sb then
		return true
	elseif sa > sb then
		return
	end

	local sa = frameStackLevels[a] or -1
	local sb = frameStackLevels[b] or -1
	if sa < sb then
		return true
	elseif sa > sb then
		return
	end

	return a < b
end

function UpdateFrameStack(tooltip, showHidden)
	local x, y = GetCursorPosition()

	for i = 1, #frameStackList do
		frameStackList[i] = nil
	end

	for k in pairs(frameStackLevels) do
		frameStackLevels[k] = nil
		frameStackStrata[k] = nil
		frameStackActive[k] = nil
	end

	local f
	local nf = EnumerateFrames()

	while nf do
		f, nf = nf, EnumerateFrames(nf)
		local es = f:GetEffectiveScale() or 1

		local Fl, Fb, Fr, Ft = f:GetRect()
		Fl = Fl or -1
		Fb = Fb or -1
		Fr = Fl + (Fr or -1)
		Ft = Fb + (Ft or -1)

		if (x >= Fl * es) and (x <= Fr * es) and (y >= Fb * es) and (y <= Ft * es) then
			local n = f:GetName()
			if n and _G[n] == f then
				-- Name is ok
			elseif n then
				n = tostring(f) .. " (" .. n .. ")"
			else
				n = tostring(f)
			end

			local s = f:GetFrameStrata() or "nil"
			local l = f:GetFrameLevel() or -1
			local a

			if f:IsVisible() then
				if f:IsMouseEnabled() then
					a = activeColorSpecs
				else
					a = colorSpecs
				end
			elseif showHidden then
				a = hiddenColorSpecs
			else
				a = nil
			end

			if a then
				frameStackLevels[n] = l
				frameStackStrata[n] = s
				frameStackActive[n] = a

				tinsert(frameStackList, n)
			end
		end
	end

	frameStackList[#frameStackList + 1] = nil

	tsort(frameStackList, FrameStackSort)

	tooltip:ClearLines()
	tooltip:AddDoubleLine(DEBUG_FRAMESTACK, format("(%.2f,%.2f)", x, y), 1, 1, 1, 1, .82, 0)

	local cs, os, ol = 1, nil, nil
	local cn = #colorSpecs
	local highlighted
	local highlightFrame = GetMouseFocus()

	for _, n in ipairs(frameStackList) do
		local s, l, a = frameStackStrata[n], frameStackLevels[n], frameStackActive[n]
		if os ~= s then
			tooltip:AddLine(s, 1, 1, 1)
			os = s
			ol = nil
			cs = 1
		end

		if l ~= ol then
			cs = fmod(cs, cn) + 1
			ol = l
		end

		if not highlighted then
			local frameName = _G[n] or match(n, "%((.+)%)$") or n
			if frameName and frameName == highlightFrame then
				tooltip:AddLine("-->" .. (a[cs] or "|cff444444") .. "<" .. l .. "> " .. n .. "|r")
				highlighted = true
			else
				tooltip:AddLine("     " .. (a[cs] or "|cff444444") .. "<" .. l .. "> " .. n .. "|r")
			end
		else
			tooltip:AddLine("     " .. (a[cs] or "|cff444444") .. "<" .. l .. "> " .. n .. "|r")
		end
	end

	tooltip:Show()

	return highlightFrame
end