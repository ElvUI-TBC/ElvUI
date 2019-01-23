local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack, select, pairs = unpack, select, pairs
local find, format = string.find, string.format

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.quest ~= true then return end

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
		"QuestRewardItemHighlight",
		"QuestFrameProgressPanel",
		"QuestFrameRewardPanel",
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
		"QuestFrameAcceptButton",
		"QuestFrameDeclineButton"
	}

	for _, button in pairs(QuestButtons) do
		_G[button]:StripTextures()
		S:HandleButton(_G[button])
	end

	local questItems = {
		["QuestLogItem"] = MAX_NUM_ITEMS,
		["QuestDetailItem"] = MAX_NUM_ITEMS,
		["QuestRewardItem"] = MAX_NUM_ITEMS,
		["QuestProgressItem"] = MAX_REQUIRED_ITEMS
	}

	for frame, numItems in pairs(questItems) do
		for i = 1, numItems do
			local item = _G[frame..i]
			local icon = _G[frame..i.."IconTexture"]
			local count = _G[frame..i.."Count"]

			item:StripTextures()
			item:SetTemplate("Default")
			item:StyleButton()
			item:Size(143, 40)
			item:SetFrameLevel(item:GetFrameLevel() + 2)

			icon:Size(E.PixelMode and 38 or 32)
			icon:SetDrawLayer("OVERLAY")
			icon:Point("TOPLEFT", E.PixelMode and 1 or 4, -(E.PixelMode and 1 or 4))
			S:HandleIcon(icon)

			count:SetParent(item.backdrop)
			count:SetDrawLayer("OVERLAY")
		end
	end

	for _, frame in pairs({"QuestLogHonorFrame", "QuestDetailHonorFrame", "QuestRewardHonorFrame"}) do
		local honor = _G[frame]
		local icon = _G[frame.."Icon"]
		local points = _G[frame.."Points"]
		local text = _G[frame.."HonorReceiveText"]

		honor:SetTemplate("Default")
		honor:Size(143, 40)
		honor:EnableMouse(true)

		honor:HookScript2("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(HONOR_POINTS, 1, 1, 1)
			GameTooltip:AddLine(TOOLTIP_HONOR_POINTS, nil, nil, nil, 1)
			GameTooltip:Show()
		end)
		honor:HookScript2("OnLeave", function()
			GameTooltip:Hide()
		end)

		honor.highlight = honor:CreateTexture(nil, "HIGHLIGHT")
		honor.highlight:SetTexture(1, 1, 1, 0.3)
		honor.highlight:SetInside()

		icon.backdrop = CreateFrame("Frame", nil, honor)
		icon.backdrop:SetFrameLevel(honor:GetFrameLevel() - 1)
		icon.backdrop:SetTemplate("Default")
		icon.backdrop:SetOutside(icon)

		icon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PVPCurrency-Honor-"..E.myfaction)
		icon.SetTexture = E.noop
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetDrawLayer("OVERLAY")
		icon:Size(E.PixelMode and 38 or 32)
		icon:ClearAllPoints()
		icon:Point("TOPLEFT", E.PixelMode and 1 or 4, -(E.PixelMode and 1 or 4))
		icon:SetParent(icon.backdrop)

		points:ClearAllPoints()
		points:Point("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -2, 2)
		points:SetParent(icon.backdrop)
		points:SetDrawLayer("OVERLAY")
		points:FontTemplate(nil, nil, "OUTLINE")

		text:Point("LEFT", honor, "LEFT", 44, 0)
		text:SetText(HONOR_POINTS)
	end

	local function QuestQualityColors(frame, text, link, quality)
		if link and not quality then
			quality = select(3, GetItemInfo(link))
		end

		if quality then
			frame:SetBackdropBorderColor(GetItemQualityColor(quality))
			frame.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))

			text:SetTextColor(GetItemQualityColor(quality))
		else
			frame:SetBackdropBorderColor(unpack(E.media.bordercolor))
			frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))

			text:SetTextColor(1, 1, 1)
		end
	end

	hooksecurefunc("QuestRewardItem_OnClick", function()
		if this.type == "choice" then
			_G[this:GetName()]:SetBackdropBorderColor(1, 0.80, 0.10)
			_G[this:GetName()].backdrop:SetBackdropBorderColor(1, 0.80, 0.10)
			_G[this:GetName().."Name"]:SetTextColor(1, 0.80, 0.10)

			for i = 1, MAX_NUM_ITEMS do
				local item = _G["QuestRewardItem"..i]
				local name = _G["QuestRewardItem"..i.."Name"]
				local link = item.type and GetQuestItemLink(item.type, item:GetID())

				if item ~= this then
					QuestQualityColors(item, name, link)
				end
			end
		end
	end)

	local function QuestObjectiveTextColor()
		local numObjectives = GetNumQuestLeaderBoards()
		local objective
		local _, type, finished
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

		QuestTitleText:SetTextColor(unpack(titleTextColor))
		QuestTitleFont:SetTextColor(unpack(titleTextColor))
		QuestFont:SetTextColor(unpack(textColor))
		QuestFontNormalSmall:SetTextColor(unpack(textColor))
		QuestDescription:SetTextColor(unpack(textColor))
		QuestObjectiveText:SetTextColor(unpack(textColor))

		QuestDetailObjectiveTitleText:SetTextColor(unpack(titleTextColor))
		QuestDetailRewardTitleText:SetTextColor(unpack(titleTextColor))
		QuestDetailItemReceiveText:SetTextColor(unpack(textColor))
		QuestDetailSpellLearnText:SetTextColor(unpack(textColor))
		QuestDetailItemChooseText:SetTextColor(unpack(textColor))

		QuestLogDescriptionTitle:SetTextColor(unpack(titleTextColor))
		QuestLogQuestTitle:SetTextColor(unpack(titleTextColor))
		QuestLogPlayerTitleText:SetTextColor(unpack(titleTextColor))
		QuestLogRewardTitleText:SetTextColor(unpack(titleTextColor))
		QuestLogObjectivesText:SetTextColor(unpack(textColor))
		QuestLogQuestDescription:SetTextColor(unpack(textColor))
		QuestLogItemChooseText:SetTextColor(unpack(textColor))
		QuestLogItemReceiveText:SetTextColor(unpack(textColor))
		QuestLogSpellLearnText:SetTextColor(unpack(textColor))

		QuestRewardRewardTitleText:SetTextColor(unpack(titleTextColor))
		QuestRewardTitleText:SetTextColor(unpack(titleTextColor))
		QuestRewardItemChooseText:SetTextColor(unpack(textColor))
		QuestRewardItemReceiveText:SetTextColor(unpack(textColor))
		QuestRewardSpellLearnText:SetTextColor(unpack(textColor))
		QuestRewardText:SetTextColor(unpack(textColor))

		if GetQuestLogRequiredMoney() > 0 then
			if GetQuestLogRequiredMoney() > GetMoney() then
				QuestLogRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				QuestLogRequiredMoneyText:SetTextColor(unpack(textColor))
			end
		end

		QuestObjectiveTextColor()

		local numQuestRewards = questState == "QuestLog" and GetNumQuestLogRewards() or GetNumQuestRewards()
		local numQuestChoices = questState == "QuestLog" and GetNumQuestLogChoices() or GetNumQuestChoices()
		local numQuestSpellRewards = questState == "QuestLog" and GetQuestLogRewardSpell() or GetRewardSpell()
		local rewardsCount = numQuestChoices + numQuestRewards + (numQuestSpellRewards and 1 or 0)

		if rewardsCount > 0 then
			for i = 1, rewardsCount do
				local item = _G[questState.."Item"..i]
				local name = _G[questState.."Item"..i.."Name"]
				local link = item.type and (questState == "QuestLog" and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

				QuestQualityColors(item, name, link)
			end
		end
	end)

	QuestLogTimerText:SetTextColor(1, 1, 1)

	QuestFrame:CreateBackdrop("Transparent")
	QuestFrame.backdrop:Point("TOPLEFT", 15, -11)
	QuestFrame.backdrop:Point("BOTTOMRIGHT", -20, 0)
	QuestFrame:Width(374)

	QuestLogFrame:SetAttribute("UIPanelLayout-width", E:Scale(685))
	QuestLogFrame:SetAttribute("UIPanelLayout-height", E:Scale(490))
	QuestLogFrame:Size(685, 490)
	QuestLogFrame:CreateBackdrop("Transparent")
	QuestLogFrame.backdrop:Point("TOPLEFT", 10, -12)
	QuestLogFrame.backdrop:Point("BOTTOMRIGHT", -1, 8)

	QuestDetailScrollFrame:Height(402)
	QuestRewardScrollFrame:Height(402)
	QuestProgressScrollFrame:Height(402)

	QuestLogListScrollFrame:StripTextures()
	QuestLogListScrollFrame:CreateBackdrop("Transparent")
	QuestLogListScrollFrame.backdrop:Point("TOPLEFT", -1, 2)
	QuestLogListScrollFrame:Size(305, 375)

	QuestLogDetailScrollFrame:StripTextures()
	QuestLogDetailScrollFrame:CreateBackdrop("Transparent")
	QuestLogDetailScrollFrame.backdrop:Point("TOPLEFT", -4, 2)
	QuestLogDetailScrollFrame:Size(300, 375)
	QuestLogDetailScrollFrame:ClearAllPoints()
	QuestLogDetailScrollFrame:Point("TOPRIGHT", QuestLogFrame, -32, -75)

	QuestLogNoQuestsText:ClearAllPoints()
	QuestLogNoQuestsText:Point("CENTER", EmptyQuestLogFrame, "CENTER", -45, 65)

	QuestLogHighlightFrame:Width(306)
	QuestLogHighlightFrame.SetWidth = E.noop

	QuestLogSkillHighlight:StripTextures()

	QuestLogHighlightFrame.Left = QuestLogHighlightFrame:CreateTexture(nil, "ARTWORK")
	QuestLogHighlightFrame.Left:Size(152, 15)
	QuestLogHighlightFrame.Left:SetPoint("LEFT", QuestLogHighlightFrame, "CENTER")
	QuestLogHighlightFrame.Left:SetTexture(E.media.blankTex)

	QuestLogHighlightFrame.Right = QuestLogHighlightFrame:CreateTexture(nil, "ARTWORK")
	QuestLogHighlightFrame.Right:Size(152, 15)
	QuestLogHighlightFrame.Right:SetPoint("RIGHT", QuestLogHighlightFrame, "CENTER")
	QuestLogHighlightFrame.Right:SetTexture(E.media.blankTex)

	hooksecurefunc(QuestLogSkillHighlight, "SetVertexColor", function(_, r, g, b)
		QuestLogHighlightFrame.Left:SetGradientAlpha("Horizontal", r, g, b, 0.35, r, g, b, 0)
		QuestLogHighlightFrame.Right:SetGradientAlpha("Horizontal", r, g, b, 0, r, g, b, 0.35)
	end)

	QuestLogFrameAbandonButton:Point("BOTTOMLEFT", 18, 15)
	QuestLogFrameAbandonButton:Width(101)
	QuestLogFrameAbandonButton:SetText(L["Abandon"])

	QuestFramePushQuestButton:ClearAllPoints()
	QuestFramePushQuestButton:Point("LEFT", QuestLogFrameAbandonButton, "RIGHT", 2, 0)
	QuestFramePushQuestButton:Width(101)
	QuestFramePushQuestButton:SetText(L["Share"])

	QuestFrameExitButton:Point("BOTTOMRIGHT", -31, 15)
	QuestFrameExitButton:Width(100)

	QuestFrameAcceptButton:Point("BOTTOMLEFT", 20, 4)
	QuestFrameDeclineButton:Point("BOTTOMRIGHT", -37, 4)
	QuestFrameCompleteButton:Point("BOTTOMLEFT", 20, 4)
	QuestFrameGoodbyeButton:Point("BOTTOMRIGHT", -37, 4)
	QuestFrameCompleteQuestButton:Point("BOTTOMLEFT", 20, 4)
	QuestFrameCancelButton:Point("BOTTOMRIGHT", -37, 4)

	QuestFrameNpcNameText:Point("CENTER", QuestNpcNameFrame, "CENTER", -1, 0)

	S:HandleScrollBar(QuestLogDetailScrollFrameScrollBar)
	S:HandleScrollBar(QuestDetailScrollFrameScrollBar)
	S:HandleScrollBar(QuestLogListScrollFrameScrollBar)
	QuestLogListScrollFrameScrollBar:Point("TOPLEFT", QuestLogListScrollFrame, "TOPRIGHT", 5, -16)
	S:HandleScrollBar(QuestProgressScrollFrameScrollBar)
	S:HandleScrollBar(QuestRewardScrollFrameScrollBar)

	S:HandleCloseButton(QuestFrameCloseButton, QuestFrame.backdrop)

	S:HandleCloseButton(QuestLogFrameCloseButton)
	QuestLogFrameCloseButton:ClearAllPoints()
	QuestLogFrameCloseButton:Point("TOPRIGHT", 2, -9)

	QuestLogTrack:Hide()

	local QuestTrack = CreateFrame("Button", "QuestTrack", QuestLogFrame, "UIPanelButtonTemplate")
	S:HandleButton(QuestTrack)
	QuestTrack:Point("LEFT", QuestFramePushQuestButton, "RIGHT", 2, 0)
	QuestTrack:Size(101, 21)
	QuestTrack:SetText(L["Track"])

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

		QuestLogListScrollFrame:Show()
	end)

	hooksecurefunc("QuestFrameProgressItems_Update", function()
		QuestProgressTitleText:SetTextColor(1, 0.80, 0.10)
		QuestProgressText:SetTextColor(1, 1, 1)
		QuestProgressRequiredItemsText:SetTextColor(1, 0.80, 0.10)

		if GetQuestMoneyToGet() > 0 then
			if GetQuestMoneyToGet() > GetMoney() then
				QuestProgressRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				QuestProgressRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end

		for i = 1, MAX_REQUIRED_ITEMS do
			local item = _G["QuestProgressItem"..i]
			local name = _G["QuestProgressItem"..i.."Name"]
			local link = item.type and GetQuestItemLink(item.type, item:GetID())

			QuestQualityColors(item, name, link)
		end
	end)

	QUESTS_DISPLAYED = 25

	for i = 7, 25 do
		local questLogTitle = CreateFrame("Button", "QuestLogTitle"..i, QuestLogFrame, "QuestLogTitleButtonTemplate")

		questLogTitle:SetID(i)
		questLogTitle:Hide()
		questLogTitle:Point("TOPLEFT", _G["QuestLogTitle"..i - 1], "BOTTOMLEFT", 0, 1)
	end

	for i = 1, QUESTS_DISPLAYED do
		local questLogTitle = _G["QuestLogTitle"..i]
		local highlight = _G["QuestLogTitle"..i.."Highlight"]

		questLogTitle:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
		questLogTitle.SetNormalTexture = E.noop
		questLogTitle:GetNormalTexture():Size(14)
		questLogTitle:GetNormalTexture():Point("LEFT", 3, 0)

		highlight:SetTexture("")
		highlight.SetTexture = E.noop

		hooksecurefunc(questLogTitle, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self:GetNormalTexture():SetTexCoord(0.540, 0.965, 0.085, 0.920)
			elseif find(texture, "PlusButton") then
				self:GetNormalTexture():SetTexCoord(0.040, 0.465, 0.085, 0.920)
			else
				self:GetNormalTexture():SetTexCoord(0, 0, 0, 0)
 			end
		end)
	end

	QuestLogCollapseAllButton:StripTextures()
	QuestLogCollapseAllButton:Point("TOPLEFT", -58, -2)

	QuestLogCollapseAllButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
	QuestLogCollapseAllButton.SetNormalTexture = E.noop
	QuestLogCollapseAllButton:GetNormalTexture():Size(15)

	QuestLogCollapseAllButton:SetHighlightTexture("")
	QuestLogCollapseAllButton.SetHighlightTexture = E.noop

	QuestLogCollapseAllButton:SetDisabledTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
	QuestLogCollapseAllButton.SetDisabledTexture = E.noop
	QuestLogCollapseAllButton:GetDisabledTexture():Size(15)
	QuestLogCollapseAllButton:GetDisabledTexture():SetTexCoord(0.040, 0.465, 0.085, 0.920)
	QuestLogCollapseAllButton:GetDisabledTexture():SetDesaturated(true)

	hooksecurefunc(QuestLogCollapseAllButton, "SetNormalTexture", function(self, texture)
		if find(texture, "MinusButton") then
			self:GetNormalTexture():SetTexCoord(0.540, 0.965, 0.085, 0.920)
		elseif find(texture, "PlusButton") then
			self:GetNormalTexture():SetTexCoord(0.040, 0.465, 0.085, 0.920)
		else
			self:GetNormalTexture():SetTexCoord(0, 0, 0, 0)
 		end
	end)

--[[
	-- Quest Watch
	hooksecurefunc("QuestWatch_Update", function()
		local questIndex, numObjectives, objectivesCompleted
		local title, level, questTag
		local titleText, color, hex
		local _, finished

		local watchText
		local watchTextIndex = 1

		for i = 1, GetNumQuestWatches() do
			questIndex = GetQuestIndexForWatch(i)
			if questIndex then
				numObjectives = GetNumQuestLeaderBoards(questIndex)
				title, level, questTag = GetQuestLogTitle(questIndex)
				color = GetQuestDifficultyColor(level)
				hex = E:RGBToHex(color.r, color.g, color.b)

				if questTag == ELITE then
					level = level.."+"
				elseif questTag == LFG_TYPE_DUNGEON then
					level = level.." D"
				elseif questTag == PVP then
					level = level.." PvP"
				elseif questTag == RAID then
					level = level.." R"
				elseif questTag == GROUP then
					level = level.." G"
				elseif questTag == "Heroic" then
					level = level.." HC"
				end

				titleText = hex.."["..level.."] "..title

				if numObjectives > 0 then
					watchText = _G["QuestWatchLine"..watchTextIndex]
					watchText:SetText(titleText)

					watchTextIndex = watchTextIndex + 1
					objectivesCompleted = 0

					for j = 1, numObjectives do
						_, _, finished = GetQuestLogLeaderBoard(j, questIndex)
						watchText = _G["QuestWatchLine"..watchTextIndex]

						if finished then
							watchText:SetTextColor(0, 1, 0)
							objectivesCompleted = objectivesCompleted + 1
						else
							watchText:SetTextColor(0.8, 0.8, 0.8)
						end

						watchTextIndex = watchTextIndex + 1
					end
				end
			end
		end
	end)
]]
end

S:AddCallback("Quest", LoadSkin)