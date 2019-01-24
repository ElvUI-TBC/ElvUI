local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule("Bags")

local _G = _G
local unpack = unpack
local tinsert = table.insert
local match, gsub = string.match, string.gsub

local CreateFrame = CreateFrame
local NUM_BAG_FRAMES = NUM_BAG_FRAMES
local KEYRING = KEYRING

local function OnEnter()
	if not E.db.bags.bagBar.mouseover then return end
	E:UIFrameFadeOut(ElvUIBags, 0.2, ElvUIBags:GetAlpha(), 1)
end

local function OnLeave()
	if not E.db.bags.bagBar.mouseover then return end
	E:UIFrameFadeOut(ElvUIBags, 0.2, ElvUIBags:GetAlpha(), 0)
end

function B:SkinBag(bag, keyring)
	local icon = _G[bag:GetName().."IconTexture"]

	bag.oldTex = keyring and "Interface\\ContainerFrame\\KeyRing-Bag-Icon" or icon:GetTexture()

	bag:StripTextures()
	bag:SetTemplate("Default", true)
	bag:StyleButton(true)

	icon:SetTexture(bag.oldTex)
	icon:SetInside()
	icon:SetTexCoord(unpack(E.TexCoords))
end

function B:SizeAndPositionBagBar()
	if not ElvUIBags then return end

	local buttonSpacing = E.db.bags.bagBar.spacing
	local backdropSpacing = E.db.bags.bagBar.backdropSpacing
	local bagBarSize = E.db.bags.bagBar.size
	local showBackdrop = E.db.bags.bagBar.showBackdrop
	local growthDirection = E.db.bags.bagBar.growthDirection
	local sortDirection = E.db.bags.bagBar.sortDirection
	local visibility = E.db.bags.bagBar.visibility

	if visibility and visibility:match("[\n\r]") then
		visibility = visibility:gsub("[\n\r]","")
	end

	RegisterStateDriver(ElvUIBags, "visibility", visibility)

	if E.db.bags.bagBar.mouseover then
		ElvUIBags:SetAlpha(0)
	else
		ElvUIBags:SetAlpha(1)
	end

	if showBackdrop then
		ElvUIBags.backdrop:Show()
	else
		ElvUIBags.backdrop:Hide()
	end

	ElvUIKeyRingButton:Size(bagBarSize)
	ElvUIKeyRingButton:ClearAllPoints()

	for i = 1, #ElvUIBags.buttons do
		local button = ElvUIBags.buttons[i]
		local prevButton = ElvUIBags.buttons[i - 1]

		button:Size(bagBarSize)
		button:ClearAllPoints()
		button:Show()

		if growthDirection == "HORIZONTAL" and sortDirection == "ASCENDING" then
			if i == 1 then
				button:Point("LEFT", ElvUIBags, "LEFT", (showBackdrop and (backdropSpacing + E.Border) or 0), 0)
			elseif prevButton then
				button:Point("LEFT", prevButton, "RIGHT", buttonSpacing, 0)
			end
		elseif growthDirection == "VERTICAL" and sortDirection == "ASCENDING" then
			if i == 1 then
				button:Point("TOP", ElvUIBags, "TOP", 0, -(showBackdrop and (backdropSpacing + E.Border) or 0))
			elseif prevButton then
				button:Point("TOP", prevButton, "BOTTOM", 0, -buttonSpacing)
			end
		elseif growthDirection == "HORIZONTAL" and sortDirection == "DESCENDING" then
			if i == 1 then
				button:Point("RIGHT", ElvUIBags, "RIGHT", -(showBackdrop and (backdropSpacing + E.Border) or 0), 0)
			elseif prevButton then
				button:Point("RIGHT", prevButton, "LEFT", -buttonSpacing, 0)
			end
		else
			if i == 1 then
				button:Point("BOTTOM", ElvUIBags, "BOTTOM", 0, (showBackdrop and (backdropSpacing + E.Border) or 0))
			elseif prevButton then
				button:Point("BOTTOM", prevButton, "TOP", 0, buttonSpacing)
			end
		end
	end

	if growthDirection == "HORIZONTAL" then
		ElvUIBags:Width(bagBarSize*(NUM_BAG_FRAMES + 2) + buttonSpacing*(NUM_BAG_FRAMES + 1) + ((showBackdrop and (E.Border + backdropSpacing) or E.Spacing)*2))
		ElvUIBags:Height(bagBarSize + ((showBackdrop and (E.Border + backdropSpacing) or E.Spacing)*2))
	else
		ElvUIBags:Height(bagBarSize*(NUM_BAG_FRAMES + 2) + buttonSpacing*(NUM_BAG_FRAMES + 1) + ((showBackdrop and (E.Border + backdropSpacing) or E.Spacing)*2))
		ElvUIBags:Width(bagBarSize + ((showBackdrop and (E.Border + backdropSpacing) or E.Spacing)*2))
	end
end

function B:LoadBagBar()
	if not E.private.bags.bagBar then return end

	local ElvUIBags = CreateFrame("Frame", "ElvUIBags", E.UIParent)
	ElvUIBags:Point("TOPRIGHT", RightChatPanel, "TOPLEFT", -4, 0)
	ElvUIBags.buttons = {}
	ElvUIBags:CreateBackdrop()
	ElvUIBags.backdrop:SetAllPoints()
	ElvUIBags:EnableMouse(true)
	ElvUIBags:SetScript("OnEnter", OnEnter)
	ElvUIBags:SetScript("OnLeave", OnLeave)

	MainMenuBarBackpackButton:SetParent(ElvUIBags)
	MainMenuBarBackpackButton.SetParent = E.dummy
	MainMenuBarBackpackButton:ClearAllPoints()
	MainMenuBarBackpackButtonCount:FontTemplate(nil, 10)
	MainMenuBarBackpackButtonCount:ClearAllPoints()
	MainMenuBarBackpackButtonCount:Point("BOTTOMRIGHT", MainMenuBarBackpackButton, "BOTTOMRIGHT", -1, 4)
	MainMenuBarBackpackButton:HookScript("OnEnter", OnEnter)
	MainMenuBarBackpackButton:HookScript("OnLeave", OnLeave)
	tinsert(ElvUIBags.buttons, MainMenuBarBackpackButton)
	self:SkinBag(MainMenuBarBackpackButton)

	for i = 0, NUM_BAG_FRAMES - 1 do
		local slot = _G["CharacterBag"..i.."Slot"]

		slot:SetParent(ElvUIBags)
		slot.SetParent = E.dummy
		slot:HookScript("OnEnter", OnEnter)
		slot:HookScript("OnLeave", OnLeave)

		self:SkinBag(slot)
		tinsert(ElvUIBags.buttons, slot)
	end

	local ElvUIKeyRing = CreateFrame("CheckButton", "ElvUIKeyRingButton", E.UIParent, "ItemButtonTemplate")
	ElvUIKeyRing:SetParent(ElvUIBags)
	ElvUIKeyRing.SetParent = E.dummy
	ElvUIKeyRing:RegisterForClicks("anyUp")
	self:SkinBag(ElvUIKeyRing, true)

	ElvUIKeyRing:SetScript("OnClick", function()
		if CursorHasItem() then
			PutKeyInKeyRing()
		else
			if E.private.bags.enable then
				if not ElvUI_ContainerFrame:IsShown() then
					ToggleFrame(ElvUI_ContainerFrame)
				end
				ToggleFrame(ElvUI_ContainerFrameKeyFrame)
			else
				ToggleKeyRing()
			end
		end
	end)
	ElvUIKeyRing:SetScript("OnReceiveDrag", function() if CursorHasItem() then PutKeyInKeyRing() end end)
	ElvUIKeyRing:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_LEFT") GameTooltip:SetText(KEYRING, 1, 1, 1) GameTooltip:AddLine() end)
	ElvUIKeyRing:SetScript("OnLeave", function() GameTooltip:Hide() end)
	ElvUIKeyRing:HookScript("OnEnter", OnEnter)
	ElvUIKeyRing:HookScript("OnLeave", OnLeave)

	tinsert(ElvUIBags.buttons, ElvUIKeyRing)

	self:SizeAndPositionBagBar()

	E:CreateMover(ElvUIBags, "BagsMover", L["Bags"], nil, nil, nil, nil, nil, "bags,general")
end