--[[
Name: LibMobHealth-4.0
Revision: $Rev: 42 $
Author: Cameron Kenneth Knight (ckknight@gmail.com)
Inspired By: MobHealth3 by Neronix
Website: http://www.wowace.com/
Description: Estimate a mob's health
License: LGPL v2.1
]]

local MAJOR_VERSION = "LibMobHealth-4.0"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 42 $"):match("%d+"))

local lib, oldMinor = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then
	return
end
local oldLib
if oldMinor then
	oldLib = {}
	for k,v in pairs(lib) do
		oldLib[k] = v
		lib[k] = nil
	end
end

local floor = math.floor
local next = next
local pairs = pairs
local setmetatable = setmetatable
local type = type

local GetInstanceDifficulty = GetInstanceDifficulty
local UnitCanAttack = UnitCanAttack
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsDead = UnitIsDead
local UnitIsFriend = UnitIsFriend
local UnitIsPlayer = UnitIsPlayer
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitPlayerControlled = UnitPlayerControlled

local frame
if oldLib then
	frame = oldLib.frame
	frame:UnregisterAllEvents()
	frame:SetScript("OnEvent", nil)
	frame:SetScript("OnUpdate", nil)
	LibMobHealth40DB = nil
end
frame = oldLib and oldLib.frame or CreateFrame("Frame", MAJOR_VERSION .. "_Frame")

frame:RegisterEvent("UNIT_COMBAT")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(this, event, ...)
	this[event](lib, ...)
end)

local mt = {__index = function(self, key)
	if key == nil then
		return nil
	end
	local t = {}
	self[key] = t
	return t
end}

local data = oldLib and oldLib.data
if data then
	setmetatable(data, nil)
	if not data.pc then
		local npc, pc, pet, legacy = {{}, {}, {}}, {}, {}, {}
		for k, v in pairs(data) do
			legacy[k] = v
			data[k] = nil
		end
		data.npc = npc
		setmetatable(npc[1], mt)
		setmetatable(npc[2], mt)
		setmetatable(npc[3], mt)
		data.pc = setmetatable(pc, mt)
		data.pet = setmetatable(pet, mt)
		data.legacy = setmetatable(legacy, mt)
	elseif not rawget(data.npc, 1) or not rawget(data.npc, 2) or not rawget(data.npc, 3) then
		data.npc = {setmetatable({}), setmetatable({}), setmetatable({})}
	end
else
	data = {
		npc = {setmetatable({}, mt), setmetatable({}, mt), setmetatable({}, mt),},
		pc = setmetatable({}, mt),
		pet = setmetatable({}, mt),
		legacy = setmetatable({}, mt)
	}
end
lib.data = data -- stores the maximum health of mobs that will actually be shown to the user
data.revision = MINOR_VERSION

local accumulatedHP = {setmetatable({}, mt), setmetatable({}, mt), setmetatable({}, mt)} -- Keeps Damage-taken data for mobs that we've actually poked during this session
local accumulatedPercent = {setmetatable({}, mt), setmetatable({}, mt), setmetatable({}, mt)} -- Keeps Percentage-taken data for mobs that we've actually poked during this session
local calculationUnneeded = {setmetatable({}, mt), setmetatable({}, mt), setmetatable({}, mt)} -- Keeps a list of things that don't need calculation (e.g. Beast Lore'd mobs)

local currentAccumulatedHP = {target = nil, focus = nil}
local currentAccumulatedPercent = {target = nil, focus = nil}
local currentName = {target = nil, focus = nil}
local currentLevel = {target = nil, focus = nil}
local recentDamage = {target = nil, focus = nil}
local lastPercent = {target = nil, focus = nil}


hash_SlashCmdList["LIBMOBHEALTHFOUR"] = nil
SlashCmdList["LIBMOBHEALTHFOUR"] = nil

function frame:ADDON_LOADED(name)
	if name == MAJOR_VERSION then
		-- if we're not an embedded library, then use a saved variable
		frame:RegisterEvent("PLAYER_LOGOUT")
		if type(LibMobHealth40DB) == "table" then
			data = LibMobHealth40DB
			if not data.pc then
				local npc, pc, pet, legacy = {{}, {}, {}}, {}, {}, {}
				for k, v in pairs(data) do
					legacy[k] = v
					data[k] = nil
				end
				data.npc = npc
				data.pc = pc
				data.pet = pet
				data.legacy = legacy
			elseif not rawget(data.npc, 1) or not rawget(data.npc, 2) or not rawget(data.npc, 3) then
				if not data.legacy then
					data.legacy = {}
				end
				for k, v in pairs(data.npc) do
					data.legacy[k] = v
					data.npc[k] = nil
				end
				data.npc = {{}, {}, {}}
			end
			setmetatable(data.npc[1], mt)
			setmetatable(data.npc[2], mt)
			setmetatable(data.npc[3], mt)
			setmetatable(data.pc, mt)
			setmetatable(data.pet, mt)
			if not data.legacy then
				data.legacy = {}
			end
			setmetatable(data.legacy, mt)
			lib.data = data
		else
			LibMobHealth40DB = data
		end

		local options = LibMobHealth40Opt
		if type(options) ~= "table" then
			options = {
				save = true,
				prune = 1000,
			}
			LibMobHealth40Opt = options
		end
		if type(options.save) ~= "boolean" then
			options.save = true
		end
		if type(options.prune) ~= "number" then
			options.prune = 1000
		end

		hash_SlashCmdList["LIBMOBHEALTHFOUR"] = nil
		SlashCmdList["LIBMOBHEALTHFOUR"] = function(text)
			text = text:lower():trim()
			local alpha, bravo = text:match("^([^%s]+)%s+(.*)$")
			if not alpha then
				alpha = text
			end
			if alpha == "" or alpha == "help" then
				DEFAULT_CHAT_FRAME:AddMessage(("|cffffff7f%s|r"):format(MAJOR_VERSION))
				DEFAULT_CHAT_FRAME:AddMessage((" - |cffffff7f%s|r [%s] - %s"):format("save", options.save and "|cff00ff00On|r" or "|cffff0000Off|r", "whether to save mob health data"))
				DEFAULT_CHAT_FRAME:AddMessage((" - |cffffff7f%s|r [%s] - %s"):format("prune", options.prune == 0 and "|cffff0000Off|r" or "|cff00ff00" .. options.prune .. "|r", "how many data points until data is pruned, 0 means no pruning"))
			elseif alpha == "save" then
				options.save = not options.save
				DEFAULT_CHAT_FRAME:AddMessage(("|cffffff7f%s|r"):format(MAJOR_VERSION))
				DEFAULT_CHAT_FRAME:AddMessage((" - |cffffff7f%s|r [%s]"):format("save", options.save and "|cff00ff00On|r" or "|cffff0000Off|r"))
			elseif alpha == "prune" then
				local bravo_num = tonumber(bravo)
				if bravo_num then
					options.prune = math.floor(bravo_num+0.5)
					DEFAULT_CHAT_FRAME:AddMessage(("|cffffff7f%s|r"):format(MAJOR_VERSION))
					DEFAULT_CHAT_FRAME:AddMessage((" - |cffffff7f%s|r [%s]"):format("prune", options.prune == 0 and "|cffff0000Off|r" or "|cff00ff00" .. options.prune .. "|r"))
				else
					DEFAULT_CHAT_FRAME:AddMessage(("|cffffff7f%s|r - prune must take a number, %q is not a number"):format(MAJOR_VERSION, bravo or ""))
				end
			else
				DEFAULT_CHAT_FRAME:AddMessage(("|cffffff7f%s|r - unknown command %q"):format(MAJOR_VERSION, alpha))
			end
		end

		SLASH_LIBMOBHEALTHFOUR1 = "/lmh4"
		SLASH_LIBMOBHEALTHFOUR2 = "/lmh"
		SLASH_LIBMOBHEALTHFOUR3 = "/libmobhealth4"
		SLASH_LIBMOBHEALTHFOUR4 = "/libmobhealth"

		function frame:PLAYER_LOGOUT()
			if not options.save then
				LibMobHealth40DB = nil
				return
			end
			local count = 0
			setmetatable(data.npc, nil)
			setmetatable(data.npc[1], nil)
			setmetatable(data.npc[2], nil)
			setmetatable(data.npc[3], nil)
			setmetatable(data.pc, nil)
			setmetatable(data.pet, nil)
			setmetatable(data.legacy, nil)
			for difficulty = 1, 3 do
				for k, v in pairs(data.npc[difficulty]) do
					if not next(v) then
						data.npc[difficulty][k] = nil
					else
						for _ in pairs(v) do
							count = count + 1
						end
					end
				end
			end
			for _, kind in ipairs({"pc", "pet", "legacy"}) do
				for k,v in pairs(data[kind]) do
					if not next(v) then
						data[kind][k] = nil
					else
						for _ in pairs(v) do
							count = count + 1
						end
					end
				end
			end
			if not next(data.legacy) then
				data.legacy = nil
			end
			local prune = options.prune
			if not prune or prune <= 0 then
				return
			end
			if count <= prune then
				return
			end

			if data.legacy then
				-- prune all legacy data
				for level, d in pairs(data.legacy) do
					for mob in pairs(d) do
						d[mob] = nil
						count = count - 1
					end
					data.legacy[level] = nil
				end
				if count <= prune then
					return
				end
			end

			-- let's try to only have one mob-level, don't have duplicates for each level, since they can be estimated, and for players/pets, this will get rid of old data
			for difficulty = 1, 3 do
				local mobs = {}
				for level, d in pairs(data.npc[difficulty]) do
					for mob, health in pairs(d) do
						if mobs[mob] then
							d[mob] = nil
							count = count - 1
						end
						mobs[mob] = level
					end
					if next(d) == nil then
						data.npc[difficulty][level] = nil
					end
				end
			end
			for _, kind in ipairs({"pc", "pet"}) do
				local mobs = {}
				for level, d in pairs(data[kind]) do
					for mob, health in pairs(d) do
						if mobs[mob] then
							d[mob] = nil
							count = count - 1
						end
						mobs[mob] = level
					end
					if next(d) == nil then
						data[kind][level] = nil
					end
				end
			end
			if count <= prune then
				return
			end
			-- still too much data, let's get rid of low-level non-bosses until we're at `prune`
			local playerLevel = UnitLevel("player")
			local maxLevel = playerLevel*3/4
			if maxLevel > playerLevel - 5 then
				maxLevel = playerLevel - 5
			end
			for level = 1, maxLevel do
				for difficulty = 1, 3 do
					local d = data.npc[difficulty][level]
					if d then
						for mob, health in pairs(d) do
							d[mob] = nil
							count = count - 1
						end
						data.npc[difficulty][level] = nil
						if count <= prune then
							return
						end
					end
				end
				for _, kind in ipairs({"pet", "pc"}) do
					local d = data[kind][level]
					if d then
						for mob, health in pairs(d) do
							d[mob] = nil
							count = count - 1
						end
						data[kind][level] = nil
						if count <= prune then
							return
						end
					end
				end
			end
		end
	end
	frame:UnregisterEvent("ADDON_LOADED")
	frame.ADDON_LOADED = nil
	if IsLoggedIn() then
		frame.PLAYER_LOGIN(self)
	end
end

function frame:PLAYER_LOGIN()
	if type(MobHealth3DB) == "table" then
		for index, value in pairs(MobHealth3DB) do
			if type(index) == "string" and type(value) == "number" then
				local name, level = index:match("^(.+):(%-?%d+)$")
				if name then
					level = level+0
					if not data.legacy[level][name] then
						data.legacy[level][name] = value
					end
				end
			end
		end
	end
	frame:UnregisterEvent("PLAYER_LOGIN")
	frame.PLAYER_LOGIN = nil
end

function frame:UNIT_COMBAT(unit, _, _, damage)
	if (unit ~= "target" and unit ~= "focus") or not currentAccumulatedHP[unit] then
		return
	end
	recentDamage[unit] = recentDamage[unit] + damage
end

local function PLAYER_unit_CHANGED(unit)
	if not UnitCanAttack("player", unit) or UnitIsDead(unit) or UnitIsFriend("player", unit) then
		-- don't store data on friends and dead men tell no tales
		currentAccumulatedHP[unit] = nil
		currentAccumulatedPercent[unit] = nil
		return
	end

	local name, server = UnitName(unit)
	if server and server ~= "" then
		name = name .. "-" .. server
	end
	local isPlayer = UnitIsPlayer(unit)
	local isPet = UnitPlayerControlled(unit) and not isPlayer -- some owners name their pets the same name as other people, because they're think they're funny. They're not.
	currentName[unit] = name
	local level = UnitLevel(unit)
	currentLevel[unit] = level

	recentDamage[unit] = 0
	lastPercent[unit] = UnitHealth(unit)

	local difficulty = 1
	if not isPlayer and not isPet then
		difficulty = GetInstanceDifficulty()
	end

	currentAccumulatedHP[unit] = accumulatedHP[difficulty][level][name]
	currentAccumulatedPercent[unit] = accumulatedPercent[difficulty][level][name]

	if not isPlayer and not isPet then
		-- Mob
		if not currentAccumulatedHP[unit] then
			local saved = data.npc[difficulty][level][name]
			if saved then
				-- We claim that the saved value is worth 100%
				accumulatedHP[difficulty][level][name] = saved
				accumulatedPercent[difficulty][level][name] = 100
			else
				-- Nothing previously known. Start fresh.
				accumulatedHP[difficulty][level][name] = 0
				accumulatedPercent[difficulty][level][name] = 0
			end
			currentAccumulatedHP[unit] = accumulatedHP[difficulty][level][name]
			currentAccumulatedPercent[unit] = accumulatedPercent[difficulty][level][name]
		end

		if currentAccumulatedPercent[unit] > 200 then
			-- keep accumulated percentage below 200% in case we hit mobs with different hp
			currentAccumulatedHP[unit] = currentAccumulatedHP[unit] / currentAccumulatedPercent[unit] * 100
			currentAccumulatedPercent[unit] = 100
		end
	else
		-- Player health can change a lot. Different gear, buffs, etc.. we only assume that we've seen 10% knocked off players previously
		if not currentAccumulatedHP[unit] then
			local saved = data[isPet and "pet" or "pc"][level][name]
			if saved then
				-- We claim that the saved value is worth 10%
				accumulatedHP[difficulty][level][name] = saved/10
				accumulatedPercent[difficulty][level][name] = 10
			else
				accumulatedHP[difficulty][level][name] = 0
				accumulatedPercent[difficulty][level][name] = 0
			end
			currentAccumulatedHP[unit] = accumulatedHP[difficulty][level][name]
			currentAccumulatedPercent[unit] = accumulatedPercent[difficulty][level][name]
		end

		if currentAccumulatedPercent[unit] > 10 then
			currentAccumulatedHP[unit] = currentAccumulatedHP[unit] / currentAccumulatedPercent[unit] * 10
			currentAccumulatedPercent[unit] = 10
		end
	end
end

function frame:PLAYER_TARGET_CHANGED()
	PLAYER_unit_CHANGED("target")
end

function frame:PLAYER_FOCUS_CHANGED()
	PLAYER_unit_CHANGED("focus")
end

function frame:UNIT_HEALTH(unit)
	if (unit ~= "target" and unit ~= "focus") or not currentAccumulatedHP[unit] then
		return
	end

	local current = UnitHealth(unit)

	if unit == "focus" and UnitIsUnit("target", "focus") then
		-- don't want to double-accumulate
		recentDamage[unit] = 0
		lastPercent[unit] = current
		return
	end

	local max = UnitHealthMax(unit)
	local name = currentName[unit]
	local level = currentLevel[unit]
	local difficulty = 1
	local kind
	if UnitIsPlayer(unit) then
		kind = "pc"
	elseif UnitPlayerControlled(unit) then
		kind = "pet"
	else
		kind = "npc"
		difficulty = GetInstanceDifficulty()
	end

	if calculationUnneeded[difficulty][level][name] then
		return
	elseif current == 0 then
		-- possibly targetting/focusing a dead person
	elseif max ~= 100 then
		-- beast lore, don't need to calculate.
		if kind == "npc" then
			data.npc[difficulty][level][name] = max
		else
			data[kind][level][name] = max
		end
		calculationUnneeded[difficulty][level][name] = true
	elseif current > lastPercent[unit] or lastPercent[unit] > 100 then
		-- it healed, so let's reset our ephemeral calculations
		lastPercent[unit] = current
		recentDamage[unit] = 0
	elseif recentDamage[unit] > 0 then
		if current ~= lastPercent[unit] then
			currentAccumulatedHP[unit] = currentAccumulatedHP[unit] + recentDamage[unit]
			currentAccumulatedPercent[unit] = currentAccumulatedPercent[unit] + (lastPercent[unit] - current)
			recentDamage[unit] = 0
			lastPercent[unit] = current

			if currentAccumulatedPercent[unit] >= 10 then
				local num = currentAccumulatedHP[unit] / currentAccumulatedPercent[unit] * 100
				if kind == "npc" then
					data.npc[difficulty][level][name] = num
				else
					data[kind][level][name] = num
				end
			end
		end
	end
end

local function guessAtMaxHealth(name, level, kind, difficulty, known)
	-- if we have data on a mob of the same name but a different level, check within two levels and guess from there.
	if not kind then
		return guessAtMaxHealth(name, level, "npc", GetInstanceDifficulty()) or guessAtMaxHealth(name, level, "pc") or guessAtMaxHealth(name, level, "pet") or guessAtMaxHealth(name, level, "legacy")
	elseif not difficulty then
		difficulty = 1
	end

	if kind == "npc" then
		local value = data.npc[difficulty][level][name]
		if value or level <= 0 or known then
			return value
		end
		if level > 1 then
			value = data.npc[difficulty][level - 1][name]
			if value then
				return value * level/(level - 1)
			end
		end
		value = data.npc[difficulty][level + 1][name]
		if value then
			return value * level/(level + 1)
		end
		if level > 2 then
			value = data.npc[difficulty][level - 2][name]
			if value then
				return value * level/(level - 2)
			end
		end
		value = data.npc[difficulty][level + 2][name]
		if value then
			return value * level/(level + 2)
		end
	else
		local value = data[kind][level][name]
		if value or level <= 0 or known then
			return value
		end
		if level > 1 then
			value = data[kind][level - 1][name]
			if value then
				return value * level/(level - 1)
			end
		end
		value = data[kind][level + 1][name]
		if value then
			return value * level/(level + 1)
		end
		if level > 2 then
			value = data[kind][level - 2][name]
			if value then
				return value * level/(level - 2)
			end
		end
		value = data[kind][level + 2][name]
		if value then
			return value * level/(level + 2)
		end
	end
	return nil
end

--[[
Arguments:
	string - name of the unit in question in the form of "Someguy", "Someguy-Some Realm"
	number - level of the unit in question
	string - kind of unit, can be "npc", "pc", "pet"
	[optional] number - difficulty of the unit, only applies to "npc". see http://wowwiki.com/API_GetInstanceDifficulty for details. Can be 1, 2, or 3. 1 by default.
	[optional] boolean - whether not to guess at the mob's health based on other levels of said mob.
Returns:
	number or nil - the maximum health of the unit or nil if unknown
Example:
	local hp = LibStub("LibMobHealth-4.0"):GetMaxHP("Young Wolf", 2)
]]
function lib:GetMaxHP(name, level, kind, difficulty, known)
	local value = guessAtMaxHealth(name, level, kind, difficulty, known)
	if value then
		return floor(value + 0.5)
	else
		return nil
	end
end

--[[
Arguments:
	string - a unit ID
Returns:
	number, boolean - the maximum health of the unit, whether the health is known or not
Example:
	local maxhp, found = LibStub("LibMobHealth-4.0"):GetUnitMaxHP("target")
]]
function lib:GetUnitMaxHP(unit)
	if not unit then return end

	local max = UnitHealthMax(unit)
	if max ~= 100 then
		return max, true
	end
	local name, server = UnitName(unit)
	if server and server ~= "" then
		name = name .. "-" .. server
	end
	local level = UnitLevel(unit)

	local kind
	local difficulty = 1
	if UnitIsPlayer(unit) then
		kind = "pc"
	elseif UnitPlayerControlled(unit) then
		kind = "pet"
	else
		kind = "npc"
		difficulty = GetInstanceDifficulty()
	end

	local value = guessAtMaxHealth(name, level, kind, difficulty)
	if value then
		return floor(value + 0.5), true
	else
		return max, false
	end
end

--[[
Arguments:
	string - a unit ID
Returns:
	number, boolean - the current health of the unit, whether the health is known or not
Example:
	local curhp, found = LibStub("LibMobHealth-4.0"):GetUnitCurrentHP("target")
]]
function lib:GetUnitCurrentHP(unit)
	if not unit then return end

	local current, max = UnitHealth(unit), UnitHealthMax(unit)
	if max ~= 100 then
		return current, true
	end

	local name, server = UnitName(unit)
	if server and server ~= "" then
		name = name .. "-" .. server
	end
	local level = UnitLevel(unit)

	local kind
	local difficulty = 1
	if UnitIsPlayer(unit) then
		kind = "pc"
	elseif UnitPlayerControlled(unit) then
		kind = "pet"
	else
		kind = "npc"
		difficulty = GetInstanceDifficulty()
	end

	local value = guessAtMaxHealth(name, level, kind, difficulty)
	if value then
		return floor(current/max * value + 0.5), true
	else
		return current, false
	end
end

--[[
Arguments:
	string - a unit ID
Returns:
	number, number, boolean - the current health of the unit, the maximum health of the unit, whether the health is known or not
Example:
	local curhp, maxhp, found = LibStub("LibMobHealth-4.0"):GetUnitHealth("target")
]]
function lib:GetUnitHealth(unit)
	if not unit then return end

	local current, max = UnitHealth(unit), UnitHealthMax(unit)
	if max ~= 100 then
		return current, max, true
	end

	local name, server = UnitName(unit)
	if server and server ~= "" then
		name = name .. "-" .. server
	end
	local level = UnitLevel(unit)

	local kind
	local difficulty = 1
	if UnitIsPlayer(unit) then
		kind = "pc"
	elseif UnitPlayerControlled(unit) then
		kind = "pet"
	else
		kind = "npc"
		difficulty = GetInstanceDifficulty()
	end

	local value = guessAtMaxHealth(name, level, kind, difficulty)
	if value then
		return floor(current/max * value + 0.5), floor(value + 0.5), true
	else
		return current, max, false
	end
end