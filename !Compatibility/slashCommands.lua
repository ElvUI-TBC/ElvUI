local strmatch = strmatch
local UIParentLoadAddOn = UIParentLoadAddOn

SLASH_FRAMESTACK1 = "/framestack"
SLASH_FRAMESTACK2 = "/fstack"
SlashCmdList["FRAMESTACK"] = function(msg)
	UIParentLoadAddOn("!DebugTools")
	local showHiddenArg, showRegionsArg = strmatch(msg, "^%s*(%S+)%s+(%S+)%s*$")
	if (not showHiddenArg or not showRegionsArg) then
		showHiddenArg = strmatch(msg, "^%s*(%S+)%s*$")
		showRegionsArg = "1"
	end
	local showHidden = showHiddenArg == "true" or showHiddenArg == "1"
	local showRegions = showRegions == "true" or showRegionsArg == "1"

	FrameStackTooltip_Toggle(showHidden, showRegions)
end

SLASH_EVENTTRACE1 = "/eventtrace"
SLASH_EVENTTRACE2 = "/etrace"
SlashCmdList["EVENTTRACE"] = function(msg)
	UIParentLoadAddOn("!DebugTools")
	EventTraceFrame_HandleSlashCmd(msg)
end

SLASH_DUMP1 = "/dump"
SlashCmdList["DUMP"] = function(msg)
	UIParentLoadAddOn("!DebugTools")
	DevTools_DumpCommand(msg)
end