local ns = oUF
local oUF = ns.oUF

local pairs, type = pairs, type
local format = string.format
local floor = math.floor

local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local UnitDebuff = UnitAura

local addon = {}
ns.oUF_RaidDebuffs = addon
oUF_RaidDebuffs = ns.oUF_RaidDebuffs
if(not _G.oUF_RaidDebuffs) then
	_G.oUF_RaidDebuffs = addon
end

local debuff_data = {}
addon.DebuffData = debuff_data

addon.ShowDispellableDebuff = true
addon.FilterDispellableDebuff = true

addon.priority = 10

local function add(spell, priority, stackThreshold)
	if(spell) then
		debuff_data[spell] = {
			priority = (addon.priority + priority),
			stackThreshold = (stackThreshold or 0)
		}
	end
end

function addon:RegisterDebuffs(t)
	for spell, value in pairs(t) do
		if(type(t[spell]) == 'boolean') then
			local oldValue = t[spell]
			t[spell] = {
				['enable'] = oldValue,
				['priority'] = 0,
				['stackThreshold'] = 0
			}
		else
			if(t[spell].enable) then
				add(spell, t[spell].priority, t[spell].stackThreshold)
			end
		end
	end
end

function addon:ResetDebuffData()
	wipe(debuff_data)
end

local DispellColor = {
	['Magic'] = {.2, .6, 1},
	['Curse'] = {.6, 0, 1},
	['Disease'] = {.6, .4, 0},
	['Poison'] = {0, .6, 0}
}

local DispellPriority = {
	['Magic'] = 4,
	['Curse'] = 3,
	['Disease'] = 2,
	['Poison'] = 1
}

local DispellFilter
do
	local dispellClasses = {
		['PRIEST'] = {
			['Magic'] = true,
			['Disease'] = true
		},
		['SHAMAN'] = {
			['Poison'] = true,
			['Disease'] = true
		},
		['PALADIN'] = {
			['Poison'] = true,
			['Magic'] = true,
			['Disease'] = true
		},
		['MAGE'] = {
			['Curse'] = true
		},
		['DRUID'] = {
			['Curse'] = true,
			['Poison'] = true
		}
	}

	DispellFilter = dispellClasses[select(2, UnitClass('player'))] or {}
end

local function formatTime(s)
	if(s > 60) then
		return format('%dm', s/60), s%60
	elseif(s < 1) then
		return format('%.1f', s), s - floor(s)
	else
		return format('%d', s), s - floor(s)
	end
end

local function onUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.1 then
		local _, _, _, _, _, _, timeLeft = UnitDebuff(self.__owner.unit, self.index, "HARMFUL")
		if timeLeft and timeLeft > 0 then
			self.time:SetText(formatTime(timeLeft))
		else
			self:SetScript('OnUpdate', nil)
			self.time:Hide()
		end
		self.elapsed = 0
	end
end

local function UpdateDebuff(self, name, icon, count, debuffType, duration, endTime, stackThreshold)
	local element = self.RaidDebuffs

	if(name and (count >= stackThreshold)) then
		element.icon:SetTexture(icon)
		element.icon:Show()
		element.duration = duration

		if(element.count) then
			if(count and count > 1) then
				element.count:SetText(count)
				element.count:Show()
			else
				element.count:SetText('')
				element.count:Hide()
			end
		end

		if(element.time) then
			if(duration and duration > 0 and endTime) then
				element:SetScript('OnUpdate', onUpdate)
				element.time:Show()
			else
				element:SetScript('OnUpdate', nil)
				element.time:Hide()
			end
		end

		if(element.cd) then
			if(duration and duration > 0 and endTime) then
				element.cd:SetCooldown(GetTime() - (endTime - duration), duration)
				element.cd:Show()
			else
				element.cd:Hide()
			end
		end

		local c = DispellColor[debuffType] or ElvUI[1].media.bordercolor
		element:SetBackdropBorderColor(c[1], c[2], c[3])

		element:Show()
	else
		element:Hide()
		element.index = nil
	end
end

local function Update(self, event, unit)
	if(not unit or self.unit ~= unit) then return end

	local element = self.RaidDebuffs

	local _, name, icon, count, debuffType, duration, expirationTime
	local _name, _icon, _count, _dtype, _duration, _endTime
	local _priority, priority = 0, 0
	local _stackThreshold = 0

	for i = 1, 40 do
		name, _, icon, count, debuffType, duration, expirationTime = UnitDebuff(unit, i, "HARMFUL")
		if not (name and icon) then break end

		if(addon.ShowDispellableDebuff and (element.showDispellableDebuff ~= false) and debuffType) then
			if(addon.FilterDispellableDebuff) then
				DispellPriority[debuffType] = (DispellPriority[debuffType] or 0) + addon.priority
				priority = DispellFilter[debuffType] and DispellPriority[debuffType] or 0
				if(priority == 0) then
					debuffType = nil
				end
			else
				priority = DispellPriority[debuffType] or 0
			end

			if(priority > _priority) then
				_priority, _name, _icon, _count, _dtype, _duration, _endTime = priority, name, icon, count, debuffType, duration, expirationTime
				element.index = i
			end
		end

		priority = debuff_data[name] and debuff_data[name].priority
		if(priority and (priority > _priority)) then
			_priority, _name, _icon, _count, _dtype, _duration, _endTime = priority, name, icon, count, debuffType, duration, expirationTime
			element.index = i
		end
	end

	if(element.forceShow) then
		_name, _, _icon = GetSpellInfo(26993)
		_count, _dtype, _duration, _endTime, _stackThreshold = 5, 'Magic', 0, 60, 0
	end

	if(_name and _icon) then
		_stackThreshold = debuff_data[_name] and debuff_data[_name].stackThreshold or _stackThreshold
	end

	UpdateDebuff(self, _name, _icon, _count, _dtype, _duration, _endTime, _stackThreshold)

	--Reset the DispellPriority
	DispellPriority = {
		['Magic'] = 4,
		['Curse'] = 3,
		['Disease'] = 2,
		['Poison'] = 1
	}
end

local function Path(self, ...)
	--[[ Override: RaidDebuffs.Override(self, event, ...)
	Used to completely override the element's update process.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event (string)
	--]]
    return (self.RaidDebuffs.Override or Update) (self, ...)
end

local function ForceUpdate(element)
    return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.RaidDebuffs
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_AURA', Update)
		return true
	end
end

local function Disable(self)
	local element = self.RaidDebuffs
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_AURA', Update)
	end
end

oUF:AddElement('RaidDebuffs', Update, Enable, Disable)