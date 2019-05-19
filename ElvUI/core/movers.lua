local E, L, V, P, G = unpack(ElvUI)
local Sticky = LibStub("LibSimpleSticky-1.0")

local _G = _G
local type, unpack, pairs, error = type, unpack, pairs, error
local format, split, find = string.format, string.split, string.find

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT

E.CreatedMovers = {}
E.DisabledMovers = {}

local function SizeChanged(frame)
	if InCombatLockdown() then return end

	if frame.dirtyWidth and frame.dirtyHeight then
		frame.mover:Size(frame.dirtyWidth, frame.dirtyHeight)
	else
		frame.mover:Size(frame:GetSize())
	end
end

local function GetPoint(obj)
	local point, anchor, secondaryPoint, x, y = obj:GetPoint()
	if not anchor then anchor = ElvUIParent end

	return format("%s,%s,%s,%d,%d", point, anchor:GetName(), secondaryPoint, E:Round(x), E:Round(y))
end

local function UpdateCoords(self)
	local mover = self.child
	local x, y, _, nudgePoint, nudgeInversePoint = E:CalculateMoverPoints(mover)

	local coordX, coordY = E:GetXYOffset(nudgeInversePoint, 1)
	ElvUIMoverNudgeWindow:ClearAllPoints()
	ElvUIMoverNudgeWindow:Point(nudgePoint, mover, nudgeInversePoint, coordX, coordY)
	E:UpdateNudgeFrame(mover, x, y)
end

local isDragging = false
local coordFrame = CreateFrame("Frame")
coordFrame:SetScript("OnUpdate", UpdateCoords)
coordFrame:Hide()

local function CreateMover(parent, name, text, overlay, snapOffset, postdrag, shouldDisable, configString)
	if not parent then return end --If for some reason the parent isnt loaded yet
	if E.CreatedMovers[name].Created then return end

	if overlay == nil then overlay = true end
	local point, anchor, secondaryPoint, x, y = split(",", GetPoint(parent))

	--Use dirtyWidth / dirtyHeight to set initial size if possible
	local width = parent.dirtyWidth or parent:GetWidth()
	local height = parent.dirtyHeight or parent:GetHeight()

	local f = CreateFrame("Button", name, E.UIParent)
	f:SetClampedToScreen(true)
	f:RegisterForDrag("LeftButton", "RightButton")
	f:EnableMouseWheel(true)
	f:SetMovable(true)
	f:Width(width)
	f:Height(height)
	f:SetTemplate("Transparent", nil, nil, true)
	f:Hide()
	f.parent = parent
	f.name = name
	f.textString = text
	f.postdrag = postdrag
	f.overlay = overlay
	f.snapOffset = snapOffset or -2
	f.shouldDisable = shouldDisable
	f.configString = configString

	f:SetFrameLevel(parent:GetFrameLevel() + 1)
	if overlay == true then
		f:SetFrameStrata("DIALOG")
	else
		f:SetFrameStrata("BACKGROUND")
	end

	E.CreatedMovers[name].mover = f
	E.snapBars[#E.snapBars + 1] = f

	local fs = f:CreateFontString(nil, "OVERLAY")
	fs:FontTemplate()
	fs:SetJustifyH("CENTER")
	fs:Point("CENTER")
	fs:SetText(text or name)
	fs:SetTextColor(unpack(E.media.rgbvaluecolor))
	f:SetFontString(fs)
	f.text = fs

	if E.db.movers and E.db.movers[name] then
		if type(E.db.movers[name]) == "table" then
			f:Point(E.db.movers[name].p, E.UIParent, E.db.movers[name].p2, E.db.movers[name].p3, E.db.movers[name].p4)
			E.db.movers[name] = GetPoint(f)
			f:ClearAllPoints()
		end

		--Backward compatibility
		local delim
		local anchorString = E.db.movers[name]
		if find(anchorString, "\031") then
			delim = "\031"
		elseif find(anchorString, ",") then
			delim = ","
		end

		local point1, anchor1, secondaryPoint1, x1, y1 = split(delim, anchorString)
		f:Point(point1, anchor1, secondaryPoint1, x1, y1)
		f.anchor = anchor
	else
		f:Point(point, anchor, secondaryPoint, x, y)
	end

	local function OnDragStart(self)
		if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end

		if E.db.general.stickyFrames then
			Sticky:StartMoving(self, E.snapBars, f.snapOffset, f.snapOffset, f.snapOffset, f.snapOffset)
		else
			self:StartMoving()
		end

		coordFrame.child = self
		coordFrame:Show()
		isDragging = true
	end

	local function OnDragStop(self)
		if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
		isDragging = false
		if E.db.general.stickyFrames then
			Sticky:StopMoving(self)
		else
			self:StopMovingOrSizing()
		end

		local x2, y2, point2 = E:CalculateMoverPoints(self)
		self:ClearAllPoints()
		local overridePoint
		if self.positionOverride then
			if self.positionOverride == "BOTTOM" or self.positionOverride == "TOP" then
				overridePoint = "BOTTOM"
			else
				overridePoint = "BOTTOMLEFT"
			end
		end

		self:Point(self.positionOverride or point2, E.UIParent, overridePoint and overridePoint or point2, x2, y2)
		if self.positionOverride then
			self.parent:ClearAllPoints()
			self.parent:Point(self.positionOverride, self, self.positionOverride)
		end

		E:SaveMoverPosition(name)

		if ElvUIMoverNudgeWindow then
			E:UpdateNudgeFrame(self, x, y)
		end

		coordFrame.child = nil
		coordFrame:Hide()

		if postdrag ~= nil and (type(postdrag) == "function") then
			postdrag(self, E:GetScreenQuadrant(self))
		end

		self:SetUserPlaced(false)
	end

	local function OnEnter(self)
		if isDragging then return end

		self.text:SetTextColor(1, 1, 1)
		ElvUIMoverNudgeWindow:Show()
		E.AssignFrameToNudge(self)
		coordFrame.child = self
		coordFrame:GetScript("OnUpdate")(coordFrame)
	end

	local function OnMouseDown(self, button)
		if button == "RightButton" then
			isDragging = false
			if E.db.general.stickyFrames then
				Sticky:StopMoving(self)
			else
				self:StopMovingOrSizing()
			end

			--Allow resetting of anchor by Ctrl+RightClick
			if IsControlKeyDown() and self.textString then
				E:ResetMovers(self.textString)
			elseif IsShiftKeyDown() then --Allow hiding a mover temporarily
				self:Hide()
			elseif self.configString then --OpenConfig
				E:ToggleConfig(self.configString)
			end
		end
	end

	local function OnLeave(self)
		if isDragging then return end
		self.text:SetTextColor(unpack(E.media.rgbvaluecolor))
	end

	local function OnShow(self)
		self:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	end

	local function OnMouseWheel(_, delta)
		if IsShiftKeyDown() then
			E:NudgeMover(delta)
		else
			E:NudgeMover(nil, delta)
		end
	end

	f:SetScript("OnDragStart", OnDragStart)
	f:SetScript("OnMouseUp", E.AssignFrameToNudge)
	f:SetScript("OnDragStop", OnDragStop)
	f:SetScript("OnEnter", OnEnter)
	f:SetScript("OnMouseDown", OnMouseDown)
	f:SetScript("OnLeave", OnLeave)
	f:SetScript("OnShow", OnShow)
	f:SetScript("OnMouseWheel", OnMouseWheel)

	parent:SetScript("OnSizeChanged", SizeChanged)
	parent.mover = f

	parent:ClearAllPoints()
	parent:Point(point, f, 0, 0)

	if postdrag ~= nil and type(postdrag) == "function" then
		f:RegisterEvent("PLAYER_ENTERING_WORLD")
		f:SetScript("OnEvent", function(self)
			postdrag(f, E:GetScreenQuadrant(f))
			self:UnregisterAllEvents()
		end)
	end

	E.CreatedMovers[name].Created = true
end

function E:CalculateMoverPoints(mover, nudgeX, nudgeY)
	local screenWidth, screenHeight, screenCenter = E.UIParent:GetRight(), E.UIParent:GetTop(), E.UIParent:GetCenter()
	local x, y = mover:GetCenter()

	local LEFT = screenWidth / 3
	local RIGHT = screenWidth * 2 / 3
	local TOP = screenHeight / 2
	local point, nudgePoint, nudgeInversePoint

	if y >= TOP then
		point = "TOP"
		nudgePoint = "TOP"
		nudgeInversePoint = "BOTTOM"
		y = -(screenHeight - mover:GetTop())
	else
		point = "BOTTOM"
		nudgePoint = "BOTTOM"
		nudgeInversePoint = "TOP"
		y = mover:GetBottom()
	end

	if x >= RIGHT then
		point = point.."RIGHT"
		nudgePoint = "RIGHT"
		nudgeInversePoint = "LEFT"
		x = mover:GetRight() - screenWidth
	elseif x <= LEFT then
		point = point.."LEFT"
		nudgePoint = "LEFT"
		nudgeInversePoint = "RIGHT"
		x = mover:GetLeft()
	else
		x = x - screenCenter
	end

	if mover.positionOverride then
		if mover.positionOverride == "TOPLEFT" then
			x = mover:GetLeft() - E.diffGetLeft
			y = mover:GetTop() - E.diffGetTop
		elseif mover.positionOverride == "TOPRIGHT" then
			x = mover:GetRight() - E.diffGetRight
			y = mover:GetTop() - E.diffGetTop
		elseif mover.positionOverride == "BOTTOMLEFT" then
			x = mover:GetLeft() - E.diffGetLeft
			y = mover:GetBottom() - E.diffGetBottom
		elseif mover.positionOverride == "BOTTOMRIGHT" then
			x = mover:GetRight() - E.diffGetRight
			y = mover:GetBottom() - E.diffGetBottom
		elseif mover.positionOverride == "BOTTOM" then
			x = mover:GetCenter() - screenCenter
			y = mover:GetBottom() - E.diffGetBottom
		elseif mover.positionOverride == "TOP" then
			x = mover:GetCenter() - screenCenter
			y = mover:GetTop() - E.diffGetTop
		end
	end

	--Update coordinates if nudged
	x = x + (nudgeX or 0)
	y = y + (nudgeY or 0)

	return x, y, point, nudgePoint, nudgeInversePoint
end

function E:UpdatePositionOverride(name)
	local frame = _G[name]
	local OnDragStop = frame and frame.GetScript and frame:GetScript("OnDragStop")
	if OnDragStop then OnDragStop(frame) end
end

function E:HasMoverBeenMoved(name)
	if E.db.movers and E.db.movers[name] then
		return true
	else
		return false
	end
end

function E:SaveMoverPosition(name)
	if not _G[name] then return end
	if not E.db.movers then E.db.movers = {} end

	local mover = _G[name]
	local _, anchor = mover:GetPoint()
	mover.anchor = anchor:GetName()

	E.db.movers[name] = GetPoint(mover)
end

function E:SetMoverSnapOffset(name, offset)
	if not _G[name] or not E.CreatedMovers[name] then return end
	E.CreatedMovers[name].mover.snapOffset = offset or -2
	E.CreatedMovers[name].snapoffset = offset or -2
end

function E:SaveMoverDefaultPosition(name)
	if not _G[name] then return end

	E.CreatedMovers[name].point = GetPoint(_G[name])
	E.CreatedMovers[name].postdrag(_G[name], E:GetScreenQuadrant(_G[name]))
end

function E:CreateMover(parent, name, text, overlay, snapoffset, postdrag, moverTypes, shouldDisable, configString)
	if not moverTypes then moverTypes = "ALL,GENERAL" end

	if E.CreatedMovers[name] == nil then
		E.CreatedMovers[name] = {}
		E.CreatedMovers[name].parent = parent
		E.CreatedMovers[name].text = text
		E.CreatedMovers[name].overlay = overlay
		E.CreatedMovers[name].postdrag = postdrag
		E.CreatedMovers[name].snapoffset = snapoffset
		E.CreatedMovers[name].point = GetPoint(parent)
		E.CreatedMovers[name].shouldDisable = shouldDisable
		E.CreatedMovers[name].configString = configString

		E.CreatedMovers[name].type = {}
		local types = {split(",", moverTypes)}
		for i = 1, #types do
			local moverType = types[i]
			E.CreatedMovers[name].type[moverType] = true
		end
	end

	CreateMover(parent, name, text, overlay, snapoffset, postdrag, shouldDisable, configString)
end

function E:ToggleMovers(show, moverType)
	self.configMode = show

	for name in pairs(E.CreatedMovers) do
		if not show then
			_G[name]:Hide()
		else
			if E.CreatedMovers[name].type[moverType] then
				_G[name]:Show()
			else
				_G[name]:Hide()
			end
		end
	end
end

function E:DisableMover(name)
	if self.DisabledMovers[name] then return end

	if not self.CreatedMovers[name] then
		error("mover doesn't exist")
	end

	self.DisabledMovers[name] = {}
	for x, y in pairs(self.CreatedMovers[name]) do
		self.DisabledMovers[name][x] = y
	end

	if self.configMode then
		_G[name]:Hide()
	end

	self.CreatedMovers[name] = nil
end

function E:EnableMover(name)
	if self.CreatedMovers[name] then return end

	if not self.DisabledMovers[name] then
		error("mover doesn't exist")
	end

	self.CreatedMovers[name] = {}
	for x, y in pairs(self.DisabledMovers[name]) do
		self.CreatedMovers[name][x] = y
	end

	--Make sure we add anchor information from a potential profile switch
	--Commented out, as it created an issue with trying to reset a mover after having used EnableMover on it. Not sure if this code is even needed anymore.
	-- if E.db.movers and E.db.movers[name] and type(E.db.movers[name]) == 'string' then
		-- self.CreatedMovers[name].point = E.db.movers[name]
	-- end

	if self.configMode then
		_G[name]:Show()
	end

	self.DisabledMovers[name] = nil
end

function E:ResetMovers(arg)
	if arg == "" or arg == nil then
		for name in pairs(E.CreatedMovers) do
			local f = _G[name]
			local point, anchor, secondaryPoint, x, y = split(",", E.CreatedMovers[name].point)
			f:ClearAllPoints()
			f:Point(point, anchor, secondaryPoint, x, y)

			for key, value in pairs(E.CreatedMovers[name]) do
				if key == "postdrag" and type(value) == "function" then
					value(f, E:GetScreenQuadrant(f))
				end
			end
		end
		self.db.movers = nil
	else
		for name in pairs(E.CreatedMovers) do
			for key, value in pairs(E.CreatedMovers[name]) do
				if key == "text" then
					if arg == value then
						local f = _G[name]
						local point, anchor, secondaryPoint, x, y = split(",", E.CreatedMovers[name].point)
						f:ClearAllPoints()
						f:Point(point, anchor, secondaryPoint, x, y)

						if self.db.movers then
							self.db.movers[name] = nil
						end

						if E.CreatedMovers[name].postdrag ~= nil and type(E.CreatedMovers[name].postdrag) == "function" then
							E.CreatedMovers[name].postdrag(f, E:GetScreenQuadrant(f))
						end
					end
				end
			end
		end
	end
end

--Profile Change
function E:SetMoversPositions()
	--E:SetMoversPositions() is the first function called in E:UpdateAll().
	--Because of that, we can allow ourselves to re-enable all disabled movers here,
	--as the subsequent updates to these elements will disable them again if needed.
	for name in pairs(E.DisabledMovers) do
		local shouldDisable = ((E.DisabledMovers[name].shouldDisable and E.DisabledMovers[name].shouldDisable()) or false)
		if not shouldDisable then
			E:EnableMover(name)
		end
	end

	for name in pairs(E.CreatedMovers) do
		local f = _G[name]
		local point, anchor, secondaryPoint, x, y
		if E.db.movers and E.db.movers[name] and type(E.db.movers[name]) == "string" then
			--Backward compatibility
			local delim
			local anchorString = E.db.movers[name]
			if find(anchorString, "\031") then
				delim = "\031"
			elseif find(anchorString, ",") then
				delim = ","
			end
			point, anchor, secondaryPoint, x, y = split(delim, anchorString)
			f:ClearAllPoints()
			f:Point(point, anchor, secondaryPoint, x, y)
		elseif f then
			point, anchor, secondaryPoint, x, y = split(",", E.CreatedMovers[name].point)
			f:ClearAllPoints()
			f:Point(point, anchor, secondaryPoint, x, y)
		end
	end
end

--Called from core.lua
function E:LoadMovers()
	for name, t in pairs(E.CreatedMovers) do
		--All of these properties are cached in E.CreatedMovers by "E:CreateMover()",
		--so that we can reproduce the function calls identically here.
		CreateMover(t.parent, name, t.text, t.overlay, t.snapoffset, t.postdrag, t.shouldDisable, t.configString)
	end
end