local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule("DataTexts")

local ipairs, pairs = ipairs, pairs
local format, join = string.format, string.join
local tinsert, wipe = table.insert, wipe

local GetMoney = GetMoney
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local IsLoggedIn = IsLoggedIn
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local Profit = 0
local Spent = 0
local resetCountersFormatter = join("", "|cffaaaaaa", L["Reset Counters: Hold Control + Right Click"], "|r")
local resetInfoFormatter = join("", "|cffaaaaaa", L["Reset Data: Hold Shift + Right Click"], "|r")

local function OnEvent(self)
	if not IsLoggedIn() then return end

	local NewMoney = GetMoney()
	ElvDB = ElvDB or {}
	ElvDB.gold = ElvDB.gold or {}
	ElvDB.gold[E.myrealm] = ElvDB.gold[E.myrealm] or {}
	ElvDB.gold[E.myrealm][E.myname] = ElvDB.gold[E.myrealm][E.myname] or NewMoney

	ElvDB.class = ElvDB.class or {}
	ElvDB.class[E.myrealm] = ElvDB.class[E.myrealm] or {}
	ElvDB.class[E.myrealm][E.myname] = E.myclass

	local OldMoney = ElvDB.gold[E.myrealm][E.myname] or NewMoney

	local Change = NewMoney - OldMoney
	if OldMoney > NewMoney then
		Spent = Spent - Change
	else
		Profit = Profit + Change
	end

	self.text:SetText(E:FormatMoney(NewMoney, E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins))

	ElvDB.gold[E.myrealm][E.myname] = NewMoney
end

local function OnClick(self, btn)
	if btn == "RightButton" then
		if IsShiftKeyDown() then
			ElvDB.gold = nil
			OnEvent(self)
			DT.tooltip:Hide()
		elseif IsControlKeyDown() then
			Profit = 0
			Spent = 0
			DT.tooltip:Hide()
		end
	else
		OpenAllBags()
	end
end

local myGold = {}
local function OnEnter(self)
	DT:SetupTooltip(self)

	local textOnly = not E.db.datatexts.goldCoins and true or false
	local style = E.db.datatexts.goldFormat or "BLIZZARD"

	DT.tooltip:AddLine(L["Session:"])
	DT.tooltip:AddDoubleLine(L["Earned:"], E:FormatMoney(Profit, style, textOnly), 1, 1, 1, 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Spent:"], E:FormatMoney(Spent, style, textOnly), 1, 1, 1, 1, 1, 1)

	if Profit < Spent then
		DT.tooltip:AddDoubleLine(L["Deficit:"], E:FormatMoney(Profit - Spent, style, textOnly), 1, 0, 0, 1, 1, 1)
	elseif (Profit - Spent) > 0 then
		DT.tooltip:AddDoubleLine(L["Profit:"], E:FormatMoney(Profit - Spent, style, textOnly), 0, 1, 0, 1, 1, 1)
	end

	DT.tooltip:AddLine(" ")

	local totalGold = 0
	DT.tooltip:AddLine(L["Character: "])

	wipe(myGold)
	for k in pairs(ElvDB.gold[E.myrealm]) do
		if ElvDB.gold[E.myrealm][k] then
			local class = ElvDB.class[E.myrealm][k] or "PRIEST"
			local color = class and (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class])
			tinsert (myGold,
				{
					name = k,
					amount = ElvDB.gold[E.myrealm][k],
					amountText = E:FormatMoney(ElvDB.gold[E.myrealm][k], E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins),
					r = color.r, g = color.g, b = color.b,
				}
			)
		end
		totalGold = totalGold + ElvDB.gold[E.myrealm][k]
	end

	for _, g in ipairs(myGold) do
		DT.tooltip:AddDoubleLine(g.name == E.myname and g.name.." |TInterface\\AddOns\\ElvUI\\media\\textures\\Indicator-Green:14|t" or g.name, g.amountText, g.r, g.g, g.b, 1, 1, 1)
	end

	DT.tooltip:AddLine(" ")
	DT.tooltip:AddLine(L["Server: "])
	DT.tooltip:AddDoubleLine(L["Total: "], E:FormatMoney(totalGold, style, textOnly), 1, 1, 1, 1, 1, 1)

	DT.tooltip:AddLine(" ")
	DT.tooltip:AddLine(resetCountersFormatter)
	DT.tooltip:AddLine(resetInfoFormatter)

	DT.tooltip:Show()
end

DT:RegisterDatatext("Gold", {"PLAYER_LOGIN", "PLAYER_MONEY", "SEND_MAIL_MONEY_CHANGED", "SEND_MAIL_COD_CHANGED", "PLAYER_TRADE_MONEY", "TRADE_MONEY_CHANGED"}, OnEvent, nil, OnClick, OnEnter, nil, L["Gold"])