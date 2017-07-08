local E, L, V, P, G = unpack(ElvUI)
local B = E:NewModule("Blizzard", "AceEvent-3.0", "AceHook-3.0")

local GetNumQuestChoices = GetNumQuestChoices
local GetNumQuestLogChoices = GetNumQuestLogChoices
local GetQuestLogRewardHonor = GetQuestLogRewardHonor
local GetQuestLogRewardMoney = GetQuestLogRewardMoney
local GetQuestLogRewardSpell = GetQuestLogRewardSpell
local GetRewardHonor = GetRewardHonor
local GetRewardMoney = GetRewardMoney
local GetRewardSpell = GetRewardSpell

E.Blizzard = B

function B:Initialize()
	self:AlertMovers()
	self:EnhanceColorPicker()
	self:KillBlizzard()
	self:PositionCaptureBar()
	self:PositionDurabilityFrame()
	self:PositionGMFrames()
	self:MoveWatchFrame()

	self:RawHook("CombatConfig_Colorize_Update", function()
		if not CHATCONFIG_SELECTED_FILTER_SETTINGS then return end
		self.hooks.CombatConfig_Colorize_Update()
	end, true)

	hooksecurefunc("QuestFrameItems_Update", function(questState)
		local spacerFrame, money, honor, numQuestChoices, numQuestSpellRewards

		if questState == "QuestLog" then
			spacerFrame = QuestLogSpacerFrame
			money, honor, numQuestChoices, numQuestSpellRewards = GetQuestLogRewardMoney(), GetQuestLogRewardHonor(), GetNumQuestLogChoices(), GetQuestLogRewardSpell()
		else
			spacerFrame = QuestSpacerFrame
			money, honor, numQuestChoices, numQuestSpellRewards = GetRewardMoney(), GetRewardHonor(), GetNumQuestChoices(), GetRewardSpell()
		end

		if money == 0 and honor > 0 and (numQuestChoices > 0 or numQuestSpellRewards) then
			numQuestSpellRewards = numQuestSpellRewards and 1 or 0
			local rewardsCount = numQuestChoices + numQuestSpellRewards

			local questItemReceiveText = _G[questState.."ItemReceiveText"]
			if numQuestSpellRewards > 0 then
				questItemReceiveText:SetText(REWARD_ITEMS)
				questItemReceiveText:SetPoint("TOPLEFT", questState.."Item"..rewardsCount, "BOTTOMLEFT", 3, 15)
			elseif numQuestChoices > 0 then
				questItemReceiveText:SetText(REWARD_ITEMS)
				local index = numQuestChoices
				if mod(index, 2) == 0 then
					index = index - 1
				end
				questItemReceiveText:SetPoint("TOPLEFT", questState.."Item"..index, "BOTTOMLEFT", 3, 15)
			else
				questItemReceiveText:SetText(REWARD_ITEMS_ONLY)
				questItemReceiveText:SetPoint("TOPLEFT", questState.."RewardTitleText", "BOTTOMLEFT", 3, 15)
			end

			QuestFrame_SetAsLastShown(questItemReceiveText, spacerFrame)
		end
	end)

--	QuestLogFrame:HookScript("OnShow", function()
--		local questFrame = QuestLogFrame:GetFrameLevel()
--		local scrollFrame = QuestLogDetailScrollFrame:GetFrameLevel()
--
--		if questFrame >= scrollFrame then
--			QuestLogDetailScrollFrame:SetFrameLevel(questFrame + 1)
--		end
--	end)
end

local function InitializeCallback()
	B:Initialize()
end

E:RegisterModule(B:GetName(), InitializeCallback)