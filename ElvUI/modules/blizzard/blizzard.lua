local E, L, V, P, G = unpack(ElvUI)
local B = E:NewModule("Blizzard", "AceEvent-3.0", "AceHook-3.0")

E.Blizzard = B

function B:Initialize()
	self:AlertMovers()
	self:EnhanceColorPicker()
	self:KillBlizzard()
	self:PositionCaptureBar()
	self:PositionDurabilityFrame()
	self:PositionGMFrames()
	self:MoveWatchFrame()

	self:RawHook("CombatConfig_Colorize_Update", function()
		if not CHATCONFIG_SELECTED_FILTER_SETTINGS then return end
		self.hooks.CombatConfig_Colorize_Update()
	end, true)

--	QuestLogFrame:HookScript("OnShow", function()
--		local questFrame = QuestLogFrame:GetFrameLevel()
--		local scrollFrame = QuestLogDetailScrollFrame:GetFrameLevel()
--
--		if questFrame >= scrollFrame then
--			QuestLogDetailScrollFrame:SetFrameLevel(questFrame + 1)
--		end
--	end)
end

local function InitializeCallback()
	B:Initialize()
end

E:RegisterModule(B:GetName(), InitializeCallback)