local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule("DataTexts")

local join = string.join

local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetContainerNumSlots = GetContainerNumSlots

local NUM_BAG_SLOTS = NUM_BAG_SLOTS

local displayString = ""
local lastPanel

local function OnEvent(self)
	local free, total, used = 0, 0, 0
	for i = 0, NUM_BAG_SLOTS do
		free, total = free + GetContainerNumFreeSlots(i), total + GetContainerNumSlots(i)
	end
	used = total - free

	self.text:SetFormattedText(displayString, L["Bags"], used, total)
	lastPanel = self
end

local function OnClick()
	OpenAllBags()
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%d/%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true

DT:RegisterDatatext("Bags", {"PLAYER_LOGIN", "BAG_UPDATE"}, OnEvent, nil, OnClick, nil, nil, L["Bags"])