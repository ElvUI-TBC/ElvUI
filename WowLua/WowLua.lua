--[[--------------------------------------------------------------------------
  Copyright (c) 2007, James Whitehead II  
  All rights reserved.
  
  WowLua is an interactive interpreter for World of Warcraft
--------------------------------------------------------------------------]]--

WowLua = {
	VERSION = "WowLua 1.0 Interactive Interpreter",
	queue = {},
	queuePos = 0,
}
local L = WowLuaLocals

WowLua_DB = {
	pages = {
		[1] = {name = format(L.NEW_PAGE_TITLE, 1), content = "", untitled = true}
	},
	currentPage = 1,
	untitled = 2,
}

local DB = {}

function WowLua:CreateNewPage()
	local name = format(L.NEW_PAGE_TITLE, WowLua_DB.untitled)
	WowLua_DB.untitled = WowLua_DB.untitled + 1
	local entry = {
		name = name,
		content = "",
		untitled = true
	}
	table.insert(WowLua_DB.pages, entry)
	WowLua_DB.currentPage = #WowLua_DB.pages
	return entry, #WowLua_DB.pages
end

function WowLua:GetNumPages()
	return #WowLua_DB.pages
end

function WowLua:SavePage(num, content)
	local entry = WowLua_DB.pages[num]
	entry.content = content
end

function WowLua:RenamePage(num, name)
	local entry = WowLua_DB.pages[num]
	entry.name = name
	entry.untitled = nil
end

function WowLua:DeletePage(num)
	table.remove(WowLua_DB.pages, num)
end

function WowLua:LockPage(num, locked)
	local entry = WowLua_DB.pages[num]
	entry.locked = locked
end

function WowLua:IsPageLocked(num)
	local entry = WowLua_DB.pages[num]
	return entry.locked
end

function WowLua:GetCurrentPage()
	local page = WowLua_DB.currentPage
	return page, WowLua_DB.pages[page]
end

function WowLua:SelectPage(id)
	if type(id) == "number" then
		WowLua_DB.currentPage = id
		return WowLua_DB.pages[id], id
	elseif type(id) == "string" then
		for idx,entry in ipairs(WowLuaDB.pages) do
			if entry.name == id then
				WowLua_DB.currentPage = idx
				return entry, idx
			end
		end
	end
end

local function wowpad_print(...)
	local out = ""
	for i=1,select("#", ...) do
		-- Comma seperate values
		if i > 1 then
			out = out .. ", "
		end

		out = out .. tostring(select(i, ...))
	end
	WowLuaFrameOutput:AddMessage("|cff999999" .. out .. "|r")
end

if not print then
	print = wowpad_print
end

local function processSpecialCommands(txt)
	if txt == L.RELOAD_COMMAND then
		ReloadUI()
		return true
	elseif txt == L.RESET_COMMAND then
		WowLuaFrame:ClearAllPoints()
		WowLuaFrame:SetPoint("CENTER")
		WowLuaFrame:SetWidth(640)
		WowLuaFrame:SetHeight(512)
		WowLuaFrameResizeBar:ClearAllPoints()
		WowLuaFrameResizeBar:SetPoint("TOPLEFT", WowLuaFrame, "BOTTOMLEFT", 14, 100)
		WowLuaFrameResizeBar:SetPoint("TOPRIGHT", WowLuaFrame, "BOTTOMRIGHT", 0, 100)
		return true
	end
end

function WowLua:ProcessLine(text)
	WowLuaFrameCommandEditBox:SetText("")
	
	if processSpecialCommands(text) then
		return
	end
	
	-- escape any color codes:
	local output = text:gsub("\124", "\124\124")

	WowLuaFrameOutput:AddMessage(WowLuaFrameCommandPrompt:GetText() .. output)

	WowLuaFrameCommandEditBox:AddHistoryLine(output)

	-- If they're using "= value" syntax, just print it
	text = text:gsub("^%s*=%s*(.+)", "print(%1)")

	-- Store this command into self.cmd in case we have multiple lines
	if self.cmd then
		self.cmd = self.cmd .. "\n" .. text
		self.orig = self.orig .. "\n" .. text
	else
		self.cmd = text
		self.orig = text
	end

	-- Trim the command before we run it
	self.cmd = string.trim(self.cmd)

	-- Process the current command
	local func,err = loadstring(self.cmd)

	-- Fail to compile?  Give it a return
	-- Check to see if this just needs a return in front of it
	if not func then
		local newfunc,newerr = loadstring("print(" .. self.cmd .. ")")
		if newfunc then
			func,err = newfunc,newerr
		end
	end

	if not func then
		-- Check to see if this is just an unfinished block
		if err:sub(-7, -1) == "'<eof>'" then
			-- Change the prompt
			WowLuaFrameCommandPrompt:SetText(">> ")
			return
		end

		WowLuaFrameOutput:AddMessage("|cffff0000" .. err .. "|r")
		self.cmd = nil
		WowLuaFrameCommandPrompt:SetText("> ")
	else
		-- Make print a global function
		local old_print = print
		print = wowpad_print

		-- Call the function
		local succ,err = pcall(func)

		-- Restore the value of print
		print = old_print

		if not succ then
			WowLuaFrameOutput:AddMessage("|cffff0000" .. err .. "|r")
		end

		self.cmd = nil
		WowLuaFrameCommandPrompt:SetText("> ")
	end
end

function WowLua:RunScript(text)
	-- escape any color codes:
	local output = text:gsub("\124", "\124\124")

	if text == L.RELOAD_COMMAND then 
		ReloadUI()
	end

	-- If they're using "= value" syntax, just print it
	text = text:gsub("^%s*=%s*(.+)", "print(%1)")

	-- Trim the command before we run it
	text = string.trim(text)

	-- Process the current command
	local func,err = loadstring(text, "WowLua")

	if not func then
		WowLuaFrameOutput:AddMessage("|cffff0000" .. err .. "|r")
		return false, err
	else
		-- Make print a global function
		local old_print = print
		print = wowpad_print

		-- Call the function
		local succ,err = pcall(func)

		-- Restore the value of print
		print = old_print

		if not succ then
			WowLuaFrameOutput:AddMessage("|cffff0000" .. err .. "|r")
			return false, err
		end
	end

	return true
end

function WowLua:Initialize(frame)
	WowLua:OnSizeChanged(frame)
	table.insert(UISpecialFrames, "WowLuaFrame")
	PlaySound("igMainMenuOpen");
	self:UpdateButtons()
end

function WowLua:Button_OnEnter(frame)
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOM");
	local operation = frame:GetName():match("WowLuaButton_(.+)"):gsub("_", " ")
	local tooltip = L.TOOLTIPS[operation]
	GameTooltip:SetText(tooltip and tooltip.name or operation)
	if tooltip then
		GameTooltip:AddLine(tooltip.text, 1, 1, 1)
	end
	GameTooltip:Show();
end

function WowLua:Button_OnLeave(frame)
	GameTooltip:Hide()
end

function WowLua:Button_OnClick(button)
	local operation = button:GetName():match("WowLuaButton_(.+)")
	if operation == "New" then
		WowLua:Button_New(button)
	elseif operation == "Open" then
		WowLua:Button_Open(button)
	elseif operation == "Save" then
		WowLua:Button_Save(button)
	elseif operation == "Undo" then
		WowLua:Button_Undo(button)
	elseif operation == "Redo" then
		WowLua:Button_Redo(button)
	elseif operation == "Delete" then
		WowLua:Button_Delete(button)
	elseif operation == "Lock" then
		WowLua:Button_Lock(button)
	elseif operation == "Unlock" then
		WowLua:Button_Unlock(button)
	elseif operation == "Previous" then
		WowLua:Button_Previous(button)
	elseif operation == "Next" then
		WowLua:Button_Next(button)
	elseif operation == "Run" then
		WowLua:Button_Run(button)
	elseif operation == "Close" then
		WowLua:Button_Close(button)
	end
end

function WowLua:DebugQueue()
	print("Current queue position: " .. self.queuePos)
	for k,v in pairs(self.queue) do
		print(k, v:sub(1, 20))
	end
end

function WowLua:FlushQueue()
	table.wipe(self.queue)
	self.queuePos = 0
end

function WowLua:Queue(text)
	if #self.queue == 0 then
		local page, entry = WowLua:GetCurrentPage()
		self.queue[1] = entry.content
		self.queuePos = 1
	end

	if text ~= self.queue[self.queuePos] then
		self.queuePos = self.queuePos+1
		self.queue[self.queuePos] = text
		for i=self.queuePos+1,#self.queue do
			self.queue[i]=nil
		end
	end
end

function WowLua:GetUndoPage()
	-- Before we do any "Undo", queue the current text
	WowLua:Queue(WowLuaFrameEditBox:GetText())

	local item = self.queue[self.queuePos-1]
	if item then 
		self.queuePos = self.queuePos-1
		return item
	end

	return self.queue[self.queuePos]
end

function WowLua:GetRedoPage()
	local item = self.queue[self.queuePos+1]
	if item then
		self.queuePos = self.queuePos+1
		return item
	end
	return self.queue[self.queuePos]
end

function WowLua:Button_New(button)
	if self:IsModified() then
		-- Display the unsaved changes dialog
		local dialog = StaticPopup_Show("WOWLUA_UNSAVED")
		dialog.data = "Button_New"
		return
	end
	
	-- Create a new page and display it
	local entry, num = WowLua:CreateNewPage()

	WowLuaFrameEditBox:SetText(entry.content)
	WowLua:UpdateButtons()
	WowLua:SetTitle(false)
	WowLua:FlushQueue()
end

function WowLua:Button_Open(button)
	ToggleDropDownMenu(1, nil, WowLuaOpenDropDown, button:GetName(), 0, 0)
end

function WowLua:OpenDropDownOnLoad(frame)
	UIDropDownMenu_Initialize(frame, self.OpenDropDownInitialize)
end

local function dropDownFunc(button, page)
	WowLua:GoToPage(page)
end

function WowLua.OpenDropDownInitialize()
	UIDropDownMenu_AddButton{
		text = L.OPEN_MENU_TITLE,
		isTitle = 1
	}
	
	for page, entry in ipairs(WowLua_DB.pages) do
		UIDropDownMenu_AddButton{
			text = entry.name,
			func = dropDownFunc,
			arg1 = page
		}
	end
end

StaticPopupDialogs["WOWLUA_SAVE_AS"] = {
	text = L.SAVE_AS_TEXT,
	button1 = TEXT(OKAY),
	button2 = TEXT(CANCEL),
	OnAccept = function()		
		local name = this:GetParent():GetName().."EditBox"
		local button = getglobal(name)
		local text = button:GetText()
		WowLua:RenamePage(WowLua.save_as, text)
		WowLua:SetTitle()
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 32,
	OnShow = function()
		getglobal(this:GetName().."Button1"):Disable();
		local editBox = getglobal(this:GetName().."EditBox")
		editBox:SetFocus()
		editBox:SetText(WowLua.save_as_name)
		editBox:HighlightText()
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		if ( getglobal(this:GetParent():GetName().."Button1"):IsEnabled() == 1 ) then
			local name = this:GetParent():GetName().."EditBox"
			local button = getglobal(name)
			local text = button:GetText()
			WowLua:RenamePage(WowLua.save_as, text)
			WowLua:SetTitle()
			this:GetParent():Hide();
		end
	end,
	EditBoxOnTextChanged = function ()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		local txt = editBox:GetText()
		if #txt > 0 then
			getglobal(this:GetParent():GetName().."Button1"):Enable();
		else
			getglobal(this:GetParent():GetName().."Button1"):Disable();
		end
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
		ClearCursor();
	end
}

function WowLua:Button_Save(button)
	if button and IsShiftKeyDown() then
		-- Show the static popup for renaming
		local page, entry = self:GetCurrentPage()
		WowLua.save_as = page
		WowLua.save_as_name = entry.name
		StaticPopup_Show("WOWLUA_SAVE_AS", entry.name)
		return
	else
		local text = WowLuaFrameEditBox:GetText()
		local page = self:GetCurrentPage()
		self:SavePage(page, text)
		self:UpdateButtons()
		self:SetTitle(false)
		WowLua:Queue(text)
	end
end

function WowLua:Button_Undo(button)
	local page, entry = self:GetCurrentPage()
	local undo = WowLua:GetUndoPage()
	WowLuaFrameEditBox:SetText(undo or entry.content)
end

function WowLua:Button_Redo(button)
	local page, entry = self:GetCurrentPage()
	local redo = WowLua:GetRedoPage()
	WowLuaFrameEditBox:SetText(redo)
end

function WowLua:Button_Delete(button)
	if self:IsModified() then
		-- Display the unsaved changes dialog
		local dialog = StaticPopup_Show("WOWLUA_UNSAVED")
		dialog.data = "Button_Delete"
		return
	end
	
	local page, entry = self:GetCurrentPage()
	if self:GetNumPages() == 1 then
		self:Button_New()
		self:Button_Previous()
	end

	self:DeletePage(page)
	
	if page > 1 then page = page - 1 end
	local entry = self:SelectPage(page)
	WowLuaFrameEditBox:SetText(entry.content)
	self:UpdateButtons()
	self:SetTitle(false)
end

function WowLua:Button_Lock(button)
	local id = self:GetCurrentPage()
	self:LockPage(id, true)
	self:UpdateButtons()
end

function WowLua:Button_Unlock(button)
	local id = self:GetCurrentPage()
	self:LockPage(id, false)
	self:UpdateButtons()
end

StaticPopupDialogs["WOWLUA_UNSAVED"] = {
	text = L.UNSAVED_TEXT,
	button1 = TEXT(OKAY),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		local page,entry = WowLua:GetCurrentPage()
		WowLuaFrameEditBox:SetText(entry.content)
		local action = this:GetParent().data
		if type(action) == "string" then
			WowLua[action](WowLua)
		else
			WowLua:GoToPage(this:GetParent().data)
		end
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
		ClearCursor();
	end
}

function WowLua:Button_Previous()
	self:GoToPage(self:GetCurrentPage() - 1)
end

function WowLua:Button_Next()
	self:GoToPage(self:GetCurrentPage() + 1)
end

function WowLua:GoToPage(page)
	if self:IsModified() then
		-- Display the unsaved changes dialog
		local dialog = StaticPopup_Show("WOWLUA_UNSAVED")
		dialog.data = page
		return
	end

	local entry = self:SelectPage(page)
	
	WowLuaFrameEditBox:SetText(entry.content)
	self:UpdateButtons()
	self:SetTitle(false)
	WowLua:FlushQueue()
end

function WowLua:UpdateButtons()
	local current = self:GetCurrentPage()
	local max = self:GetNumPages()
	
	if current == 1 then
		WowLuaButton_Previous:Disable()
	else
		WowLuaButton_Previous:Enable()
	end

	if current == max then
		WowLuaButton_Next:Disable()
	else
		WowLuaButton_Next:Enable()
	end
	
	self.indent.indentEditbox(WowLuaFrameEditBox)

	if self:IsPageLocked(current) then
		WowLuaButton_Unlock:Show()
		WowLuaButton_Lock:Hide()
		WowLuaButton_Delete:Disable()
		WowLuaFrameEditBox:SetScript("OnTextChanged", self.lockedTextChanged)
	else
		WowLuaButton_Unlock:Hide()
		WowLuaButton_Lock:Show()
		WowLuaButton_Delete:Enable()
		WowLuaFrameEditBox:SetScript("OnTextChanged", self.unlockedTextChanged)
	end
end

function WowLua.lockedTextChanged(box)
	if WowLua.reverting then
		WowLua.reverting = false
	else
		WowLua.reverting = true
		local entry = select(2, WowLua:GetCurrentPage())
		local pos = WowLua.lastCursorPos
		box:SetText(entry.content)
		WowLua.indent.indentEditbox(WowLuaFrameEditBox)
		if pos then
			box:SetCursorPosition(pos)
		end
	end
end

function WowLua:Button_Run()
	local text = WowLuaFrameEditBox:GetText()

	-- Run the script, if there is an error then highlight it
	if text then
		-- Add the current state of the page to the queue 
		WowLua:Queue(text)

		local succ,err = WowLua:RunScript(text)
		if not succ then
			local chunkName,lineNum = err:match("(%b[]):(%d+):")
			lineNum = tonumber(lineNum)
			WowLua:UpdateLineNums(lineNum)

			-- Highlight the text in the editor by finding the char of the line number we're on
			text = WowLua.indent.coloredGetText(WowLuaFrameEditBox)

			local curLine,start = 1,1
			while curLine < lineNum do
				local s,e = text:find("\n", start)
				start = e + 1
				curLine = curLine + 1
			end

			local nextLine = select(2, text:find("\n", start))
			
			WowLuaFrameEditBox:SetFocus()
			WowLuaFrameEditBox:SetCursorPosition(start - 1)
		end
	end
end

function WowLua:Button_Close()
	if self:IsModified() then
		-- Display the unsaved changes dialog
		local dialog = StaticPopup_Show("WOWLUA_UNSAVED")
		dialog.data = "Button_Close"
		return
	end
	
	HideUIPanel(WowLuaFrame)
end

function WowLua:IsModified()
	local page,entry = self:GetCurrentPage()
	local orig = entry.content
	local current = WowLuaFrameEditBox:GetText(true)
	return orig ~= current
end

function WowLua:IsUntitled()
	local page, entry = self:GetCurrentPage()
	return entry.untitled
end

function WowLua:SetTitle(modified)
	local page,entry = self:GetCurrentPage()
	WowLuaFrameTitle:SetFormattedText("%s%s - WowLua Editor", entry.name, self:IsModified() and "*" or "")
end

local first = true
SlashCmdList["WOWLUA"] = function(txt)
	local page, entry = WowLua:GetCurrentPage()
	if first then
		WowLuaFrameEditBox:SetText(entry.content)
		WowLuaFrameEditBox:SetWidth(WowLuaFrameEditScrollFrame:GetWidth())
		WowLua:SetTitle(false)
		first = false
	end

	WowLuaFrame:Show()
	
	if processSpecialCommands(txt) then
		return
	end

	if txt:match("%S") then
		WowLua:ProcessLine(txt)
	end

	WowLuaFrameCommandEditBox:SetFocus()
end

function WowLua:OnSizeChanged(frame)
	-- The first graphic is offset 13 pixels to the right
	local width = frame:GetWidth() - 13
	local bg2w,bg3w,bg4w = 0,0,0

	-- Resize bg2 up to 256 width
	local bg2w = width - 256
	if bg2w > 256 then
		bg3w = bg2w - 256
		bg2w = 256
	end

	if bg3w > 256 then
		bg4w = bg3w - 256
		bg3w = 256
	end

	local bg2 = WowLuaFrameBG2
	local bg3 = WowLuaFrameBG3
	local bg4 = WowLuaFrameBG4

	if bg2w > 0 then
		bg2:SetWidth(bg2w)
		bg2:SetTexCoord(0, (bg2w / 256), 0, 1)
		bg2:Show()
	else
		bg2:Hide()
	end
		
	if bg3w and bg3w > 0 then
		bg3:SetWidth(bg3w)
		bg3:SetTexCoord(0, (bg3w / 256), 0, 1)
		bg3:Show()
	else
		bg3:Hide()
	end

	if bg4w and bg4w > 0 then
		bg4:SetWidth(bg4w)
		bg4:SetTexCoord(0, (bg4w / 256), 0, 1)
		bg4:Show()
	else
		bg4:Hide()
	end

	if WowLuaFrameResizeBar and false then
		local parent = WowLuaFrameResizeBar:GetParent()
		local cursorY = select(2, GetCursorPosition())
		local newPoint = select(5, WowLuaFrameResizeBar:GetPoint())
		local maxPoint = parent:GetHeight() - 175; 

		if newPoint < 100 then
			newPoint = 100
		elseif newPoint > maxPoint then
			newPoint = maxPoint
		end

		WowLuaFrameResizeBar:ClearAllPoints()
		WowLuaFrameResizeBar:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 14, newPoint)
		WowLuaFrameResizeBar:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 0, newPoint)
	end
end

function WowLua:ResizeBar_OnMouseDown(frame, button)
	frame.cursorStart = select(2, GetCursorPosition())
	frame.anchorStart = select(5, frame:GetPoint())
	frame:SetScript("OnUpdate", function(...) WowLua:ResizeBar_OnUpdate(...) end)
end

function WowLua:ResizeBar_OnMouseUp(frame, button)
	frame:SetScript("OnUpdate", nil)
end

function WowLua:ResizeBar_OnUpdate(frame, elapsed)
	local parent = frame:GetParent()
	local cursorY = select(2, GetCursorPosition())
	local newPoint = frame.anchorStart - (frame.cursorStart - cursorY)/frame:GetEffectiveScale()
	local maxPoint = parent:GetHeight() - 175; 

	if newPoint < 100 then
		newPoint = 100
	elseif newPoint > maxPoint then
		newPoint = maxPoint
	end

	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 14, newPoint)
	frame:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 0, newPoint)
end

function WowLua:OnVerticalScroll(scrollFrame)
	local offset = scrollFrame:GetVerticalScroll();
	local scrollbar = getglobal(scrollFrame:GetName().."ScrollBar");
	
	scrollbar:SetValue(offset);
	local min, max = scrollbar:GetMinMaxValues();
	local display = false;
	if ( offset == 0 ) then
	    getglobal(scrollbar:GetName().."ScrollUpButton"):Disable();
	else
	    getglobal(scrollbar:GetName().."ScrollUpButton"):Enable();
	    display = true;
	end
	if ((scrollbar:GetValue() - max) == 0) then
	    getglobal(scrollbar:GetName().."ScrollDownButton"):Disable();
	else
	    getglobal(scrollbar:GetName().."ScrollDownButton"):Enable();
	    display = true;
	end
	if ( display ) then
		scrollbar:Show();
	else
		scrollbar:Hide();
	end
end

function WowLua:UpdateLineNums(highlightNum)
	-- highlightNum is the line number indicated by the error message
	if highlightNum then 
		WowLua.highlightNum = highlightNum
	else
		highlightNum = WowLua.highlightNum
	end

	-- Since we know this is FAIAP enabled, we need to pass true in order
	-- to get the raw values
	local editbox = WowLuaFrameEditBox
	local linebox = WowLuaFrameLineNumEditBox
	local linetest = WowLuaFrameEditBoxLineTest
	local linescroll = WowLuaFrameLineNumScrollFrame

	local width = editbox:GetWidth() 
	local text = editbox:GetText(true)

	local linetext = ""
	local count = 1
	for line in text:gmatch("([^\n]*\n?)") do
		if #line > 0 then
			if count == highlightNum then
				linetext = linetext .. "|cFFFF1111" .. count .. "|r" .. "\n"
			else
				linetext = linetext .. count .. "\n"
			end
			count = count + 1

			-- Check to see if the line of text spans more than one actual line
			linetest:SetText(line:gsub("|", "||"))
			local testwidth = linetest:GetWidth()
			if testwidth >= width then
				linetext = linetext .. string.rep("\n", testwidth / width) 
			end
		end
	end

	if text:sub(-1, -1) == "\n" then
		linetext = linetext .. count .. "\n"
		count = count + 1
	end

	-- Make the line number frame wider as necessary
	local offset = tostring(count):len() * 10
	linescroll:ClearAllPoints()
	linescroll:SetPoint("TOPLEFT", WowLuaFrame, "TOPLEFT", 18, -74)
	linescroll:SetPoint("BOTTOMRIGHT", WowLuaFrameResizeBar, "TOPLEFT", 15 + offset, -4)

	linebox:SetText(linetext)
	linetest:SetText(text)
end

local function canScroll(scroll, direction)
	local num, displayed, currScroll = scroll:GetNumMessages(),
					   scroll:GetNumLinesDisplayed(),
					   scroll:GetCurrentScroll();
	if ( direction == "up" and
	     (
		num == displayed or
		num == ( currScroll + displayed )
	      )
	) then
		return false;
	elseif ( direction == "down" and currScroll == 0 ) then
		return false;
	end
	return true;
end

function WowLua:UpdateScrollingMessageFrame(frame)
	local name = frame:GetName();
	local display = false;
	
	if ( canScroll(frame, "up") ) then
		getglobal(name.."UpButton"):Enable();
		display = true;
	else
		getglobal(name.."UpButton"):Disable();
	end
	
	if ( canScroll(frame, "down") ) then
		getglobal(name.."DownButton"):Enable();
		display = true;
	else
		getglobal(name.."DownButton"):Disable();
	end
	
	if ( display ) then
		getglobal(name.."UpButton"):Show();
		getglobal(name.."DownButton"):Show();
	else
		getglobal(name.."UpButton"):Hide();
		getglobal(name.."DownButton"):Hide();
	end
end

local scrollMethods = {
	["line"] = { ["up"] = "ScrollUp", ["down"] = "ScrollDown" },
	["page"] = { ["up"] = "PageUp", ["down"] = "PageDown" },
	["end"] = { ["up"] = "ScrollToTop", ["down"] = "ScrollToBottom" },
};

function WowLua:ScrollingMessageFrameScroll(scroll, direction, type)
	-- Make sure we can scroll first
	if ( not canScroll(scroll, direction) ) then
		return;
	end
	local method = scrollMethods[type][direction];
	scroll[method](scroll);
end

function WowLua:OnTextChanged(frame)
	frame.highlightNum = nil
end

function WowLua:OnCursorChanged(frame)
	WowLua.dirty = true
end

BINDING_HEADER_WOWLUA = "WowLua Editor/Interpreter"
BINDING_NAME_TOGGLE_WOWLUA = "Show/Hide window"
BINDING_NAME_RUN_WOWLUA = "Run current page"
BINDING_NAME_SAVE_WOWLUA = "Save current page"

