local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true then return end

	local PlayerTalentFrame = _G["PlayerTalentFrame"]
	PlayerTalentFrame:StripTextures()
	PlayerTalentFrame:CreateBackdrop("Transparent")
	PlayerTalentFrame.backdrop:Point("TOPLEFT", 13, -12)
	PlayerTalentFrame.backdrop:Point("BOTTOMRIGHT", -31, 76)

	PlayerTalentFramePortrait:Hide()

	S:HandleCloseButton(PlayerTalentFrameCloseButton)

	PlayerTalentFrameCancelButton:Kill()

	for i = 1, 5 do
		S:HandleTab(_G["PlayerTalentFrameTab"..i])
	end

	PlayerTalentFrameScrollFrame:StripTextures()
	PlayerTalentFrameScrollFrame:SetHitRectInsets(0, 0, 1, 1)

	PlayerTalentFrame.bg = CreateFrame("Frame", nil, PlayerTalentFrame)
	PlayerTalentFrame.bg:SetTemplate("Default")	
	PlayerTalentFrame.bg:Point("TOPLEFT", PlayerTalentFrameBackgroundTopLeft, "TOPLEFT", -1, 1)
	PlayerTalentFrame.bg:Point("BOTTOMRIGHT", PlayerTalentFrameBackgroundBottomRight, "BOTTOMRIGHT", -19, 51)

	PlayerTalentFrameBackgroundTopLeft:SetParent(PlayerTalentFrame.bg)
	PlayerTalentFrameBackgroundTopRight:SetParent(PlayerTalentFrame.bg)
	PlayerTalentFrameBackgroundBottomLeft:SetParent(PlayerTalentFrame.bg)
	PlayerTalentFrameBackgroundBottomRight:SetParent(PlayerTalentFrame.bg)

	S:HandleScrollBar(PlayerTalentFrameScrollFrameScrollBar)
	PlayerTalentFrameScrollFrameScrollBar:Point("TOPLEFT", PlayerTalentFrameScrollFrame, "TOPRIGHT", 10, -16)

	PlayerTalentFrameScrollButtonOverlay:Hide()

	PlayerTalentFrameSpentPoints:Point("TOP", 0, -42)
	PlayerTalentFrameTalentPointsText:Point("BOTTOMRIGHT", PlayerTalentFrame, "BOTTOMLEFT", 220, 84)

	for i = 1, MAX_NUM_TALENTS do
		local talent = _G["PlayerTalentFrameTalent"..i]
		local icon = _G["PlayerTalentFrameTalent"..i.."IconTexture"]
		local border = _G["PlayerTalentFrameTalent"..i.."RankBorder"]
		local rank = _G["PlayerTalentFrameTalent"..i.."Rank"]

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

S:AddCallbackForAddon("Blizzard_TalentUI", "Talent", LoadSkin)