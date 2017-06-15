local E, L, V, P, G = unpack(ElvUI)
local CC = E:NewModule("ChatCache", "AceEvent-3.0")

local LW = LibStub:GetLibrary("LibWho-2.0")

local find = string.find
local wipe = table.wipe
local pairs = pairs
local select = select

local GetFriendInfo = GetFriendInfo
local GetGuildRosterInfo = GetGuildRosterInfo
local GetNumFriends = GetNumFriends
local GetNumGuildMembers = GetNumGuildMembers
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local GetNumWhoResults = GetNumWhoResults
local GetRealZoneText = GetRealZoneText
local GetTime = GetTime
local GetWhoInfo = GetWhoInfo
local IsInGuild = IsInGuild
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitIsFriend = UnitIsFriend
local UnitIsPlayer = UnitIsPlayer
local UnitName = UnitName

local UNKNOWN = UNKNOWN
local WHO_TAG_CLASS = WHO_TAG_CLASS
local WHO_TAG_ZONE = WHO_TAG_ZONE

local GAME_LOCALE = GetLocale()
local ENGLISH_CLASS_NAMES

local function GetEnglishClassName(class)
	if class == UNKNOWN or GAME_LOCALE == "enUS" then
		return class
	end

	if not ENGLISH_CLASS_NAMES then
		ENGLISH_CLASS_NAMES = {}

		for english, localized in pairs(LOCALIZED_CLASS_NAMES_MALE) do
			ENGLISH_CLASS_NAMES[localized] = english
		end
		for english, localized in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
			ENGLISH_CLASS_NAMES[localized] = english
		end
	end

	return ENGLISH_CLASS_NAMES[class]
end

local function WhoCallback(result)
	if result and result.NoLocaleClass then
		CC:CachePlayer(result.Name, result.NoLocaleClass)
	end
end

function CC:GetClassByName(name, realm)
	if not name or name == "" then return end
	if realm and realm == "" then return end

	if self.db.classCacheStoreInDB then
		if realm then
			if self.cache[realm][name] then
				return self.cache[realm][name]
			else
				return
			end
		else
			if self.cache[E.myrealm][name] then
				return self.cache[E.myrealm][name]
			end
		end
	else
		if realm then
			if self.tempCache[realm][name] then
				return self.tempCache[realm][name]
			else
				return
			end
		else
			if self.tempCache[E.myrealm][name] then
				return self.tempCache[E.myrealm][name]
			end
		end
	end

	local result = LW:UserInfo(name, {
		queue = LW.WHOLIB_QUEUE_QUIET,
		timeout = 0,
		callback = function(result)
			WhoCallback(result)
		end
	})

	if result and result.NoLocaleClass then
		self:CachePlayer(result.Name, result.NoLocaleClass)
		return result.NoLocaleClass
	end
end

function CC:CachePlayer(name, class, realm)
	if not (name and class and class ~= UNKNOWN) then return end

	if realm and realm == "" then return end

	if self.db.classCacheStoreInDB then
		if realm and not self.cache[realm] then
			self.cache[realm] = {}
		end

		if realm then
			self.cache[realm][name] = class
		else
			self.cache[E.myrealm][name] = class
		end
	else
		if realm and not self.tempCache[realm] then
			self.tempCache[realm] = {}
		end

		if realm then
			self.tempCache[realm][name] = class
		else
			self.tempCache[E.myrealm][name] = class
		end
	end
end

function CC:SwitchCacheType()
	if self.db.classCacheStoreInDB then
		if not self.cache[E.myrealm] then
			self.cache[E.myrealm] = {}
		end

		if not self.cache[E.myrealm][E.myname] then
			self.cache[E.myrealm][E.myname] = E.myclass
		end

		for realm in pairs(self.tempCache) do
			if not self.cache[realm] then
				self.cache[realm] = {}
			end

			for name, class in pairs(self.tempCache[realm]) do
				self.cache[realm][name] = class
			end
		end
	else
		if not self.tempCache[E.myrealm] then
			self.tempCache[E.myrealm] = {}
		end

		if not self.tempCache[E.myrealm][E.myname] then
			self.tempCache[E.myrealm][E.myname] = E.myclass
		end

		for realm in pairs(self.cache) do
			if not self.cache[realm] then
				self.tempCache[realm] = {}
			end

			for name, class in pairs(self.cache[realm]) do
				self.tempCache[realm][name] = class
			end
		end
	end
end

function CC:GetCacheTable()
	if self.db.classCacheStoreInDB then
		return self.cache
	else
		return self.tempCache
	end
end

function CC:GetCacheSize(global)
	if not (self.cacheCalculationTime + 30 < GetTime()) then return self.cacheSize end

	local size = 0

	if global then
		for realm in pairs(self.cache) do
			for name in pairs(self.cache[realm]) do
				size = size + 1
			end
		end
	else
		for realm in pairs(self.tempCache) do
			for name in pairs(self.tempCache[realm]) do
				size = size + 1
			end
		end
	end

	self.cacheCalculationTime = GetTime()
	self.cacheSize = size

	return size > 1
end

function CC:WipeCache(global)
	if global then
		for realm in pairs(self.cache) do
			wipe(realm)
		end
		wipe(self.cache)

		E:Print(L["Class DB cache wiped."])
	else
		for realm in pairs(self.tempCache) do
			wipe(realm)
		end
		wipe(self.tempCache)

		E:Print(L["Class session cache wiped."])
	end

	self.cacheCalculationTime = 0
end

function CC:UpdateAggressiveMode()
	if self.db.classCacheAggressiveMode then
		if self.inInstance or self.inBattleground then
			self:UnregisterEvent("PLAYER_TARGET_CHANGED")
			self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
			self:UnregisterEvent("WORLD_MAP_UPDATE")
--			self:UnregisterEvent("CHAT_MSG_SYSTEM")
		else
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
			self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
			self:RegisterEvent("WORLD_MAP_UPDATE")
--			self:RegisterEvent("CHAT_MSG_SYSTEM")
		end
	end
end

function CC:UpdateCachingMode()
	if self.db.classCacheMode == "PASSIVE" then
		self:UnregisterAllEvents()
	else
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("PLAYER_GUILD_UPDATE")

		self:RegisterEvent("FRIENDLIST_UPDATE")
		self:RegisterEvent("PARTY_MEMBERS_CHANGED")
		self:RegisterEvent("RAID_ROSTER_UPDATE")

		self:PLAYER_ENTERING_WORLD()
	end
end

function CC:PLAYER_ENTERING_WORLD()
	if self.db.classCacheMode == "AGGRESSIVE" then
		self.inInstance = IsInInstance()
		self.inBattleground = UnitInBattleground("player") and true or false
		self:UpdateAggressiveMode()
	end

	self:PLAYER_GUILD_UPDATE()

	if not self.initUpdate then
		if GetNumRaidMembers() > 0 then
			self:RAID_ROSTER_UPDATE()
		elseif GetNumPartyMembers() > 0 then
			self:PARTY_MEMBERS_CHANGED()
		end

		self:GUILD_ROSTER_UPDATE(nil, true)

		self.initUpdate = true
	end
end

function CC:PLAYER_GUILD_UPDATE()
	if IsInGuild() then
		self:RegisterEvent("GUILD_ROSTER_UPDATE")
	else
		self:UnregisterEvent("RAID_ROSTER_UPDATE")
	end
end

function CC:FRIENDLIST_UPDATE()
	local name, class, _

	for i = 1, GetNumFriends() do
		name, _, class = GetFriendInfo(i)

		if class then
			self:CachePlayer(name, GetEnglishClassName(class))
		end
	end
end

function CC:GUILD_ROSTER_UPDATE(_, update)
	if not update then return end

	local name, class, _

	for i = 1, GetNumGuildMembers() do
		name, _, _, _, _, _, _, _, _, _, class = GetGuildRosterInfo(i)

		if class then
			self:CachePlayer(name, class)
		end
	end
end

function CC:PARTY_MEMBERS_CHANGED()
	local name, realm, class, _

	for i = 1, GetNumPartyMembers() do
		name, realm = UnitName("party"..i)
		_, class = UnitClass("party"..i)

		if not class then return end

		if self.inBattleground then
			self:CachePlayer(name, class, realm)
		else
			self:CachePlayer(name, class)
		end
	end
end

function CC:RAID_ROSTER_UPDATE()
	local name, realm, class, _

	for i = 1, GetNumRaidMembers() do
		name, realm = UnitName("raid"..i)
		_, class = UnitClass("raid"..i)

		if not class then return end

		if self.inBattleground then
			self:CachePlayer(name, class, realm)
		else
			self:CachePlayer(name, class)
		end
	end
end

function CC:PLAYER_TARGET_CHANGED()
	if not UnitExists("target") or not UnitIsPlayer("target") or not UnitIsFriend("player", "target") then return end

	local _, class = UnitClass("target")
	if not class then return end

	local name, realm = UnitName("target")

	if self.inBattleground then
		self:CachePlayer(name, class, realm)
	else
		self:CachePlayer(name, class)
	end
end

function CC:UPDATE_MOUSEOVER_UNIT()
	if not UnitExists("mouseover") or not UnitIsPlayer("mouseover") or not UnitIsFriend("player", "mouseover") then return end

	local _, class = UnitClass("mouseover")
	if not class then return end

	local name, realm = UnitName("mouseover")

	if self.inBattleground then
		self:CachePlayer(name, class, realm)
	else
		self:CachePlayer(name, class)
	end
end

function CC:CHAT_MSG_SYSTEM(_, msg)
	local name, class = select(3, find(msg, "^|Hplayer:%w+|h%[(%w+)%]|h: %w+ %d+ %w+ (%w+)"))

	if name and class then
		self:CachePlayer(name, GetEnglishClassName(class))
	end
end

function CC:WORLD_MAP_UPDATE()
	if self.inInstance or self.inBattleground then return end

	local zone = GetRealZoneText()
	if not zone then return end

	LW:Who(WHO_TAG_ZONE..zone, {
		queue = LW.WHOLIB_QUEUE_SCANNING,
		timeout = 0,
		callback = function(...)
			self:WHOLIB_QUERY_RESULT("WORLD_MAP_UPDATE", ...)
		end
	})
end

function CC:ForceCachingByClass()
	for _, class in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		LW:Who(WHO_TAG_CLASS..class, {
			queue = LW.WHOLIB_QUEUE_SCANNING,
			timeout = 0,
			callback = function(...)
				self:WHOLIB_QUERY_RESULT("FORCE_CLASS_CACHING", ...)
			end
		})
	end
end

function CC:WHOLIB_QUERY_RESULT(_, query, results, complete)
	for _, result in pairs(results) do
		if result and result.NoLocaleClass then
			self:CachePlayer(result.Name, result.NoLocaleClass)
		end
	end
end

function CC:ToggleModule()
	if E.private.chat.classCache then
		if not self.initialized then
			self:SwitchCacheType()

			self.initialized = true
		end

		self:UpdateCachingMode()
		LW.RegisterCallback(self, "WHOLIB_QUERY_RESULT", "WHOLIB_QUERY_RESULT")
	else
		self:UnregisterAllEvents()
		LW.UnregisterAllCallbacks(self)
	end
end

function CC:Initialize()
	self.db = E.db.chat
	self.cache = E.global.chat.classCache

	self.tempCache = {}
	self.cacheCalculationTime = 0

	LW:SetWhoLibDebug(false)

	if E.private.chat.enable and E.private.chat.classCache then
		self:ToggleModule()
	end
end

E:RegisterModule(CC:GetName())