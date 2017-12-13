--Cache global variables
local strmatch = strmatch
--WoW API
local IsAddOnLoaded = IsAddOnLoaded

local checked
local function LoadDebugTools()
	if checked then return end

	local _, _, _, loadable, _, reason = GetAddOnInfo("!DebugTools")
	checked = true

	if reason == "MISSING" then return end

	if loadable then
		LoadAddOn("!DebugTools")
	else
		EnableAddOn("!DebugTools")
		LoadAddOn("!DebugTools")
		DisableAddOn("!DebugTools")
	end
end

SLASH_FRAMESTACK1 = "/framestack"
SLASH_FRAMESTACK2 = "/fstack"
SlashCmdList["FRAMESTACK"] = function(msg)
	LoadDebugTools()

	if IsAddOnLoaded("!DebugTools") then
		local showHiddenArg, showRegionsArg = strmatch(msg, "^%s*(%S+)%s+(%S+)%s*$")
		if (not showHiddenArg or not showRegionsArg) then
			showHiddenArg = strmatch(msg, "^%s*(%S+)%s*$")
			showRegionsArg = "1"
		end
		local showHidden = showHiddenArg == "true" or showHiddenArg == "1"
		local showRegions = showRegions == "true" or showRegionsArg == "1"

		FrameStackTooltip_Toggle(showHidden, showRegions)
	end
end

SLASH_EVENTTRACE1 = "/eventtrace"
SLASH_EVENTTRACE2 = "/etrace"
SlashCmdList["EVENTTRACE"] = function(msg)
	LoadDebugTools()

	if IsAddOnLoaded("!DebugTools") then
		EventTraceFrame_HandleSlashCmd(msg)
	end
end

SLASH_DUMP1 = "/dump"
SlashCmdList["DUMP"] = function(msg)
	LoadDebugTools()

	if IsAddOnLoaded("!DebugTools") then
		DevTools_DumpCommand(msg)
	end
end