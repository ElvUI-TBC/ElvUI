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
	MainMenuBarPerformanceBar:SetPoint("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 9, -36);
end

function MainMenuMicroButton_SetNormal()
	MainMenuMicroButton:SetButtonState("NORMAL");
	MainMenuBarPerformanceBar:SetPoint("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 10, -34);
end

function FCF_SavePositionAndDimensions(chatFrame)
	local centerX = chatFrame:GetLeft() + chatFrame:GetWidth() / 2;
	local centerY = chatFrame:GetBottom() + chatFrame:GetHeight() / 2;

	local horizPoint, vertPoint;
	local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight();
	local xOffset, yOffset;
	if ( centerX > screenWidth / 2 ) then
		horizPoint = "RIGHT";
		xOffset = (chatFrame:GetRight() - screenWidth)/screenWidth;
	else
		horizPoint = "LEFT";
		xOffset = chatFrame:GetLeft()/screenWidth;
	end

	if ( centerY > screenHeight / 2 ) then
		vertPoint = "TOP";
		yOffset = (chatFrame:GetTop() - screenHeight)/screenHeight;
	else
		vertPoint = "BOTTOM";
		yOffset = chatFrame:GetBottom()/screenHeight;
	end

	SetChatWindowShown(chatFrame:GetID(), vertPoint..horizPoint, xOffset, yOffset);
end

function ToggleChatColorNamesByClassGroup(checked, group)
	local info = ChatTypeGroup[group];
	if ( info ) then
		for key, value in pairs(info) do
			-- SetChatColorNameByClass(strsub(value, 10), checked);	--strsub gets rid of CHAT_MSG_
		end
	else
		-- SetChatColorNameByClass(group, checked);
	end
end

CHAT_CATEGORY_LIST = {
	PARTY = { "PARTY_LEADER", "PARTY_GUIDE", "MONSTER_PARTY" },
	RAID = { "RAID_LEADER", "RAID_WARNING" },
	GUILD = { "GUILD_ACHIEVEMENT" },
	WHISPER = { "WHISPER_INFORM", "AFK", "DND" },
	CHANNEL = { "CHANNEL_JOIN", "CHANNEL_LEAVE", "CHANNEL_NOTICE", "CHANNEL_USER" },
	BATTLEGROUND = { "BATTLEGROUND_LEADER" },
};

CHAT_INVERTED_CATEGORY_LIST = {};
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

local accessIDs = {};
local nextAccessID = 1;

local accessIDToType = {};
local accessIDToTarget = {};

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

--Private functions
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

local maxTempIndex = NUM_CHAT_WINDOWS + 1;
function FCF_OpenTemporaryWindow(chatType, chatTarget, sourceChatFrame, selectWindow)
	local chatFrame, chatTab, conversationIcon;
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

	if ( sourceChatFrame ) then
		--Stop displaying this type of chat in the old chat frame.
		if ( chatType == "WHISPER" ) then
			ChatFrame_ExcludePrivateMessageTarget(sourceChatFrame, chatTarget);
		end

		--Copy over messages
		local accessID = ChatHistory_GetAccessID(chatType, chatTarget);
		for i = 1, sourceChatFrame:GetNumMessages(accessID) do
			local text, accessID, lineID, extraData = sourceChatFrame:GetMessageInfo(i, accessID);
			local cType, cTarget = ChatHistory_GetChatType(extraData);

			local info = ChatTypeInfo[cType];
			chatFrame:AddMessage(text, info.r, info.g, info.b, lineID, false, accessID, extraData);
		end
		--Remove the messages from the old frame.
		sourceChatFrame:RemoveMessagesByAccessID(accessID);
	end

	--Close the Editbox
	chatFrame.editBox:Hide();

	-- Show the frame and tab
	chatFrame:Show();
	chatTab:Show();

	-- Dock the frame by default
	FCF_DockFrame(chatFrame, (#FCFDock_GetChatFrames(DOCKED_CHAT_FRAMES)+1), selectWindow);
	return chatFrame;
end

function FCF_SetTemporaryWindowType(chatFrame, chatType, chatTarget)
	local chatTab = _G[chatFrame:GetName().."Tab"];
	--If the frame was already registered, unregister it.
	if ( chatFrame.isRegistered ) then
		FCFManager_UnregisterDedicatedFrame(chatFrame, chatFrame.chatType, chatFrame.chatTarget);
		chatFrame.isRegistered = false;
	end

	--Set the title text
	local name;
	if ( chatType == "WHISPER" or chatType == "BN_WHISPER" ) then
		name = chatTarget;
	elseif ( chatType == "BN_CONVERSATION" ) then
		name = format(CONVERSATION_NAME, tonumber(chatTarget) + MAX_WOW_CHAT_CHANNELS);
	end
	FCF_SetWindowName(chatFrame, name);


	--Set up the window to receive the message types we want.
	chatFrame.chatType = chatType;
	chatFrame.chatTarget = chatTarget;

	ChatFrame_RemoveAllMessageGroups(chatFrame);
	ChatFrame_RemoveAllChannels(chatFrame);
	ChatFrame_ReceiveAllPrivateMessages(chatFrame);
	ChatFrame_ReceiveAllBNConversations(chatFrame);

	ChatFrame_AddMessageGroup(chatFrame, chatType);

	chatFrame.editBox:SetAttribute("chatType", chatType);
	chatFrame.editBox:SetAttribute("stickyType", chatType);

	if ( chatType == "WHISPER" or chatType == "BN_WHISPER" ) then
		chatFrame.editBox:SetAttribute("tellTarget", chatTarget);
		ChatFrame_AddPrivateMessageTarget(chatFrame, chatTarget);
	elseif ( chatType == "BN_CONVERSATION" ) then
		chatFrame.editBox:SetAttribute("channelTarget", chatTarget);
		ChatFrame_AddBNConversationTarget(chatFrame, chatTarget);
	end

	-- Set up the colors
	local info = ChatTypeInfo[chatType];
	chatTab.selectedColorTable = { r = info.r, g = info.g, b = info.b };
	FCFTab_UpdateColors(chatTab, not chatFrame.isDocked or chatFrame == FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK));

	--If it's a conversation, create the conversation button
	if ( chatType == "BN_CONVERSATION" or chatType == "BN_WHISPER" ) then
		if ( chatFrame.conversationButton ) then
			BNConversationButton_UpdateTarget(chatFrame.conversationButton);
			chatFrame.conversationButton:Show();
		else
			CreateFrame("Button", chatFrame:GetName().."ConversationButton", chatFrame.buttonFrame, "BNConversationRosterButtonTemplate", chatFrame:GetID());
		end
		if ( chatFrame:GetHeight() < CHAT_FRAME_BIGGER_MIN_HEIGHT ) then
			chatFrame:SetHeight(CHAT_FRAME_BIGGER_MIN_HEIGHT);
		end
		chatFrame:SetMinResize(CHAT_FRAME_MIN_WIDTH, CHAT_FRAME_BIGGER_MIN_HEIGHT);
	else
		if ( chatFrame.conversationButton ) then
			chatFrame.conversationButton:Hide();
		end
		chatFrame:SetMinResize(CHAT_FRAME_MIN_WIDTH, CHAT_FRAME_NORMAL_MIN_HEIGHT);
	end

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

	if ( self.conversationIcon ) then
		self.conversationIcon:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	end

	local minimizedFrame = _G["ChatFrame"..self:GetID().."Minimized"];
	if ( minimizedFrame ) then
		minimizedFrame.selectedColorTable = self.selectedColorTable;
		FCFMin_UpdateColors(minimizedFrame);
	end
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

function FCF_StartAlertFlash(chatFrame)
	if ( chatFrame.minFrame ) then
		UIFrameFlash(chatFrame.minFrame.glow, 1.0, 1.0, -1, false, 0, 0, "chat");

		chatFrame.minFrame.alerting = true;
	end

	local chatTab = _G[chatFrame:GetName().."Tab"];
	UIFrameFlash(chatTab.glow, 1.0, 1.0, -1, false, 0, 0, "chat");

	chatTab.alerting = true;

	FCFTab_UpdateAlpha(chatFrame);

	FCFDockOverflowButton_UpdatePulseState(GENERAL_CHAT_DOCK.overflowButton);
end

function FCFDockOverflowButton_UpdatePulseState(self)
	local dock = self:GetParent();
	local shouldPulse = false;
	for _, chatFrame in pairs(FCFDock_GetChatFrames(dock)) do
		local chatTab = _G[chatFrame:GetName().."Tab"];
		if ( not chatFrame.isStaticDocked and chatTab.alerting) then
			--Make sure the rects are valid. (Not always the case when resizing the WoW client
			if ( not chatTab:GetRight() or not dock.scrollFrame:GetRight() ) then
				return false;
			end
			--Check if it's off the screen.
			local DELTA = 3;	--Chosen through experimentation
			if ( chatTab:GetRight() < (dock.scrollFrame:GetLeft() + DELTA) or chatTab:GetLeft() > (dock.scrollFrame:GetRight() - DELTA) ) then
				shouldPulse = true;
				break;
			end
		end
	end

	if ( shouldPulse ) then
		UIFrameFlash(self:GetHighlightTexture(), 1.0, 1.0, -1, true, 0, 0, "chat");
		self:LockHighlight();
		self.alerting = true;
	else
		UIFrameFlashStop(self:GetHighlightTexture());
		self:UnlockHighlight();
		self:GetHighlightTexture():Show();
		self.alerting = false;
	end

	if ( self.list:IsShown() ) then
		FCFDockOverflowList_Update(self.list, dock);
	end
	return true;
end