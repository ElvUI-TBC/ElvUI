local ns = oUF
local oUF = ns.oUF

local hiddenParent = CreateFrame("Frame")
hiddenParent:Hide()

local HandleFrame = function(baseName)
	local frame
	if(type(baseName) == "string") then
		frame = _G[baseName]
	else
		frame = baseName
	end

	if(frame) then
		frame:UnregisterAllEvents()
		frame:Hide()

		-- Keep frame hidden without causing taint
		frame:SetParent(hiddenParent)

		local health = frame.healthbar
		if(health) then
			health:UnregisterAllEvents()
		end

		local power = frame.manabar
		if(power) then
			power:UnregisterAllEvents()
		end

		local spell = frame.spellbar
		if(spell) then
			spell:UnregisterAllEvents()
		end
	end
end

function oUF:DisableBlizzard(unit)
	if(not unit) then return end

	if(unit == "player") then
		HandleFrame(PlayerFrame)

		PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	elseif(unit == "pet") then
		HandleFrame(PetFrame)
	elseif(unit == "target") then
		HandleFrame(TargetFrame)
		HandleFrame(ComboFrame)
	elseif(unit == "targettarget") then
		HandleFrame(TargetofTargetFrame)
	elseif(unit:match("(party)%d?$") == "party") then
		local id = unit:match("party(%d)")
		if(id) then
			HandleFrame("PartyMemberFrame" .. id)
		else
			for i = 1, 4 do
				HandleFrame(("PartyMemberFrame%d"):format(i))
			end
		end
	end
end