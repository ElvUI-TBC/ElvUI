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

CHAT_CATEGORY_LIST = {
	PARTY = { "PARTY_LEADER", "PARTY_GUIDE", "MONSTER_PARTY" },
	RAID = { "RAID_LEADER", "RAID_WARNING" },
	GUILD = { "GUILD_ACHIEVEMENT" },
	WHISPER = { "WHISPER_INFORM", "AFK", "DND" },
	CHANNEL = { "CHANNEL_JOIN", "CHANNEL_LEAVE", "CHANNEL_NOTICE", "CHANNEL_USER" },
	BATTLEGROUND = { "BATTLEGROUND_LEADER" },
};

CHAT_INVERTED_CATEGORY_LIST = {};

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

local function FCFManager_GetToken(chatType, chatTarget)
	return strlower(chatType)..(chatTarget and ";;"..strlower(chatTarget) or "");
end

function FCFManager_ShouldSuppressMessage(chatFrame, chatType, chatTarget)
	--Using GetToken probably isn't the best way to do this due to the string concatenation, but it's the easiest to get in quickly.
	if ( chatFrame.chatType and FCFManager_GetToken(chatType, chatTarget) == FCFManager_GetToken(chatFrame.chatType, chatFrame.chatTarget) ) then
		--This frame is a dedicated frame of this type, so we should always display.
		return false;
	end

	return false;
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

function FCF_CopyChatSettings(copyTo, copyFrom)
	local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(copyFrom:GetID());
	FCF_SetWindowColor(copyTo, r, g, b, 1);
	FCF_SetWindowAlpha(copyTo, a, 1);
	--If we're copying to a docked window, we don't want to copy locked.
	if ( not copyTo.isDocked ) then
		FCF_SetLocked(copyTo, locked);
	end
	FCF_SetChatWindowFontSize(nil, copyTo, fontSize);
end

function FCF_OpenTemporaryWindow(chatType, chatTarget, sourceChatFrame, selectWindow)
	local chatFrame, chatTab;
	for _, chatFrameName in pairs(CHAT_FRAMES) do
		local frame = _G[chatFrameName];
		if ( frame.isTemporary ) then
			if ( not frame.inUse and not frame.isDocked ) then
				chatFrame = frame;
				chatTab = _G[chatFrame:GetName().."Tab"];
				break;
			end
		end
	end

	--Copy chat settings from the source frame.
	FCF_CopyChatSettings(chatFrame, sourceChatFrame or DEFAULT_CHAT_FRAME);

	-- clear stale messages
	chatFrame:Clear();
	chatFrame.inUse = true;
	chatFrame.isTemporary = true;

	FCF_SetTemporaryWindowType(chatFrame, chatType, chatTarget);

	--Clear the edit box history.
	chatFrame.editBox:ClearHistory();

	--Close the Editbox
	chatFrame.editBox:Hide();

	-- Show the frame and tab
	chatFrame:Show();
	chatTab:Show();

	-- Dock the frame by default
	FCF_DockFrame(chatFrame, (#(DOCKED_CHAT_FRAMES)+1), selectWindow);
	return chatFrame;
end

function FCF_SetTemporaryWindowType(chatFrame, chatType, chatTarget)
	local chatTab = _G[chatFrame:GetName().."Tab"];
	--If the frame was already registered, unregister it.
	if ( chatFrame.isRegistered ) then
		chatFrame.isRegistered = false;
	end

	--Set the title text
	local name;
	if ( chatType == "WHISPER" ) then
		name = chatTarget;
	end
	FCF_SetWindowName(chatFrame, name);


	--Set up the window to receive the message types we want.
	chatFrame.chatType = chatType;
	chatFrame.chatTarget = chatTarget;

	ChatFrame_RemoveAllMessageGroups(chatFrame);
	ChatFrame_RemoveAllChannels(chatFrame);

	ChatFrame_AddMessageGroup(chatFrame, chatType);

	chatFrame.editBox:SetAttribute("chatType", chatType);
	chatFrame.editBox:SetAttribute("stickyType", chatType);

	-- Set up the colors
	local info = ChatTypeInfo[chatType];
	chatTab.selectedColorTable = { r = info.r, g = info.g, b = info.b };
	FCFTab_UpdateColors(chatTab, not chatFrame.isDocked or chatFrame == GetChatWindowInfo(DEFAULT_CHAT_FRAME:GetID()));

	--Register this frame
	FCFManager_RegisterDedicatedFrame(chatFrame, chatType, chatTarget);
	chatFrame.isRegistered = true;

	--The window name may have been updated, so update the dock and tabs.
	FCF_DockUpdate();
end

function FCFTab_UpdateColors(self, selected)
	if ( selected ) then
		self.leftSelectedTexture:Show();
		self.middleSelectedTexture:Show();
		self.rightSelectedTexture:Show();
	else
		self.leftSelectedTexture:Hide();
		self.middleSelectedTexture:Hide();
		self.rightSelectedTexture:Hide();
	end

	local colorTable = self.selectedColorTable or DEFAULT_TAB_SELECTED_COLOR_TABLE;

	if ( self.selectedColorTable ) then
		self:GetFontString():SetTextColor(colorTable.r, colorTable.g, colorTable.b);
	else
		self:GetFontString():SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end

	self.leftSelectedTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	self.middleSelectedTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	self.rightSelectedTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);

	self.leftHighlightTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	self.middleHighlightTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	self.rightHighlightTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	self.glow:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);

end

function FCFMin_UpdateColors(minFrame)
	--Color it.
	local colorTable = minFrame.selectedColorTable or DEFAULT_TAB_SELECTED_COLOR_TABLE;

	if ( minFrame.selectedColorTable ) then
		minFrame:GetFontString():SetTextColor(colorTable.r, colorTable.g, colorTable.b);
	else
		minFrame:GetFontString():SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end

	minFrame.leftHighlightTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	minFrame.middleHighlightTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	minFrame.rightHighlightTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	minFrame.glow:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
end

function FCFTab_UpdateAlpha(chatFrame)
	local chatTab = _G[chatFrame:GetName().."Tab"];
	if ( not chatFrame.isDocked or chatFrame == FCF_GetCurrentChatFrame(DEFAULT_CHAT_FRAME) ) then
		chatTab.mouseOverAlpha = CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA;
		chatTab.noMouseAlpha = CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA;
	else
		if ( chatTab.alerting ) then
			chatTab.mouseOverAlpha = CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA;
			chatTab.noMouseAlpha = CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA;
		else
			chatTab.mouseOverAlpha = CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA;
			chatTab.noMouseAlpha = CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA;
		end
	end

	-- If this is in the middle of fading, stop it, since we're about to set the alpha
	UIFrameFadeRemoveFrame(chatTab);

	if ( chatFrame.hasBeenFaded ) then
		chatTab:SetAlpha(chatTab.mouseOverAlpha);
	else
		chatTab:SetAlpha(chatTab.noMouseAlpha);
	end
end