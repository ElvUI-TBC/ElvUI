local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local split = string.split

local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bgscore ~= true then return end

	WorldStateScoreFrame:StripTextures()
	WorldStateScoreFrame:CreateBackdrop("Transparent")
	WorldStateScoreFrame.backdrop:Point("TOPLEFT", 10, -15)
	WorldStateScoreFrame.backdrop:Point("BOTTOMRIGHT", -113, 67)

	WorldStateScoreScrollFrame:StripTextures()

	S:HandleScrollBar(WorldStateScoreScrollFrameScrollBar)

	local tab
	for i = 1, 3 do
		tab = _G["WorldStateScoreFrameTab"..i]

		S:HandleTab(tab)

		_G["WorldStateScoreFrameTab"..i.."Text"]:Point("CENTER", 0, 2)
	end

	S:HandleButton(WorldStateScoreFrameLeaveButton)
	S:HandleCloseButton(WorldStateScoreFrameCloseButton)

	WorldStateScoreFrameKB:StyleButton()
	WorldStateScoreFrameDeaths:StyleButton()
	WorldStateScoreFrameHK:StyleButton()
	WorldStateScoreFrameDamageDone:StyleButton()
	WorldStateScoreFrameHealingDone:StyleButton()
	WorldStateScoreFrameHonorGained:StyleButton()
	WorldStateScoreFrameName:StyleButton()
	WorldStateScoreFrameClass:StyleButton()
	WorldStateScoreFrameTeam:StyleButton()

	for i = 1, 5 do
		_G["WorldStateScoreColumn"..i]:StyleButton()
	end

	hooksecurefunc("WorldStateScoreFrame_Update", function()
		local inArena = IsActiveBattlefieldArena()
		local offset = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame)
		local _, index, name, faction, classToken, classTextColor
		local nameText, realmText, color

		for i = 1, MAX_WORLDSTATE_SCORE_BUTTONS do
			index = offset + i
			name, _, _, _, _, faction, _, _, _, classToken = GetBattlefieldScore(index)

			if name then
				nameText, realmText = split("-", name, 2)

				if name == E.myname then
					nameText = "> "..nameText.." <"
				end

				if realmText then
					if inArena then
						if faction == 1 then
							color = "|cffffd100"
						else
							color = "|cff19ff19"
						end
					else
						if faction == 1 then
							color = "|cff00adf0"
						else
							color = "|cffff1919"
						end
					end

					realmText = color..realmText.."|r"
					nameText = nameText.."|cffffffff - |r"..realmText
				end

				classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classToken] or RAID_CLASS_COLORS[classToken]

				_G["WorldStateScoreButton"..i.."NameText"]:SetText(nameText)
				_G["WorldStateScoreButton"..i.."NameText"]:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
			end
		end
	end)
end

S:AddCallback("WorldStateScore", LoadSkin)