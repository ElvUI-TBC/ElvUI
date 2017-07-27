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
		"QuestFrameCompleteButton",
		"QuestFrameGoodbyeButton",
		"QuestFrameCompleteQuestButton",
		"QuestFrameCancelButton",
		"QuestFrameGreetingGoodbyeButton",
		"QuestFrameAcceptButton",
		"QuestFrameDeclineButton"
	}

	for _, button in pairs(QuestButtons) do
		_G[button]:StripTextures()
		S:HandleButton(_G[button])
	end

	for i = 1, MAX_NUM_ITEMS do
		local item = _G["QuestLogItem" .. i]
		local icon = _G["QuestLogItem" .. i .. "IconTexture"]
		local count = _G["QuestLogItem" .. i .. "Count"]

		item:StripTextures()
		item:SetTemplate("Default")
		item:StyleButton()
		item:Width(item:GetWidth() - 4)
		item:SetFrameLevel(item:GetFrameLevel() + 2)

		icon:SetDrawLayer("OVERLAY")
		icon:Size(icon:GetWidth() -(E.Spacing*2), icon:GetHeight() -(E.Spacing*2))
		icon:Point("TOPLEFT", E.Border, -E.Border)
		S:HandleIcon(icon)

		count:SetParent(item.backdrop)
		count:SetDrawLayer("OVERLAY")
	end

	for i = 1, 6 do
		local item = _G["QuestDetailItem" .. i]
		local icon = _G["QuestDetailItem" .. i .. "IconTexture"]
		local count = _G["QuestDetailItem" .. i .. "Count"]

		item:StripTextures()
		item:SetTemplate("Default")
		item:StyleButton()
		item:Width(item:GetWidth() - 4)
		item:SetFrameLevel(item:GetFrameLevel() + 2)

		icon:SetDrawLayer("OVERLAY")
		icon:Size(icon:GetWidth() -(E.Spacing*2), icon:GetHeight() -(E.Spacing*2))
		icon:Point("TOPLEFT", E.Border, -E.Border)
		S:HandleIcon(icon)

		count:SetParent(item.backdrop)
		count:SetDrawLayer("OVERLAY")
	end

	for i = 1, 6 do
		local item = _G["QuestRewardItem" .. i]
		local icon = _G["QuestRewardItem" .. i .. "IconTexture"]
		local count = _G["QuestRewardItem" .. i .. "Count"]

		item:StripTextures()
		item:SetTemplate("Default")
		item:StyleButton()
		item:Width(item:GetWidth() - 4)
		item:SetFrameLevel(item:GetFrameLevel() + 2)

		icon:SetDrawLayer("OVERLAY")
		icon:Size(icon:GetWidth() -(E.Spacing*2), icon:GetHeight() -(E.Spacing*2))
		icon:Point("TOPLEFT", E.Border, -E.Border)
		S:HandleIcon(icon)

		count:SetParent(item.backdrop)
		count:SetDrawLayer("OVERLAY")
	end

	QuestRewardItemHighlight:StripTextures()
	QuestRewardItemHighlight:SetTemplate("Default", nil, true)
	QuestRewardItemHighlight:SetBackdropBorderColor(1, 1, 0)
	QuestRewardItemHighlight:SetBackdropColor(0, 0, 0, 0)
	QuestRewardItemHighlight:Size(142, 40)

	hooksecurefunc("QuestRewardItem_OnClick", function()
		QuestRewardItemHighlight:ClearAllPoints();
		QuestRewardItemHighlight:SetOutside(this:GetName() .. "IconTexture")
		_G[this:GetName() .. "Name"]:SetTextColor(1, 1, 0)

		for i = 1, MAX_NUM_ITEMS do
			local questItem = _G["QuestRewardItem" .. i]
			if questItem ~= this then
				_G[questItem:GetName() .. "Name"]:SetTextColor(1, 1, 1)
			end
		end
	end)

	local function QuestObjectiveTextColor()
		local numObjectives = GetNumQuestLeaderBoards()
		local objective
		local _, type, finished;
		local numVisibleObjectives = 0
		for i = 1, numObjectives do
			_, type, finished = GetQuestLogLeaderBoard(i)
			if type ~= "spell" then
				numVisibleObjectives = numVisibleObjectives + 1
				objective = _G["QuestLogObjective"..numVisibleObjectives]
				if finished then
					objective:SetTextColor(1, 0.80, 0.10)
				else
					objective:SetTextColor(0.6, 0.6, 0.6)
				end
			end
		end
	end

	hooksecurefunc("QuestLog_UpdateQuestDetails", function()
		local requiredMoney = GetQuestLogRequiredMoney()
		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				QuestLogRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				QuestLogRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end
	end)

	hooksecurefunc("QuestFrameItems_Update", function(questState)
		local titleTextColor = {1, 0.80, 0.10}
		local textColor = {1, 1, 1}

		QuestDetailObjectiveTitleText:SetTextColor(unpack(titleTextColor))
		QuestDetailRewardTitleText:SetTextColor(unpack(titleTextColor))
		QuestLogDescriptionTitle:SetTextColor(unpack(titleTextColor))
		QuestLogQuestTitle:SetTextColor(unpack(titleTextColor))
		QuestLogPlayerTitleText:SetTextColor(unpack(titleTextColor))
		QuestLogRewardTitleText:SetTextColor(unpack(titleTextColor))
		QuestRewardRewardTitleText:SetTextColor(unpack(titleTextColor))
		QuestRewardTitleText:SetTextColor(unpack(titleTextColor))
		QuestTitleText:SetTextColor(unpack(titleTextColor))
		QuestTitleFont:SetTextColor(unpack(titleTextColor))
		QuestTitleFont:SetFont("Fonts\\MORPHEUS.TTF", E.db.general.fontSize + 6)
		QuestTitleFont.SetFont = E.noop

		QuestDescription:SetTextColor(unpack(textColor))
		QuestDetailItemReceiveText:SetTextColor(unpack(textColor))
		QuestDetailSpellLearnText:SetTextColor(unpack(textColor))
		QuestDetailItemChooseText:SetTextColor(unpack(textColor))
		QuestFont:SetTextColor(unpack(textColor))
		QuestFontNormalSmall:SetTextColor(unpack(textColor))
		QuestLogObjectivesText:SetTextColor(unpack(textColor))
		QuestLogQuestDescription:SetTextColor(unpack(textColor))
		QuestLogItemChooseText:SetTextColor(unpack(textColor))
		QuestLogItemReceiveText:SetTextColor(unpack(textColor))
		QuestLogSpellLearnText:SetTextColor(unpack(textColor))
		QuestObjectiveText:SetTextColor(unpack(textColor))
		QuestRewardItemChooseText:SetTextColor(unpack(textColor))
		QuestRewardItemReceiveText:SetTextColor(unpack(textColor))
		QuestRewardSpellLearnText:SetTextColor(unpack(textColor))
		QuestRewardText:SetTextColor(unpack(textColor))

		QuestObjectiveTextColor()

		local numQuestRewards, numQuestChoices
		if questState == "QuestLog" then
			numQuestRewards, numQuestChoices = GetNumQuestLogRewards(), GetNumQuestLogChoices()
		else
			numQuestRewards, numQuestChoices = GetNumQuestRewards(), GetNumQuestChoices()
		end

		local rewardsCount = numQuestChoices + numQuestRewards
		if rewardsCount > 0 then
			local questItem, itemName, itemLink, quality
			local questItemName = questState.."Item"

			for i = 1, rewardsCount do
				questItem = _G[questItemName..i]
				itemName = _G[questItemName..i.."Name"]

				if questState == "QuestLog" then
					itemLink = GetQuestLogItemLink(questItem.type, questItem:GetID())
				else
					itemLink = GetQuestItemLink(questItem.type, questItem:GetID())
				end

				if itemLink then
					quality = select(3, GetItemInfo(itemLink))
					if quality and quality > 1 then
						questItem:SetBackdropBorderColor(GetItemQualityColor(quality))
						questItem.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
						itemName:SetTextColor(GetItemQualityColor(quality))
					else
						questItem:SetBackdropBorderColor(unpack(E["media"].bordercolor))
						questItem.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
						itemName:SetTextColor(1, 1, 1)
					end
				end
			end
		end
	end)

	QuestLogTimerText:SetTextColor(1, 1, 1)

	QuestFrameGreetingPanel:HookScript("OnShow", function()
		GreetingText:SetTextColor(1, 0.80, 0.10)
		CurrentQuestsText:SetTextColor(1, 1, 1)
		AvailableQuestsText:SetTextColor(1, 1, 1)
	end)

	QuestFrame:CreateBackdrop("Transparent")
	QuestFrame.backdrop:Point("TOPLEFT", 15, -19)
	QuestFrame.backdrop:Point("BOTTOMRIGHT", -30, 67)

	QuestLogFrame:SetAttribute("UIPanelLayout-width", E:Scale(685))
	QuestLogFrame:SetAttribute("UIPanelLayout-height", E:Scale(490))
	QuestLogFrame:Size(685, 490)
	QuestLogFrame:CreateBackdrop("Transparent")
	QuestLogFrame.backdrop:Point("TOPLEFT", 10, -12)
	QuestLogFrame.backdrop:Point("BOTTOMRIGHT", -1, 8)

	QuestLogFrame:HookScript("OnUpdate", function()
		if not QuestLogListScrollFrame:IsShown() then
			QuestLogListScrollFrame:Show()
		end
	end)

	QuestLogListScrollFrame:StripTextures()
	QuestLogListScrollFrame:CreateBackdrop("Default", true)
	QuestLogListScrollFrame:Size(305, 375)

	QuestLogDetailScrollFrame:StripTextures()
	QuestLogDetailScrollFrame:CreateBackdrop("Default", true)
	QuestLogDetailScrollFrame:Size(300, 375)
	QuestLogDetailScrollFrame:ClearAllPoints()
	QuestLogDetailScrollFrame:Point("TOPRIGHT", QuestLogFrame, -32, -75)

	QuestLogNoQuestsText:ClearAllPoints()
	QuestLogNoQuestsText:Point("CENTER", EmptyQuestLogFrame, "CENTER", -45, 65)

	QuestLogFrameAbandonButton:Point("BOTTOMLEFT", 18, 15)
	QuestLogFrameAbandonButton:Width(152)

	QuestFramePushQuestButton:Point("RIGHT", QuestFrameExitButton, "LEFT", -229, 0)
	QuestFramePushQuestButton:Width(152)

	QuestFrameExitButton:Point("BOTTOMRIGHT", -31, 15)
	QuestFrameExitButton:Width(100)

	S:HandleScrollBar(QuestLogDetailScrollFrameScrollBar)
	S:HandleScrollBar(QuestDetailScrollFrameScrollBar)
	S:HandleScrollBar(QuestLogListScrollFrameScrollBar)
	S:HandleScrollBar(QuestProgressScrollFrameScrollBar)
	S:HandleScrollBar(QuestRewardScrollFrameScrollBar)

	S:HandleCloseButton(QuestFrameCloseButton)

	S:HandleCloseButton(QuestLogFrameCloseButton)
	QuestLogFrameCloseButton:ClearAllPoints()
	QuestLogFrameCloseButton:Point("TOPRIGHT", 2, -9)

	QuestLogTrack:Hide()

	local QuestTrack = CreateFrame("Button", "QuestTrack", QuestLogFrame, "UIPanelButtonTemplate")

	S:HandleButton(QuestTrack)
	QuestTrack:SetText(TRACK_QUEST)
	QuestTrack:Point("BOTTOM", QuestLogFrame, "BOTTOM", 64, 15)
	QuestTrack:Size(110, 21)

    QuestTrack:HookScript2("OnClick", function()
        if IsQuestWatched(GetQuestLogSelection()) then
            RemoveQuestWatch(GetQuestLogSelection())
 
            QuestWatch_Update()
        else
            if GetNumQuestLeaderBoards(GetQuestLogSelection()) == 0 then
                UIErrorsFrame:AddMessage(QUEST_WATCH_NO_OBJECTIVES, 1.0, 0.1, 0.1, 1.0)
                return
            end
 
            if GetNumQuestWatches() >= MAX_WATCHABLE_QUESTS then
                UIErrorsFrame:AddMessage(format(QUEST_WATCH_TOO_MANY, MAX_WATCHABLE_QUESTS), 1.0, 0.1, 0.1, 1.0)
                return
            end
 
            AddQuestWatch(GetQuestLogSelection())
 
            QuestLog_Update()
            QuestWatch_Update()
        end
 
        QuestLog_Update()
    end)
 
    hooksecurefunc("QuestLog_Update", function()
        local numEntries = GetNumQuestLogEntries()
        if numEntries == 0 then
            QuestTrack:Disable()
        else
            QuestTrack:Enable()
        end
    end)

	for i = 1, 6 do
		local item = _G["QuestProgressItem" .. i]
		local icon = _G["QuestProgressItem" .. i .. "IconTexture"]
		local count = _G["QuestProgressItem" .. i .. "Count"]

		item:StripTextures()
		item:SetTemplate("Default")
		item:StyleButton()
		item:Width(item:GetWidth() - 4)
		item:SetFrameLevel(item:GetFrameLevel() + 2)

		icon:SetDrawLayer("OVERLAY")
		icon:Size(icon:GetWidth() -(E.Spacing*2), icon:GetHeight() -(E.Spacing*2))
		icon:Point("TOPLEFT", E.Border, -E.Border)
		S:HandleIcon(icon)

		count:SetParent(item.backdrop)
		count:SetDrawLayer("OVERLAY")
	end

	hooksecurefunc("QuestFrameProgressItems_Update", function()
		QuestProgressTitleText:SetTextColor(1, 0.80, 0.10)
		QuestProgressText:SetTextColor(1, 1, 1)

		QuestProgressRequiredItemsText:SetTextColor(1, 0.80, 0.10)

		if GetQuestMoneyToGet() > GetMoney() then
			QuestProgressRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
		else
			QuestProgressRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
		end
	end)

	QUESTS_DISPLAYED = 25

	for i = 7, 25 do
		local questLogTitle = CreateFrame("Button", "QuestLogTitle" .. i, QuestLogFrame, "QuestLogTitleButtonTemplate")

		questLogTitle:SetID(i)
		questLogTitle:Hide()
		questLogTitle:Point("TOPLEFT", _G["QuestLogTitle" .. i - 1], "BOTTOMLEFT", 0, 1)
	end

	for i = 1, QUESTS_DISPLAYED do
		local questLogTitle = _G["QuestLogTitle" .. i]

		questLogTitle:SetNormalTexture("")
		questLogTitle.SetNormalTexture = E.noop

		_G["QuestLogTitle" .. i .. "Highlight"]:SetTexture("")
		_G["QuestLogTitle" .. i .. "Highlight"].SetTexture = E.noop

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

	QuestLogCollapseAllButton:StripTextures()
	QuestLogCollapseAllButton:SetNormalTexture("")
	QuestLogCollapseAllButton.SetNormalTexture = E.noop
	QuestLogCollapseAllButton:SetHighlightTexture("")
	QuestLogCollapseAllButton.SetHighlightTexture = E.noop
	QuestLogCollapseAllButton:SetDisabledTexture("")
	QuestLogCollapseAllButton.SetDisabledTexture = E.noop
	QuestLogCollapseAllButton:Point("TOPLEFT", -45, 7)

	QuestLogCollapseAllButton.Text = QuestLogCollapseAllButton:CreateFontString(nil, "OVERLAY")
	QuestLogCollapseAllButton.Text:FontTemplate(nil, 22)
	QuestLogCollapseAllButton.Text:Point("LEFT", 3, 0)
	QuestLogCollapseAllButton.Text:SetText("+")

	hooksecurefunc(QuestLogCollapseAllButton, "SetNormalTexture", function(self, texture)
		if(find(texture, "MinusButton")) then
			self.Text:SetText("-")
		else
			self.Text:SetText("+")
		end
	end)
end

S:AddCallback("Quest", S.LoadQuestSkin)