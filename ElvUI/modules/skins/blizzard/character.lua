local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")


local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.character ~= true then return end

	CharacterFrame:StripTextures(true)
	CharacterFrame:CreateBackdrop("Transparent")
	CharacterFrame.backdrop:Point("TOPLEFT", 12, -12)
	CharacterFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:HandleCloseButton(CharacterFrameCloseButton);
	CharacterFrameCloseButton:ClearAllPoints()
	CharacterFrameCloseButton:Point("CENTER", CharacterFrame, "TOPRIGHT", -45, -25);

	for i = 1, 5 do
		local tab = _G["CharacterFrameTab"..i];
		S:HandleTab(tab);
	end
	
	PaperDollFrame:StripTextures()
	S:HandleDropDownBox(PlayerTitleDropDown)

	S:HandleRotateButton(CharacterModelFrameRotateLeftButton)
	CharacterModelFrameRotateLeftButton:ClearAllPoints()
	CharacterModelFrameRotateLeftButton:Point("TOPLEFT", 3, -3)
	S:HandleRotateButton(CharacterModelFrameRotateRightButton)
	CharacterModelFrameRotateRightButton:ClearAllPoints()
	CharacterModelFrameRotateRightButton:Point("TOPLEFT", CharacterModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)

	CharacterAttributesFrame:StripTextures()
	S:HandleDropDownBox(PlayerStatFrameLeftDropDown)
	S:HandleDropDownBox(PlayerStatFrameRightDropDown)

	CharacterResistanceFrame:CreateBackdrop("Default");
	CharacterResistanceFrame.backdrop:SetOutside(MagicResFrame1, nil, nil, MagicResFrame5);

	for i = 1, 5 do
		local frame = _G["MagicResFrame" .. i];
		frame:Size(24);
		frame = _G["PetMagicResFrame" .. i];
		frame:Size(24);
	end

	select(1, MagicResFrame1:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.25, 0.3203125);
	select(1, MagicResFrame2:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.0234375, 0.09375);
	select(1, MagicResFrame3:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.13671875, 0.20703125);
	select(1, MagicResFrame4:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.36328125, 0.43359375);
	select(1, MagicResFrame5:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.4765625, 0.546875);

	local slots = {"HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "ShirtSlot", "TabardSlot", "WristSlot",
		"HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot",
		"MainHandSlot", "SecondaryHandSlot", "RangedSlot", "AmmoSlot"
	};

	for _, slot in pairs(slots) do
		local icon = _G["Character"..slot.."IconTexture"];
		local cooldown = _G["Character"..slot.."Cooldown"];

		slot = _G["Character"..slot];
		slot:StripTextures();
		slot:StyleButton(false);
		slot:SetTemplate("Default", true, true);

		icon:SetTexCoord(unpack(E.TexCoords));
		icon:SetInside();

		slot:SetFrameLevel(PaperDollFrame:GetFrameLevel() + 2);

		if(cooldown) then
		--	E:RegisterCooldown(cooldown);
		end
	end

	local function ColorItemBorder()
		for _, slot in pairs(slots) do
			local target = _G["Character"..slot]
			local slotId, _, _ = GetInventorySlotInfo(slot)
			--local itemId = GetInventoryItemID("player", slotId)

			--if itemId then
				local rarity = GetInventoryItemQuality("player", slotId);
				if rarity and rarity > 1 then
					target:SetBackdropBorderColor(GetItemQualityColor(rarity))
				else
					target:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				end
			--else
			--	target:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			--end
		end
	end

	local CheckItemBorderColor = CreateFrame("Frame")
	CheckItemBorderColor:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	CheckItemBorderColor:SetScript("OnEvent", ColorItemBorder)
	CharacterFrame:HookScript("OnShow", ColorItemBorder)
	ColorItemBorder()
end

S:AddCallback("Character", LoadSkin)