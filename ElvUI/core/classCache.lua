local E, L, V, P, G = unpack(ElvUI)
local CC = E:NewModule("ClassCache", "AceEvent-3.0")
local LW = LibStub:GetLibrary("LibWho-2.0")

local split, upper = string.split, string.upper
local wipe = table.wipe
local pairs = pairs

local GetBattlefieldScore = GetBattlefieldScore
local GetFriendInfo = GetFriendInfo
local GetGuildRosterInfo = GetGuildRosterInfo
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetNumFriends = GetNumFriends
local GetNumGuildMembers = GetNumGuildMembers
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local GetTime = GetTime
local IsInGuild = IsInGuild
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitIsPlayer = UnitIsPlayer
local UnitName = UnitName

local UNKNOWN = UNKNOWN

local MYREALM = E.myrealm
local GAME_LOCALE = GetLocale()
local ENGLISH_CLASS_NAMES

local function GetEnglishClassName(class)
	if class == UNKNOWN then
		return class
	elseif GAME_LOCALE == "enUS" then
		return upper(class)
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
		CC:SendMessage("ClassCache_QueryResult", result.Name, result.NoLocaleClass)
	end
end

function CC:GetClassByName(name, realm)
	if not name or name == "" then return end
	if realm and realm == "" then return end

	local cacheDB = self:GetCacheTable()

	if realm then
		if cacheDB[realm] and cacheDB[realm][name] then
			return cacheDB[realm][name]
		else
			return
		end
	else
		if cacheDB[MYREALM][name] then
			return cacheDB[MYREALM][name]
		end
	end

	if E.db.general.classCacheRequestInfo and self.onBattleground ~= "arena" then
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
end

function CC:CachePlayer(name, class, realm)
	if not (name and class and class ~= UNKNOWN) then return end

	if realm and realm == "" then return end

	local cacheDB = self:GetCacheTable()
	realm = realm or MYREALM

	cacheDB[realm] = cacheDB[realm] or {}

	if cacheDB[realm][name] ~= class then
		CC:SendMessage("ClassCache_ClassUpdated", name, class)
	end

	cacheDB[realm][name] = class
end

function CC:SwitchCacheType(init)
	local newDB = self:GetCacheTable()

	newDB[MYREALM] = newDB[MYREALM] or {}
	newDB[MYREALM][E.myname] = E.myclass

	if not init then
		local oldDB = E.db.general.classCacheStoreInDB and self.tempCache or self.cache

		for realm in pairs(oldDB) do
			newDB[realm] = newDB[realm] or {}

			for name, class in pairs(oldDB[realm]) do
				newDB[realm][name] = class
			end
		end
	end
end

function CC:GetCacheTable()
	if E.db.general.classCacheStoreInDB then
		return self.cache
	else
		return self.tempCache
	end
end

function CC:GetCacheSize(global)
	if global and not (self.cacheDBCalculationTime + 30 < GetTime()) then
		return self.cacheDBSize > 1, self.cacheDBSize
	elseif not global and not (self.cacheLocalCalculationTime + 30 < GetTime()) then
		return self.cacheLocalSize > 1, self.cacheLocalSize
	end

	local size = 0
	local cacheDB = global and self.cache or self.tempCache

	for realm in pairs(cacheDB) do
		for _ in pairs(cacheDB[realm]) do
			size = size + 1
		end
	end

	if global then
		self.cacheDBSize = size
		self.cacheDBCalculationTime = GetTime()
	else
		self.cacheLocalSize = size
		self.cacheLocalCalculationTime = GetTime()
	end

	return size > 1, size
end

function CC:WipeCache(global)
	local cacheDB = global and self.cache or self.tempCache

	for realm in pairs(cacheDB) do
		wipe(cacheDB[realm])
	end

	wipe(cacheDB)
	self:SwitchCacheType(true)

	if global then
		self.cacheDBCalculationTime = 0
		E:Print(L["Class DB cache wiped."])
	else
		self.cacheLocalCalculationTime = 0
		E:Print(L["Class session cache wiped."])
	end
end

function CC:PLAYER_ENTERING_WORLD()
	local inInstance, instanceType = IsInInstance()
	self.inInstance = inInstance

	if instanceType == "arena" or instanceType == "pvp" then
		self.onBattleground = instanceType
	else
		self.onBattleground = false
	end

	if self.inInstance or self.onBattleground then
		self.lastNumPlayers = 0

		self:UnregisterEvent("PLAYER_TARGET_CHANGED")
		self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")

		self:UnregisterEvent("PARTY_MEMBERS_CHANGED")
		self:UnregisterEvent("RAID_ROSTER_UPDATE")

		self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")

		if self.onBattleground then
			self:UPDATE_BATTLEFIELD_SCORE()
		end
	else
		self.lastNumPlayers = 0

		self:RegisterEvent("PLAYER_TARGET_CHANGED")
		self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

		self:RegisterEvent("PARTY_MEMBERS_CHANGED")
		self:RegisterEvent("RAID_ROSTER_UPDATE")

		self:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
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
		name, _, classLocalized = GetFriendInfo(i)

		if class then
			self:CachePlayer(name, GetEnglishClassName(classLocalized))
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

		if self.onBattleground then
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

		if self.onBattleground then
			self:CachePlayer(name, class, realm)
		else
			self:CachePlayer(name, class)
		end
	end
end

function CC:PLAYER_TARGET_CHANGED()
	if not UnitExists("target") or not UnitIsPlayer("target") then return end

	local _, class = UnitClass("target")
	if not class then return end

	local name, realm = UnitName("target")

	if self.onBattleground then
		self:CachePlayer(name, class, realm)
	else
		self:CachePlayer(name, class)
	end
end

function CC:UPDATE_MOUSEOVER_UNIT()
	if not UnitExists("mouseover") or not UnitIsPlayer("mouseover") then return end

	local _, class = UnitClass("mouseover")
	if not class then return end

	local name, realm = UnitName("mouseover")

	if self.onBattleground then
		self:CachePlayer(name, class, realm)
	else
		self:CachePlayer(name, class)
	end
end

function CC:UPDATE_BATTLEFIELD_SCORE()
	local numPlayers = GetNumBattlefieldScores() or 0

	if self.lastNumPlayers == numPlayers then
		return
	elseif self.lastNumPlayers > numPlayers then
		self.lastNumPlayers = numPlayers
		return
	end

	local name, realm, class, _

	for i = 1, numPlayers do
		name, _, _, _, _, _, _, _, _, class = GetBattlefieldScore(i)

		if name and class then
			name, realm = split("-", name)
			self:CachePlayer(name, class, realm)
		end
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
	if E.private.general.classCache then
		if not self.initialized then
			self:SwitchCacheType(true)
			self.initialized = true
		end

		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("PLAYER_GUILD_UPDATE")

		self:RegisterEvent("FRIENDLIST_UPDATE")
		self:RegisterEvent("PARTY_MEMBERS_CHANGED")
		self:RegisterEvent("RAID_ROSTER_UPDATE")

		LW.RegisterCallback(self, "WHOLIB_QUERY_RESULT", "WHOLIB_QUERY_RESULT")
	else
		self:UnregisterAllEvents()
		LW.UnregisterAllCallbacks(self)
	end
end

function CC:Initialize()
	self.cache = E.global.classCache
	self.tempCache = {}

	self.cacheLocalCalculationTime = 0
	self.cacheDBCalculationTime = 0

	LW:SetWhoLibDebug(false)

	if E.private.general.classCache then
		self:ToggleModule()
	end
end

local function InitializeCallback()
	CC:Initialize()
end

E:RegisterModule(CC:GetName(), InitializeCallback)