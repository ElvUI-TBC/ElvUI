--[[
# Element: Castbar

Handles the visibility and updating of spell castbars.
Based upon oUF_Castbar by starlon.

## Widget

Castbar - A `StatusBar` to represent spell cast/channel progress.

## Sub-Widgets

.Text     - A `FontString` to represent spell name.
.Icon     - A `Texture` to represent spell icon.
.Time     - A `FontString` to represent spell duration.
.SafeZone - A `Texture` to represent latency.

## Notes

A default texture will be applied to the StatusBar and Texture widgets if they don't have a texture or a color set.

## Options

.timeToHold - indicates for how many seconds the castbar should be visible after a _FAILED or _INTERRUPTED
              event. Defaults to 0 (number)

## Examples

    -- Position and size
    local Castbar = CreateFrame('StatusBar', nil, self)
    Castbar:SetSize(20, 20)
    Castbar:SetPoint('TOP')
    Castbar:SetPoint('LEFT')
    Castbar:SetPoint('RIGHT')

    -- Add a background
    local Background = Castbar:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints(Castbar)
    Background:SetTexture(1, 1, 1, .5)

    -- Add a spark
    local Spark = Castbar:CreateTexture(nil, 'OVERLAY')
    Spark:SetSize(20, 20)
    Spark:SetBlendMode('ADD')

    -- Add a timer
    local Time = Castbar:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    Time:SetPoint('RIGHT', Castbar)

    -- Add spell text
    local Text = Castbar:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    Text:SetPoint('LEFT', Castbar)

    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, 'OVERLAY')
    Icon:SetSize(20, 20)
    Icon:SetPoint('TOPLEFT', Castbar, 'TOPLEFT')

    -- Add safezone
    local SafeZone = Castbar:CreateTexture(nil, 'OVERLAY')

    -- Register it with oUF
    Castbar.bg = Background
    Castbar.Spark = Spark
    Castbar.Time = Time
    Castbar.Text = Text
    Castbar.Icon = Icon
    Castbar.SafeZone = SafeZone
    self.Castbar = Castbar
--]]
local ns = oUF
local oUF = ns.oUF

local GetNetStats = GetNetStats
local GetTime = GetTime
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo

local tradeskillCastTime, tradeskillCastDuration, tradeskillCurrent, tradeskillTotal, mergeTradeskill = 0, 0, 0, 0, false

local function updateSafeZone(self)
	local safeZone = self.SafeZone
	local width = self:GetWidth()
	local _, _, ms = GetNetStats()

	local safeZoneRatio = (ms / 1e3) / self.max
	if(safeZoneRatio > 1) then
		safeZoneRatio = 1
	end

	safeZone:SetWidth(width * safeZoneRatio)
end

local function UNIT_SPELLCAST_SENT(self, event, unit, spell, rank, target)
	local element = self.Castbar
	element.curTarget = (target and target ~= '') and target or nil

	if element.isTradeSkill then
		element.tradeSkillCastName = spell
	end
end

local function UNIT_SPELLCAST_START(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	local name, _, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit)
	if(not name) then
		return element:Hide()
	end

	endTime = endTime / 1e3
	startTime = startTime / 1e3
	local max = endTime - startTime

	element.castName = name
	element.duration = GetTime() - startTime
	element.max = max
	element.delay = 0
	element.casting = true
	element.holdTime = 0
	element.isTradeSkill = isTradeSkill

	if(mergeTradeskill and isTradeSkill and self.unit == 'player') then
		element.duration = element.duration + (element.max * tradeskillCurrent)
		element.max = max * tradeskillTotal

		if(unit == 'player') then
			tradeskillCurrent = tradeskillCurrent + 1
			tradeskillCastDuration = element.duration
			tradeskillCastTime = max
		end

		element:SetValue(element.duration)
	else
		element:SetValue(0)
	end
	element:SetMinMaxValues(0, element.max)

	if(element.Text) then element.Text:SetText(text) end
	if(element.Icon) then element.Icon:SetTexture(texture) end
	if(element.Time) then element.Time:SetText() end

	local sf = element.SafeZone
	if(sf) then
		sf:ClearAllPoints()
		sf:SetPoint('RIGHT')
		sf:SetPoint('TOP')
		sf:SetPoint('BOTTOM')
		updateSafeZone(element)
	end

	--[[ Callback: Castbar:PostCastStart(unit, name)
	Called after the element has been updated upon a spell cast start.

	* self    - the Castbar widget
	* unit    - unit for which the update has been triggered (string)
	* name    - name of the spell being cast (string)
	--]]
	if(element.PostCastStart) then
		element:PostCastStart(unit, name)
	end
	element:Show()
end

local function UNIT_SPELLCAST_FAILED(self, event, unit, spellname)
	if(not self.casting) then return end
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	if(spellname and (element.castName ~= spellname and element.tradeSkillCastName ~= spellname)) then
		return
	end

	if(mergeTradeskill and self.unit == 'player') then
		mergeTradeskill = false
		element.tradeSkillCastName = nil
	end

	local text = element.Text
	if(text) then
		text:SetText(FAILED)
	end

	element.casting = nil
	element.holdTime = element.timeToHold or 0

	--[[ Callback: Castbar:PostCastFailed(unit, name)
	Called after the element has been updated upon a failed spell cast.

	* self    - the Castbar widget
	* unit    - unit for which the update has been triggered (string)
	* name    - name of the failed spell (string)
	--]]
	if(element.PostCastFailed) then
		return element:PostCastFailed(unit, spellname)
	end
end

local function UNIT_SPELLCAST_FAILED_QUIET(self, event, unit, spellname)
	if(not self.casting) then return end
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	if(spellname and (element.castName ~= spellname and element.tradeSkillCastName ~= spellname)) then
		return
	end

	if(mergeTradeskill and self.unit == 'player') then
		mergeTradeskill = false
		element.tradeSkillCastName = nil
	end

	element.casting = nil
	element:SetValue(0)
	element:Hide()
end

local function UNIT_SPELLCAST_INTERRUPTED(self, event, unit, spellname)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	if(spellname and element.castName ~= spellname) then
		return
	end

	local text = element.Text
	if(text) then
		text:SetText(INTERRUPTED)
	end

	element.casting = nil
	element.channeling = nil
	element.holdTime = element.timeToHold or 0

	--[[ Callback: Castbar:PostCastInterrupted(unit, name)
	Called after the element has been updated upon an interrupted spell cast.

	* self    - the Castbar widget
	* unit    - unit for which the update has been triggered (string)
	* name    - name of the interrupted spell (string)
	--]]
	if(element.PostCastInterrupted) then
		return element:PostCastInterrupted(unit, spellname)
	end
end

local function UNIT_SPELLCAST_DELAYED(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	local name, _, _, _, startTime = UnitCastingInfo(unit)
	if(not startTime or not element:IsShown()) then return end

	local duration = GetTime() - (startTime / 1000)
	if(duration < 0) then duration = 0 end

	element.delay = element.delay + element.duration - duration
	element.duration = duration

	element:SetValue(duration)

	--[[ Callback: Castbar:PostCastDelayed(unit, name)
	Called after the element has been updated when a spell cast has been delayed.

	* self    - the Castbar widget
	* unit    - unit that the update has been triggered (string)
	* name    - name of the delayed spell (string)
	--]]
	if(element.PostCastDelayed) then
		return element:PostCastDelayed(unit, name)
	end
end

local function UNIT_SPELLCAST_STOP(self, event, unit, spellname)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	if(spellname and (element.castName ~= spellname)) then
		return
	end

	if(mergeTradeskill and self.unit == 'player') then
		if(tradeskillCurrent == tradeskillTotal) then
			mergeTradeskill = false
		end
	else
		element.casting = nil
	end

	--[[ Callback: Castbar:PostCastStop(unit, name)
	Called after the element has been updated when a spell cast has finished.

	* self    - the Castbar widget
	* unit    - unit for which the update has been triggered (string)
	* name    - name of the spell (string)
	--]]
	if(element.PostCastStop) then
		return element:PostCastStop(unit, spellname)
	end
end

local function UNIT_SPELLCAST_CHANNEL_START(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	local name, _, _, texture, startTime, endTime = UnitChannelInfo(unit)
	if(not name) then
		return
	end

	endTime = endTime / 1e3
	startTime = startTime / 1e3
	local max = (endTime - startTime)
	local duration = endTime - GetTime()

	element.duration = duration
	element.max = max
	element.delay = 0
	element.startTime = startTime
	element.endTime = endTime
	element.extraTickRatio = 0
	element.channeling = true
	element.holdTime = 0

	-- We have to do this, as it's possible for spell casts to never have _STOP
	-- executed or be fully completed by the OnUpdate handler before CHANNEL_START
	-- is called.
	element.casting = nil
	element.castName = nil

	element:SetMinMaxValues(0, max)
	element:SetValue(duration)

	if(element.Text) then element.Text:SetText(name) end
	if(element.Icon) then element.Icon:SetTexture(texture) end
	if(element.Time) then element.Time:SetText() end

	local sf = element.SafeZone
	if(sf) then
		sf:ClearAllPoints()
		sf:SetPoint('LEFT')
		sf:SetPoint('TOP')
		sf:SetPoint('BOTTOM')
		updateSafeZone(element)
	end

	--[[ Callback: Castbar:PostChannelStart(unit, name)
	Called after the element has been updated upon a spell channel start.

	* self    - the Castbar widget
	* unit    - unit for which the update has been triggered (string)
	* name    - name of the channeled spell (string)
	--]]
	if(element.PostChannelStart) then
		element:PostChannelStart(unit, name)
	end
	element:Show()
end

local function UNIT_SPELLCAST_CHANNEL_UPDATE(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	local name, _, _, _, startTime, endTime = UnitChannelInfo(unit)
	if(not name or not element:IsShown()) then
		return
	end

	local duration = (endTime / 1000) - GetTime()
	element.delay = element.delay + element.duration - duration
	element.duration = duration
	element.max = (endTime - startTime) / 1000
	element.startTime = startTime / 1000
	element.endTime = endTime / 1000

	element:SetMinMaxValues(0, element.max)
	element:SetValue(duration)

	--[[ Callback: Castbar:PostChannelUpdate(unit, name)
	Called after the element has been updated after a channeled spell has been delayed or interrupted.

	* self    - the Castbar widget
	* unit    - unit for which the update has been triggered (string)
	* name    - name of the channeled spell (string)
	--]]
	if(element.PostChannelUpdate) then
		return element:PostChannelUpdate(unit, name)
	end
end

local function UNIT_SPELLCAST_CHANNEL_STOP(self, event, unit, spellname)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	if(element:IsShown()) then
		element.channeling = nil

		--[[ Callback: Castbar:PostChannelUpdate(unit, name)
		Called after the element has been updated after a channeled spell has been completed.

		* self    - the Castbar widget
		* unit    - unit for which the update has been triggered (string)
		* name    - name of the channeled spell (string)
		--]]
		if(element.PostChannelStop) then
			return element:PostChannelStop(unit, spellname)
		end
	end
end

local function onUpdate(self, elapsed)
	if(self.casting) then
		local duration = self.duration + elapsed
		if(duration >= self.max or (tradeskillTotal > 1 and duration >= (tradeskillCastDuration + tradeskillCastTime * 1.25))) then
			self.casting = nil
			self:Hide()
			if self.unit == "player" then
				tradeskillTotal = 0
			end

			if(self.PostCastStop) then self:PostCastStop(self.__owner.unit) end
			return
		end

		if(self.Time) then
			if(self.delay ~= 0) then
				if(self.CustomDelayText) then
					self:CustomDelayText(duration)
				else
					self.Time:SetFormattedText('%.1f|cffff0000-%.1f|r', duration, self.delay)
				end
			else
				if(self.CustomTimeText) then
					self:CustomTimeText(duration)
				else
					self.Time:SetFormattedText('%.1f', duration)
				end
			end
		end

		self.duration = duration
		self:SetValue(duration)

		if(self.Spark) then
			self.Spark:SetPoint('CENTER', self, 'LEFT', (duration / self.max) * self:GetWidth(), 0)
		end
	elseif(self.channeling) then
		local duration = self.duration - elapsed

		if(duration <= 0) then
			self.channeling = nil
			self:Hide()

			if(self.PostChannelStop) then self:PostChannelStop(self.__owner.unit) end
			return
		end

		if(self.Time) then
			if(self.delay ~= 0) then
				if(self.CustomDelayText) then
					self:CustomDelayText(duration)
				else
					self.Time:SetFormattedText('%.1f|cffff0000-%.1f|r', duration, self.delay)
				end
			else
				if(self.CustomTimeText) then
					self:CustomTimeText(duration)
				else
					self.Time:SetFormattedText('%.1f', duration)
				end
			end
		end

		self.duration = duration
		self:SetValue(duration)
		if(self.Spark) then
			self.Spark:SetPoint('CENTER', self, 'LEFT', (duration / self.max) * self:GetWidth(), 0)
		end
	elseif(self.holdTime > 0) then
		self.holdTime = self.holdTime - elapsed
	else
		self.casting = nil
		self.castName = nil
		self.channeling = nil
		if self.unit == "player" then
			tradeskillTotal = 0
		end

		self:Hide()
	end
end

local function Update(self, ...)
	UNIT_SPELLCAST_START(self, ...)
	return UNIT_SPELLCAST_CHANNEL_START(self, ...)
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.Castbar
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if(not (unit and unit:match('%wtarget$'))) then
			self:RegisterEvent('UNIT_SPELLCAST_START', UNIT_SPELLCAST_START)
			self:RegisterEvent('UNIT_SPELLCAST_FAILED', UNIT_SPELLCAST_FAILED)
			self:RegisterEvent('UNIT_SPELLCAST_STOP', UNIT_SPELLCAST_STOP)
			self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED', UNIT_SPELLCAST_INTERRUPTED)
			self:RegisterEvent('UNIT_SPELLCAST_DELAYED', UNIT_SPELLCAST_DELAYED)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START', UNIT_SPELLCAST_CHANNEL_START)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', UNIT_SPELLCAST_CHANNEL_UPDATE)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', UNIT_SPELLCAST_CHANNEL_STOP)
			self:RegisterEvent('UNIT_SPELLCAST_SENT', UNIT_SPELLCAST_SENT, true)
			self:RegisterEvent('UNIT_SPELLCAST_FAILED_QUIET', UNIT_SPELLCAST_FAILED_QUIET)
		end

		element.holdTime = 0
		element:SetScript('OnUpdate', element.OnUpdate or onUpdate)

		if(self.unit == 'player') then
			CastingBarFrame:UnregisterAllEvents()
			CastingBarFrame.Show = CastingBarFrame.Hide
			CastingBarFrame:Hide()

			PetCastingBarFrame:UnregisterAllEvents()
			PetCastingBarFrame.Show = PetCastingBarFrame.Hide
			PetCastingBarFrame:Hide()
		end

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		local spark = element.Spark
		if(spark and spark:IsObjectType('Texture') and not spark:GetTexture()) then
			spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
		end

		local safeZone = element.SafeZone
		if(safeZone and safeZone:IsObjectType('Texture') and not safeZone:GetTexture()) then
			safeZone:SetTexture(1, 0, 0)
		end

		element:Hide()

		return true
	end
end

local function Disable(self)
	local element = self.Castbar
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_SPELLCAST_START', UNIT_SPELLCAST_START)
		self:UnregisterEvent('UNIT_SPELLCAST_FAILED', UNIT_SPELLCAST_FAILED)
		self:UnregisterEvent('UNIT_SPELLCAST_STOP', UNIT_SPELLCAST_STOP)
		self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTED', UNIT_SPELLCAST_INTERRUPTED)
		self:UnregisterEvent('UNIT_SPELLCAST_DELAYED', UNIT_SPELLCAST_DELAYED)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START', UNIT_SPELLCAST_CHANNEL_START)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', UNIT_SPELLCAST_CHANNEL_UPDATE)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', UNIT_SPELLCAST_CHANNEL_STOP)
		self:UnregisterEvent('UNIT_SPELLCAST_SENT', UNIT_SPELLCAST_SENT)
		self:UnregisterEvent('UNIT_SPELLCAST_FAILED_QUIET', UNIT_SPELLCAST_FAILED_QUIET)

		element:SetScript('OnUpdate', nil)
	end
end

hooksecurefunc('DoTradeSkill', function(_, num)
	tradeskillCastTime = 0
	tradeskillCastDuration = 0
	tradeskillCurrent = 0
	tradeskillTotal = num or 1
	mergeTradeskill = true
end)

oUF:AddElement('Castbar', Update, Enable, Disable)