local E, L, V, P, G = unpack(ElvUI)
local A = E:NewModule("Auras", "AceHook-3.0", "AceEvent-3.0")

local mainhand, offhand, _

function A:BuffFrame_Update()
	BUFF_ACTUAL_DISPLAY = 0;
	for i = 1, BUFF_MAX_DISPLAY do
		if BuffButton_Update("BuffButton", i, "HELPFUL") then
			BUFF_ACTUAL_DISPLAY = BUFF_ACTUAL_DISPLAY + 1
			self:StyleBuffs("BuffButton", i)
		end
	end

	for i = 1, DEBUFF_MAX_DISPLAY do
		if BuffButton_Update("DebuffButton", i, "HARMFUL") then
			DEBUFF_ACTUAL_DISPLAY = DEBUFF_ACTUAL_DISPLAY + 1
			self:StyleBuffs("DebuffButton", i)
		end
	end

	self:TempEnchant_Update()
end

function A:TempEnchant_Update()
	TemporaryEnchantFrame:ClearAllPoints()
	TemporaryEnchantFrame:SetPoint("TOPRIGHT", AurasHolder, "TOPRIGHT", 0, 0)

	TempEnchant1:ClearAllPoints()
	TempEnchant2:ClearAllPoints()
	TempEnchant1:Point("TOPRIGHT", AurasHolder, "TOPRIGHT")
	TempEnchant2:Point("RIGHT", TempEnchant1, "LEFT", -self.db.spacing, 0)

	for i = 1, 2 do
		self:StyleBuffs("TempEnchant", i)
		_G["TempEnchant"..i]:SetBackdropBorderColor(137/255, 0, 191/255)
	end
end

function A:StyleBuffs(buttonName, index)
	local font = E.LSM:Fetch("font", self.db.font)

	local button = _G[buttonName..index]
	local icon = _G[buttonName..index.."Icon"]
	local border = _G[buttonName..index.."Border"]
	local duration = _G[buttonName..index.."Duration"]
	local count = _G[buttonName..index.."Count"]

	button:Size(self.db.size)
	button:SetTemplate("Default")

	icon:SetDrawLayer("BORDER")
	icon:SetInside(button)
	icon:SetTexCoord(unpack(E.TexCoords))

	duration:ClearAllPoints()
	duration:Point("TOP", button, "BOTTOM", 1 + self.db.timeXOffset, 0 + self.db.timeYOffset)
	duration:SetDrawLayer("OVERLAY")
	duration:FontTemplate(font, self.db.fontSize, self.db.fontOutline)

	count:ClearAllPoints()
	count:Point("BOTTOMRIGHT", -1 + self.db.countXOffset, 1 + self.db.countYOffset)
	count:SetDrawLayer("OVERLAY")
	count:FontTemplate(font, self.db.fontSize, self.db.fontOutline)

	if button.SetHighlightTexture and not button.highlightr then
		local highlight = button:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetTexture(1, 1, 1, 0.3)
		highlight:SetAllPoints(icon)

		button.highlightr = highlight
		button:SetHighlightTexture(highlight)
	end

	if border then border:Hide() end
end

function A:BuffButton_OnUpdate()
	if this.untilCancelled == 1 then return end

	local buffIndex = this:GetID();
	local timeLeft = GetPlayerBuffTimeLeft(buffIndex)

	local timerValue, formatID;
	timerValue, formatID, self.nextUpdate = E:GetTimeInfo(timeLeft, A.db.fadeThreshold);
	_G[this:GetName().."Duration"]:SetFormattedText(("%s%s|r"):format(E.TimeColors[formatID], E.TimeFormats[formatID][1]), timerValue)

	if timeLeft < self.db.fadeThreshold then
		this:SetAlpha(BuffFrame.BuffAlphaValue)
	else
		this:SetAlpha(1.0);
	end
end

function A:BuffButton_UpdateAnchors(buttonName, index, filter)
	local rows = ceil(BUFF_ACTUAL_DISPLAY/self.db.perRow)
	local buff = _G[buttonName..index]

	if not buff.isSkinned then
		self:StyleBuffs(buttonName, index)
		buff.isSkinned = true
	end

	if filter == "HELPFUL" then
		buff:ClearAllPoints()
		if index > 1 and (mod(index, self.db.perRow) == 1) then
			if index == self.db.perRow + 1 then
				buff:SetPoint("RIGHT", AurasHolder, "RIGHT", 0, 0)
			else
				buff:SetPoint("TOPRIGHT", getglobal(buttonName..(index-BUFFS_PER_ROW)), "TOPRIGHT", 0, 0)
			end
		elseif index == 1 then
			mainhand, _, _, offhand = GetWeaponEnchantInfo()
			if mainhand and offhand then
				buff:SetPoint("RIGHT", TempEnchant2, "LEFT", -self.db.spacing, 0)
			elseif (mainhand and not offhand) or (offhand and not mainhand) then
				buff:SetPoint("RIGHT", TempEnchant1, "LEFT", -self.db.spacing, 0)
			else
				buff:SetPoint("TOPRIGHT", AurasHolder, "TOPRIGHT", 0, 0)
			end
		else
			buff:SetPoint("RIGHT", _G[buttonName..(index-1)], "LEFT", -self.db.spacing, 0)
		end

		if index > (self.db.perRow*2) then
			buff:Hide()
		else
			buff:Show()
		end
	else
		local color
		local debuffType = GetPlayerBuffDispelType(index)
		if debuffType then
			color = DebuffTypeColor[debuffType]
		else
			color = DebuffTypeColor["none"]
		end
		buff:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)

		buff:ClearAllPoints()
		if index == 1 then
			buff:SetPoint("BOTTOMRIGHT", AurasHolder, "BOTTOMRIGHT", 0, 0)
		else
			buff:SetPoint("RIGHT", _G[buttonName..(index-1)], "LEFT", -self.db.spacing, 0)
		end

		if index > self.db.perRow then
			buff:Hide()
		else
			buff:Show()
		end
	end
end

function A:Update_WeaponEnchantInfo()
	if mainhand or offhand then BuffFrame_Update() end
	mainhand, _, _, offhand = GetWeaponEnchantInfo()
end

function A:Initialize()
	self.db = E.db.auras
	if E.private.auras.enable ~= true then return end

	local holder = CreateFrame("Frame", "AurasHolder", E.UIParent)
	holder:Point("TOPRIGHT", MMHolder, "TOPLEFT", -(6 + E.Border), -E.Border - E.Spacing)
	holder:Width(456)
	holder:Height(E.MinimapHeight)
	E:CreateMover(holder, "AurasMover", L["Auras Frame"])

	self:SecureHook("BuffButton_OnUpdate")
	self:SecureHook("BuffButton_UpdateAnchors")

	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "Update_WeaponEnchantInfo")
	self:RegisterEvent("PLAYER_EVENTERING_WORLD", "Update_WeaponEnchantInfo")

	self:BuffFrame_Update()
end

local function InitializeCallback()
	A:Initialize()
end

E:RegisterModule(A:GetName(), InitializeCallback)