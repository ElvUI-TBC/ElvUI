local select = select
local type = type

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

function print(...)
	if (select("#", ...) == 0) then return end

	local args, text = {}, ""

	if (select("#", ...) == 1) then
		if type(...) == "string" then
			text = ...
		else
			text = tostring(...)
		end
	elseif (select("#", ...) > 1) then
		args = {...}

		for i, arg in pairs(args) do
			if type(arg) == "string" then
				text = text.." "..arg
			else
				text = text.." "..tostring(arg)
			end
		end
	end
	DEFAULT_CHAT_FRAME:AddMessage(text);
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


string.join = function() end

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