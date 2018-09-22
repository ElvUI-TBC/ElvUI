local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule("UnitFrames")

local CombatTextures = {
	["DEFAULT"] = [[Interface\CharacterFrame\UI-StateIcon]],
	["COMBAT"] = [[Interface\AddOns\ElvUI\media\textures\combat]],
	["ATTACK"] = [[Interface\CURSOR\Attack]],
	["ALERT"] = [[Interface\AddOns\ElvUI\media\textures\UI-Dialog-Icon-AlertNew]],
	["ALERT2"] = [[Interface\AddOns\ElvUI\media\textures\UI-OptionsFrame-NewFeatureIcon]],
	["ARTHAS"] = [[Interface\AddOns\ElvUI\media\textures\UI-LFR-PORTRAIT]],
	["SKULL"] = [[Interface\LootFrame\LootPanel-Icon]]
}

function UF:Construct_CombatIndicator(frame)
	return frame.RaisedElementParent.TextureParent:CreateTexture(nil, "OVERLAY")
end

function UF:Configure_CombatIndicator(frame)
	if not frame.VARIABLES_SET then return end

	local Icon = frame.CombatIndicator
	local db = frame.db.CombatIcon

	Icon:ClearAllPoints()
	Icon:Point("CENTER", frame.Health, db.anchorPoint, db.xOffset, db.yOffset)
	Icon:Size(db.size)

	if db.defaultColor then
		Icon:SetVertexColor(1, 1, 1, 1)
		Icon:SetDesaturated(false)
	else
		Icon:SetVertexColor(db.color.r, db.color.g, db.color.b, db.color.a)
		Icon:SetDesaturated(true)
	end

	if db.texture == "CUSTOM" and db.customTexture then
		Icon:SetTexture(db.customTexture)
		Icon:SetTexCoord(0, 1, 0, 1)
	elseif db.texture ~= "DEFAULT" and CombatTextures[db.texture] then
		Icon:SetTexture(CombatTextures[db.texture])
		Icon:SetTexCoord(0, 1, 0, 1)
	else
		Icon:SetTexture(CombatTextures.DEFAULT)
		Icon:SetTexCoord(.5, 1, 0, .49)
	end

	if db.enable and not frame:IsElementEnabled("CombatIndicator") then
		frame:EnableElement("CombatIndicator")
	elseif not db.enable and frame:IsElementEnabled("CombatIndicator") then
		frame:DisableElement("CombatIndicator")
	end
end