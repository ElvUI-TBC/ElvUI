local error = error
local geterrorhandler = geterrorhandler
local pairs = pairs
local pcall = pcall
local securecall = securecall
local select = select
local setmetatable, getmetatable = setmetatable, getmetatable
local tostring = tostring
local type = type
local unpack = unpack

local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff

function UnitAura(unit, i, filter)
	if filter == "HELPFUL" then
		return UnitBuff(unit, i)
	else
		return UnitDebuff(unit, i)
	end
end

--[[function GameTooltip.SetUnitAura(unit, i, filter)
	if filter == "HELPFUL" then
		return GameTooltip:SetUnitBuff(unit, i)
	else
		return GameTooltip:SetUnitDebuff(unit, i)
	end
end]]

function table.copy(t, deep, seen)
	if not t or type(t) ~= "table" then return end
	seen = seen or {}
	if seen[t] then return seen[t] end

	local temp = {}
	for k, v in pairs(t) do
		if deep and type(v) == "table" then
			temp[k] = table.copy(v, deep, seen)
		else
			temp[k] = v
		end
	end

	setmetatable(temp, table.copy(getmetatable(t), deep, seen))
	seen[t] = temp

	return temp
end

function table:wipe(t)
	if not t or type(t) ~= "table" then return end

	for k in pairs(t) do
		t[k] = nil
	end

	return t
end
wipe = table.wipe

-- Print
local LOCAL_ToStringAllTemp = {}
function tostringall(...)
	local n = select('#', ...)
	-- Simple versions for common argument counts
	if (n == 1) then
		return tostring(...)
	elseif (n == 2) then
		local a, b = ...
		return tostring(a), tostring(b)
	elseif (n == 3) then
		local a, b, c = ...
		return tostring(a), tostring(b), tostring(c)
	elseif (n == 0) then
		return
	end

	local needfix
	for i = 1, n do
		local v = select(i, ...)
		if (type(v) ~= "string") then
			needfix = i
			break
		end
	end
	if (not needfix) then return ... end

	wipe(LOCAL_ToStringAllTemp)
	for i = 1, needfix - 1 do
		LOCAL_ToStringAllTemp[i] = select(i, ...)
	end
	for i = needfix, n do
		LOCAL_ToStringAllTemp[i] = tostring(select(i, ...))
	end
	return unpack(LOCAL_ToStringAllTemp)
end

local LOCAL_PrintHandler = function(...)
	DEFAULT_CHAT_FRAME:AddMessage(strjoin(" ", tostringall(...)))
end

function setprinthandler(func)
	if (type(func) ~= "function") then
		error("Invalid print handler")
	else
		LOCAL_PrintHandler = func
	end
end

function getprinthandler() return LOCAL_PrintHandler end

local function print_inner(...)
	local ok, err = pcall(LOCAL_PrintHandler, ...)
	if (not ok) then
		local func = geterrorhandler()
		func(err)
	end
end

function print(...)
	securecall(pcall, print_inner, ...)
end

function _ERRORMESSAGE(message)
	debuginfo()
	print("Error: " .. message .. "\n")
	local stack = debugstack(4);
	print("Stack: " .. stack)

	return message;
end
seterrorhandler(_ERRORMESSAGE);

DEFAULT_CHAT_FRAME:SetMaxResize(1000, 1000)

function BetterDate(formatString, timeVal)
	local dateTable = date("*t", timeVal);
	local amString = (dateTable.hour >= 12) and TIMEMANAGER_PM or TIMEMANAGER_AM;
	
	--First, we'll replace %p with the appropriate AM or PM.
	formatString = gsub(formatString, "^%%p", amString)	--Replaces %p at the beginning of the string with the am/pm token
	formatString = gsub(formatString, "([^%%])%%p", "%1"..amString); -- Replaces %p anywhere else in the string, but doesn't replace %%p (since the first % escapes the second)
	
	return date(formatString, timeVal);
end

QuestDifficultyColors = {
	["impossible"] = {r = 1.00, g = 0.10, b = 0.10};
	["verydifficult"] = {r = 1.00, g = 0.50, b = 0.25};
	["difficult"] = {r = 1.00, g = 1.00, b = 0.00};
	["standard"] = {r = 0.25, g = 0.75, b = 0.25};
	["trivial"] = {r = 0.50, g = 0.50, b = 0.50};
	["header"] = {r = 0.70, g = 0.70, b = 0.70}
}

function GetQuestDifficultyColor(level)
	local levelDiff = level - UnitLevel("player")
	local color
	if levelDiff >= 5 then
		return QuestDifficultyColors["impossible"]
	elseif levelDiff >= 3 then
		return QuestDifficultyColors["verydifficult"]
	elseif levelDiff >= -2 then
		return QuestDifficultyColors["difficult"]
	elseif -levelDiff <= GetQuestGreenRange() then
		return QuestDifficultyColors["standard"]
	else
		return QuestDifficultyColors["trivial"]
	end
end