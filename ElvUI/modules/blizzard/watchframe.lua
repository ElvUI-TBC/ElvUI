local E, L, DF = unpack(ElvUI)
local B = E:GetModule("Blizzard")

local hooksecurefunc = hooksecurefunc

local WatchFrameHolder = CreateFrame("Frame", "WatchFrameHolder", E.UIParent)
WatchFrameHolder:Size(150, 22)
WatchFrameHolder:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -135, -300)

function B:MoveWatchFrame()
	E:CreateMover(WatchFrameHolder, "WatchFrameMover", L["Watch Frame"])
	WatchFrameHolder:SetAllPoints(WatchFrameMover)

	QuestWatchFrame:ClearAllPoints()
	QuestWatchFrame:SetPoint("TOP", WatchFrameHolder, "TOP")
	QuestWatchFrame:SetClampedToScreen(false)

	hooksecurefunc(QuestWatchFrame, "SetPoint", function(_, _, parent)
		if parent ~= WatchFrameHolder then
			QuestWatchFrame:ClearAllPoints()
			QuestWatchFrame:SetPoint("TOP", WatchFrameHolder, "TOP")
		end
	end)
end