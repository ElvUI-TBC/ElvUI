local E, L, V, P, G = unpack(ElvUI)
local mod = E:GetModule("NamePlates")
local LSM = E.LSM

local unpack = unpack

local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local FAILED = FAILED
local INTERRUPTED = INTERRUPTED

function mod:UpdateElement_CastBarOnUpdate(elapsed)
	if self.casting then
		self.value = self.value + elapsed
		if self.value >= self.maxValue then
			self:SetValue(self.maxValue)
			self:Hide()
			return
		end
		self:SetValue(self.value)

		if self.castTimeFormat == "CURRENT" then
			self.Time:SetFormattedText("%.1f", self.value)
		elseif self.castTimeFormat == "CURRENT_MAX" then
			self.Time:SetFormattedText("%.1f / %.1f", self.value, self.maxValue)
		else --REMAINING
			self.Time:SetFormattedText("%.1f", (self.maxValue - self.value))
		end

		if self.Spark then
			local sparkPosition = (self.value / self.maxValue) * self:GetWidth()
			self.Spark:SetPoint("CENTER", self, "LEFT", sparkPosition, 0)
		end
	elseif self.channeling then
		self.value = self.value - elapsed
		if self.value <= 0 then
			self:Hide()
			return
		end
		self:SetValue(self.value)

		if self.channelTimeFormat == "CURRENT" then
			self.Time:SetFormattedText("%.1f", (self.maxValue - self.value))
		elseif self.channelTimeFormat == "CURRENT_MAX" then
			self.Time:SetFormattedText("%.1f / %.1f", (self.maxValue - self.value), self.maxValue)
		else --REMAINING
			self.Time:SetFormattedText("%.1f", self.value)
		end
	else
		self:Hide()
	end
end

function mod:UpdateElement_Cast(frame, event, unit)
	if self.db.units[frame.UnitType].castbar.enable ~= true then return end
	if self.db.units[frame.UnitType].healthbar.enable ~= true and not (frame.isTarget and self.db.alwaysShowTargetHealth) then return end --Bug

	if unit then
		if not event then
			if UnitChannelInfo(unit) then
				event = "UNIT_SPELLCAST_CHANNEL_START"
			elseif UnitCastingInfo(unit) then
				event = "UNIT_SPELLCAST_START"
			end
		end
	elseif frame.CastBar:IsShown() then
		frame.CastBar:Hide()
	end

	if event == "UNIT_SPELLCAST_START" then
		local name, _, _, texture, startTime, endTime = UnitCastingInfo(unit)
		if not name then
			frame.CastBar:Hide()
			return
		end

		if frame.CastBar.Spark then
			frame.CastBar.Spark:Show()
		end
		frame.CastBar.Name:SetText(name)
		frame.CastBar.value = (GetTime() - (startTime / 1000))
		frame.CastBar.maxValue = (endTime - startTime) / 1000
		frame.CastBar:SetMinMaxValues(0, frame.CastBar.maxValue)
		frame.CastBar:SetValue(frame.CastBar.value)

		if frame.CastBar.Icon then
			frame.CastBar.Icon.texture:SetTexture(texture)
		end

		frame.CastBar.casting = true
		frame.CastBar.channeling = nil

		frame.CastBar:Show()
	elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
		if not frame.CastBar:IsVisible() then
			frame.CastBar:Hide()
		end
		if (frame.CastBar.casting and event == "UNIT_SPELLCAST_STOP") or (frame.CastBar.channeling and event == "UNIT_SPELLCAST_CHANNEL_STOP") then
			if frame.CastBar.Spark then
				frame.CastBar.Spark:Hide()
			end

			frame.CastBar:SetValue(frame.CastBar.maxValue)
			if event == "UNIT_SPELLCAST_STOP" then
				frame.CastBar.casting = nil
			else
				frame.CastBar.channeling = nil
			end

			frame.CastBar:Hide()
		end
	elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
		if frame.CastBar:IsShown() then
			frame.CastBar:SetValue(frame.CastBar.maxValue)
			if frame.CastBar.Spark then
				frame.CastBar.Spark:Hide()
			end

			if event == "UNIT_SPELLCAST_FAILED" then
				frame.CastBar.Name:SetText(FAILED)
			else
				frame.CastBar.Name:SetText(INTERRUPTED)
			end
			frame.CastBar.casting = nil
			frame.CastBar.channeling = nil
		end
	elseif event == "UNIT_SPELLCAST_DELAYED" then
		if frame:IsShown() then
			local name, _, _, _, startTime, endTime = UnitCastingInfo(unit)
			if not name then
				-- if there is no name, there is no bar
				frame.CastBar:Hide()
				return
			end

			frame.CastBar.Name:SetText(name)
			frame.CastBar.value = (GetTime() - (startTime / 1000))
			frame.CastBar.maxValue = (endTime - startTime) / 1000
			frame.CastBar:SetMinMaxValues(0, frame.CastBar.maxValue)

			if not frame.CastBar.casting then
				if frame.CastBar.Spark then
					frame.CastBar.Spark:Show()
				end

				frame.CastBar.casting = true
				frame.CastBar.channeling = nil
			end
		end
	elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
		local name, _, _, texture, startTime, endTime = UnitChannelInfo(unit)
		if not name then
			frame.CastBar:Hide()
			return
		end

		frame.CastBar.Name:SetText(name)
		frame.CastBar.value = (endTime / 1000) - GetTime()
		frame.CastBar.maxValue = (endTime - startTime) / 1000
		frame.CastBar:SetMinMaxValues(0, frame.CastBar.maxValue)
		frame.CastBar:SetValue(frame.CastBar.value)

		if frame.CastBar.Icon then
			frame.CastBar.Icon.texture:SetTexture(texture)
		end
		if frame.CastBar.Spark then
			frame.CastBar.Spark:Hide()
		end

		frame.CastBar.casting = nil
		frame.CastBar.channeling = true

		frame.CastBar:Show()
	elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
		if frame.CastBar:IsShown() then
			local name, _, _, _, startTime, endTime = UnitChannelInfo(unit)
			if not name then
				frame.CastBar:Hide()
				return
			end

			frame.CastBar.Name:SetText(name)
			frame.CastBar.value = ((endTime / 1000) - GetTime())
			frame.CastBar.maxValue = (endTime - startTime) / 1000
			frame.CastBar:SetMinMaxValues(0, frame.CastBar.maxValue)
			frame.CastBar:SetValue(frame.CastBar.value)
		end
	end

	if frame.CastBar:IsShown() then --This is so we can trigger based on Cast Name
		self:UpdateElement_Filters(frame, "UpdateElement_Cast")
	end
end

function mod:ConfigureElement_CastBar(frame)
	if not frame.UnitType then return end

	local castBar = frame.CastBar

	castBar:ClearAllPoints()
	castBar:SetPoint("TOPLEFT", frame.HealthBar, "BOTTOMLEFT", 0, -self.db.units[frame.UnitType].castbar.offset)
	castBar:SetPoint("TOPRIGHT", frame.HealthBar, "BOTTOMRIGHT", 0, -self.db.units[frame.UnitType].castbar.offset)
	castBar:SetHeight(self.db.units[frame.UnitType].castbar.height)

	castBar.Icon:ClearAllPoints()
	if self.db.units[frame.UnitType].castbar.iconPosition == "RIGHT" then
		castBar.Icon:SetPoint("TOPLEFT", frame.HealthBar, "TOPRIGHT", self.db.units[frame.UnitType].castbar.offset, 0)
		castBar.Icon:SetPoint("BOTTOMLEFT", castBar, "BOTTOMRIGHT", self.db.units[frame.UnitType].castbar.offset, 0)
	elseif self.db.units[frame.UnitType].castbar.iconPosition == "LEFT" then
		castBar.Icon:SetPoint("TOPRIGHT", frame.HealthBar, "TOPLEFT", -self.db.units[frame.UnitType].castbar.offset, 0)
		castBar.Icon:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMLEFT", -self.db.units[frame.UnitType].castbar.offset, 0)
	end
	castBar.Icon:SetWidth(self.db.units[frame.UnitType].castbar.height + self.db.units[frame.UnitType].healthbar.height + self.db.units[frame.UnitType].castbar.offset)
	castBar.Icon.texture:SetTexCoord(unpack(E.TexCoords))

	castBar.Time:SetPoint("TOPRIGHT", castBar, "BOTTOMRIGHT", 0, -E.Border*3)
	castBar.Name:SetPoint("TOPLEFT", castBar, "BOTTOMLEFT", 0, -E.Border*3)
	castBar.Name:SetPoint("TOPRIGHT", castBar.Time, "TOPLEFT")
	castBar.Name:SetJustifyH("LEFT")
	castBar.Name:SetJustifyV("TOP")
	castBar.Name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	castBar.Time:SetJustifyH("RIGHT")
	castBar.Time:SetJustifyV("TOP")
	castBar.Time:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)

	if self.db.units[frame.UnitType].castbar.hideSpellName then
		castBar.Name:Hide()
	else
		castBar.Name:Show()
	end
	if self.db.units[frame.UnitType].castbar.hideTime then
		castBar.Time:Hide()
	else
		castBar.Time:Show()
	end

	castBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
	castBar:SetStatusBarColor(self.db.castColor.r, self.db.castColor.g, self.db.castColor.b)

	castBar.castTimeFormat = self.db.units[frame.UnitType].castbar.castTimeFormat
	castBar.channelTimeFormat = self.db.units[frame.UnitType].castbar.channelTimeFormat
end

function mod:ConstructElement_CastBar(parent)
	local function updateGlowPosition()
		if not parent then return end

		mod:UpdatePosition_Glow(parent)
	end

	local frame = CreateFrame("StatusBar", "$parentCastBar", parent)
	self:StyleFrame(frame)
	frame:SetScript("OnUpdate", mod.UpdateElement_CastBarOnUpdate)
	frame:SetScript("OnShow", updateGlowPosition)
	frame:SetScript("OnHide", updateGlowPosition)

	frame.Icon = CreateFrame("Frame", nil, frame)
	frame.Icon.texture = frame.Icon:CreateTexture(nil, "BORDER")
	frame.Icon.texture:SetAllPoints()
	self:StyleFrame(frame.Icon)

	frame.Name = frame:CreateFontString(nil, "OVERLAY")
	frame.Name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)

	frame.Time = frame:CreateFontString(nil, "OVERLAY")
	frame.Time:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)

	frame.Spark = frame:CreateTexture(nil, "OVERLAY")
	frame.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	frame.Spark:SetBlendMode("ADD")
	frame.Spark:SetSize(15, 15)

	frame:Hide()

	return frame
end