local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.inspect then return end

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
		local slot = _G["Inspect"..slot]

		slot:StripTextures()
		slot:StyleButton(false)
		slot:SetTemplate("Default", true, true)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
	end

	hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
		if button.hasItem then
			local itemID = GetInventoryItemLink(InspectFrame.unit, button:GetID())
			if itemID then
				local _, _, quality = GetItemInfo(itemID)
				if not quality then
					E:Delay(0.1, function()
						if InspectFrame.unit then
							InspectPaperDollItemSlotButton_Update(button)
						end
					end)
					return
				elseif quality then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
					return
				end
			end
		end
		button:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end)

	S:HandleRotateButton(InspectModelRotateLeftButton)
	InspectModelRotateLeftButton:Point("TOPLEFT", 3, -3)

	S:HandleRotateButton(InspectModelRotateRightButton)
	InspectModelRotateRightButton:Point("TOPLEFT", InspectModelRotateLeftButton, "TOPRIGHT", 3, 0)

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

	InspectTalentFrameCancelButton:Hide()

	InspectTalentFrameSpentPoints:Point("BOTTOMLEFT", 65, 84)

	for i = 1, 3 do
		local headerTab = _G["InspectTalentFrameTab"..i]

		headerTab:StripTextures()
		headerTab:CreateBackdrop("Default", true)
		headerTab.backdrop:Point("TOPLEFT", 3, -7)
		headerTab.backdrop:Point("BOTTOMRIGHT", 2, -1)
		headerTab:SetHitRectInsets(1, 0, 7, -1)

		headerTab:HookScript2("OnEnter", S.SetModifiedBackdrop)
		headerTab:HookScript2("OnLeave", S.SetOriginalBackdrop)

		headerTab:Width(101)
		headerTab.SetWidth = E.noop

		if i == 1 then
			headerTab:Point("TOPLEFT", 19, -40)
		end
	end

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
	InspectTalentFrameScrollFrame.backdrop:Point("TOPLEFT", -1, 2)
	InspectTalentFrameScrollFrame.backdrop:Point("BOTTOMRIGHT", 5, -2)

	S:HandleScrollBar(InspectTalentFrameScrollFrameScrollBar)
	InspectTalentFrameScrollFrameScrollBar:Point("TOPLEFT", InspectTalentFrameScrollFrame, "TOPRIGHT", 8, -19)
end

S:AddCallbackForAddon("Blizzard_InspectUI", "Inspect", LoadSkin)