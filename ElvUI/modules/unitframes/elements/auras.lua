local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule("UnitFrames")
local LSM = E.LSM

local unpack = unpack
local find = string.find
local format = string.format
local tsort = table.sort
local ceil = math.ceil

local GetTime = GetTime
local CreateFrame = CreateFrame
local IsShiftKeyDown = IsShiftKeyDown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local UnitAura = UnitAura
local UnitIsFriend = UnitIsFriend

function UF:Construct_Buffs(frame)
	local buffs = CreateFrame("Frame", frame:GetName().."Buffs", frame)
	buffs.spacing = E.Spacing
	buffs.PreSetPosition = (not frame:GetScript("OnUpdate")) and self.SortAuras or nil
	buffs.PostCreateIcon = self.Construct_AuraIcon
	buffs.PostUpdateIcon = self.PostUpdateAura
	buffs.CustomFilter = self.AuraFilter
	buffs:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 10) --Make them appear above any text element
	buffs.type = "buffs"
	--Set initial width to prevent division by zero. This value doesn't matter, as it will be updated later
	buffs:Width(100)

	return buffs
end

function UF:Construct_Debuffs(frame)
	local debuffs = CreateFrame("Frame", frame:GetName().."Debuffs", frame)
	debuffs.spacing = E.Spacing
	debuffs.PreSetPosition = (not frame:GetScript("OnUpdate")) and self.SortAuras or nil
	debuffs.PostCreateIcon = self.Construct_AuraIcon
	debuffs.PostUpdateIcon = self.PostUpdateAura
	debuffs.CustomFilter = self.AuraFilter
	debuffs.type = "debuffs"
	debuffs:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 10) --Make them appear above any text element
	--Set initial width to prevent division by zero. This value doesn't matter, as it will be updated later
	debuffs:Width(100)

	return debuffs
end

function UF:Construct_AuraIcon(button)
	local offset = UF.thinBorders and E.mult or E.Border

	button.text = button.cd:CreateFontString(nil, "OVERLAY")
	button.text:Point("CENTER", 1, 1)
	button.text:SetJustifyH("CENTER")

	button:SetTemplate("Default", nil, nil, UF.thinBorders, true)

	-- cooldown override settings
	if not button.timerOptions then
		button.timerOptions = {}
	end

	button.timerOptions.reverseToggle = UF.db.cooldown.reverse

	if UF.db.cooldown.override and E.TimeColors.unitframe then
		button.timerOptions.timeColors, button.timerOptions.timeThreshold = E.TimeColors.unitframe, UF.db.cooldown.threshold
	else
		button.timerOptions.timeColors, button.timerOptions.timeThreshold = nil, nil
	end

	if UF.db.cooldown.checkSeconds then
		button.timerOptions.hhmmThreshold, button.timerOptions.mmssThreshold = UF.db.cooldown.hhmmThreshold, UF.db.cooldown.mmssThreshold
	else
		button.timerOptions.hhmmThreshold, button.timerOptions.mmssThreshold = nil, nil
	end

	if UF.db.cooldown.fonts and UF.db.cooldown.fonts.enable then
		button.timerOptions.fontOptions = UF.db.cooldown.fonts
	elseif E.db.cooldown.fonts and E.db.cooldown.fonts.enable then
		button.timerOptions.fontOptions = E.db.cooldown.fonts
	else
		button.timerOptions.fontOptions = nil
	end

	button.cd:SetReverse(true)
	button.cd:SetInside(button, offset, offset)

	button.icon:SetInside(button, offset, offset)
	button.icon:SetTexCoord(unpack(E.TexCoords))
	button.icon:SetDrawLayer("ARTWORK")

	button.count:ClearAllPoints()
	button.count:Point("BOTTOMRIGHT", 1, 1)
	button.count:SetJustifyH("RIGHT")

	button.overlay:SetTexture(nil)

	button:RegisterForClicks("RightButtonUp")
	button:SetScript("OnClick", function(self)
		if E.db.unitframe.auraBlacklistModifier == "NONE" or not ((E.db.unitframe.auraBlacklistModifier == "SHIFT" and IsShiftKeyDown()) or (E.db.unitframe.auraBlacklistModifier == "ALT" and IsAltKeyDown()) or (E.db.unitframe.auraBlacklistModifier == "CTRL" and IsControlKeyDown())) then return end
		local auraName = self.name

		if auraName then
			E:Print(format(L["The spell '%s' has been added to the Blacklist unitframe aura filter."], auraName))
			E.global.unitframe.aurafilters.Blacklist.spells[auraName] = {
				["enable"] = true,
				["priority"] = 0
			}

			UF:Update_AllFrames()
		end
	end)

	-- support cooldown override
	if not button.isRegisteredCooldown then
		button.CooldownOverride = "unitframe"
		button.isRegisteredCooldown = true

		if not E.RegisteredCooldowns.unitframe then E.RegisteredCooldowns.unitframe = {} end
		tinsert(E.RegisteredCooldowns.unitframe, button)
	end

	UF:UpdateAuraIconSettings(button, true)
end

function UF:EnableDisable_Auras(frame)
	if frame.db.debuffs.enable or frame.db.buffs.enable then
		if not frame:IsElementEnabled("Auras") then
			frame:EnableElement("Auras")
		end
	else
		if frame:IsElementEnabled("Auras") then
			frame:DisableElement("Auras")
		end
	end
end

local function ReverseUpdate(frame)
	UF:Configure_Auras(frame, "Debuffs")
	UF:Configure_Auras(frame, "Buffs")
end

function UF:Configure_Auras(frame, auraType)
	if not frame.VARIABLES_SET then return end
	local db = frame.db

	local auras = frame[auraType]
	auraType = auraType:lower()
	local rows = db[auraType].numrows

	local totalWidth = frame.UNIT_WIDTH - frame.SPACING*2
	if frame.USE_POWERBAR_OFFSET then
		local powerOffset = ((frame.ORIENTATION == "MIDDLE" and 2 or 1) * frame.POWERBAR_OFFSET)

		if not (db[auraType].attachTo == "POWER" and frame.ORIENTATION == "MIDDLE") then
			totalWidth = totalWidth - powerOffset
		end
	end
	auras:Width(totalWidth)

	auras.forceShow = frame.forceShowAuras
	auras.num = db[auraType].perrow * rows
	auras.size = db[auraType].sizeOverride ~= 0 and db[auraType].sizeOverride or ((((auras:GetWidth() - (auras.spacing*(auras.num/rows - 1))) / auras.num)) * rows)

	if db[auraType].sizeOverride and db[auraType].sizeOverride > 0 then
		auras:Width(db[auraType].perrow * db[auraType].sizeOverride)
	end

	local attachTo = self:GetAuraAnchorFrame(frame, db[auraType].attachTo, db.debuffs.attachTo == "BUFFS" and db.buffs.attachTo == "DEBUFFS")
	local x, y = E:GetXYOffset(db[auraType].anchorPoint, frame.SPACING)

	if db[auraType].attachTo == "FRAME" then
		y = 0
	elseif db[auraType].attachTo == "HEALTH" or db[auraType].attachTo == "POWER" then
		local newX = E:GetXYOffset(db[auraType].anchorPoint, -frame.BORDER)
		local _, newY = E:GetXYOffset(db[auraType].anchorPoint, (frame.BORDER + frame.SPACING))
		x = newX
		y = newY
	else
		x = 0
	end

	if auraType == "buffs" and frame.Debuffs.attachTo and frame.Debuffs.attachTo == frame.Buffs and db[auraType].attachTo == "DEBUFFS" then
		--Update Debuffs first, as we would otherwise get conflicting anchor points
		--This is usually only an issue on profile change
		ReverseUpdate(frame)
		return
	end

	auras:ClearAllPoints()
	auras:Point(E.InversePoints[db[auraType].anchorPoint], attachTo, db[auraType].anchorPoint, x + db[auraType].xOffset, y + db[auraType].yOffset)
	auras:Height(auras.size * rows)
	auras["growth-y"] = find(db[auraType].anchorPoint, "TOP") and "UP" or "DOWN"
	auras["growth-x"] = db[auraType].anchorPoint == "LEFT" and "LEFT" or db[auraType].anchorPoint == "RIGHT" and "RIGHT" or (find(db[auraType].anchorPoint, "LEFT") and "RIGHT" or "LEFT")
	auras.initialAnchor = E.InversePoints[db[auraType].anchorPoint]

	--These are needed for SmartAuraPosition
	auras.attachTo = attachTo
	auras.point = E.InversePoints[db[auraType].anchorPoint]
	auras.anchorPoint = db[auraType].anchorPoint
	auras.xOffset = x + db[auraType].xOffset
	auras.yOffset = y + db[auraType].yOffset

	if db[auraType].enable then
		auras:Show()
		UF:UpdateAuraIconSettings(auras)
	else
		auras:Hide()
	end

	local position = db.smartAuraPosition
	if position == "BUFFS_ON_DEBUFFS" then
		if db.debuffs.attachTo == "BUFFS" then
			E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Buffs"], L["Debuffs"], L["Frame"]))
			db.debuffs.attachTo = "FRAME"
			frame.Debuffs.attachTo = frame
		end
		db.buffs.attachTo = "DEBUFFS"
		frame.Buffs.attachTo = frame.Debuffs
		frame.Buffs.PostUpdate = nil
		frame.Debuffs.PostUpdate = UF.UpdateBuffsHeaderPosition
	elseif position == "DEBUFFS_ON_BUFFS" then
		if db.buffs.attachTo == "DEBUFFS" then
			E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Debuffs"], L["Buffs"], L["Frame"]))
			db.buffs.attachTo = "FRAME"
			frame.Buffs.attachTo = frame
		end
		db.debuffs.attachTo = "BUFFS"
		frame.Debuffs.attachTo = frame.Buffs
		frame.Buffs.PostUpdate = UF.UpdateDebuffsHeaderPosition
		frame.Debuffs.PostUpdate = nil
	elseif position == "FLUID_BUFFS_ON_DEBUFFS" then
		if db.debuffs.attachTo == "BUFFS" then
			E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Buffs"], L["Debuffs"], L["Frame"]))
			db.debuffs.attachTo = "FRAME"
			frame.Debuffs.attachTo = frame
		end
		db.buffs.attachTo = "DEBUFFS"
		frame.Buffs.attachTo = frame.Debuffs
		frame.Buffs.PostUpdate = UF.UpdateBuffsHeight
		frame.Debuffs.PostUpdate = UF.UpdateBuffsPositionAndDebuffHeight
	elseif position == "FLUID_DEBUFFS_ON_BUFFS" then
		if db.buffs.attachTo == "DEBUFFS" then
			E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Debuffs"], L["Buffs"], L["Frame"]))
			db.buffs.attachTo = "FRAME"
			frame.Buffs.attachTo = frame
		end
		db.debuffs.attachTo = "BUFFS"
		frame.Debuffs.attachTo = frame.Buffs
		frame.Buffs.PostUpdate = UF.UpdateDebuffsPositionAndBuffHeight
		frame.Debuffs.PostUpdate = UF.UpdateDebuffsHeight
	else
		frame.Buffs.PostUpdate = nil
		frame.Debuffs.PostUpdate = nil
	end
end

local function SortAurasByTime(a, b)
	if a and b and a:GetParent().db then
		if a:IsShown() and b:IsShown() then
			local sortDirection = a:GetParent().db.sortDirection
			local aTime = a.expiration or -1
			local bTime = b.expiration or -1
			if aTime and bTime then
				if sortDirection == "DESCENDING" then
					return aTime < bTime
				else
					return aTime > bTime
				end
			end
		elseif a:IsShown() then
			return true
		end
	end
end

local function SortAurasByName(a, b)
	if a and b and a:GetParent().db then
		if a:IsShown() and b:IsShown() then
			local sortDirection = a:GetParent().db.sortDirection
			local aName = a.spell or ""
			local bName = b.spell or ""
			if aName and bName then
				if sortDirection == "DESCENDING" then
					return aName < bName
				else
					return aName > bName
				end
			end
		elseif a:IsShown() then
			return true
		end
	end
end

local function SortAurasByDuration(a, b)
	if a and b and a:GetParent().db then
		if a:IsShown() and b:IsShown() then
			local sortDirection = a:GetParent().db.sortDirection
			local aTime = a.duration or -1
			local bTime = b.duration or -1
			if aTime and bTime then
				if sortDirection == "DESCENDING" then
					return aTime < bTime
				else
					return aTime > bTime
				end
			end
		elseif a:IsShown() then
			return true
		end
	end
end

function UF:SortAuras()
	if not self.db then return end

	--Sorting by Index is Default
	if self.db.sortMethod == "TIME_REMAINING" then
		tsort(self, SortAurasByTime)
	elseif self.db.sortMethod == "NAME" then
		tsort(self, SortAurasByName)
	elseif self.db.sortMethod == "DURATION" then
		tsort(self, SortAurasByDuration)
	end

	--Look into possibly applying filter priorities for auras here.

	return 1, #self --from/to range needed for the :SetPosition call in oUF aura element. Without this aura icon position gets all whacky when not sorted by index
end

function UF:UpdateAuraIconSettings(auras, noCycle)
	local frame = auras:GetParent()
	local type = auras.type
	if noCycle then
		frame = auras:GetParent():GetParent()
		type = auras:GetParent().type
	end
	if not frame.db then return end

	local db = frame.db[type]
	local unitframeFont = LSM:Fetch("font", E.db.unitframe.font)
	local unitframeFontOutline = E.db.unitframe.fontOutline
	local button, cooldownFont
	local index = 1
	auras.db = db
	if db then
		if not noCycle then
			while auras[index] do
				button = auras[index]

				if button.timerOptions and button.timerOptions.fontOptions and (not cooldownFont) then
					cooldownFont = LSM:Fetch("font", button.timerOptions.fontOptions.font)
				end

				if button.timerOptions and button.timerOptions.fontOptions and button.timerOptions.fontOptions.enable and cooldownFont then
					button.text:FontTemplate(cooldownFont, button.timerOptions.fontOptions.fontSize, button.timerOptions.fontOptions.fontOutline)
				else
					button.text:FontTemplate(unitframeFont, db.fontSize, unitframeFontOutline)
				end

				button.count:FontTemplate(unitframeFont, db.countFontSize or db.fontSize, unitframeFontOutline)

				button.unit = frame.unit -- used to update cooldown text

				if db.clickThrough and button:IsMouseEnabled() then
					button:EnableMouse(false)
				elseif not db.clickThrough and not button:IsMouseEnabled() then
					button:EnableMouse(true)
				end
				index = index + 1
			end
		else
			if auras.timerOptions and auras.timerOptions.fontOptions then
				cooldownFont = LSM:Fetch("font", auras.timerOptions.fontOptions.font)
			end

			if auras.timerOptions and auras.timerOptions.fontOptions and auras.timerOptions.fontOptions.enable and cooldownFont then
				auras.text:FontTemplate(cooldownFont, auras.timerOptions.fontOptions.fontSize, auras.timerOptions.fontOptions.fontOutline)
			else
				auras.text:FontTemplate(unitframeFont, db.fontSize, unitframeFontOutline)
			end

			auras.count:FontTemplate(unitframeFont, db.countFontSize or db.fontSize, unitframeFontOutline)

			auras.unit = frame.unit -- used to update cooldown text

			if db.clickThrough and auras:IsMouseEnabled() then
				auras:EnableMouse(false)
			elseif not db.clickThrough and not auras:IsMouseEnabled() then
				auras:EnableMouse(true)
			end
		end
	end
end

local unstableAffliction = GetSpellInfo(30108)
local vampiricTouch = GetSpellInfo(34914)
function UF:PostUpdateAura(unit, button, index)
	local name, _, _, _, dtype, duration, expiration = UnitAura(unit, index, button.filter)
	if expiration then expiration = expiration + GetTime() end

	local isFriend = UnitIsFriend("player", unit) == 1 and true or false

	local auras = button:GetParent()
	local frame = auras:GetParent()
	local type = auras.type
	local db = frame.db and frame.db[type]

	if db then
		if db.clickThrough and button:IsMouseEnabled() then
			button:EnableMouse(false)
		elseif not db.clickThrough and not button:IsMouseEnabled() then
			button:EnableMouse(true)
		end
	end

	if button.isDebuff then
		local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
		if (name == unstableAffliction or name == vampiricTouch) and E.myclass ~= "WARLOCK" then
			button:SetBackdropBorderColor(0.05, 0.85, 0.94)
		else
			button:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
		end
	else
		button:SetBackdropBorderColor(unpack(E.media.unitframeBorderColor))
	end

	local size = button:GetParent().size
	if size then
		button:SetSize(size, size)
	end

	button.spell = name
	button.duration = duration

	if E:Cooldown_IsEnabled(button) then
		if duration ~= 0 then
			if not button:GetScript("OnUpdate") then
				button.nextupdate = -1
				button:SetScript("OnUpdate", UF.UpdateAuraTimer)
			end
		end
		if duration == 0 then
			button.priority = nil
			button.duration = nil
			button:SetScript("OnUpdate", nil)
			if button.text:GetFont() then
				button.text:SetText("")
			end
		end
	end
end

function UF:UpdateAuraTimer(elapsed)
	if self.nextupdate > 0 then
		self.nextupdate = self.nextupdate - elapsed
		return
	end

	local textHasFont = self.text and self.text:GetFont()
	local _, _, _, _, _, duration, timeLeft = UnitAura(self:GetParent().__owner.unit, self:GetID(), self.filter)
	if (not E:Cooldown_IsEnabled(self)) or (timeLeft and timeLeft <= 0) then
		if textHasFont then
			self.text:SetText("")
		end
		return
	else
		self.cd:SetCooldown(GetTime() - (duration - timeLeft), duration)
	end

	local timeColors, timeThreshold = (self.timerOptions and self.timerOptions.timeColors) or E.TimeColors, (self.timerOptions and self.timerOptions.timeThreshold) or E.db.cooldown.threshold
	if not timeThreshold then timeThreshold = E.TimeThreshold end

	local hhmmThreshold = (self.timerOptions and self.timerOptions.hhmmThreshold) or (E.db.cooldown.checkSeconds and E.db.cooldown.hhmmThreshold)
	local mmssThreshold = (self.timerOptions and self.timerOptions.mmssThreshold) or (E.db.cooldown.checkSeconds and E.db.cooldown.mmssThreshold)

	local value1, formatid, nextupdate, value2 = E:GetTimeInfo(timeLeft, timeThreshold, hhmmThreshold, mmssThreshold)
	if nextupdate > 1 then nextupdate = 1.01 end
	self.nextupdate = nextupdate

	if textHasFont then
		self.text:SetFormattedText(format("%s%s|r", timeColors[formatid], E.TimeFormats[formatid][2]), value1, value2)
	end
end

function UF:CheckFilter(filterType, isFriend)
	local FRIENDLY_CHECK, ENEMY_CHECK = false, false
	if type(filterType) == "boolean" then
		FRIENDLY_CHECK = filterType
		ENEMY_CHECK = filterType
	elseif filterType then
		FRIENDLY_CHECK = filterType.friendly
		ENEMY_CHECK = filterType.enemy
	end

	if (FRIENDLY_CHECK and isFriend) or (ENEMY_CHECK and not isFriend) then
		return true
	end

	return false
end

function UF:AuraFilter(unit, button, name, _, _, _, dtype, duration)
	local db = self:GetParent().db
	if not db or not db[self.type] then return true end

	db = db[self.type]

	local returnValue = true
	local anotherFilterExists = false
	local isFriend = UnitIsFriend("player", unit) == 1 and true or false

	button.name = name
	button.priority = 0

	local turtleBuff = E.global.unitframe.aurafilters.TurtleBuffs.spells[name]
	if turtleBuff and turtleBuff.enable then
		button.priority = turtleBuff.priority
	end

	if UF:CheckFilter(db.onlyDispellable, isFriend) then
		if (self.type == "debuffs" and dtype and not E:IsDispellableByMe(dtype)) or dtype == nil then
			returnValue = false
		end

		anotherFilterExists = true
	end

	if UF:CheckFilter(db.noDuration, isFriend) then
		if duration == 0 or not duration then
			returnValue = false
		end

		anotherFilterExists = true
	end

	if db.minDuration and (db.minDuration > 0) then
		if duration and (duration < db.minDuration) then
			returnValue = false
		end

		anotherFilterExists = true
	end

	if db.maxDuration and (db.maxDuration > 0) then
		if duration and (duration > db.maxDuration) then
			returnValue = false
		end

		anotherFilterExists = true
	end

	if UF:CheckFilter(db.useBlacklist, isFriend) then
		local blackList = E.global.unitframe.aurafilters.Blacklist.spells[name]
		if blackList and blackList.enable then
			returnValue = false
		end

		anotherFilterExists = true
	end

	if UF:CheckFilter(db.useWhitelist, isFriend) then
		local whiteList = E.global.unitframe.aurafilters.Whitelist.spells[name]
		if whiteList and whiteList.enable then
			returnValue = true
			button.priority = whiteList.priority
		elseif not anotherFilterExists then
			returnValue = false
		end

		anotherFilterExists = true
	end

	if db.useFilter and E.global.unitframe.aurafilters[db.useFilter] then
		local type = E.global.unitframe.aurafilters[db.useFilter].type
		local spellList = E.global.unitframe.aurafilters[db.useFilter].spells
		local spell = spellList[name]

		if type == "Whitelist" then
			if spell and spell.enable then
				returnValue = true
				button.priority = spell.priority
			elseif not anotherFilterExists then
				returnValue = false
			end
		elseif type == "Blacklist" and spell and spell.enable then
			returnValue = false
		end
	end

	return returnValue
end

function UF:UpdateBuffsHeaderPosition()
	local parent = self:GetParent()
	local buffs = parent.Buffs
	local debuffs = parent.Debuffs
	local numDebuffs = self.visibleDebuffs

	if numDebuffs == 0 then
		buffs:ClearAllPoints()
		buffs:Point(debuffs.point, debuffs.attachTo, debuffs.anchorPoint, debuffs.xOffset, debuffs.yOffset)
	else
		buffs:ClearAllPoints()
		buffs:Point(buffs.point, buffs.attachTo, buffs.anchorPoint, buffs.xOffset, buffs.yOffset)
	end
end

function UF:UpdateDebuffsHeaderPosition()
	local parent = self:GetParent()
	local debuffs = parent.Debuffs
	local buffs = parent.Buffs
	local numBuffs = self.visibleBuffs

	if numBuffs == 0 then
		debuffs:ClearAllPoints()
		debuffs:Point(buffs.point, buffs.attachTo, buffs.anchorPoint, buffs.xOffset, buffs.yOffset)
	else
		debuffs:ClearAllPoints()
		debuffs:Point(debuffs.point, debuffs.attachTo, debuffs.anchorPoint, debuffs.xOffset, debuffs.yOffset)
	end
end

function UF:UpdateBuffsPositionAndDebuffHeight()
	local parent = self:GetParent()
	local db = parent.db
	local buffs = parent.Buffs
	local debuffs = parent.Debuffs
	local numDebuffs = self.visibleDebuffs

	if numDebuffs == 0 then
		buffs:ClearAllPoints()
		buffs:Point(debuffs.point, debuffs.attachTo, debuffs.anchorPoint, debuffs.xOffset, debuffs.yOffset)
	else
		buffs:ClearAllPoints()
		buffs:Point(buffs.point, buffs.attachTo, buffs.anchorPoint, buffs.xOffset, buffs.yOffset)
	end

	if numDebuffs > 0 then
		local numRows = ceil(numDebuffs/db.debuffs.perrow)
		debuffs:Height(debuffs.size * (numRows > db.debuffs.numrows and db.debuffs.numrows or numRows))
	else
		debuffs:Height(debuffs.size)
	end
end

function UF:UpdateDebuffsPositionAndBuffHeight()
	local parent = self:GetParent()
	local db = parent.db
	local debuffs = parent.Debuffs
	local buffs = parent.Buffs
	local numBuffs = self.visibleBuffs

	if numBuffs == 0 then
		debuffs:ClearAllPoints()
		debuffs:Point(buffs.point, buffs.attachTo, buffs.anchorPoint, buffs.xOffset, buffs.yOffset)
	else
		debuffs:ClearAllPoints()
		debuffs:Point(debuffs.point, debuffs.attachTo, debuffs.anchorPoint, debuffs.xOffset, debuffs.yOffset)
	end

	if numBuffs > 0 then
		local numRows = ceil(numBuffs/db.buffs.perrow)
		buffs:Height(buffs.size * (numRows > db.buffs.numrows and db.buffs.numrows or numRows))
	else
		buffs:Height(buffs.size)
	end
end

function UF:UpdateBuffsHeight()
	local parent = self:GetParent()
	local db = parent.db
	local buffs = parent.Buffs
	local numBuffs = self.visibleBuffs

	if numBuffs > 0 then
		local numRows = ceil(numBuffs/db.buffs.perrow)
		buffs:Height(buffs.size * (numRows > db.buffs.numrows and db.buffs.numrows or numRows))
	else
		buffs:Height(buffs.size)
		-- Any way to get rid of the last row as well?
		-- Using buffs:SetHeight(0) makes frames anchored to this one disappear
	end
end

function UF:UpdateDebuffsHeight()
	local parent = self:GetParent()
	local db = parent.db
	local debuffs = parent.Debuffs
	local numDebuffs = self.visibleDebuffs

	if numDebuffs > 0 then
		local numRows = ceil(numDebuffs/db.debuffs.perrow)
		debuffs:Height(debuffs.size * (numRows > db.debuffs.numrows and db.debuffs.numrows or numRows))
	else
		debuffs:Height(debuffs.size)
		-- Any way to get rid of the last row as well?
		-- Using debuffs:SetHeight(0) makes frames anchored to this one disappear
	end
end