local E, L, V, P, G = unpack(ElvUI)
local B = E:NewModule("Blizzard", "AceEvent-3.0", "AceHook-3.0")

E.Blizzard = B

function B:Initialize()
	self:EnhanceColorPicker()
	self:KillBlizzard()
	self:PositionCaptureBar()
	self:PositionDurabilityFrame()
	self:PositionGMFrames()

--	QuestLogFrame:HookScript("OnShow", function()
--		local questFrame = QuestLogFrame:GetFrameLevel()
--		local scrollFrame = QuestLogDetailScrollFrame:GetFrameLevel()
--
--		if questFrame >= scrollFrame then
--			QuestLogDetailScrollFrame:SetFrameLevel(questFrame + 1)
--		end
--	end)
end

E:RegisterModule(B:GetName())