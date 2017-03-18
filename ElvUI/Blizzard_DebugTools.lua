DEBUGLOCALS_LEVEL = 4;

local ERROR_FORMAT = [[|cffffd200Message:|cffffffff %s
|cffffd200Time:|cffffffff %s
|cffffd200Count:|cffffffff %s
|cffffd200Stack:|cffffffff %s
|cffffd200Locals:|cffffffff %s]];

local INDEX_ORDER_FORMAT = "%d / %d"

local _ScriptErrorsFrame;

function ScriptErrorsFrame_OnLoad ()
	this.title:SetText("LUA_ERROR");
	this:RegisterForDrag("LeftButton");
	this.seen = {};
	this.order = {};
	this.count = {};
	this.messages = {};
	this.times = {};
	this.locals = {};
	_ScriptErrorsFrame = this;
	print(this)
end

function ScriptErrorsFrame_OnShow ()
	ScriptErrorsFrame_Update();
end

function ScriptErrorsFrame_OnError (message, keepHidden)
	local stack = debugstack(DEBUGLOCALS_LEVEL);
	--print(stack)
	
	local messageStack = message..stack; -- Fix me later
	
	if ( _ScriptErrorsFrame ) then
		local index = _ScriptErrorsFrame.seen[messageStack];
		if ( index ) then
			_ScriptErrorsFrame.count[index] = _ScriptErrorsFrame.count[index] + 1;
			_ScriptErrorsFrame.messages[index] = message;
			_ScriptErrorsFrame.times[index] = date();
			_ScriptErrorsFrame.locals[index] = debuglocals(DEBUGLOCALS_LEVEL);
		else
			tinsert(_ScriptErrorsFrame.order, stack);
			index = #_ScriptErrorsFrame.order;
			_ScriptErrorsFrame.count[index] = 1;
			_ScriptErrorsFrame.messages[index] = message;
			_ScriptErrorsFrame.times[index] = date();
			_ScriptErrorsFrame.seen[messageStack] = index;
			_ScriptErrorsFrame.locals[index] = debuglocals(DEBUGLOCALS_LEVEL);
		end
		
		if ( not _ScriptErrorsFrame:IsShown() and not keepHidden ) then
			_ScriptErrorsFrame.index = index;
			_ScriptErrorsFrame:Show();
		else
			ScriptErrorsFrame_Update();
		end
	end
end

function ScriptErrorsFrame_Update ()
	local editBox = ScriptErrorsFrameScrollFrameText;
	local index = _ScriptErrorsFrame.index;
	if ( not index or not _ScriptErrorsFrame.order[index] ) then
		index = #_ScriptErrorsFrame.order;
		_ScriptErrorsFrame.index = index;
	end
	
	if ( index == 0 ) then
		editBox:SetText("");
		ScriptErrorsFrame_UpdateButtons();
		return;
	end
	
	local text = string.format(
		ERROR_FORMAT, 
		_ScriptErrorsFrame.messages[index], 
		_ScriptErrorsFrame.times[index], 
		_ScriptErrorsFrame.count[index], 
		_ScriptErrorsFrame.order[index],
		_ScriptErrorsFrame.locals[index]
		);

	local parent = editBox:GetParent();
	local prevText = editBox.text;
	editBox.text = text;
	if ( prevText ~= text ) then
		editBox:SetText(text);
		editBox:HighlightText(0);
		editBox:SetCursorPosition(0);
	else
		ScrollingEdit_OnTextChanged(editBox, parent);
	end
	parent:SetVerticalScroll(0);

	ScriptErrorsFrame_UpdateButtons();
end

function ScriptErrorsFrame_UpdateButtons ()
	local index = _ScriptErrorsFrame.index;
	local numErrors = #_ScriptErrorsFrame.order;
	if ( index == 0 ) then
	--	_ScriptErrorsFrame.next:Disable();
	--	_ScriptErrorsFrame.previous:Disable();
	else
		if ( numErrors == 1 ) then
		--	_ScriptErrorsFrame.next:Disable();
		--	_ScriptErrorsFrame.previous:Disable();
		elseif ( index == 1 ) then
			_ScriptErrorsFrame.next:Enable();
		--	_ScriptErrorsFrame.previous:Disable();
		elseif ( index == numErrors ) then
		--	_ScriptErrorsFrame.next:Disable();
			_ScriptErrorsFrame.previous:Enable();
		else
			_ScriptErrorsFrame.next:Enable();
			_ScriptErrorsFrame.previous:Enable();
		end
	end
	
	_ScriptErrorsFrame.indexLabel:SetText(string.format(INDEX_ORDER_FORMAT, index, numErrors));
end

function ScriptErrorsFrame_DeleteError (index)
	if ( _ScriptErrorsFrame.order[index] ) then
		_ScriptErrorsFrame.seen[_ScriptErrorsFrame.messages[index] .. _ScriptErrorsFrame.order[index]] = nil;
		tremove(_ScriptErrorsFrame.order, index);
		tremove(_ScriptErrorsFrame.messages, index);
		tremove(_ScriptErrorsFrame.times, index);
		tremove(_ScriptErrorsFrame.count, index);
	end
end

function ScriptErrorsFrameButton_OnClick (self)
	local id = self:GetID();
	
	
	if ( id == 1 ) then
		_ScriptErrorsFrame.index = _ScriptErrorsFrame.index + 1;
	else
		_ScriptErrorsFrame.index = _ScriptErrorsFrame.index - 1;
	end
		
	ScriptErrorsFrame_Update();
end

--[[  function ScriptErrorsFrameDelete_OnClick (self);
	local index = _ScriptErrorsFrame.index;
	ScriptErrorsFrame_DeleteError(index);
	
	local numErrors = #_ScriptErrorsFrame.order;
	if ( numErrors == 0 ) then
		_ScriptErrorsFrame.index = 0;
	elseif ( index > numErrors ) then
		_ScriptErrorsFrame.index = numErrors;
	end
	
	ScriptErrorsFrame_Update();
end ]]

function DebugTooltip_OnLoad(self)
	self:SetFrameLevel(self:GetFrameLevel() + 2);
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
	self.statusBar2 = getglobal(self:GetName().."StatusBar2");
	self.statusBar2Text = getglobal(self:GetName().."StatusBar2Text");
end

function FrameStackTooltip_Toggle (showHidden)
	local tooltip = _G["FrameStackTooltip"];
	if ( tooltip:IsVisible() ) then
		tooltip:Hide();
	else
		tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		tooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -CONTAINER_OFFSET_X - 13, CONTAINER_OFFSET_Y);
		tooltip.default = 1;
		tooltip.showHidden = showHidden;
		tooltip:SetFrameStack(showHidden);
	end
end

FRAMESTACK_UPDATE_TIME = .1
local _timeSinceLast = 0
function FrameStackTooltip_OnUpdate (self, elapsed)
	_timeSinceLast = _timeSinceLast - elapsed;
	if ( _timeSinceLast <= 0 ) then
		_timeSinceLast = FRAMESTACK_UPDATE_TIME;
		self:SetFrameStack(self.showHidden);
	end
end

function FrameStackTooltip_OnShow (self)
	local parent = self:GetParent() or UIParent;
	local ps = parent:GetEffectiveScale();
	local px, py = parent:GetCenter();
	px, py = px * ps, py * ps;
	local x, y = GetCursorPosition();
	self:ClearAllPoints();
	if (x > px) then
		if (y > py) then
			self:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 20, 20);
		else
			self:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, -20);
		end
	else
		if (y > py) then
			self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 20);
		else
			self:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -20, -20);
		end
	end
end

FrameStackTooltip_OnEnter = FrameStackTooltip_OnShow;