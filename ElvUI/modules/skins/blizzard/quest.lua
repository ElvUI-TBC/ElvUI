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

	QuestFrameExitButton:Point("BOTTOMRIGHT", QuestLogFrame, -30, 15)

	QuestLogFrameAbandonButton:Point("BOTTOMLEFT", QuestLogFrame, 17, 15)
	QuestLogFrameAbandonButton:Width(150)

	QuestFramePushQuestButton:Point("RIGHT", QuestFrameExitButton, "LEFT", -253, 0)
	QuestFramePushQuestButton:Width(150)

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

	for i = 1, 6 do
		local button = _G["QuestDetailItem" .. i]
		local texture = _G["QuestDetailItem" .. i .. "IconTexture"]
		button:StripTextures()
		button:StyleButton()
		button:Width(button:GetWidth() - 4)
		button:SetFrameLevel(button:GetFrameLevel() + 2)
		texture:SetTexCoord(unpack(E.TexCoords))
		texture:SetDrawLayer("OVERLAY")
		texture:Size(texture:GetWidth() -(E.Spacing*2), texture:GetHeight() -(E.Spacing*2))
		texture:Point("TOPLEFT", E.Border, -E.Border)
		S:HandleIcon(texture)
		_G["QuestDetailItem" .. i .. "Count"]:SetParent(button.backdrop)
		_G["QuestDetailItem" .. i .. "Count"]:SetDrawLayer("OVERLAY")
		button:SetTemplate("Default")
	end

	QuestRewardItemHighlight:StripTextures()
	QuestRewardItemHighlight:SetTemplate("Default", nil, true)
	QuestRewardItemHighlight:SetBackdropBorderColor(1, 1, 0)
	QuestRewardItemHighlight:SetBackdropColor(0, 0, 0, 0)
	QuestRewardItemHighlight:Size(142, 40)

	for i = 1, 6 do
		local button = _G["QuestRewardItem" .. i]
		local texture = _G["QuestRewardItem" .. i .. "IconTexture"]
		button:StripTextures()
		button:StyleButton()
		button:Width(button:GetWidth() - 4)
		button:SetFrameLevel(button:GetFrameLevel() + 2)
		texture:SetTexCoord(unpack(E.TexCoords))
		texture:SetDrawLayer("OVERLAY")
		texture:Size(texture:GetWidth() -(E.Spacing*2), texture:GetHeight() -(E.Spacing*2))
		texture:Point("TOPLEFT", E.Border, -E.Border)
		S:HandleIcon(texture)
		_G["QuestRewardItem" .. i .. "Count"]:SetParent(button.backdrop)
		_G["QuestRewardItem" .. i .. "Count"]:SetDrawLayer("OVERLAY")
		button:SetTemplate("Default")
	end

	hooksecurefunc("QuestRewardItem_OnClick", function()
		QuestRewardItemHighlight:ClearAllPoints();
		QuestRewardItemHighlight:SetOutside(this:GetName() .. "IconTexture");
		_G[this:GetName() .. "Name"]:SetTextColor(1, 1, 0);

		for i = 1, MAX_NUM_ITEMS do
			local questItem = _G["QuestRewardItem" .. i];
			if(questItem ~= this) then
				_G[questItem:GetName() .. "Name"]:SetTextColor(1, 1, 1);
			end
		end
	end);

	hooksecurefunc("QuestFrameItems_Update", function(questState)
		local titleTextColor = {1, 1, 0}
		local textColor = {1, 1, 1}

		QuestDetailObjectiveTitleText:SetTextColor(unpack(titleTextColor))
		QuestDetailRewardTitleText:SetTextColor(unpack(titleTextColor))
		QuestLogDescriptionTitle:SetTextColor(unpack(titleTextColor))
		QuestLogQuestTitle:SetTextColor(unpack(titleTextColor))
		QuestLogPlayerTitleText:SetTextColor(unpack(titleTextColor))
		QuestLogRewardTitleText:SetTextColor(unpack(titleTextColor))
		QuestRewardRewardTitleText:SetTextColor(unpack(titleTextColor))
		QuestRewardTitleText:SetTextColor(unpack(titleTextColor))
		QuestTitleFont:SetTextColor(unpack(titleTextColor))
		QuestTitleText:SetTextColor(unpack(titleTextColor))

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

		local r, g, b = QuestLogRequiredMoneyText:GetTextColor()
		QuestLogRequiredMoneyText:SetTextColor(1 - r, 1 - g, 1 - b)

		for i = 1, MAX_OBJECTIVES do
			local r, g, b = _G["QuestLogObjective"..i]:GetTextColor()
			_G["QuestLogObjective"..i]:SetTextColor(1 - r, 1 - g, 1 - b)
		end

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
		GreetingText:SetTextColor(1, 1, 0)
		CurrentQuestsText:SetTextColor(1, 1, 1)
		AvailableQuestsText:SetTextColor(1, 1, 1)
	end)

	QuestFrame:CreateBackdrop("Transparent")
	QuestFrame.backdrop:Point("TOPLEFT", QuestFrame, "TOPLEFT", 15, -19)
	QuestFrame.backdrop:Point("BOTTOMRIGHT", QuestFrame, "BOTTOMRIGHT", -30, 67)

	QuestLogListScrollFrame:StripTextures()
	QuestLogListScrollFrame:CreateBackdrop("Default", true)
	QuestLogListScrollFrame:Size(300, 375)

	QuestLogDetailScrollFrame:StripTextures()
	QuestLogDetailScrollFrame:CreateBackdrop("Default", true)
	QuestLogDetailScrollFrame:Size(300, 375)
	QuestLogDetailScrollFrame:ClearAllPoints()
	QuestLogDetailScrollFrame:Point("TOPRIGHT", QuestLogFrame, -32, -75)

	QuestLogFrame:SetAttribute("UIPanelLayout-width", E:Scale(680))
	QuestLogFrame:SetAttribute("UIPanelLayout-height", E:Scale(490))
	QuestLogFrame:Size(680, 490)
	QuestLogFrame:CreateBackdrop("Transparent")
	QuestLogFrame.backdrop:Point("TOPLEFT", QuestLogFrame, "TOPLEFT", 10, -12)
	QuestLogFrame.backdrop:Point("BOTTOMRIGHT", QuestLogFrame, "BOTTOMRIGHT", -1, 8)

	QuestLogHighlightFrame:ClearAllPoints()
	QuestLogHighlightFrame:Width(QuestLogFrame:GetWidth() - 48)

	S:HandleCloseButton(QuestLogFrameCloseButton)
	QuestLogFrameCloseButton:ClearAllPoints()
	QuestLogFrameCloseButton:Point("TOPRIGHT", "QuestLogFrame", "TOPRIGHT", 2, -9)
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
		button:Width(button:GetWidth() - 4)
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