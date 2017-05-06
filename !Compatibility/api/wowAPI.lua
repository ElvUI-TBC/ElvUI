--Cache global variables
local date = date
local gsub = string.gsub
local strsub = string.sub
local strupper = string.upper
local strlower = string.lower
--WoW API
local GetQuestGreenRange = GetQuestGreenRange
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local UnitLevel = UnitLevel
--WoW Variables
local TIMEMANAGER_AM = TIMEMANAGER_AM
local TIMEMANAGER_PM = TIMEMANAGER_PM

CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1.0;
CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0.4;
CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1.0;
CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1.0;
CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 0.6;
CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0.2;

CHAT_FRAME_FADE_OUT_TIME = 2.0;
CHAT_FRAME_BUTTON_FRAME_MIN_ALPHA = 0.2;

CHAT_FRAME_NORMAL_MIN_HEIGHT = 120;
CHAT_FRAME_BIGGER_MIN_HEIGHT = 147;
CHAT_FRAME_MIN_WIDTH = 296;

CURRENT_CHAT_FRAME_ID = nil;

LOCALIZED_CLASS_NAMES_MALE = {}
LOCALIZED_CLASS_NAMES_FEMALE = {}

local accessIDs = {};
local nextAccessID = 1;

local accessIDToType = {};
local accessIDToTarget = {};

local maxTempIndex = NUM_CHAT_WINDOWS + 1;

function UnitAura(unit, i, filter)
	if filter == "HELPFUL" then
		local name, rank, aura, count, duration, maxDuration = UnitBuff(unit, i)
		return name, rank, aura, count, nil, duration, maxDuration
	else
		return UnitDebuff(unit, i)
	end
end

function BetterDate(formatString, timeVal)
	local dateTable = date("*t", timeVal)
	local amString = (dateTable.hour >= 12) and TIMEMANAGER_PM or TIMEMANAGER_AM

	--First, we'll replace %p with the appropriate AM or PM.
	formatString = gsub(formatString, "^%%p", amString)	--Replaces %p at the beginning of the string with the am/pm token
	formatString = gsub(formatString, "([^%%])%%p", "%1"..amString) -- Replaces %p anywhere else in the string, but doesn't replace %%p (since the first % escapes the second)

	return date(formatString, timeVal)
end

CLASS_ICON_TCOORDS = {
	["WARRIOR"] = {0, 0.25, 0, 0.25},
	["MAGE"] = {0.25, 0.49609375, 0, 0.25},
	["ROGUE"] = {0.49609375, 0.7421875, 0, 0.25},
	["DRUID"] = {0.7421875, 0.98828125, 0, 0.25},
	["HUNTER"] = {0, 0.25, 0.25, 0.5},
	["SHAMAN"] = {0.25, 0.49609375, 0.25, 0.5},
	["PRIEST"] = {0.49609375, 0.7421875, 0.25, 0.5},
	["WARLOCK"] = {0.7421875, 0.98828125, 0.25, 0.5},
	["PALADIN"] = {0, 0.25, 0.5, 0.75}
}

QuestDifficultyColors = {
	["impossible"] = {r = 1.00, g = 0.10, b = 0.10},
	["verydifficult"] = {r = 1.00, g = 0.50, b = 0.25},
	["difficult"] = {r = 1.00, g = 1.00, b = 0.00},
	["standard"] = {r = 0.25, g = 0.75, b = 0.25},
	["trivial"] = {r = 0.50, g = 0.50, b = 0.50},
	["header"] = {r = 0.70, g = 0.70, b = 0.70}
}

CHAT_CATEGORY_LIST = {
	PARTY = { "PARTY_LEADER", "PARTY_GUIDE", "MONSTER_PARTY" },
	RAID = { "RAID_LEADER", "RAID_WARNING" },
	WHISPER = { "WHISPER_INFORM", "AFK", "DND" },
	CHANNEL = { "CHANNEL_JOIN", "CHANNEL_LEAVE", "CHANNEL_NOTICE", "CHANNEL_USER" },
	BATTLEGROUND = { "BATTLEGROUND_LEADER" },
}

CHAT_INVERTED_CATEGORY_LIST = {}

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

function ToggleFrame(frame)
	if ( frame:IsShown() ) then
		HideUIPanel(frame);
	else
		ShowUIPanel(frame);
	end
end

function MainMenuMicroButton_SetPushed()
	MainMenuMicroButton:SetButtonState("PUSHED", 1);
end

function MainMenuMicroButton_SetNormal()
	MainMenuMicroButton:SetButtonState("NORMAL");
end

for category, sublist in pairs(CHAT_CATEGORY_LIST) do
	for _, item in pairs(sublist) do
		CHAT_INVERTED_CATEGORY_LIST[item] = category;
	end
end

function Chat_GetChatCategory(chatType)
	return CHAT_INVERTED_CATEGORY_LIST[chatType] or chatType;
end

function ChatHistory_GetAccessID(chatType, chatTarget)
	if ( not accessIDs[ChatHistory_GetToken(chatType, chatTarget)] ) then
		accessIDs[ChatHistory_GetToken(chatType, chatTarget)] = nextAccessID;
		accessIDToType[nextAccessID] = chatType;
		accessIDToTarget[nextAccessID] = chatTarget;
		nextAccessID = nextAccessID + 1;
	end
	return accessIDs[ChatHistory_GetToken(chatType, chatTarget)];
end

function ChatHistory_GetChatType(accessID)
	return accessIDToType[accessID], accessIDToTarget[accessID];
end

function ChatHistory_GetToken(chatType, chatTarget)
	return strlower(chatType)..";;"..(chatTarget and strlower(chatTarget) or "");
end