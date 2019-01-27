local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local pairs, unpack = pairs, unpack

local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local GetInventoryItemLink = GetInventoryItemLink
local GetItemQualityColor = GetItemQualityColor
local MAX_NUM_TALENTS = MAX_NUM_TALENTS

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.inspect then return end

	-- Inspect Frame
	local InspectFrame = _G["InspectFrame"]
	InspectFrame:StripTextures(true)
	InspectFrame:CreateBackdrop("Transparent")
	InspectFrame.backdrop:Point("TOPLEFT", 10, -12)
	InspectFrame.backdrop:Point("BOTTOMRIGHT", -31, 75)

	InspectPaperDollFrame:StripTextures()

	S:HandleRotateButton(InspectModelRotateLeftButton)
	InspectModelRotateLeftButton:Point("TOPLEFT", 3, -3)

	S:HandleRotateButton(InspectModelRotateRightButton)
	InspectModelRotateRightButton:Point("TOPLEFT", InspectModelRotateLeftButton, "TOPRIGHT", 3, 0)

	S:HandleCloseButton(InspectFrameCloseButton)

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

	for _, i in pairs(slots) do
		local item = _G["Inspect"..i]
		local icon = _G["Inspect"..i.."IconTexture"]

		item:StripTextures()
		item:SetTemplate("Default", true, true)
		item:StyleButton(false)

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

	-- Inspect Frame Tabs
	for i = 1, 3 do
		S:HandleTab(_G["InspectFrameTab"..i])
	end

	-- Inspect PvP Frame
	InspectPVPFrame:StripTextures()

	for i = 1, MAX_ARENA_TEAMS do
		_G["InspectPVPTeam"..i]:StripTextures()
		_G["InspectPVPTeam"..i]:CreateBackdrop("Transparent")
		_G["InspectPVPTeam"..i].backdrop:Point("TOPLEFT", 9, -6)
		_G["InspectPVPTeam"..i].backdrop:Point("BOTTOMRIGHT", -24, -5)
	end

	-- Inspect Talent Frame
	InspectTalentFrame:StripTextures()

	InspectTalentFrame.bg = CreateFrame("Frame", nil, InspectTalentFrame)
	InspectTalentFrame.bg:SetTemplate("Default")	
	InspectTalentFrame.bg:Point("TOPLEFT", InspectTalentFrameBackgroundTopLeft, "TOPLEFT", -1, 1)
	InspectTalentFrame.bg:Point("BOTTOMRIGHT", InspectTalentFrameBackgroundBottomRight, "BOTTOMRIGHT", -19, 51)

	InspectTalentFrameBackgroundTopLeft:SetParent(InspectTalentFrame.bg)
	InspectTalentFrameBackgroundTopRight:SetParent(InspectTalentFrame.bg)
	InspectTalentFrameBackgroundBottomLeft:SetParent(InspectTalentFrame.bg)
	InspectTalentFrameBackgroundBottomRight:SetParent(InspectTalentFrame.bg)

	InspectTalentFrameScrollFrame:StripTextures()
	InspectTalentFrameScrollFrame:SetHitRectInsets(0, 0, 1, 1)

	S:HandleScrollBar(InspectTalentFrameScrollFrameScrollBar)
	InspectTalentFrameScrollFrameScrollBar:Point("TOPLEFT", InspectTalentFrameScrollFrame, "TOPRIGHT", 8, -19)

	S:HandleCloseButton(InspectTalentFrameCloseButton)

	InspectTalentFrameCancelButton:Hide()

	InspectTalentFrameSpentPoints:Point("BOTTOMLEFT", 65, 84)

	for i = 1, 3 do
		local tab = _G["InspectTalentFrameTab"..i]

		tab:StripTextures()
		tab:CreateBackdrop("Default", true)
		tab.backdrop:Point("TOPLEFT", 3, -7)
		tab.backdrop:Point("BOTTOMRIGHT", 2, -1)
		tab:SetHitRectInsets(1, 0, 7, -1)

		tab:HookScript2("OnEnter", S.SetModifiedBackdrop)
		tab:HookScript2("OnLeave", S.SetOriginalBackdrop)

		tab:Width(101)
		tab.SetWidth = E.noop

		if i == 1 then
			tab:Point("TOPLEFT", 19, -40)
		end
	end

	for i = 1, MAX_NUM_TALENTS do
		local talent = _G["InspectTalentFrameTalent"..i]
		local icon = _G["InspectTalentFrameTalent"..i.."IconTexture"]
		local border = _G["InspectTalentFrameTalent"..i.."RankBorder"]
		local rank = _G["InspectTalentFrameTalent"..i.."Rank"]

		if talent then
			talent:StripTextures()
			talent:SetTemplate("Default")
			talent:StyleButton()

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer("ARTWORK")

			border:Point("CENTER", talent, "BOTTOMRIGHT", 3, -5)

			rank:SetFont(E.LSM:Fetch("font", E.db.general.font), 12, "OUTLINE")
		end
	end
end

S:AddCallbackForAddon("Blizzard_InspectUI", "Inspect", LoadSkin)