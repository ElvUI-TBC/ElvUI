--Cache global variables
local strmatch = strmatch
--WoW API
local GetCVar = GetCVar
local IsAddOnLoaded = IsAddOnLoaded
local LoadAddOn = LoadAddOn
local UIParentLoadAddOn = UIParentLoadAddOn

local _ERROR_COUNT = 0
local _ERROR_LIMIT = 1000

function _ERRORMESSAGE_NEW(message)
	debuginfo()

	LoadAddOn("!DebugTools")
	local loaded = IsAddOnLoaded("!DebugTools")

	if (GetCVar("scriptErrors") == "1") then
		if (not loaded or DEBUG_DEBUGTOOLS) then
			ScriptErrors_Message:SetText(message)
			ScriptErrors:Show()
			if (DEBUG_DEBUGTOOLS) then
				ScriptErrorsFrame_OnError(message)
			end
		else
			ScriptErrorsFrame_OnError(message)
		end
	elseif (loaded) then
		ScriptErrorsFrame_OnError(message, true)
	end

	_ERROR_COUNT = _ERROR_COUNT + 1
	if (_ERROR_COUNT == _ERROR_LIMIT) then
		StaticPopup_Show("TOO_MANY_LUA_ERRORS")
	end

	return message
end

seterrorhandler(_ERRORMESSAGE_NEW)

function message(text)
	if (not ScriptErrors:IsShown()) then
		ScriptErrors_Message:SetText(text)
		ScriptErrors:Show()
	end
end

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