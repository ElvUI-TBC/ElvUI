local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local hooksecurefunc = hooksecurefunc

function S:LoadQuestTimerSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.questtimer ~= true) then return end

	QuestTimerFrame:StripTextures()
	QuestTimerFrame:SetTemplate("Transparent")

	QuestTimerHeader:Point("TOP", 1, 8)

	E:CreateMover(QuestTimerFrame, "QuestTimerFrameMover", L["Quest Timer Frame"])
	QuestTimerFrame:SetAllPoints(QuestTimerFrameMover)

	local QuestTimerFrameHolder = CreateFrame("Frame", "QuestTimerFrameHolder", E.UIParent)
	QuestTimerFrameHolder:Size(150, 22)
	QuestTimerFrameHolder:Point("TOP", QuestTimerFrameMover, "TOP")

	QuestTimerFrame:ClearAllPoints()
	QuestTimerFrame:SetPoint("TOP", QuestTimerFrameMover, "TOP")
	QuestTimerFrame:SetClampedToScreen(false)

	hooksecurefunc(QuestTimerFrame, "SetPoint", function(_, _, parent)
		if parent ~= QuestTimerFrameHolder then
			QuestTimerFrame:ClearAllPoints()
			QuestTimerFrame:SetPoint("TOP", QuestTimerFrameHolder, "TOP")
		end
	end)
end

S:AddCallback("QuestTimer", S.LoadQuestTimerSkin)