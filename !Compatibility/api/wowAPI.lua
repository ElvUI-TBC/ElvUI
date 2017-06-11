--Cache global variables
local date = date
local format, gsub, lower, match, upper = string.format, string.gsub, string.lower, string.match, string.upper
local pairs = pairs
--WoW API
local GetCurrentDungeonDifficulty = GetCurrentDungeonDifficulty
local GetQuestGreenRange = GetQuestGreenRange
local GetRealZoneText = GetRealZoneText
local IsInInstance = IsInInstance
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local UnitLevel = UnitLevel
--WoW Variables
local TIMEMANAGER_AM = TIMEMANAGER_AM
local TIMEMANAGER_PM = TIMEMANAGER_PM
--Libs
local LBC = LibStub("LibBabble-Class-3.0"):GetLookupTable()
local LBZ = LibStub("LibBabble-Zone-3.0"):GetLookupTable()

CLASS_SORT_ORDER = {
	"WARRIOR",
	"PALADIN",
	"PRIEST",
	"SHAMAN",
	"DRUID",
	"ROGUE",
	"MAGE",
	"WARLOCK",
	"HUNTER"
}
MAX_CLASSES = #CLASS_SORT_ORDER

LOCALIZED_CLASS_NAMES_MALE = {}
LOCALIZED_CLASS_NAMES_FEMALE = {}

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

DEFAULT_TAB_SELECTED_COLOR_TABLE = {r = 1, g = 0.5, b = 0.25}

CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1.0
CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0.4
CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1.0
CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1.0
CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 0.6
CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0.2

CHAT_FRAME_FADE_OUT_TIME = 2.0
CHAT_FRAME_BUTTON_FRAME_MIN_ALPHA = 0.2

CHAT_FRAME_NORMAL_MIN_HEIGHT = 120
CHAT_FRAME_BIGGER_MIN_HEIGHT = 147
CHAT_FRAME_MIN_WIDTH = 296

CHAT_FRAMES = {
	"ChatFrame1",
	"ChatFrame2",
	"ChatFrame3",
	"ChatFrame4",
	"ChatFrame5",
	"ChatFrame6",
	"ChatFrame7",
}

CHAT_CATEGORY_LIST = {
	PARTY = {"PARTY_LEADER", "PARTY_GUIDE", "MONSTER_PARTY"},
	RAID = {"RAID_LEADER", "RAID_WARNING"},
	WHISPER = {"WHISPER_INFORM", "AFK", "DND"},
	CHANNEL = {"CHANNEL_JOIN", "CHANNEL_LEAVE", "CHANNEL_NOTICE", "CHANNEL_USER"},
	BATTLEGROUND = {"BATTLEGROUND_LEADER"},
}

CHAT_INVERTED_CATEGORY_LIST = {}

function UnitAura(unit, i, filter)
	if match(filter, "\|*(HELPFUL)") then
		local name, rank, aura, count, duration, maxDuration = UnitBuff(unit, i, filter)
		return name, rank, aura, count, nil, duration, maxDuration
	else
		return UnitDebuff(unit, i, filter)
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

function FillLocalizedClassList(tab, female)
	if not (tab and type(tab) == "table") then return end

	for _, engClass in ipairs(CLASS_SORT_ORDER) do
		if female then
			tab[engClass] = LBC[engClass]
		else
			tab[engClass] = LBC[engClass:lower():gsub("^%l", upper)]
		end
	end

	return true
end

FillLocalizedClassList(LOCALIZED_CLASS_NAMES_MALE)
FillLocalizedClassList(LOCALIZED_CLASS_NAMES_FEMALE, true)

local zoneInfo = {
	-- Battlegrounds
	[LBZ["Warsong Gulch"]] = {mapID = 443, maxPlayers = 10},
	[LBZ["Arathi Basin"]] = {mapID = 461, maxPlayers = 15},
	[LBZ["Alterac Valley"]] = {mapID = 401, maxPlayers = 40},
	-- TBC
	[LBZ["Eye of the Storm"]] = {mapID = 566, maxPlayers = 15},

	-- Raids
	[LBZ["Zul'Gurub"]] = {mapID = 309, maxPlayers = 20},
	[LBZ["Onyxia's Lair"]] = {mapID = 249, maxPlayers = 40},
	[LBZ["Molten Core"]] = {mapID = 409, maxPlayers = 40},
	[LBZ["Ruins of Ahn'Qiraj"]] = {mapID = 509, maxPlayers = 20},
	[LBZ["Temple of Ahn'Qiraj"]] = {mapID = 531, maxPlayers = 40},
	[LBZ["Blackwing Lair"]] = {mapID = 469, maxPlayers = 40},
--	[LBZ["Naxxramas"]] = {mapID = 533, maxPlayers = 40},
	-- TBC
	[LBZ["Karazhan"]] = {mapID = 532, maxPlayers = 10},
	[LBZ["Gruul's Lair"]] = {mapID = 565, maxPlayers = 25},
	[LBZ["Magtheridon's Lair"]] = {mapID = 544, maxPlayers = 25},
	[LBZ["Zul'Aman"]] = {mapID = 568, maxPlayers = 10},
	[LBZ["Serpentshrine Cavern"]] = {mapID = 548, maxPlayers = 25},
	[LBZ["The Eye"]] = {mapID = 550, maxPlayers = 25},
	[LBZ["Hyjal Summit"]] = {mapID = 534, maxPlayers = 25},
	[LBZ["Black Temple"]] = {mapID = 564, maxPlayers = 25},
	[LBZ["Sunwell Plateau"]] = {mapID = 580, maxPlayers = 25},
}

local mapByID = {}
for mapName in pairs(zoneInfo) do
	mapByID[zoneInfo[mapName].mapID] = mapName
end

local function GetMaxPlayersByType(instanceType, zoneName)
	if instanceType == "none" then
		return 40
	elseif instanceType == "party" then
		return 5
	elseif instanceType == "arena" then
		return 5
	elseif zoneName ~= "" and zoneInfo[zoneName] then
		if instanceType == "pvp" then
			return zoneInfo[zoneName].maxPlayers
		elseif instanceType == "raid" then
			return zoneInfo[zoneName].maxPlayers
		end
	else
		return 0
	end
end

function GetInstanceInfo()
	local inInstance, instanceType = IsInInstance()
	if not inInstance then return end

	local name = GetRealZoneText()

	local difficulty = GetCurrentDungeonDifficulty()
	local difficultyName = difficulty == 1 and DUNGEON_DIFFICULTY1 or DUNGEON_DIFFICULTY2
	local maxPlayers = GetMaxPlayersByType(instanceType, name)

	difficultyName = format("%d %s", maxPlayers, difficultyName)

	return name, instanceType, difficulty, difficultyName, maxPlayers
end

function GetCurrentMapAreaID()
	if not IsInInstance() then return end
	local zoneName = GetRealZoneText()

	if zoneName ~= "" and zoneInfo[zoneName] then
		return zoneInfo[zoneName].mapID
	else
		return 0
	end
end

function GetMapNameByID(id)
	if not id then return end

	if type(id) == "string" then
		tonumber(id)
	end

	assert(type(id) == "number", "Bad argument #1 to `GetMapNameByID' (number expected)")

	return mapByID[id] or nil
end

function ToggleFrame(frame)
	if frame:IsShown() then
		HideUIPanel(frame)
	else
		ShowUIPanel(frame)
	end
end

function MainMenuMicroButton_SetPushed()
	MainMenuMicroButton:SetButtonState("PUSHED", 1)
end

function MainMenuMicroButton_SetNormal()
	MainMenuMicroButton:SetButtonState("NORMAL")
end

local dedicatedWindows = {}

local accessIDs = {}
local nextAccessID = 1

local accessIDToType = {}
local accessIDToTarget = {}

local maxTempIndex = NUM_CHAT_WINDOWS + 1

for category, sublist in pairs(CHAT_CATEGORY_LIST) do
	for _, item in pairs(sublist) do
		CHAT_INVERTED_CATEGORY_LIST[item] = category
	end
end

function Chat_GetChatCategory(chatType)
	return CHAT_INVERTED_CATEGORY_LIST[chatType] or chatType
end

function ChatHistory_GetAccessID(chatType, chatTarget)
	if not accessIDs[ChatHistory_GetToken(chatType, chatTarget)] then
		accessIDs[ChatHistory_GetToken(chatType, chatTarget)] = nextAccessID
		accessIDToType[nextAccessID] = chatType
		accessIDToTarget[nextAccessID] = chatTarget
		nextAccessID = nextAccessID + 1
	end
	return accessIDs[ChatHistory_GetToken(chatType, chatTarget)]
end

function ChatHistory_GetChatType(accessID)
	return accessIDToType[accessID], accessIDToTarget[accessID]
end

function ChatHistory_GetToken(chatType, chatTarget)
	return lower(chatType)..";;"..(chatTarget and lower(chatTarget) or "")
end

function FCF_OpenTemporaryWindow(chatType, chatTarget, sourceChatFrame, selectWindow)
	local chatFrame, chatTab
	for _, chatFrameName in pairs(CHAT_FRAMES) do
		local frame = _G[chatFrameName]
		if frame.isTemporary then
			if not frame.inUse and not frame.isDocked then
				chatFrame = frame
				chatTab = _G[chatFrame:GetName().."Tab"]
				break
			end
		end
	end

	if not chatFrame then
		chatTab = CreateFrame("Button", "ChatFrame"..maxTempIndex.."Tab", UIParent, "ChatTabTemplate", maxTempIndex)

		local tabText = _G[chatTab:GetName().."Text"]
		tabText:SetPoint("LEFT", chatTab, "RIGHT", 10, -6)
		tabText:SetJustifyH("LEFT")
		chatTab.sizePadding = 10

		chatFrame = CreateFrame("ScrollingMessageFrame", "ChatFrame"..maxTempIndex, UIParent, "FloatingChatFrameTemplate", maxTempIndex)
		chatFrame:SetScript("OnMouseWheel", FloatingChatFrame_OnMouseScroll)
		chatFrame:EnableMouseWheel(true)

		maxTempIndex = maxTempIndex + 1
	end

	--Copy chat settings from the source frame.
	FCF_CopyChatSettings(chatFrame, sourceChatFrame or DEFAULT_CHAT_FRAME)

	-- clear stale messages
	chatFrame:Clear()
	chatFrame.inUse = true
	chatFrame.isTemporary = true

	FCF_SetTemporaryWindowType(chatFrame, chatType, chatTarget)

	if sourceChatFrame then
		--Stop displaying this type of chat in the old chat frame.
		if chatType == "WHISPER" then
			ChatFrame_ExcludePrivateMessageTarget(sourceChatFrame, chatTarget)
		end

		--Copy over messages
		local accessID = ChatHistory_GetAccessID(chatType, chatTarget)
--[[
		for i = 1, sourceChatFrame:GetNumMessages(accessID) do
			local text, accessID, lineID, extraData = sourceChatFrame:GetMessageInfo(i, accessID)
			local cType, cTarget = ChatHistory_GetChatType(extraData)

			local info = ChatTypeInfo[cType]
			chatFrame:AddMessage(text, info.r, info.g, info.b, lineID, false, accessID, extraData)
		end
]]
		--Remove the messages from the old frame.
		sourceChatFrame:RemoveChatWindowMessages(accessID)
	end

	--Close the Editbox
--	ChatEdit_DeactivateChat(chatFrame.editBox)

	-- Show the frame and tab
	chatFrame:Show()
	chatTab:Show()

	-- Dock the frame by default
	FCF_DockFrame(chatFrame, (#FCFDock_GetChatFrames(DEFAULT_CHAT_FRAME)+1), selectWindow)

	return chatFrame
end

function FCF_SetTemporaryWindowType(chatFrame, chatType, chatTarget)
	local chatTab = _G[chatFrame:GetName().."Tab"]
	--If the frame was already registered, unregister it.
	if chatFrame.isRegistered then
		FCFManager_UnregisterDedicatedFrame(chatFrame, chatFrame.chatType, chatFrame.chatTarget)
		chatFrame.isRegistered = false
	end

	--Set the title text
	local name
	if chatType == "WHISPER" then
		name = chatTarget
	end
	FCF_SetWindowName(chatFrame, name)

	--Set up the window to receive the message types we want.
	chatFrame.chatType = chatType
	chatFrame.chatTarget = chatTarget

	ChatFrame_RemoveAllMessageGroups(chatFrame)
	ChatFrame_RemoveAllChannels(chatFrame)
	ChatFrame_ReceiveAllPrivateMessages(chatFrame)

	ChatFrame_AddMessageGroup(chatFrame, chatType)

	chatFrame.editBox:SetAttribute("chatType", chatType)
	chatFrame.editBox:SetAttribute("stickyType", chatType)

	if chatType == "WHISPER" then
		chatFrame.editBox:SetAttribute("tellTarget", chatTarget)
		ChatFrame_AddPrivateMessageTarget(chatFrame, chatTarget)
	end

	-- Set up the colors
	local info = ChatTypeInfo[chatType]
	chatTab.selectedColorTable = {r = info.r, g = info.g, b = info.b}
	FCFTab_UpdateColors(chatTab, not chatFrame.isDocked or chatFrame == FCFDock_GetSelectedWindow(DEFAULT_CHAT_FRAME))

	chatFrame:SetMinMaxValues(CHAT_FRAME_MIN_WIDTH, CHAT_FRAME_NORMAL_MIN_HEIGHT)

	--Register this frame
	FCFManager_RegisterDedicatedFrame(chatFrame, chatType, chatTarget)
	chatFrame.isRegistered = true

	--The window name may have been updated, so update the dock and tabs.
	FCF_DockUpdate()
end

function ChatEdit_DeactivateChat(editBox)
	if ACTIVE_CHAT_EDIT_BOX == editBox then
		ACTIVE_CHAT_EDIT_BOX = nil
	end

	ChatEdit_SetDeactivated(editBox)
end

local function ChatEdit_SetDeactivated(editBox)
	editBox:SetFrameStrata("LOW")
	editBox:SetText("")
	editBox.header:Hide()
	editBox:SetAlpha(0.35)
	editBox:ClearFocus()

	editBox.focusLeft:Hide()
	editBox.focusRight:Hide()
	editBox.focusMid:Hide()
end

function FCFManager_UnregisterDedicatedFrame(chatFrame, chatType, chatTarget)
	local token = FCFManager_GetToken(chatType, chatTarget)
	local windowList = dedicatedWindows[token]

	if windowList then
		tDeleteItem(windowList, chatFrame)
	end
end

function FCFTab_UpdateColors(self, selected)
	if selected then
		self.leftSelectedTexture:Show()
		self.middleSelectedTexture:Show()
		self.rightSelectedTexture:Show()
	else
		self.leftSelectedTexture:Hide()
		self.middleSelectedTexture:Hide()
		self.rightSelectedTexture:Hide()
	end

	local colorTable = self.selectedColorTable or DEFAULT_TAB_SELECTED_COLOR_TABLE

	if self.selectedColorTable then
		self:GetFontString():SetTextColor(colorTable.r, colorTable.g, colorTable.b)
	else
		self:GetFontString():SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	end

	self.leftSelectedTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b)
	self.middleSelectedTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b)
	self.rightSelectedTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b)

	self.leftHighlightTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b)
	self.middleHighlightTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b)
	self.rightHighlightTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b)
	self.glow:SetVertexColor(colorTable.r, colorTable.g, colorTable.b)

	if self.conversationIcon then
		self.conversationIcon:SetVertexColor(colorTable.r, colorTable.g, colorTable.b)
	end

	local minimizedFrame = _G["ChatFrame"..self:GetID().."Minimized"]
	if minimizedFrame then
		minimizedFrame.selectedColorTable = self.selectedColorTable
		FCFMin_UpdateColors(minimizedFrame)
	end
end

function FCFDock_GetSelectedWindow(dock)
	return dock.selected
end

function FCFTab_UpdateAlpha(chatFrame)
	local chatTab = _G[chatFrame:GetName().."Tab"]

	if not chatFrame.isDocked or chatFrame == FCFDock_GetSelectedWindow(DEFAULT_CHAT_FRAME) then
		chatTab.mouseOverAlpha = CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA
		chatTab.noMouseAlpha = CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA
	else
		if chatTab.alerting then
			chatTab.mouseOverAlpha = CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA
			chatTab.noMouseAlpha = CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA
		else
			chatTab.mouseOverAlpha = CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA
			chatTab.noMouseAlpha = CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA
		end
	end

	-- If this is in the middle of fading, stop it, since we're about to set the alpha
	UIFrameFadeRemoveFrame(chatTab)

	if chatFrame.hasBeenFaded then
		chatTab:SetAlpha(chatTab.mouseOverAlpha)
	else
		chatTab:SetAlpha(chatTab.noMouseAlpha)
	end
end

function FloatingChatFrame_OnMouseScroll(self, delta)
	if delta > 0 then
		self:ScrollUp()
	else
		self:ScrollDown()
	end
end

function FCF_GetChatWindowInfo(id)
	if id > NUM_CHAT_WINDOWS then
		local frame = _G["ChatFrame"..id]
		local tab = _G["ChatFrame"..id.."Tab"]
		local background = _G["ChatFrame"..id.."Background"]

		if frame and tab and background then
			local r, g, b, a = background:GetVertexColor()

			return tab:GetText(), select(2, frame:GetFont()), r, g, b, a, frame:IsShown(), frame.isLocked, frame.isDocked, frame.isUninteractable
			--This is a temporary chat window. Pass this to whatever handles those options.
		end
	else
		return GetChatWindowInfo(id)
	end
end

function FCF_CopyChatSettings(copyTo, copyFrom)
	local name, fontSize, r, g, b, a, shown, locked, docked = FCF_GetChatWindowInfo(copyFrom:GetID())
	FCF_SetWindowColor(copyTo, r, g, b, 1)
	FCF_SetWindowAlpha(copyTo, a, 1)

	--If we're copying to a docked window, we don't want to copy locked.
	if not copyTo.isDocked then
		FCF_SetLocked(copyTo, locked)
	end

--	FCF_SetUninteractable(copyTo, uninteractable)
	FCF_SetChatWindowFontSize(nil, copyTo, fontSize)
end

local function FCFManager_GetToken(chatType, chatTarget)
	return lower(chatType)..(chatTarget and ";;"..lower(chatTarget) or "")
end

function FCFManager_RegisterDedicatedFrame(chatFrame, chatType, chatTarget)
	local token = FCFManager_GetToken(chatType, chatTarget)

	if not dedicatedWindows[token] then
		dedicatedWindows[token] = {}
	end

	if not tContains(dedicatedWindows[token], chatFrame) then
		tinsert(dedicatedWindows[token], chatFrame)
	end
end

function FCFDock_GetChatFrames(dock)
	return dock.DOCKED_CHAT_FRAMES
end

function ChatFrame_AddPrivateMessageTarget(chatFrame, chatTarget)
	ChatFrame_RemoveExcludePrivateMessageTarget(chatFrame, chatTarget)

	if chatFrame.privateMessageList then
		chatFrame.privateMessageList[lower(chatTarget)] = true
	else
		chatFrame.privateMessageList = {[lower(chatTarget)] = true}
	end
end

function ChatFrame_RemovePrivateMessageTarget(chatFrame, chatTarget)
	if chatFrame.privateMessageList then
		chatFrame.privateMessageList[lower(chatTarget)] = nil
	end
end

function ChatFrame_ExcludePrivateMessageTarget(chatFrame, chatTarget)
	ChatFrame_RemovePrivateMessageTarget(chatFrame, chatTarget)

	if chatFrame.excludePrivateMessageList then
		chatFrame.excludePrivateMessageList[lower(chatTarget)] = true
	else
		chatFrame.excludePrivateMessageList = {[lower(chatTarget)] = true}
	end
end

function ChatFrame_RemoveExcludePrivateMessageTarget(chatFrame, chatTarget)
	if chatFrame.excludePrivateMessageList then
		chatFrame.excludePrivateMessageList[lower(chatTarget)] = nil
	end
end

function ChatFrame_ReceiveAllPrivateMessages(chatFrame)
	chatFrame.privateMessageList = nil
	chatFrame.excludePrivateMessageList = nil
end

function FCFManager_ShouldSuppressMessage(chatFrame, chatType, chatTarget)
	--Using GetToken probably isn't the best way to do this due to the string concatenation, but it's the easiest to get in quickly.
	if chatFrame.chatType and FCFManager_GetToken(chatType, chatTarget) == FCFManager_GetToken(chatFrame.chatType, chatFrame.chatTarget) then
		--This frame is a dedicated frame of this type, so we should always display.
		return false
	end

	return false
end

function ChatEdit_ActivateChat(editBox)
	if ACTIVE_CHAT_EDIT_BOX and ACTIVE_CHAT_EDIT_BOX ~= editBox then
		ChatEdit_DeactivateChat(ACTIVE_CHAT_EDIT_BOX)
	end

	ACTIVE_CHAT_EDIT_BOX = editBox

	ChatEdit_SetLastActiveWindow(editBox)

	--Stop any sort of fading
	UIFrameFadeRemoveFrame(editBox)

	editBox:Show()
	editBox:SetFocus()
	editBox:SetFrameStrata("DIALOG")
	editBox:Raise()

	editBox:SetAlpha(1.0)

	ChatEdit_UpdateHeader(editBox)

	if CHAT_SHOW_IME then
		_G[editBox:GetName().."Language"]:Show()
	end
end

local function ChatEdit_SetDeactivated(editBox)
	editBox:SetFrameStrata("LOW")
	editBox:SetText("")
	editBox.header:Hide()
	editBox:SetAlpha(0.35)
	editBox:ClearFocus()

	editBox.focusLeft:Hide()
	editBox.focusRight:Hide()
	editBox.focusMid:Hide()
	ChatEdit_ResetChatTypeToSticky(editBox)
	ChatEdit_ResetChatType(editBox)
	_G[editBox:GetName().."Language"]:Hide()
end

function ChatEdit_DeactivateChat(editBox)
	if ACTIVE_CHAT_EDIT_BOX == editBox then
		ACTIVE_CHAT_EDIT_BOX = nil
	end

	ChatEdit_SetDeactivated(editBox)
end

function ChatEdit_ResetChatTypeToSticky(editBox)
	editBox:SetAttribute("chatType", editBox:GetAttribute("stickyType"))
end

function ChatEdit_ResetChatType(self)
	if self:GetAttribute("chatType") == "PARTY" and UnitName("party1") == "" then
		self:SetAttribute("chatType", "SAY")
	end
	if self:GetAttribute("chatType") == "RAID" and (GetNumRaidMembers() == 0) then
		self:SetAttribute("chatType", "SAY")
	end
	if (self:GetAttribute("chatType") == "GUILD" or self:GetAttribute("chatType") == "OFFICER") and not IsInGuild() then
		self:SetAttribute("chatType", "SAY")
	end
	if self:GetAttribute("chatType") == "BATTLEGROUND" and (GetNumRaidMembers() == 0) then
		self:SetAttribute("chatType", "SAY")
	end

	self.tabCompleteIndex = 1
	self.tabCompleteText = nil
	ChatEdit_UpdateHeader(self)
	ChatEdit_OnInputLanguageChanged(self)
end

function ChatEdit_SetLastActiveWindow(editBox)
	local previousValue = LAST_ACTIVE_CHAT_EDIT_BOX
	LAST_ACTIVE_CHAT_EDIT_BOX = editBox
end