local E, L, V, P, G = unpack(ElvUI)
local B = E:NewModule("Blizzard", "AceEvent-3.0", "AceHook-3.0")

E.Blizzard = B

local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local GetTradeSkillListLink = GetTradeSkillListLink
local Minimap_SetPing = Minimap_SetPing
local MINIMAPPING_FADE_TIMER = MINIMAPPING_FADE_TIMER

-- function B:ADDON_LOADED(_, addon)
-- 	if addon == "Blizzard_TradeSkillUI" then
-- 		TradeSkillLinkButton:SetScript("OnClick", function()
-- 			local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
-- 			if not ChatFrameEditBox:IsShown() then
-- 				ChatEdit_ActivateChat(ChatFrameEditBox)
-- 			end

-- 			ChatFrameEditBox:Insert(GetTradeSkillListLink())
-- 		end)
-- 	end
-- end

function B:Initialize()
	self:EnhanceColorPicker()
	self:KillBlizzard()
	self:PositionCaptureBar()
	self:PositionDurabilityFrame()
	self:PositionGMFrames()

	-- self:RegisterEvent("ADDON_LOADED")

	if (GetLocale() == "deDE") then
		DAY_ONELETTER_ABBR = "%d d"
		MINUTE_ONELETTER_ABBR = "%d m"
	end

	--[[QuestLogFrame:HookScript("OnShow", function()
		local questFrame = QuestLogFrame:GetFrameLevel()
		local controlPanel = QuestLogControlPanel:GetFrameLevel()
		local scrollFrame = QuestLogDetailScrollFrame:GetFrameLevel()

		if questFrame >= controlPanel then
			QuestLogControlPanel:SetFrameLevel(questFrame + 1)
		end
		if questFrame >= scrollFrame then
			QuestLogDetailScrollFrame:SetFrameLevel(questFrame + 1)
		end
	end)]]
end

E:RegisterModule(B:GetName())