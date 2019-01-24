local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule("DataTexts")

local select = select
local format, join = string.format, string.join

local GetItemInfo = GetItemInfo
local GetInventoryItemLink = GetInventoryItemLink
local ContainerIDToInventoryID = ContainerIDToInventoryID
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetItemQualityColor = GetItemQualityColor
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local BACKPACK_TOOLTIP = BACKPACK_TOOLTIP

local displayString = ""

local lastPanel

local function OnEvent(self)
	local bagFree, bagType
	local free, total, used = 0, 0, 0
	for i = 0, NUM_BAG_SLOTS do
		bagFree, bagType = GetContainerNumFreeSlots(i)
		if bagType == 0 then -- Skips "special" non-generic bags such as quivers, mining bags, etc.
			free, total = free + bagFree, total + GetContainerNumSlots(i)
		end
	end
	used = total - free

	self.text:SetFormattedText(displayString, L["Bags"], used, total)

	lastPanel = self
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local r, g, b
	local _, name, quality, link
	local free, total, used

	for i = 0, NUM_BAG_SLOTS do
		if i ~= 0 then
			link = GetInventoryItemLink("player", ContainerIDToInventoryID(i))
			if link then
				name, _, quality = GetItemInfo(link)
				r, g, b = GetItemQualityColor(quality)
			end
		end

		free, total, used = 0, 0, 0
		free, total = GetContainerNumFreeSlots(i), GetContainerNumSlots(i)
		used = total - free

		if i == 0 then
			DT.tooltip:AddDoubleLine(join("", BACKPACK_TOOLTIP), format("%d / %d", used, total), 1, 1, 1)
		else
			if link then
				DT.tooltip:AddDoubleLine(join("", name), format("%d / %d", used, total), r, g, b)
			end
		end
	end

	DT.tooltip:Show()
end

local function OnClick(_, btn)
	if not E.bags then
		if btn == "LeftButton" then
			OpenAllBags()
		elseif btn == "RightButton" then
			ToggleKeyRing()
		end
	else
		OpenAllBags()
	end
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%d/%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Bags", {"PLAYER_LOGIN", "BAG_UPDATE"}, OnEvent, nil, OnClick, OnEnter, nil, L["Bags"])