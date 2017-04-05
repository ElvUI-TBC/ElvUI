local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

function S:LoadInspectSkin()
	if(not E.private.skins.blizzard.enable or not E.private.skins.blizzard.inspect) then return end

	InspectFrame:StripTextures(true)
	InspectFrame:CreateBackdrop("Transparent")
	InspectFrame.backdrop:Point("TOPLEFT", 10, -12)
	InspectFrame.backdrop:Point("BOTTOMRIGHT", -31, 75)

	S:HandleCloseButton(InspectFrameCloseButton)

	for i = 1, 3 do
		S:HandleTab(_G["InspectFrameTab"..i])
	end

	InspectPaperDollFrame:StripTextures()

	local slots = {
		"HeadSlot",
		"NeckSlot",
		"ShoulderSlot",
		"BackSlot",
		"ChestSlot",
		"ShirtSlot",
		"TabardSlot",
		"WristSlot",
		"HandsSlot",
		"WaistSlot",
		"LegsSlot",
		"FeetSlot",
		"Finger0Slot",
		"Finger1Slot",
		"Trinket0Slot",
		"Trinket1Slot",
		"MainHandSlot",
		"SecondaryHandSlot",
		"RangedSlot"
	}

	for _, slot in pairs(slots) do
		local icon = _G["Inspect"..slot.."IconTexture"]
		local cooldown = _G["Inspect"..slot.."Cooldown"]

		slot = _G["Inspect"..slot]
		slot:StripTextures()
		slot:StyleButton(false)
		slot:SetTemplate("Default", true, true)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		if(cooldown) then
			E:RegisterCooldown(cooldown)
		end
	end

	local function ColorItemBorder(_, event, unit)
		if event == "UNIT_INVENTORY_CHANGED" and unit ~= "target" then return end

		for _, slot in pairs(slots) do
			local target = _G["Inspect"..slot]
			local slotId, _, _ = GetInventorySlotInfo(slot)
			local itemId = GetInventoryItemTexture("player", slotId)
			if itemId then
				local rarity = GetInventoryItemQuality("player", slotId)
				if rarity and rarity > 1 then
					target:SetBackdropBorderColor(GetItemQualityColor(rarity))
				else
					target:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			else
				target:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end

	local checkItemBorderColor = CreateFrame("Frame")
	checkItemBorderColor:RegisterEvent("UNIT_INVENTORY_CHANGED")
	checkItemBorderColor:SetScript("OnEvent", ColorItemBorder)
	InspectFrame:HookScript("OnShow", ColorItemBorder)
	ColorItemBorder()

	S:HandleRotateButton(InspectModelRotateLeftButton)
	S:HandleRotateButton(InspectModelRotateRightButton)

	InspectPVPFrame:StripTextures()

	for i = 1, MAX_ARENA_TEAMS do
		_G["InspectPVPTeam"..i]:StripTextures()
		_G["InspectPVPTeam"..i]:CreateBackdrop("Transparent")
		_G["InspectPVPTeam"..i].backdrop:Point("TOPLEFT", 9, -6)
		_G["InspectPVPTeam"..i].backdrop:Point("BOTTOMRIGHT", -24, -5)
	--	_G["InspectPVPTeam"..i.."StandardBar"]:Kill()
	end

	InspectTalentFrame:StripTextures()

	S:HandleCloseButton(InspectTalentFrameCloseButton)
	S:HandleButton(InspectTalentFrameCancelButton)

	InspectTalentFrameTab1:StripTextures()
	InspectTalentFrameTab2:StripTextures()
	InspectTalentFrameTab3:StripTextures()

	for i = 1, MAX_NUM_TALENTS do
		local talent = _G["InspectTalentFrameTalent"..i]
		local icon = _G["InspectTalentFrameTalent"..i.."IconTexture"]
		local rank = _G["InspectTalentFrameTalent"..i.."Rank"]

		if talent then
			talent:StripTextures()
			talent:SetTemplate("Default")
			talent:StyleButton()

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer("ARTWORK")

			rank:SetFont(E.LSM:Fetch("font", E.db["general"].font), 12, "OUTLINE")
		end
	end

	InspectTalentFrameScrollFrame:StripTextures()
	InspectTalentFrameScrollFrame:CreateBackdrop("Transparent")
	InspectTalentFrameScrollFrame.backdrop:Point("TOPLEFT", -1, 1)
	InspectTalentFrameScrollFrame.backdrop:Point("BOTTOMRIGHT", 5, -4)
	S:HandleScrollBar(InspectTalentFrameScrollFrameScrollBar)
	InspectTalentFrameScrollFrameScrollBar:Point("TOPLEFT", InspectTalentFrameScrollFrame, "TOPRIGHT", 8, -19)
<<<<<<< HEAD
=======

	-- InspectTalentFramePointsBar:StripTextures()
>>>>>>> master
end

S:AddCallbackForAddon("Blizzard_InspectUI", "Inspect", S.LoadInspectSkin)