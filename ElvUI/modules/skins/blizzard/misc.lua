local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select

local GetLocale = GetLocale
local UnitIsUnit = UnitIsUnit

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.misc ~= true then return end

	-- ESC/Menu Buttons
	GameMenuFrame:StripTextures()
	GameMenuFrame:CreateBackdrop("Transparent")

	GameMenuFrameHeader:ClearAllPoints()
	GameMenuFrameHeader:Point("TOP", GameMenuFrame, 0, 7)

	local BlizzardMenuButtons = {
		"Options",
		"UIOptions",
		"Keybindings",
		"Macros",
		"SoundOptions",
		"Logout",
		"Quit",
		"Continue",
	}

	for i = 1, #BlizzardMenuButtons do
		local ElvuiMenuButtons = _G["GameMenuButton"..BlizzardMenuButtons[i]]
		if ElvuiMenuButtons then
			S:HandleButton(ElvuiMenuButtons)
		end
	end

	if E.isMacClient then
		S:HandleButton(GameMenuButtonMacOptions)
	end

	-- Static Popups
	for i = 1, 4 do
		local staticPopup = _G["StaticPopup"..i]
		local itemFrame = _G["StaticPopup"..i.."ItemFrame"]
		local itemFrameBox = _G["StaticPopup"..i.."EditBox"]
		local itemFrameTexture = _G["StaticPopup"..i.."ItemFrameIconTexture"]
		local itemFrameNormal = _G["StaticPopup"..i.."ItemFrameNormalTexture"]
		local itemFrameName = _G["StaticPopup"..i.."ItemFrameNameFrame"]
		local closeButton = _G["StaticPopup"..i.."CloseButton"]
		local wideBox = _G["StaticPopup"..i.."WideEditBox"]

		staticPopup:SetTemplate("Transparent")

		S:HandleEditBox(itemFrameBox)
		itemFrameBox.backdrop:Point("TOPLEFT", -2, -4)
		itemFrameBox.backdrop:Point("BOTTOMRIGHT", 2, 4)

		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameGold"])
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameSilver"])
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameCopper"])

		for k = 1, itemFrameBox:GetNumRegions() do
			local region = select(k, itemFrameBox:GetRegions())
			if region and region:GetObjectType() == "Texture" then
				if region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Left" or region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Right" then
					region:Kill()
				end
			end
		end

		closeButton:StripTextures()
		S:HandleCloseButton(closeButton)

		itemFrame:GetNormalTexture():Kill()
		itemFrame:SetTemplate()
		itemFrame:StyleButton()

		hooksecurefunc("StaticPopup_Show", function(which, _, _, data)
			local info = StaticPopupDialogs[which]
			if not info then return nil end

			if info.hasItemFrame then
				if data and type(data) == "table" then
					itemFrame:SetBackdropBorderColor(unpack(data.color or {1, 1, 1, 1}))
				end
			end
		end)

		itemFrameTexture:SetTexCoord(unpack(E.TexCoords))
		itemFrameTexture:SetInside()

		itemFrameNormal:SetAlpha(0)
		itemFrameName:Kill()

		select(8, wideBox:GetRegions()):Hide()
		S:HandleEditBox(wideBox)
		wideBox:Height(22)

		for j = 1, 3 do
			S:HandleButton(_G["StaticPopup"..i.."Button"..j])
		end
	end

	-- Ready Check Frame
	ReadyCheckPortrait:Kill()

	ReadyCheckFrame:StripTextures()
	ReadyCheckFrame:SetTemplate("Transparent")
	ReadyCheckFrame:Size(290, 85)

	S:HandleButton(ReadyCheckFrameYesButton)
	ReadyCheckFrameYesButton:ClearAllPoints()
	ReadyCheckFrameYesButton:Point("LEFT", ReadyCheckFrame, 15, -20)
	ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)

	S:HandleButton(ReadyCheckFrameNoButton)
	ReadyCheckFrameNoButton:ClearAllPoints()
	ReadyCheckFrameNoButton:Point("RIGHT", ReadyCheckFrame, -15, -20)
	ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame)

	ReadyCheckFrameText:ClearAllPoints()
	ReadyCheckFrameText:SetPoint("TOP", 0, -15)
	ReadyCheckFrameText:SetParent(ReadyCheckFrame)
	ReadyCheckFrameText:SetTextColor(1, 1, 1)

	ReadyCheckFrame:HookScript("OnShow", function(self) -- bug fix, don't show it if initiator
		if UnitIsUnit("player", self.initiator) then
			self:Hide()
		end
	end)

	-- Coin PickUp Frame
	CoinPickupFrame:StripTextures()
	CoinPickupFrame:SetTemplate("Transparent")

	S:HandleButton(CoinPickupOkayButton)
	S:HandleButton(CoinPickupCancelButton)

	-- Zone Text Frame
	ZoneTextFrame:ClearAllPoints()
	ZoneTextFrame:Point("TOP", UIParent, 0, -128)

	-- Stack Split Frame
	StackSplitFrame:SetTemplate("Transparent")
	StackSplitFrame:GetRegions():Hide()
	StackSplitFrame:SetFrameStrata("DIALOG")

	StackSplitFrame.bg1 = CreateFrame("Frame", nil, StackSplitFrame)
	StackSplitFrame.bg1:SetTemplate("Transparent")
	StackSplitFrame.bg1:Point("TOPLEFT", 10, -15)
	StackSplitFrame.bg1:Point("BOTTOMRIGHT", -10, 55)
	StackSplitFrame.bg1:SetFrameLevel(StackSplitFrame.bg1:GetFrameLevel() - 1)

	S:HandleButton(StackSplitOkayButton)
	S:HandleButton(StackSplitCancelButton)

	-- Opacity Frame
	OpacityFrame:StripTextures()
	OpacityFrame:SetTemplate("Transparent")

	S:HandleSliderFrame(OpacityFrameSlider)

	-- Declension Frame
	if GetLocale() == "ruRU" then
		DeclensionFrame:SetTemplate("Transparent")

		S:HandleNextPrevButton(DeclensionFrameSetPrev)
		S:HandleNextPrevButton(DeclensionFrameSetNext)
		S:HandleButton(DeclensionFrameOkayButton)
		S:HandleButton(DeclensionFrameCancelButton)

		for i = 1, RUSSIAN_DECLENSION_PATTERNS do
			local editBox = _G["DeclensionFrameDeclension"..i.."Edit"]
			if editBox then
				editBox:StripTextures()
				S:HandleEditBox(editBox)
			end
		end
	end

	-- Rating Menu Frame
	if GetLocale() == "koKR" then
		S:HandleButton(GameMenuButtonRatings)

		RatingMenuFrame:SetTemplate("Transparent")
		RatingMenuFrameHeader:Kill()
		S:HandleButton(RatingMenuButtonOkay)
	end

	-- Channel Pullout Frame
	ChannelPullout:SetTemplate("Transparent")

	ChannelPulloutBackground:Kill()

	S:HandleTab(ChannelPulloutTab)
	ChannelPulloutTab:Size(107, 26)
	ChannelPulloutTabText:Point("LEFT", ChannelPulloutTabLeft, "RIGHT", 0, 4)

	S:HandleCloseButton(ChannelPulloutCloseButton)
	ChannelPulloutCloseButton:Size(32)

	-- Ticket Frame
	local ticketBG = select(2, TicketStatusFrame:GetChildren())
	ticketBG:SetTemplate("Transparent")
	ticketBG:HookScript2("OnEnter", S.SetModifiedBackdrop)
	ticketBG:HookScript2("OnLeave", S.SetOriginalBackdrop)

	TicketStatusFrameButton:StripTextures()
	TicketStatusFrameButton:SetTemplate()
	TicketStatusFrameButton:Point("TOPRIGHT", -3, -5)

	TicketStatusFrameButton.tex = TicketStatusFrameButton:CreateTexture(nil, "ARTWORK")
	TicketStatusFrameButton.tex:SetTexture("Interface\\Icons\\INV_Scroll_09")
	TicketStatusFrameButton.tex:SetTexCoord(unpack(E.TexCoords))
	TicketStatusFrameButton.tex:SetInside()

	-- Quest Timers
	QuestTimerFrame:StripTextures()

	QuestTimerHeader:Point("TOP", 0, 8)

	-- Dropdown Menu
	hooksecurefunc("UIDropDownMenu_Initialize", function()
		for i = 1, UIDROPDOWNMENU_MAXLEVELS do
			local dropBackdrop = _G["DropDownList"..i.."Backdrop"]
			local dropMenuBackdrop = _G["DropDownList"..i.."MenuBackdrop"]

			dropBackdrop:SetTemplate("Transparent")
			dropMenuBackdrop:SetTemplate("Transparent")

			for j = 1, UIDROPDOWNMENU_MAXBUTTONS do
				local button = _G["DropDownList"..i.."Button"..j]
				local highlight = _G["DropDownList"..i.."Button"..j.."Highlight"]
				local normalText = _G["DropDownList"..i.."Button"..j.."NormalText"]
				local colorSwatch = _G["DropDownList"..i.."Button"..j.."ColorSwatch"]

				button:SetFrameLevel(dropBackdrop:GetFrameLevel() + 1)
				highlight:SetTexture(1, 1, 1, 0.3)
				normalText:SetFont(E.media.normFont, E.db.general.fontSize)
				S:HandleColorSwatch(colorSwatch, 14)
			end
		end
	end)

	-- Chat Menu
	local ChatMenus = {
		"ChatMenu",
		"EmoteMenu",
		"LanguageMenu",
		"VoiceMacroMenu",
	}

	for i = 1, #ChatMenus do
		if _G[ChatMenus[i]] == _G["ChatMenu"] then
			_G[ChatMenus[i]]:HookScript("OnShow", function(self)
				self:SetTemplate("Transparent")
				self:SetBackdropColor(unpack(E.media.backdropfadecolor))
				self:ClearAllPoints()
				self:Point("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 30)
			end)
		else
			_G[ChatMenus[i]]:HookScript("OnShow", function(self)
				self:SetTemplate("Transparent")
				self:SetBackdropColor(unpack(E.media.backdropfadecolor))
			end)
		end
	end

	for i = 1, 32 do
		S:HandleButtonHighlight(_G["ChatMenuButton"..i])
		S:HandleButtonHighlight(_G["EmoteMenuButton"..i])
		S:HandleButtonHighlight(_G["LanguageMenuButton"..i])
		S:HandleButtonHighlight(_G["VoiceMacroMenuButton"..i])
	end
end

S:AddCallback("SkinMisc", LoadSkin)