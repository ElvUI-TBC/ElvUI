local E, L, DF = unpack(ElvUI)
local B = E:GetModule("Blizzard")

local _G = _G

function B:PositionDurabilityFrame()
	DurabilityFrame:SetFrameStrata("HIGH")

	local function SetPosition(self, _, parent)
		if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
			self:ClearAllPoints()
			self:Point("RIGHT", Minimap, "RIGHT", -10, 0)
			self:SetScale(0.7)
		end
	end
	hooksecurefunc(DurabilityFrame, "SetPoint", SetPosition)
end