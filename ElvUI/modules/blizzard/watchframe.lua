local E, L, DF = unpack(ElvUI)
local B = E:GetModule("Blizzard")

local min = math.min

local hooksecurefunc = hooksecurefunc
local GetScreenWidth = GetScreenWidth
local GetScreenHeight = GetScreenHeight

local WatchFrameHolder = CreateFrame("Frame", "WatchFrameHolder", E.UIParent)
WatchFrameHolder:Size(150, 22)
WatchFrameHolder:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -135, -300)

function B:SetWatchFrameHeight()
	local top = QuestWatchFrame:GetTop() or 0
	local screenHeight = GetScreenHeight()
	local gapFromTop = screenHeight - top
	local maxHeight = screenHeight - gapFromTop
	local watchFrameHeight = min(maxHeight, E.db.general.watchFrameHeight)

	QuestWatchFrame:Height(watchFrameHeight)
end

function B:MoveWatchFrame()
	E:CreateMover(WatchFrameHolder, "WatchFrameMover", L["Watch Frame"])
	WatchFrameHolder:SetAllPoints(WatchFrameMover)

	QuestWatchFrame:ClearAllPoints()
	QuestWatchFrame:SetPoint("TOP", WatchFrameHolder, "TOP")
	B:SetWatchFrameHeight()
	QuestWatchFrame:SetClampedToScreen(false)

	hooksecurefunc(QuestWatchFrame, "SetPoint", function(_, _, parent)
		if parent ~= WatchFrameHolder then
			QuestWatchFrame:ClearAllPoints()
			QuestWatchFrame:SetPoint("TOP", WatchFrameHolder, "TOP")
		end
	end)
end