local E, L, V, P, G = unpack(ElvUI)
local CH = E:NewModule("Chat", "AceTimer-3.0", "AceHook-3.0", "AceEvent-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local _G = _G;
local time, difftime = time, difftime;
local pairs, unpack, select, tostring, pcall, next, tonumber, type, assert = pairs, unpack, select, tostring, pcall, next, tonumber, type, assert;
local tinsert, tremove, tsort, twipe, tconcat = table.insert, table.remove, table.sort, table.wipe, table.concat;
local random = math.random;
local len, gsub, find, sub, gmatch, format, split = string.len, string.gsub, string.find, string.sub, string.gmatch, string.format, string.split;
local strlower, strsub, strlen, strupper = strlower, strsub, strlen, strupper;

local hooksecurefunc = hooksecurefunc;
local CreateFrame = CreateFrame;
local GetTime = GetTime;
local UnitName = UnitName;
local IsShiftKeyDown = IsShiftKeyDown;
local InCombatLockdown = InCombatLockdown;
local ChatFrame_SendTell = ChatFrame_SendTell;
local GetChannelName = GetChannelName;
local ToggleFrame = ToggleFrame;
local FCF_GetChatWindowInfo = FCF_GetChatWindowInfo;
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize;
local GetMouseFocus = GetMouseFocus;
local GetChatWindowSavedPosition = GetChatWindowSavedPosition;
local IsMouseButtonDown = IsMouseButtonDown;
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions;
local PlaySoundFile = PlaySoundFile;
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend;
local ChatEdit_ActivateChat = ChatEdit_ActivateChat;
local ShowUIPanel, HideUIPanel = ShowUIPanel, HideUIPanel;
local BetterDate = BetterDate;
local GetPlayerInfoByGUID = GetPlayerInfoByGUID;
local StaticPopup_Visible = StaticPopup_Visible;
local Chat_GetChatCategory = Chat_GetChatCategory;
local FCFManager_ShouldSuppressMessage = FCFManager_ShouldSuppressMessage;
local ChatHistory_GetAccessID = ChatHistory_GetAccessID;
local GMChatFrame_IsGM = GMChatFrame_IsGM
local ChatEdit_SetLastTellTarget = ChatEdit_SetLastTellTarget;
local PlaySound = PlaySound;
local FCF_StartAlertFlash = FCF_StartAlertFlash;
local ChatFrame_ConfigEventHandler = ChatFrame_ConfigEventHandler;
local ChatFrame_SystemEventHandler = ChatFrame_SystemEventHandler;
local FloatingChatFrame_OnEvent = FloatingChatFrame_OnEvent;
local FCFTab_UpdateAlpha = FCFTab_UpdateAlpha;
local FCF_GetCurrentChatFrame = FCF_GetCurrentChatFrame;
local GetGuildRosterMOTD = GetGuildRosterMOTD;
local ScrollFrameTemplate_OnMouseWheel = ScrollFrameTemplate_OnMouseWheel;
local NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS;

local GlobalStrings = {
	["AFK"] = AFK,
	["CHAT_FILTERED"] = CHAT_FILTERED,
	["CHAT_IGNORED"] = CHAT_IGNORED,
	["CHAT_RESTRICTED"] = CHAT_RESTRICTED,
	["CHAT_TELL_ALERT_TIME"] = CHAT_TELL_ALERT_TIME,
	["DND"] = DND,
	["MAX_WOW_CHAT_CHANNELS"] = MAX_WOW_CHAT_CHANNELS,
	["RAID_WARNING"] = RAID_WARNING
};

local CreatedFrames = 0;
local lines = {};
local msgList, msgCount, msgTime = {}, {}, {}
local chatFilters = {};

local PLAYER_REALM = gsub(E.myrealm,"[%s%-]","")

local RAID_CLASS_COLORS = RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS;

local DEFAULT_STRINGS = {
	BATTLEGROUND = L["BG"],
	GUILD = L["G"],
	PARTY = L["P"],
	RAID = L["R"],
	OFFICER = L["O"],
	BATTLEGROUND_LEADER = L["BGL"],
	PARTY_LEADER = L["PL"],
	RAID_LEADER = L["RL"],
}

local hyperlinkTypes = {
	["item"] = true,
	["spell"] = true,
	["unit"] = true,
	["quest"] = true,
	["enchant"] = true,
	["achievement"] = true,
	["instancelock"] = true,
	["talent"] = true,
	["glyph"] = true,
}

local numScrollMessages
local function ChatFrame_OnMouseScroll(frame, delta)
	numScrollMessages = CH.db.numScrollMessages or 3
	if CH.db.scrollDirection == "TOP" then
		if delta < 0 then
			if IsShiftKeyDown() then
				frame:ScrollToTop()
			else
				for i = 1, numScrollMessages do
					frame:ScrollUp()
				end
			end
		elseif delta > 0 then
			if IsShiftKeyDown() then
				frame:ScrollToBottom()
			else
				for i = 1, numScrollMessages do
					frame:ScrollDown()
				end
			end

			if CH.db.scrollDownInterval ~= 0 then
				if frame.ScrollTimer then
					CH:CancelTimer(frame.ScrollTimer, true)
				end

				frame.ScrollTimer = CH:ScheduleTimer("ScrollToBottom", CH.db.scrollDownInterval, frame)
			end
		end
	else
		if delta < 0 then
			if IsShiftKeyDown() then
				frame:ScrollToBottom()
			else
				for i = 1, numScrollMessages do
					frame:ScrollDown()
				end
			end
		elseif delta > 0 then
			if IsShiftKeyDown() then
				frame:ScrollToTop()
			else
				for i = 1, numScrollMessages do
					frame:ScrollUp()
				end
			end

			if CH.db.scrollDownInterval ~= 0 then
				if frame.ScrollTimer then
					CH:CancelTimer(frame.ScrollTimer, true)
				end

				frame.ScrollTimer = CH:ScheduleTimer("ScrollToBottom", CH.db.scrollDownInterval, frame)
			end
		end
	end
end

function CH:StyleChat(frame)
	local name = frame:GetName()
	_G[name.."TabText"]:FontTemplate(LSM:Fetch("font", self.db.tabFont), self.db.tabFontSize, self.db.tabFontOutline)

	if frame.styled then return end

	local id = frame:GetID()

	local tab = _G[name.."Tab"]
	local editbox = frame.editBox

	_G[tab:GetName().."Left"]:SetTexture(nil)
	_G[tab:GetName().."Middle"]:SetTexture(nil)
	_G[tab:GetName().."Right"]:SetTexture(nil)

	tab.text = _G[name.."TabText"]
	tab.text:SetTextColor(unpack(E["media"].rgbvaluecolor))
	hooksecurefunc(tab.text, "SetTextColor", function(self, r, g, b)
		local rR, gG, bB = unpack(E["media"].rgbvaluecolor)
		if r ~= rR or g ~= gG or b ~= bB then
			self:SetTextColor(rR, gG, bB)
		end
	end)

	frame:StripTextures(true)

	local function OnTextChanged(self)
		local text = self:GetText()

		if InCombatLockdown() then
			local MIN_REPEAT_CHARACTERS = E.db.chat.numAllowedCombatRepeat
			if len(text) > MIN_REPEAT_CHARACTERS then
				local repeatChar = true
				for i = 1, MIN_REPEAT_CHARACTERS, 1 do
					if sub(text,(0-i), (0-i)) ~= sub(text,(-1-i),(-1-i)) then
						repeatChar = false
						break
					end
				end
				if repeatChar then
					self:Hide()
					return
				end
			end
		end

		if text:len() < 5 then
			if text:sub(1, 4) == "/tt " then
				local unitname, realm = UnitName("target")
				if unitname and realm and not UnitIsSameServer("player", "target") then
					unitname = unitname .. "-" .. realm:gsub(" ", "")
				end
				ChatFrame_SendTell((unitname or L["Invalid Target"]), ChatFrame1)
			end
		end

		local new, found = gsub(text, "|Kf(%S+)|k(%S+)%s(%S+)|k", "%2 %3")
		if found > 0 then
			new = new:gsub("|", "")
			self:SetText(new)
		end
	end

	local a, b, c = select(6, editbox:GetRegions()); a:Kill(); b:Kill(); c:Kill()
	editbox:SetTemplate("Default", true)
	editbox:SetAltArrowKeyMode(CH.db.useAltKey)
	editbox:HookScript("OnEditFocusGained", function(self) self:Show(); if(not LeftChatPanel:IsShown()) then LeftChatPanel.editboxforced = true; LeftChatToggleButton:GetScript("OnEnter")(LeftChatToggleButton); end end);
	editbox:HookScript("OnEditFocusLost", function(self) if(LeftChatPanel.editboxforced) then LeftChatPanel.editboxforced = nil; if(LeftChatPanel:IsShown()) then LeftChatToggleButton:GetScript("OnLeave")(LeftChatToggleButton); end end self:Hide(); end);
	editbox:SetAllPoints(LeftChatDataPanel)
	--self:SecureHook(editbox, "AddHistoryLine", "ChatEdit_AddHistory")
	editbox:HookScript("OnTextChanged", OnTextChanged)

	editbox.historyLines = ElvCharacterDB.ChatEditHistory
	editbox.historyIndex = 0

	for i, text in pairs(ElvCharacterDB.ChatEditHistory) do
		editbox:AddHistoryLine(text)
	end

	hooksecurefunc("ChatEdit_UpdateHeader", function()
		local type = editbox:GetAttribute("chatType")
		if type == "CHANNEL" then
			local id = GetChannelName(editbox:GetAttribute("channelTarget"))
			if id == 0 then
				editbox:SetBackdropBorderColor(unpack(E.media.bordercolor))
			else
				editbox:SetBackdropBorderColor(ChatTypeInfo[type..id].r,ChatTypeInfo[type..id].g,ChatTypeInfo[type..id].b)
			end
		elseif type then
			editbox:SetBackdropBorderColor(ChatTypeInfo[type].r,ChatTypeInfo[type].g,ChatTypeInfo[type].b)
		end
	end)

	frame.button = CreateFrame("Button", format("CopyChatButton%d", id), frame)
	frame.button:EnableMouse(true)
	frame.button:SetAlpha(0.35)
	frame.button:Size(20, 22)
	frame.button:SetPoint("TOPRIGHT")
	frame.button:SetFrameLevel(frame:GetFrameLevel() + 5)

	frame.button.tex = frame.button:CreateTexture(nil, "OVERLAY")
	frame.button.tex:SetInside()
	frame.button.tex:SetTexture([[Interface\AddOns\ElvUI\media\textures\copy.tga]])

	frame.button:SetScript("OnMouseUp", function(self, btn)
		if btn == "LeftButton" then
			CH:CopyChat(self:GetParent())
		elseif btn == "RightButton" and id ~= 2 then
			ChatMenu:Show()
		end
	end)

	frame.button:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
	frame.button:SetScript("OnLeave", function(self)
		if _G[self:GetParent():GetName().."TabText"]:IsShown() then
			self:SetAlpha(0.35)
		else
			self:SetAlpha(0)
		end

	end)

	CreatedFrames = id
	frame.styled = true
end

function CH:UpdateSettings()
	for i = 1, CreatedFrames do
		local chat = _G[format("ChatFrame%d", i)]
		local name = chat:GetName()
		local editbox = _G[name.."EditBox"]
		editbox:SetAltArrowKeyMode(CH.db.useAltKey)
	end
end

local function removeIconFromLine(text)
	for i = 1, 8 do
		text = gsub(text, "|TInterface\\TargetingFrame\\UI%-RaidTargetingIcon_"..i..":0|t", "{"..strlower(_G["RAID_TARGET_"..i]).."}")
	end
	text = gsub(text, "(|TInterface(.*)|t)", "")

	return text
end

local function colorizeLine(text, r, g, b)
	local hexCode = E:RGBToHex(r, g, b)
	local hexReplacement = format("|r%s", hexCode)

	text = gsub(text, "|r", hexReplacement)
	text = format("%s%s|r", hexCode, text)

	return text
end

function CH:GetLines(...)
	local index = 1
	wipe(lines)
	for i = select("#", ...), 1, -1 do
		local region = select(i, ...)
		if region:GetObjectType() == "FontString" then
			local line = tostring(region:GetText())
			local r, g, b = region:GetTextColor()

			line = removeIconFromLine(line)
			line = colorizeLine(line, r, g, b)

			lines[index] = line
			index = index + 1
		end
	end
	return index - 1
end

function CH:CopyChat(frame)
	if not CopyChatFrame:IsShown() then
		--local _, fontSize = FCF_GetChatWindowInfo(frame:GetID())
		--if fontSize < 10 then fontSize = 12 end
		--FCF_SetChatWindowFontSize(frame, frame, 0.01)
		CopyChatFrame:Show()
		local lineCt = self:GetLines(frame:GetRegions())
		local text = tconcat(lines, "\n", 1, lineCt)
		--FCF_SetChatWindowFontSize(frame, frame, fontSize)
		CopyChatFrameEditBox:SetText(text)
	else
		CopyChatFrame:Hide()
	end
end

function CH:ScrollToBottom(frame)
	frame:ScrollToBottom()

	self:CancelTimer(frame.ScrollTimer, true)
end

function CH:SetupChat()
	if E.private.chat.enable ~= true then return end
	for i, frame in pairs(DOCKED_CHAT_FRAMES) do
		--local _, fontSize = FCF_GetChatWindowInfo(i)
		local id = frame:GetID()
		self:StyleChat(frame)
		--FCFTab_UpdateAlpha(frame)
		--frame:SetFont(LSM:Fetch("font", self.db.font), fontSize, self.db.fontOutline)
		if self.db.fontOutline ~= "NONE" then
			frame:SetShadowColor(0, 0, 0, 0.2)
		else
			frame:SetShadowColor(0, 0, 0, 1)
		end
		frame:SetTimeVisible(100)
		frame:SetShadowOffset((E.mult or 1), -(E.mult or 1))
		frame:SetFading(self.db.fade)

		if not frame.scriptsSet then
			frame:SetScript("OnMouseWheel", ChatFrame_OnMouseScroll)
			frame:EnableMouseWheel(true)

			--[[THIS CAUSES LUA ERROR WHEN RESETTING CHAT TO DEFAULTS OR WHEN RUNNING FCF_ResetChatWindows()
			if id > NUM_CHAT_WINDOWS then
				frame:SetScript("OnEvent", CH.FloatingChatFrame_OnEvent)
			elseif id ~= 2 then
				frame:SetScript("OnEvent", CH.ChatFrame_OnEvent)
			end]]
			--Use this instead for the time being
			--if id ~= 2 then
			--	frame:SetScript("OnEvent", CH.FloatingChatFrame_OnEvent)
			--end
			frame.scriptsSet = true
		end
	end

	if self.db.hyperlinkHover then
	--	self:EnableHyperlink()
	end

	--GeneralDockManager:SetParent(LeftChatPanel)
	--self:ScheduleRepeatingTimer("PositionChat", 1)
	--self:PositionChat(true)

	if not self.HookSecured then
		--self:SecureHook("FCF_OpenTemporaryWindow", "SetupChat")
		self.HookSecured = true
	end
end

function CH:Initialize()
	self.db = E.db.chat

	E.Chat = self

	--self:RegisterEvent("UPDATE_CHAT_WINDOWS", "SetupChat")
	--self:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS", "SetupChat")

	self:SetupChat()

	local S = E:GetModule("Skins")
	S:HandleNextPrevButton(CombatLogQuickButtonFrame_CustomAdditionalFilterButton, true)
	local frame = CreateFrame("Frame", "CopyChatFrame", E.UIParent)
	tinsert(UISpecialFrames, "CopyChatFrame")
	frame:SetTemplate("Transparent")
	frame:Size(700, 200)
	frame:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 3)
	frame:Hide()
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetResizable(true)
	frame:SetMinResize(350, 100)
	frame:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" and not self.isMoving then
			self:StartMoving()
			self.isMoving = true;
		elseif(button == "RightButton" and not self.isSizing) then
			self:StartSizing()
			self.isSizing = true;
		end
	end)
	frame:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and self.isMoving then
			self:StopMovingOrSizing()
			self.isMoving = false
		elseif button == "RightButton" and self.isSizing then
			self:StopMovingOrSizing()
			self.isSizing = false
		end
	end)
	frame:SetScript("OnHide", function(self)
		if self.isMoving or self.isSizing then
			self:StopMovingOrSizing()
			self.isMoving = false
			self.isSizing = false
		end
	end)
	frame:SetFrameStrata("DIALOG")

	local scrollArea = CreateFrame("ScrollFrame", "CopyChatScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scrollArea:Point("TOPLEFT", frame, "TOPLEFT", 8, -30)
	scrollArea:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)
	S:HandleScrollBar(CopyChatScrollFrameScrollBar)
	scrollArea:SetScript("OnSizeChanged", function(self)
		CopyChatFrameEditBox:Width(self:GetWidth())
		CopyChatFrameEditBox:Height(self:GetHeight())
	end)
	scrollArea:HookScript("OnVerticalScroll", function(self, offset)
		CopyChatFrameEditBox:SetHitRectInsets(0, 0, offset, (CopyChatFrameEditBox:GetHeight() - offset - self:GetHeight()))
	end)

	local editBox = CreateFrame("EditBox", "CopyChatFrameEditBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(GameFontNormal)
	editBox:Width(scrollArea:GetWidth())
	editBox:Height(200)
	editBox:SetScript("OnEscapePressed", function() CopyChatFrame:Hide() end)
	scrollArea:SetScrollChild(editBox)
	CopyChatFrameEditBox:SetScript("OnTextChanged", function(_, userInput)
		if userInput then return end
		local scrollBar = CopyChatScrollFrameScrollBar
		local _, max = scrollBar:GetMinMaxValues()
		for i = 1, max do
			scrollBar:SetValue(scrollBar:GetValue() + (scrollBar:GetHeight() / 2))
		end
	end)

	local close = CreateFrame("Button", "CopyChatFrameCloseButton", frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT")
	close:SetFrameLevel(close:GetFrameLevel() + 1)
	close:EnableMouse(true)

	S:HandleCloseButton(close)
end

E:RegisterModule(CH:GetName())