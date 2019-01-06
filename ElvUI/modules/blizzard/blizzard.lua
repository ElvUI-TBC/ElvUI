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
local REWARD_ITEMS = REWARD_ITEMS
local REWARD_ITEMS_ONLY = REWARD_ITEMS_ONLY

E.Blizzard = B

function B:Initialize()
	self:AlertMovers()
	self:EnhanceColorPicker()
	self:KillBlizzard()
	self:PositionCaptureBar()
	self:PositionDurabilityFrame()
	self:PositionGMFrames()
	self:MoveWatchFrame()
	self:MoveQuestTimerFrame()

	self:RawHook("CombatConfig_Colorize_Update", function()
		if not CHATCONFIG_SELECTED_FILTER_SETTINGS then return end
		self.hooks.CombatConfig_Colorize_Update()
	end, true)

	hooksecurefunc("QuestFrameItems_Update", function(questState)
		local spacerFrame, money, honor, numQuestRewards, numQuestChoices, numQuestSpellRewards

		if questState == "QuestLog" then
			spacerFrame = QuestLogSpacerFrame
			money, honor, numQuestRewards, numQuestChoices, numQuestSpellRewards = GetQuestLogRewardMoney(), GetQuestLogRewardHonor(), GetNumQuestLogRewards(), GetNumQuestLogChoices(), GetQuestLogRewardSpell()
		else
			spacerFrame = QuestSpacerFrame
			money, honor, numQuestRewards, numQuestChoices, numQuestSpellRewards = GetRewardMoney(), GetRewardHonor(), GetNumQuestRewards(), GetNumQuestChoices(), GetRewardSpell()
		end

		if money == 0 and honor > 0 and (numQuestRewards > 0 or numQuestChoices > 0 or numQuestSpellRewards) then
			numQuestSpellRewards = numQuestSpellRewards and 1 or 0
			local rewardsCount = numQuestRewards + numQuestChoices + numQuestSpellRewards
			local honorFrame = _G[questState.."HonorFrame"]

			if numQuestRewards > 0 then
				honorFrame:ClearAllPoints()
				honorFrame:SetPoint("TOPLEFT", questState.."Item"..rewardsCount, "BOTTOMLEFT", 0, -3)

				QuestFrame_SetAsLastShown(questState.."HonorFrame", spacerFrame)
			else
				local questItemReceiveText = _G[questState.."ItemReceiveText"]
				honorFrame:ClearAllPoints()
				honorFrame:SetPoint("TOPLEFT", questItemReceiveText, "BOTTOMLEFT", -3, -6)

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
		end
	end)
end

local function InitializeCallback()
	B:Initialize()
end

E:RegisterModule(B:GetName(), InitializeCallback)