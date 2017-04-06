local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack
local find = string.find

function S:LoadQuestSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.quest ~= true) then return end

	local QuestStrip = {
		"QuestFrame",
		"QuestLogFrame",
		"QuestLogCount",
		"EmptyQuestLogFrame",
		"QuestFrameDetailPanel",
		"QuestDetailScrollFrame",
		"QuestDetailScrollChildFrame",
		"QuestRewardScrollFrame",
		"QuestRewardScrollChildFrame",
		"QuestFrameProgressPanel",
		"QuestFrameRewardPanel",
		"QuestFrameGreetingPanel"
	}

	for _, object in pairs(QuestStrip) do
		_G[object]:StripTextures(true)
	end

	local QuestButtons = {
		"QuestLogFrameAbandonButton",
		"QuestFrameExitButton",
		"QuestFramePushQuestButton",
	}

	for _, button in pairs(QuestButtons) do
		_G[button]:StripTextures()
		S:HandleButton(_G[button])
	end

	S:HandleButton(QuestFrameAcceptButton)
	QuestFrameAcceptButton:Point("BOTTOMLEFT", QuestFrame, 19, 71)
	S:HandleButton(QuestFrameDeclineButton)
	QuestFrameDeclineButton:Point("BOTTOMRIGHT", QuestFrame, -34, 71)

	S:HandleButton(QuestFrameCompleteButton)
	S:HandleButton(QuestFrameGoodbyeButton)
	S:HandleButton(QuestFrameCompleteQuestButton)
	S:HandleButton(QuestFrameCancelButton)
	S:HandleButton(QuestFrameGreetingGoodbyeButton)

	for i = 1, MAX_NUM_ITEMS do
		_G["QuestLogItem" .. i]:StripTextures()
		_G["QuestLogItem" .. i]:StyleButton()
		_G["QuestLogItem" .. i]:Width(_G["QuestLogItem" .. i]:GetWidth() - 4)
		_G["QuestLogItem" .. i]:SetFrameLevel(_G["QuestLogItem" .. i]:GetFrameLevel() + 2)
		_G["QuestLogItem" .. i .. "IconTexture"]:SetTexCoord(unpack(E.TexCoords))
		_G["QuestLogItem" .. i .. "IconTexture"]:SetDrawLayer("OVERLAY")
		_G["QuestLogItem" .. i .. "IconTexture"]:Size(_G["QuestLogItem" .. i .. "IconTexture"]:GetWidth() -(E.Spacing*2), _G["QuestLogItem" .. i .. "IconTexture"]:GetHeight() -(E.Spacing*2))
		_G["QuestLogItem" .. i .. "IconTexture"]:Point("TOPLEFT", E.Border, -E.Border)
		S:HandleIcon(_G["QuestLogItem" .. i .. "IconTexture"])
		_G["QuestLogItem" .. i]:SetTemplate("Default")
		_G["QuestLogItem" .. i .. "Count"]:SetParent(_G["QuestLogItem" .. i].backdrop)
		_G["QuestLogItem" .. i .. "Count"]:SetDrawLayer("OVERLAY")
	end

	QuestRewardItemHighlight:StripTextures()
	QuestRewardItemHighlight:SetTemplate("Default", nil, true)
	QuestRewardItemHighlight:SetBackdropBorderColor(1, 1, 0)
	QuestRewardItemHighlight:SetBackdropColor(0, 0, 0, 0)
	QuestRewardItemHighlight:Size(142, 40)

	hooksecurefunc("QuestRewardItem_OnClick", function(self)
		QuestInfoItemHighlight:ClearAllPoints()
		QuestInfoItemHighlight:SetOutside(self:GetName() .. "IconTexture")
		_G[self:GetName() .. "Name"]:SetTextColor(1, 1, 0)

		for i = 1, MAX_NUM_ITEMS do
			local questItem = _G["QuestInfoItem" .. i]
			if(questItem ~= self) then
				_G[questItem:GetName() .. "Name"]:SetTextColor(1, 1, 1)
			end
		end
	end)

	local function QuestObjectiveText()
		local numObjectives = GetNumQuestLeaderBoards()
		local objective
		local _, type, finished
		local numVisibleObjectives = 0
		for i = 1, numObjectives do
			_, type, finished = GetQuestLogLeaderBoard(i)
			if(type ~= "spell") then
				numVisibleObjectives = numVisibleObjectives+1
				objective = _G["QuestInfoObjective" .. numVisibleObjectives]
				if(finished) then
					objective:SetTextColor(1, 1, 0)
				else
					objective:SetTextColor(0.6, 0.6, 0.6)
				end
			end
		end
	end

	hooksecurefunc("QuestLog_SetFirstValidSelection", function()
		local textColor = {1, 1, 1}
		local titleTextColor = {1, 1, 0}

		QuestInfoTitleHeader:SetTextColor(unpack(titleTextColor))
		QuestInfoDescriptionHeader:SetTextColor(unpack(titleTextColor))
		QuestInfoObjectivesHeader:SetTextColor(unpack(titleTextColor))
		QuestInfoRewardsHeader:SetTextColor(unpack(titleTextColor))

		QuestInfoDescriptionText:SetTextColor(unpack(textColor))
		QuestInfoObjectivesText:SetTextColor(unpack(textColor))
		QuestInfoGroupSize:SetTextColor(unpack(textColor))
		QuestInfoRewardText:SetTextColor(unpack(textColor))

		QuestInfoItemChooseText:SetTextColor(unpack(textColor))
		QuestInfoItemReceiveText:SetTextColor(unpack(textColor))
		QuestInfoSpellLearnText:SetTextColor(unpack(textColor))
		QuestInfoHonorFrameReceiveText:SetTextColor(unpack(textColor))
		QuestInfoArenaPointsFrameReceiveText:SetTextColor(unpack(textColor))
		QuestInfoTalentFrameReceiveText:SetTextColor(unpack(textColor))
		QuestInfoXPFrameReceiveText:SetTextColor(unpack(textColor))
		QuestInfoReputationText:SetTextColor(unpack(textColor))

		for i = 1, MAX_REPUTATIONS do
			_G["QuestInfoReputation" .. i .. "Faction"]:SetTextColor(unpack(textColor))
		end

		local r, g, b = QuestInfoRequiredMoneyText:GetTextColor()
		QuestInfoRequiredMoneyText:SetTextColor(1 - r, 1 - g, 1 - b)

		for i = 1, MAX_OBJECTIVES do
			local r, g, b = _G["QuestInfoObjective"..i]:GetTextColor()
			_G["QuestInfoObjective"..i]:SetTextColor(1 - r, 1 - g, 1 - b)
		end

		QuestObjectiveText()
	end)

	QuestLogTimerText:SetTextColor(1, 1, 1)
	-- QuestInfoAnchor:SetTextColor(1, 1, 1)

	QuestFrameGreetingPanel:HookScript("OnShow", function()
		GreetingText:SetTextColor(1, 1, 0)
		CurrentQuestsText:SetTextColor(1, 1, 1)
		AvailableQuestsText:SetTextColor(1, 1, 1)
	end)

	-- QuestLogScrollFrame:SetTemplate("Default")
	QuestLogDetailScrollFrame:StripTextures()
	QuestLogDetailScrollFrame:SetTemplate("Default")

	QuestFrame:CreateBackdrop("Transparent")
	QuestFrame.backdrop:Point("TOPLEFT", QuestFrame, "TOPLEFT", 15, -19)
	QuestFrame.backdrop:Point("BOTTOMRIGHT", QuestFrame, "BOTTOMRIGHT", -30, 67)

	QuestLogDetailScrollFrame:StripTextures()
	QuestLogDetailScrollFrame:CreateBackdrop("Transparent")
	QuestLogDetailScrollFrame.backdrop:Point("TOPLEFT", QuestLogDetailFrame, "TOPLEFT", 10, -12)
	QuestLogDetailScrollFrame.backdrop:Point("BOTTOMRIGHT", QuestLogDetailFrame, "BOTTOMRIGHT", 0, 4)

	QuestLogFrame:CreateBackdrop("Transparent")
	QuestLogFrame.backdrop:Point("TOPLEFT", QuestLogFrame, "TOPLEFT", 10, -12)
	QuestLogFrame.backdrop:Point("BOTTOMRIGHT", QuestLogFrame, "BOTTOMRIGHT", -1, 8)

	S:HandleCloseButton(QuestLogFrameCloseButton)
	S:HandleCloseButton(QuestFrameCloseButton)

	S:HandleScrollBar(QuestLogDetailScrollFrameScrollBar)
	S:HandleScrollBar(QuestDetailScrollFrameScrollBar)
	S:HandleScrollBar(QuestLogListScrollFrameScrollBar)
	S:HandleScrollBar(QuestProgressScrollFrameScrollBar)
	S:HandleScrollBar(QuestRewardScrollFrameScrollBar)

	for i = 1, 6 do
		local button = _G["QuestProgressItem" .. i]
		local texture = _G["QuestProgressItem" .. i .. "IconTexture"]
		button:StripTextures()
		button:StyleButton()
		button:SetWidth(button:GetWidth() - 4)
		button:SetFrameLevel(button:GetFrameLevel() + 2)
		texture:SetTexCoord(unpack(E.TexCoords))
		texture:SetDrawLayer("OVERLAY")
		texture:Size(texture:GetWidth() -(E.Spacing*2), texture:GetHeight() -(E.Spacing*2))
		texture:Point("TOPLEFT", E.Border, -E.Border)
		S:HandleIcon(texture)
		_G["QuestProgressItem" .. i .. "Count"]:SetParent(button.backdrop)
		_G["QuestProgressItem" .. i .. "Count"]:SetDrawLayer("OVERLAY")
		button:SetTemplate("Default")
	end

	hooksecurefunc("QuestFrameProgressItems_Update", function()
		QuestProgressTitleText:SetTextColor(1, 1, 0)
		QuestProgressText:SetTextColor(1, 1, 1)
		QuestProgressRequiredItemsText:SetTextColor(1, 1, 0)
		QuestProgressRequiredMoneyText:SetTextColor(1, 1, 0)
	end)

	for i = 1, QUESTS_DISPLAYED do
		local questLogTitle = _G["QuestLogTitle" .. i]
		questLogTitle:SetNormalTexture("")
		questLogTitle.SetNormalTexture = E.noop
		questLogTitle:SetHighlightTexture("")
		questLogTitle.SetHighlightTexture = E.noop

		questLogTitle.Text = questLogTitle:CreateFontString(nil, "OVERLAY")
		questLogTitle.Text:FontTemplate(nil, 22)
		questLogTitle.Text:Point("LEFT", 3, 0)
		questLogTitle.Text:SetText("+")

		hooksecurefunc(questLogTitle, "SetNormalTexture", function(self, texture)
			if(find(texture, "MinusButton")) then
				self.Text:SetText("-")
			elseif(find(texture, "PlusButton")) then
				self.Text:SetText("+")
			else
				self.Text:SetText("")
			end
		end)
	end
end

S:AddCallback("Quest", S.LoadQuestSkin)