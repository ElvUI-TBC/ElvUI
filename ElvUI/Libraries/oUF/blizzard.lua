local ns = oUF
local oUF = ns.oUF

local hiddenParent = CreateFrame("Frame")

-- sourced from FrameXML/PartyMemberFrame.lua
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS or 4

local hiddenParent = CreateFrame('Frame', nil, UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()

local function handleFrame(baseName)
	local frame
	if(type(baseName) == 'string') then
		frame = _G[baseName]
	else
		frame = baseName
	end

	if(frame) then
		frame:UnregisterAllEvents()
		frame:Hide()

		-- Keep frame hidden without causing taint
		frame:SetParent(hiddenParent)

		local health = frame.healthBar or frame.healthbar
		if(health) then
			health:UnregisterAllEvents()
		end

		local power = frame.manabar
		if(power) then
			power:UnregisterAllEvents()
		end

		local spell = frame.castBar or frame.spellbar
		if(spell) then
			spell:UnregisterAllEvents()
		end

		local buffFrame = frame.BuffFrame
		if(buffFrame) then
			buffFrame:UnregisterAllEvents()
		end
	end
end

function oUF:DisableBlizzard(unit)
	if(not unit) then return end

	if(unit == 'player') then
		handleFrame(PlayerFrame)
	elseif(unit == 'pet') then
		handleFrame(PetFrame)
	elseif(unit == 'target') then
		handleFrame(TargetFrame)
		handleFrame(ComboFrame)
	elseif(unit == 'targettarget') then
		handleFrame(TargetofTargetFrame)
	elseif(unit:match('party%d?$')) then
		local id = unit:match('party(%d)')
		if(id) then
			handleFrame('PartyMemberFrame' .. id)
		else
			for i = 1, MAX_PARTY_MEMBERS do
				handleFrame(string.format('PartyMemberFrame%d', i))
			end
		end
	end
end