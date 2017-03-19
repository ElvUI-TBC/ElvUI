local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G

function S:LoadTalentSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true then return end

	PlayerTalentFrame:StripTextures()
	PlayerTalentFrame:CreateBackdrop("Transparent")
	PlayerTalentFrame.backdrop:Point("TOPLEFT", 13, -12)
	PlayerTalentFrame.backdrop:Point("BOTTOMRIGHT", -31, 76)

	PlayerTalentFramePortrait:Hide()

	S:HandleCloseButton(PlayerTalentFrameCloseButton)

	S:HandleButton(PlayerTalentFrameCancelButton)
	
	for i = 1, 5 do
		S:HandleTab(_G["PlayerTalentFrameTab" .. i])
	end

	PlayerTalentFrameScrollFrame:StripTextures();
	PlayerTalentFrameScrollFrame:CreateBackdrop("Default");
	S:HandleScrollBar(PlayerTalentFrameScrollFrameScrollBar);

	for i = 1, MAX_NUM_TALENTS do
		local talent = _G["PlayerTalentFrameTalent"..i];
		local icon = _G["PlayerTalentFrameTalent"..i.."IconTexture"];
		local rank = _G["PlayerTalentFrameTalent"..i.."Rank"];

		if (talent) then
			talent:StripTextures();
			talent:SetTemplate("Default");
			talent:StyleButton();

			icon:SetInside();
			icon:SetTexCoord(unpack(E.TexCoords));
			icon:SetDrawLayer("ARTWORK");

			rank:SetFont(E.LSM:Fetch("font", E.db["general"].font), 12, "OUTLINE");
		end
	end

	--PlayerTalentFrameScrollButtonOverlay
end

S:AddCallbackForAddon("Blizzard_TalentUI", "Talent", S.LoadTalentSkin)