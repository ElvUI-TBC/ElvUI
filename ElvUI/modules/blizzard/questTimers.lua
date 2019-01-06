local E, L, DF = unpack(ElvUI)
local B = E:GetModule("Blizzard")

local hooksecurefunc = hooksecurefunc
local QUEST_TIMERS = QUEST_TIMERS

local QuestTimerFrameHolder = CreateFrame("Frame", "QuestTimerFrameHolder", E.UIParent)
QuestTimerFrameHolder:Size(150, 22)
QuestTimerFrameHolder:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -135, -250)

function B:MoveQuestTimerFrame()
	E:CreateMover(QuestTimerFrameHolder, "QuestTimerFrameMover", QUEST_TIMERS)
	QuestTimerFrameHolder:SetAllPoints(QuestTimerFrameMover)

	QuestTimerFrame:ClearAllPoints()
	QuestTimerFrame:SetPoint("TOP", QuestTimerFrameHolder, "TOP")
	QuestTimerFrame:SetClampedToScreen(false)

	hooksecurefunc(QuestTimerFrame, "SetPoint", function(_, _, parent)
		if parent ~= QuestTimerFrameHolder then
			QuestTimerFrame:ClearAllPoints()
			QuestTimerFrame:SetPoint("TOP", QuestTimerFrameHolder, "TOP")
		end
	end)
end