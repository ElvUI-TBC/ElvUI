local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")
local TT = E:GetModule("Tooltip")

local _G = _G
local pairs = pairs

local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tooltip ~= true then return end

	S:HandleCloseButton(ItemRefCloseButton)

	local GameTooltip = _G["GameTooltip"]
	local GameTooltipStatusBar = _G["GameTooltipStatusBar"]
	local tooltips = {
		GameTooltip,
		ItemRefTooltip,
		ShoppingTooltip1,
		ShoppingTooltip2,
		WorldMapTooltip
	}

	for _, tt in pairs(tooltips) do
		TT:SecureHookScript(tt, "OnShow", "SetStyle")

		tt:SetClampedToScreen(true)
	end

	GameTooltipStatusBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(GameTooltipStatusBar)
	GameTooltipStatusBar:CreateBackdrop("Transparent")
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:Point("TOPLEFT", GameTooltip, "BOTTOMLEFT", E.Border, -(E.Spacing * 3))
	GameTooltipStatusBar:Point("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -E.Border, -(E.Spacing * 3))

	TT:SecureHookScript(GameTooltip, "OnSizeChanged", "CheckBackdropColor")
	TT:SecureHookScript(GameTooltip, "OnUpdate", "CheckBackdropColor")
	TT:RegisterEvent("CURSOR_UPDATE", "CheckBackdropColor")
end

S:AddCallback("SkinTooltip", LoadSkin)