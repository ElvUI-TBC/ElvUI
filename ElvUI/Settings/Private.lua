local E, L, V, P, G = unpack(ElvUI)

--Locked Settings, These settings are stored for your character only regardless of profile options.

V["general"] = {
	["loot"] = true,
	["lootRoll"] = true,
	["normTex"] = "ElvUI Norm",
	["glossTex"] = "ElvUI Norm",
	["dmgfont"] = "Homespun",
	["namefont"] = "PT Sans Narrow",
	["chatBubbles"] = "backdrop",
	["chatBubbleFont"] = "PT Sans Narrow",
	["chatBubbleFontSize"] = 14,
	["chatBubbleFontOutline"] = "NONE",
	["chatBubbleName"] = false,
	["pixelPerfect"] = true,
	["replaceBlizzFonts"] = true,
	["minimap"] = {
		["enable"] = true,
		["hideCalendar"] = true,
		["zoomLevel"] = 0
	},
	["classCache"] = true,
	["classColorMentionsSpeech"] = true
}

V["bags"] = {
	["enable"] = true,
	["bagBar"] = false
}

V["nameplates"] = {
	["enable"] = true,
}

V["auras"] = {
	["enable"] = true,
	["disableBlizzard"] = true,
	["lbf"] = {
		enable = false,
		skin = "Blizzard"
	}
}

V["chat"] = {
	["enable"] = true
}

V["skins"] = {
	["ace3"] = {
		["enable"] = true,
	},
	["checkBoxSkin"] = true,
	["blizzard"] = {
		["enable"] = true,
		["alertframes"] = true,
		["arena"] = true,
		["arenaregistrar"] = true,
		["auctionhouse"] = true,
		["bags"] = true,
		["barber"] = true,
		["battlefield"] = true,
		["bgmap"] = true,
		["bgscore"] = true,
		["binding"] = true,
		["BlizzardOptions"] = true,
		["calendar"] = true,
		["character"] = true,
		["debug"] = true,
		["dressingroom"] = true,
		["friends"] = true,
		["gbank"] = true,
		["glyph"] = true,
		["gmchat"] = true,
		["gossip"] = true,
		["greeting"] = true,
		["guildregistrar"] = true,
		["help"] = true,
		["inspect"] = true,
		["lfg"] = true,
		["loot"] = true,
		["lootRoll"] = true,
		["macro"] = true,
		["mail"] = true,
		["merchant"] = true,
		["misc"] = true,
		["petition"] = true,
		["quest"] = true,
		["questtimer"] = true,
		["raid"] = true,
		["socket"] = true,
		["spellbook"] = true,
		["stable"] = true,
		["tabard"] = true,
		["talent"] = true,
		["taxi"] = true,
		["timemanager"] = true,
		["tooltip"] = true,
		["trade"] = true,
		["tradeskill"] = true,
		["trainer"] = true,
		["tutorial"] = true,
		["watchframe"] = true,
		["worldmap"] = true,
		["mirrorTimers"] = true
	}
}

V["tooltip"] = {
	["enable"] = true,
}

V["unitframe"] = {
	["enable"] = true,
	["disabledBlizzardFrames"] = {
		["player"] = true,
		["target"] = true,
		["party"] = true
	}
}

V["actionbar"] = {
	["enable"] = true,
	["lbf"] = {
		enable = false,
		skin = "Blizzard"
	}
}