local E, L, V, P, G = unpack(ElvUI)
local LSM = E.LSM

local SetCVar = SetCVar

local function SetFont(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	if not obj then return end

	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
	elseif r then obj:SetAlpha(r) end
end

function E:UpdateBlizzardFonts()
	local NORMAL			= self.media.normFont
	local COMBAT			= LSM:Fetch("font", self.private.general.dmgfont)
	local NUMBER			= self.media.normFont
	local NAMEFONT			= LSM:Fetch("font", self.private.general.namefont)
	local MONOCHROME		= ""

	CHAT_FONT_HEIGHTS = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

	UNIT_NAME_FONT		= NAMEFONT
	NAMEPLATE_FONT		= NAMEFONT
	DAMAGE_TEXT_FONT	= COMBAT

	if self.db.general.font == "Homespun" then
		MONOCHROME = "MONOCHROME"
	end

	if self.eyefinity then
		-- damage are huge on eyefinity, so we disable it
		InterfaceOptionsCombatTextPanelTargetDamage:Hide()
		InterfaceOptionsCombatTextPanelPeriodicDamage:Hide()
		InterfaceOptionsCombatTextPanelPetDamage:Hide()
		InterfaceOptionsCombatTextPanelHealing:Hide()
		SetCVar("CombatLogPeriodicSpells", 0)
		SetCVar("PetMeleeDamage", 0)
		SetCVar("CombatDamage", 0)
		SetCVar("CombatHealing", 0)

		-- set an invisible font for xp, honor kill, etc
		local INVISIBLE = [=[Interface\Addons\ElvUI\media\fonts\Invisible.ttf]=]
		COMBAT = INVISIBLE
	end

	if self.private.general.replaceBlizzFonts then
		SetFont(SystemFont,							NORMAL, self.db.general.fontSize)
		SetFont(GameFontNormal,						NORMAL, self.db.general.fontSize)
		SetFont(GameFontNormalSmall,				NORMAL, self.db.general.fontSize)
		SetFont(GameFontNormalLarge,				NORMAL, self.db.general.fontSize)
		SetFont(GameFontNormalHuge,					NORMAL, 25, MONOCHROME.."OUTLINE")
		SetFont(BossEmoteNormalHuge,				NORMAL, 25, MONOCHROME.."OUTLINE")
		SetFont(GameFontBlack,						NORMAL, self.db.general.fontSize)
		SetFont(NumberFontNormal,					NUMBER, self.db.general.fontSize, MONOCHROME.."OUTLINE")
		SetFont(NumberFontNormalSmall,				NUMBER, self.db.general.fontSize)
		SetFont(NumberFontNormalLarge,				NUMBER, self.db.general.fontSize)
		SetFont(NumberFontNormalHuge,				NUMBER, self.db.general.fontSize)
		SetFont(ChatFontNormal,						NORMAL, self.db.general.fontSize)
		SetFont(ChatFontSmall,						NORMAL, self.db.general.fontSize)
		SetFont(QuestTitleFont,						NORMAL, self.db.general.fontSize + 8)
		SetFont(QuestFont,							NORMAL, self.db.general.fontSize)
		SetFont(QuestFontHighlight,					NORMAL, self.db.general.fontSize)
		SetFont(ItemTextFontNormal,					NORMAL, self.db.general.fontSize)
		SetFont(ItemTextFontNormal,					NORMAL, self.db.general.fontSize)
		SetFont(MailTextFontNormal,					NORMAL, self.db.general.fontSize)
		SetFont(SubSpellFont,						NORMAL, self.db.general.fontSize)
		SetFont(DialogButtonNormalText,				NORMAL, self.db.general.fontSize)
		SetFont(ZoneTextFont,						NORMAL, 32, MONOCHROME.."OUTLINE")
		SetFont(SubZoneTextFont,					NORMAL, 24, MONOCHROME.."OUTLINE")
		SetFont(PVPInfoTextFont,					NORMAL, 22, MONOCHROME.."OUTLINE")
		SetFont(TextStatusBarText,					NORMAL, self.db.general.fontSize)
		SetFont(TextStatusBarTextSmall,				NORMAL, self.db.general.fontSize)
		SetFont(InvoiceTextFontNormal,				NORMAL, self.db.general.fontSize)
		SetFont(InvoiceTextFontSmall,				NORMAL, self.db.general.fontSize)
		SetFont(CombatTextFont,						COMBAT, 25, MONOCHROME.."OUTLINE")
	end
end
