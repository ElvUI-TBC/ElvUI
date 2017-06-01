local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule("ActionBars")

local _G = _G
local ceil = math.ceil

local CreateFrame = CreateFrame
local NUM_BONUS_ACTION_SLOTS = NUM_BONUS_ACTION_SLOTS

local bar = CreateFrame("Frame", "ElvUI_BonusBar", E.UIParent, "SecureStateHeaderTemplate")

function AB:PositionAndSizeBonusBar()
	local spacing = E:Scale(self.db["bar1"].buttonspacing)
	local buttonsPerRow = self.db["bar1"].buttonsPerRow
	local numButtons = self.db["bar1"].buttons
	local size = E:Scale(self.db["bar1"].buttonsize)
	local point = self.db["bar1"].point
	local numColumns = ceil(numButtons / buttonsPerRow)
	local widthMult = self.db["bar1"].widthMult
	local heightMult = self.db["bar1"].heightMult

	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons
	end

	if numColumns < 1 then
		numColumns = 1
	end

	bar:Width(spacing + ((size * (buttonsPerRow * widthMult)) + ((spacing * (buttonsPerRow - 1)) * widthMult) + (spacing * widthMult)))
	bar:Height(spacing + ((size * (numColumns * heightMult)) + ((spacing * (numColumns - 1)) * heightMult) + (spacing * heightMult)))
	
	if self.db["bar1"].backdrop then
		bar.backdrop:Show()
	else
		bar.backdrop:Hide()
	end

	local horizontalGrowth, verticalGrowth
	if point == "TOPLEFT" or point == "TOPRIGHT" then
		verticalGrowth = "DOWN"
	else
		verticalGrowth = "UP"
	end

	if point == "BOTTOMLEFT" or point == "TOPLEFT" then
		horizontalGrowth = "RIGHT"
	else
		horizontalGrowth = "LEFT"
	end

	local button, lastButton, lastColumnButton
	for i = 1, NUM_BONUS_ACTION_SLOTS do
		button = _G["BonusActionButton"..i]
		lastButton = _G["BonusActionButton"..i-1]
		lastColumnButton = _G["BonusActionButton"..i-buttonsPerRow]
		button:SetParent(bar)
		button:ClearAllPoints()
		button:Size(size)
		button:SetAttribute("showgrid", 1)
		ActionButton_ShowGrid(button)

		if self.db["bar1"].mouseover == true then
			bar:SetAlpha(0)

			if not self.hooks[bar] then
				self:HookScript(bar, "OnEnter", "Bar_OnEnter")
				self:HookScript(bar, "OnLeave", "Bar_OnLeave")
			end

			if not self.hooks[button] then
				self:HookScript(button, "OnEnter", "Button_OnEnter")
				self:HookScript(button, "OnLeave", "Button_OnLeave")
			end
		else
			bar:SetAlpha(self.db["bar1"].alpha)

			if self.hooks[bar] then
				self:Unhook(bar, "OnEnter")
				self:Unhook(bar, "OnLeave")
			end

			if self.hooks[button] then
				self:Unhook(button, "OnEnter")
				self:Unhook(button, "OnLeave")
			end
		end

		if i == 1 then
			local x, y
				if point == "BOTTOMLEFT" then
					x, y = spacing, spacing
				elseif point == "TOPRIGHT" then
					x, y = -spacing, -spacing
				elseif point == "TOPLEFT" then
					x, y = spacing, -spacing
				else
					x, y = -spacing, spacing
				end

			button:Point(point, bar, point, x, y)
		elseif (i - 1) % buttonsPerRow == 0 then
			local x = 0
			local y = -spacing
			local buttonPoint, anchorPoint = "TOP", "BOTTOM"

			if verticalGrowth == "UP" then
				y = spacing
				buttonPoint = "BOTTOM"
				anchorPoint = "TOP"
			end

			button:Point(buttonPoint, lastColumnButton, anchorPoint, x, y)
		else
			local x = spacing
			local y = 0
			local buttonPoint, anchorPoint = "LEFT", "RIGHT"

			if horizontalGrowth == "LEFT" then
				x = -spacing
				buttonPoint = "RIGHT"
				anchorPoint = "LEFT"
			end

			button:Point(buttonPoint, lastButton, anchorPoint, x, y)
		end

		if i > numButtons then
			button:SetScale(0.000001)
			button:SetAlpha(0)
		else
			button:SetScale(1)
			button:SetAlpha(1)
		end
	end

	if self.db["bar1"].enabled or not bar.initialized then
		if not self.db["bar1"].mouseover then
			bar:SetAlpha(self.db["bar1"].alpha)
		end

		bar:Hide()
		if not bar.initialized then
			bar.initialized = true
			AB:PositionAndSizeBonusBar()
			return
		end
		
	else
		bar:Hide()
	end

	AB:UpdateBonusBar()
end

function AB:UpdateBonusBar()

  local offset = GetBonusBarOffset()
  
  
  if self.db["bar1"].enabled then
    if ( offset > 0 ) then
		ElvUI_Bar1:Hide()
      	ElvUI_BonusBar:Show();
		BonusActionBarFrame:Show();
	else
      	ElvUI_Bar1:Show()
      	ElvUI_BonusBar:Hide();
		BonusActionBarFrame:Hide();
	end
  else
	  ElvUI_Bar1:Hide()
	  ElvUI_BonusBar:Hide();
	  BonusActionBarFrame:Hide();
  end
  
end

function AB:CreateBonusBar()
	bar:CreateBackdrop("Default")
	bar.backdrop:SetAllPoints()
	bar:Point("BOTTOM", 0, 3)

  	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "UpdateBonusBar")

	self:PositionAndSizeBonusBar()
end