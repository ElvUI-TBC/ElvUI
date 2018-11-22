local MAJOR, MINOR = 'LibElvUIPlugin-1.0', 22
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

--Cache global variables
--Lua functions
local pairs, tonumber = pairs, tonumber
local format, gsub, strmatch, strsplit, strsub, strlen, ceil = format, gsub, strmatch, strsplit, strsub, strlen, ceil
--WoW API / Variables
local CreateFrame, IsAddOnLoaded = CreateFrame, IsAddOnLoaded
local GetAddOnMetadata = GetAddOnMetadata
local GetNumPartyMembers, GetNumRaidMembers = GetNumPartyMembers, GetNumRaidMembers
local GetLocale, IsInGuild = GetLocale, IsInGuild
local IsInInstance = IsInInstance
local SendAddonMessage = SendAddonMessage
--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: ElvUI

lib.plugins = {}
lib.index = 0
lib.groupSize = 0
lib.prefix = 'ElvUIPluginVC'
------------------------------
local MSG_OUTDATED = "Your version of %s %s is out of date (latest is version %s). You can download the latest version from https://github.com/ElvUI-TBC/ElvUI/"
local HDR_CONFIG = "Plugins"
local HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - Plugins Loaded  (Green means you have current version, Red means out of date)"
local INFO_BY = "by"
local INFO_VERSION = "Version:"
local INFO_NEW = "Newest:"
local LIBRARY = "Library"

if GetLocale() == "deDE" then
	MSG_OUTDATED = "Deine Version von %s %s ist veraltet (akutelle Version ist %s). Du kannst die aktuelle Version von https://github.com/ElvUI-TBC/ElvUI/ herunterrladen."
	HDR_CONFIG = "Plugins"
	HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - Plugins geladen (Grün bedeutet du hast die aktuelle Version, Rot bedeutet es ist veraltet)"
	INFO_BY = "von"
	INFO_VERSION = "Version:"
	INFO_NEW = "Neuste:"
	LIBRARY = "Bibliothek"
end

if GetLocale() == "ruRU" then
	MSG_OUTDATED = "Ваша версия %s %s устарела (последняя версия %s). Вы можете скачать последнюю версию на https://github.com/ElvUI-TBC/ElvUI/"
	HDR_CONFIG = "Плагины"
	HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - загруженные плагины (зеленый означает, что у вас последняя версия, красный - устаревшая)"
	INFO_BY = "от"
	INFO_VERSION = "Версия:"
	INFO_NEW = "Последняя:"
	LIBRARY = "Библиотека"
end
------------------------------
--
-- Plugin table format:
--	{ name (string) - The name of the plugin,
--		version (string) - The version of the plugin,
--		optionCallback (string) - The callback to call when ElvUI_Config is loaded
--	}
--
--
-- RegisterPlugin(name,callback)
--	Registers a module with the given name and option callback, pulls version info from metadata
--
------------------------------
function lib:RegisterPlugin(name, callback, isLib)
	local plugin = {
		name = name,
		callback = callback,
		version = name == MAJOR and MINOR or GetAddOnMetadata(name, 'Version')
	}

	if isLib then
		plugin.isLib = true
		plugin.version = 1
	end

	lib.plugins[name] = plugin

	if not lib.registeredPrefix then
		lib.VCFrame:RegisterEvent('CHAT_MSG_ADDON')
		lib.VCFrame:RegisterEvent('RAID_ROSTER_UPDATE')
		lib.VCFrame:RegisterEvent('PARTY_MEMBERS_CHANGED')
		lib.VCFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
		lib.registeredPrefix = true
	end

	local loaded = IsAddOnLoaded('ElvUI_Config')
	if not loaded then
		lib.CFFrame:RegisterEvent('ADDON_LOADED')
	elseif loaded then
		-- Need to update plugins list
		if name ~= MAJOR then
			ElvUI[1].Options.args.plugins.args.plugins.name = lib:GeneratePluginList()
		end

		if callback then callback() end
	end

	return plugin
end

local function SendVersionCheckMessage()
	lib:SendPluginVersionCheck(lib:GenerateVersionCheckMessage())
end

function lib:DelayedSendVersionCheck(delay)
	local E = ElvUI[1]

	if not E.SendPluginVersionCheck then
		ElvUI[1].SendPluginVersionCheck = SendVersionCheckMessage
	end

	if not lib.SendMessageTimer then
		lib.SendMessageTimer = E:ScheduleTimer('SendPluginVersionCheck', delay or 10)
	end
end

function lib:ConfigLoaded(_, addon)
	if addon == 'ElvUI_Config' then
		for _, plugin in pairs(lib.plugins) do
			if plugin.callback then
				plugin.callback()
			end
		end
	end
end

function lib:GenerateVersionCheckMessage()
	local list = ''
	for _, plugin in pairs(lib.plugins) do
		if plugin.name ~= MAJOR then
			list = list..plugin.name..'='..plugin.version..';'
		end
	end
	return list
end

function lib:GetPluginOptions()
	ElvUI[1].Options.args.plugins = {
        order = -10,
        type = 'group',
        name = HDR_CONFIG,
        guiInline = false,
        args = {
            pluginheader = {
                order = 1,
                type = 'header',
                name = format(HDR_INFORMATION, MINOR),
            },
            plugins = {
                order = 2,
                type = 'description',
                name = lib:GeneratePluginList(),
            },
        }
    }
end

function lib:VersionCheck(event, prefix, message, _, sender)
	local E = ElvUI[1]
	if (event == 'CHAT_MSG_ADDON' and prefix == lib.prefix) and (sender and message and not strmatch(message, '^%s-$')) then
		if not lib.myName then lib.myName = E.myname end
		if sender == lib.myName then return end

		if not E.pluginRecievedOutOfDateMessage then
			local name, version, plugin, Pname, Pver, ver
			for _, p in pairs({strsplit(';',message)}) do
				if not strmatch(p, '^%s-$') then
					name, version = strmatch(p, '([%w_]+)=([%d%p]+)')
					plugin = name and lib.plugins[name]

					if version and plugin and plugin.version and (plugin.version ~= 'BETA') then
						Pver, ver = tonumber(plugin.version), tonumber(version)
						if (ver and Pver) and (ver > Pver) then
							plugin.old, plugin.newversion = true, ver
							Pname = GetAddOnMetadata(plugin.name, 'Title')
							E:Print(format(MSG_OUTDATED, Pname, plugin.version, plugin.newversion))
							ElvUI[1].pluginRecievedOutOfDateMessage = true
						elseif (ver and Pver) and (ver < Pver) then
							lib:DelayedSendVersionCheck()
						end
					end
				end
			end
		end
	elseif event == 'RAID_ROSTER_UPDATE' or event == 'PARTY_MEMBERS_CHANGED' then
		local numRaid, numParty = GetNumRaidMembers(), GetNumPartyMembers() + 1
		local num = numRaid > 0 and numRaid or numParty
		if num ~= lib.groupSize then
			if num > 1 and num > lib.groupSize then
				lib:DelayedSendVersionCheck()
			end
			lib.groupSize = num
		end
	end
end

function lib:GeneratePluginList()
	local E, list = ElvUI[1], ''
	local author, Pname, color
	for _, plugin in pairs(lib.plugins) do
		if plugin.name ~= MAJOR then
			author = GetAddOnMetadata(plugin.name, "Author")
			Pname = GetAddOnMetadata(plugin.name, "Title") or plugin.name
			color = plugin.old and E:RGBToHex(1,0,0) or E:RGBToHex(0,1,0)
			list = list..Pname
			if author then list = list..' '..INFO_BY..' '..author end
			list = list..color..(plugin.isLib and ' '..LIBRARY or ' - '..INFO_VERSION..' '..plugin.version)
			if plugin.old then list = list..' ('..INFO_NEW..' '..plugin.newversion..')' end
			list = list..'|r\n'
		end
	end
	return list
end

function lib:ClearSendMessageTimer()
	lib.SendMessageTimer = nil
end

function lib:SendPluginVersionCheck(message)
	if (not message) or strmatch(message, '^%s-$') then
		lib.ClearSendMessageTimer()
		return
	end

	local ChatType
	if GetNumRaidMembers() > 1 then
		local _, instanceType = IsInInstance()
		ChatType = instanceType == 'pvp' and 'BATTLEGROUND' or 'RAID'
	elseif GetNumPartyMembers() > 0 then
		ChatType = 'PARTY'
	elseif IsInGuild() then
		ChatType = 'GUILD'
	end

	if not ChatType then
		lib.ClearSendMessageTimer()
		return
	end

	local delay, maxChar, msgLength = 0, 250, strlen(message)
	if msgLength > maxChar then
		local E, splitMessage = ElvUI[1]
		for _ = 1, ceil(msgLength/maxChar) do
			splitMessage = strmatch(strsub(message, 1, maxChar), ".+;")
			if splitMessage then -- incase the string is over 250 but doesnt contain `;`
				message = gsub(message, "^"..gsub(splitMessage, '([%(%)%.%%%+%-%*%?%[%^%$])','%%%1'), "")
				E:Delay(delay, SendAddonMessage, lib.prefix, splitMessage, ChatType)
				delay = delay + 1
				E:Delay(delay, lib.ClearSendMessageTimer) -- keep this after `delay = delay + 1`
			end
		end
	else
		SendAddonMessage(lib.prefix, message, ChatType)
		lib.ClearSendMessageTimer()
	end
end

lib.VCFrame = CreateFrame('Frame')
lib.VCFrame:SetScript('OnEvent', lib.VersionCheck)

lib.CFFrame = CreateFrame('Frame')
lib.CFFrame:SetScript('OnEvent', lib.ConfigLoaded)

lib:RegisterPlugin(MAJOR, lib.GetPluginOptions)