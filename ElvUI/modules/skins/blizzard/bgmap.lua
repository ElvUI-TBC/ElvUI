local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bgmap ~= true then return end

	local BattlefieldMinimap = _G["BattlefieldMinimap"]
	BattlefieldMinimap:SetClampedToScreen(true)
	BattlefieldMinimapCorner:Kill()
	BattlefieldMinimapBackground:Kill()
	BattlefieldMinimapTab:Kill()
	BattlefieldMinimapTabLeft:Kill()
	BattlefieldMinimapTabMiddle:Kill()
	BattlefieldMinimapTabRight:Kill()

	BattlefieldMinimap:CreateBackdrop("Default")
	BattlefieldMinimap.backdrop:Point("BOTTOMRIGHT", -4, 2)
	BattlefieldMinimap:SetFrameStrata("LOW")

	BattlefieldMinimapCloseButton:ClearAllPoints()
	BattlefieldMinimapCloseButton:Point("TOPRIGHT", -4, 0)
	S:HandleCloseButton(BattlefieldMinimapCloseButton)
	BattlefieldMinimapCloseButton:SetFrameStrata("MEDIUM")

	BattlefieldMinimap:EnableMouse(true)
	BattlefieldMinimap:SetMovable(true)

	BattlefieldMinimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "LeftButton" then
			BattlefieldMinimapTab:StopMovingOrSizing()
			BattlefieldMinimapTab:SetUserPlaced(true)
			if OpacityFrame:IsShown() then OpacityFrame:Hide() end -- seem to be a bug with default ui in 4.0, we hide it on next click
		elseif btn == "RightButton" then
			ToggleDropDownMenu(1, nil, BattlefieldMinimapTabDropDown, self:GetName(), 0, -4)
			if OpacityFrame:IsShown() then OpacityFrame:Hide() end -- seem to be a bug with default ui in 4.0, we hide it on next click
		end
	end)

	BattlefieldMinimap:SetScript("OnMouseDown", function(_, btn)
		if btn == "LeftButton" then
			if BattlefieldMinimapOptions and BattlefieldMinimapOptions.locked then
				return
			else
				BattlefieldMinimapTab:StartMoving()
			end
		end
	end)

	hooksecurefunc("BattlefieldMinimap_SetOpacity", function()
		local alpha = 1.0 - BattlefieldMinimapOptions.opacity or 0
		BattlefieldMinimap.backdrop:SetAlpha(alpha)
	end)

	local oldAlpha
	BattlefieldMinimap:HookScript2("OnEnter", function()
		oldAlpha = BattlefieldMinimapOptions.opacity or 0
		BattlefieldMinimap_SetOpacity(0)
	end)

	BattlefieldMinimap:HookScript2("OnLeave", function()
		if oldAlpha then
			BattlefieldMinimap_SetOpacity(oldAlpha)
			oldAlpha = nil
		end
	end)

	BattlefieldMinimapCloseButton:HookScript2("OnEnter", function()
		oldAlpha = BattlefieldMinimapOptions.opacity or 0
		BattlefieldMinimap_SetOpacity(0)
	end)

	BattlefieldMinimapCloseButton:HookScript2("OnLeave", function()
		if oldAlpha then
			BattlefieldMinimap_SetOpacity(oldAlpha)
			oldAlpha = nil
		end
	end)
end

S:AddCallbackForAddon("Blizzard_BattlefieldMinimap", "BattlefieldMinimap", LoadSkin)