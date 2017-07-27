local E, L, V, P, G = unpack(ElvUI)

local print, unpack = print, unpack

local GetSpellInfo = GetSpellInfo

local function SpellName(id)
	local name = GetSpellInfo(id)
	if not name then
		print("|cff1784d1ElvUI:|r SpellID is not valid: "..id..". Please check for an updated version, if none exists report to ElvUI author.")
		return "Impale"
	else
		return name
	end
end

local function Defaults(priorityOverride)
	return {["enable"] = true, ["priority"] = priorityOverride or 0, ["stackThreshold"] = 0}
end

G.unitframe.aurafilters = {}

G.unitframe.aurafilters["CCDebuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Druid
		[99] = Defaults(), -- Demoralizing Roar
		[339] = Defaults(), -- Entangling Roots
		[2637] = Defaults(), -- Hibernate
		[5211] = Defaults(), -- Bash
		[9005] = Defaults(), -- Pounce
		[22570] = Defaults(), -- Maim
		[33786] = Defaults(), -- Cyclone
		[45334] = Defaults(), -- Feral Charge Effect
	-- Hunter
		[1513] = Defaults(), -- Scare Beast
		[3355] = Defaults(), -- Freezing Trap Effect
		[19386] = Defaults(), -- Wyvern Sting
		[19503] = Defaults(), -- Scatter Shot
		[24394] = Defaults(), -- Intimidation
		[34490] = Defaults(), -- Silencing Shot
	-- Mage
		[118] = Defaults(), -- Polymorph
		[122] = Defaults(), -- Frost Nova
		[18469] = Defaults(), -- Counterspell - Silenced
		[31589] = Defaults(), -- Slow
		[31661] = Defaults(), -- Dragon's Breath
		[33395] = Defaults(), -- Freeze
	-- Paladin
		[853] = Defaults(), -- Hammer of Justice
		[10326] = Defaults(), -- Turn Evil
		[20066] = Defaults(), -- Repentance
		[31935] = Defaults(), -- Avenger's Shield
	-- Priest
		[605] = Defaults(), -- Mind Control
		[8122] = Defaults(), -- Psychic Scream
		[9484] = Defaults(), -- Shackle Undead
		[15487] = Defaults(), -- Silence
	-- Rogue
		[408] = Defaults(), -- Kidney Shot
		[1330] = Defaults(), -- Garrote - Silence
		[1776] = Defaults(), -- Gouge
		[1833] = Defaults(), -- Cheap Shot
		[2094] = Defaults(), -- Blind
		[6770] = Defaults(), -- Sap
		[18425] = Defaults(), -- Kick - Silenced
	-- Shaman
		[3600] = Defaults(), -- Earthbind
		[8056] = Defaults(), -- Frost Shock
		[39796] = Defaults(), -- Stoneclaw Stun
	-- Warlock
		[710] = Defaults(), -- Banish
		[5782] = Defaults(), -- Fear
		[6358] = Defaults(), -- Seduction
		[6789] = Defaults(), -- Death Coil
		[17928] = Defaults(), -- Howl of Terror
		[24259] = Defaults(), -- Spell Lock
		[30283] = Defaults(), -- Shadowfury
	-- Warrior
		[676] = Defaults(), -- Disarm
		[7922] = Defaults(), -- Charge Stun
		[18498] = Defaults(), -- Shield Bash - Silenced
		[20511] = Defaults(), -- Intimidating Shout
	-- Racial
		[25046] = Defaults(), -- Arcane Torrent
		[20549] = Defaults(), -- War Stomp
	}
}

G.unitframe.aurafilters["TurtleBuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Mage
		[45438] = Defaults(5), -- Ice Block
	-- Priest
		[33206] = Defaults(3), -- Pain Suppression
	-- Warlock

	-- Druid
		[22812] = Defaults(2), -- Barkskin
--		[34496] = Defaults(), -- Survival Instincts
	-- Hunter
		[19263] = Defaults(5), -- Deterrence
	-- Rogue
		[5277] = Defaults(5), -- Evasion
		[31224] = Defaults(), -- Cloak of Shadows
		[45182] = Defaults(), -- Cheating Death
	-- Shaman
		[30823] = Defaults(), -- Shamanistic Rage
	-- Paladin
		[498] = Defaults(2), -- Divine Protection
		[642] = Defaults(5), -- Divine Shield
		[1022] = Defaults(5), -- Blessing of Protection
		[6940] = Defaults(), -- Blessing of Sacrifice
		[31821] = Defaults(3), -- Aura Mastery
	-- Warrior
		[871] = Defaults(3), -- Shield Wall
	}
}

G.unitframe.aurafilters["PlayerBuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Mage
		[12042] = Defaults(), -- Arcane Power
		[12051] = Defaults(), -- Evocation
		[12472] = Defaults(), -- Icy Veins
		[32612] = Defaults(), -- Invisibility
		[45438] = Defaults(), -- Ice Block
	-- Priest
		[6346] = Defaults(), -- Fear Ward
		[10060] = Defaults(), -- Power Infusion
		[20711] = Defaults(), -- Spirit of Redemption
		[33206] = Defaults(), -- Pain Suppression
	-- Warlock

	-- Druid
		[1850] = Defaults(), -- Dash
		[22812] = Defaults(), -- Barkskin
	-- Hunter
		[3045] = Defaults(), -- Rapid Fire
		[5384] = Defaults(), -- Feign Death
		[19263] = Defaults(), -- Deterrence
	-- Rogue
		[2983] = Defaults(), -- Sprint
		[5277] = Defaults(), -- Evasion
		[11327] = Defaults(), -- Vanish
		[13750] = Defaults(), -- Adrenaline Rush
		[31224] = Defaults(), -- Cloak of Shadows
		[45182] = Defaults(), -- Cheating Death
	-- Shaman
		[2825] = Defaults(), -- Bloodlust
		[8178] = Defaults(), -- Grounding Totem Effect
		[16166] = Defaults(), -- Elemental Mastery
		[16188] = Defaults(), -- Nature's Swiftness
		[16191] = Defaults(), -- Mana Tide
		[30823] = Defaults(), -- Shamanistic Rage
		[32182] = Defaults(), -- Heroism
	-- Paladin
		[498] = Defaults(), -- Divine Protection
		[1022] = Defaults(), -- Blessing of Protection
		[1044] = Defaults(), -- Blessing of Freedom
		[6940] = Defaults(), -- Blessing of Sacrifice
		[31821] = Defaults(), -- Aura Mastery
		[31842] = Defaults(), -- Divine Illumination
		[31850] = Defaults(), -- Ardent Defender
		[31884] = Defaults(), -- Avenging Wrath
	-- Warrior
		[871] = Defaults(), -- Shield Wall
		[1719] = Defaults(), -- Recklessness
		[3411] = Defaults(), -- Intervene
		[12292] = Defaults(), -- Death Wish
		[12975] = Defaults(), -- Last Stand
		[18499] = Defaults(), -- Berserker Rage
		[23920] = Defaults(), -- Spell Reflection
	-- Racial
		[20594] = Defaults(), -- Stoneform
		[28880] = Defaults(), -- Gift of the Naaru
		[20572] = Defaults(), -- Blood Fury
		[26297] = Defaults() -- Berserking
	}
}

G.unitframe.aurafilters["Blacklist"] = {
	["type"] = "Blacklist",
	["spells"] = {
		[6788] = Defaults(), -- Weakened Soul
		[8326] = Defaults(), -- Ghost
		[15007] = Defaults(), -- Resurrection Sickness
		[23445] = Defaults(), -- Evil Twin
		[24755] = Defaults(), -- Tricked or Treated
		[25771] = Defaults(), -- Forbearance
		[26013] = Defaults(), -- Deserter
		[36032] = Defaults(), -- Arcane Blast
		[36893] = Defaults(), -- Transporter Malfunction
		[36900] = Defaults(), -- Soul Split: Evil!
		[36901] = Defaults(), -- Soul Split: Good
		[41425] = Defaults(), -- Hypothermia
	}
}

G.unitframe.aurafilters["Whitelist"] = {
	["type"] = "Whitelist",
	["spells"] = {
		[1022] = Defaults(), -- Blessing of Protection
		[1490] = Defaults(), -- Curse of the Elements
		[2825] = Defaults(), -- Bloodlust
		[12051] = Defaults(), -- Evocation
		[18708] = Defaults(), -- Fel Domination
		[29166] = Defaults(), -- Innervate
		[31821] = Defaults(), -- Aura Mastery
		[32182] = Defaults(), -- Heroism
	-- Turtling abilities
		[871] = Defaults(), -- Shield Wall
		[19263] = Defaults(), -- Deterrence
		[22812] = Defaults(), -- Barkskin
		[31224] = Defaults(), -- Cloak of Shadows
		[33206] = Defaults(), -- Pain Suppression
	-- Immunities
		[642] = Defaults(), -- Divine Shield
		[45438] = Defaults(), -- Ice Block
	-- Offensive
		[12292] = Defaults(), -- Death Wish
		[31884] = Defaults(), -- Avenging Wrath
		[34471] = Defaults() -- The Beast Within
	}
}

G.unitframe.aurafilters["RaidDebuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Karazhan
		-- Moroes
		[37066] = Defaults(), -- Garrote

		-- Maiden of Virtue
		[29522] = Defaults(), -- Holy Fire
		[29511] = Defaults(), -- Repentance

		-- The Opera Event: The Big Bad Wolf
		[30753] = Defaults(), -- Red Riding Hood

		-- Terestian Illhoof
		[30115] = Defaults(), -- Sacrifice

		-- Prince Malchezaar
		[30843] = Defaults(), -- Enfeeble

	-- Zul'Aman
		-- Nalorakk
		[42389] = Defaults(), -- Mangle

		-- Akil'zon
		[43657] = Defaults(), -- Electrical Storm
		[43622] = Defaults(), -- Static Disruption

		-- Jan'alai
		[43299] = Defaults(), -- Flame Buffet

		-- Halazzi
		[43303] = Defaults(), -- Flame Shock

		-- Hexxlord Jin'Zakk
		[43613] = Defaults(), -- Cold Stare
		[43501] = Defaults(), -- Siphon Soul

		-- Zul'jin
		[43093] = Defaults(), -- Grievous Throw
		[43095] = Defaults(), -- Creeping Paralysis
		[43150] = Defaults(), -- Claw Rage

	-- Serpentshrine Cavern
		-- Trash
		[39042] = Defaults(), -- Rampant Infection
		[39044] = Defaults(), -- Serpentshrine Parasite

		-- Hydross the Unstable
		[38235] = Defaults(), -- Water Tomb
		[38246] = Defaults(), -- Vile Sludge

		-- Leotheras the Blind
		[37676] = Defaults(), -- Insidious Whisper
		[37641] = Defaults(), -- Whirlwind
		[37749] = Defaults(), -- Consuming Madness

		-- Morogrim Tidewalker
		[37850] = Defaults(), -- Watery Grave

		-- Lady Vashj
		[38280] = Defaults(), -- Static Charge

	-- The Eye (Tempest Keep)
		-- Trash
		[37123] = Defaults(), -- Saw Blade
		[37120] = Defaults(), -- Fragmentation Bomb
		[37118] = Defaults(), -- Shell Shock

		-- High Astromancer Solarian
		[42783] = Defaults(), -- Wrath of the Astromancer

		-- Kael'thas Sunstrider
		[36798] = Defaults(), -- Mind Control
		[37027] = Defaults(), -- Remote Toy

	-- Hyjal Summit
		-- Rage Winterchill
		[31249] = Defaults(), -- Icebolt

		-- Anetheron
		[31306] = Defaults(), -- Carrion Swarm
		[31298] = Defaults(), -- Sleep

		-- Azgalor
		[31347] = Defaults(), -- Doom
		[31341] = Defaults(), -- Unquenchable Flames
		[31344] = Defaults(), -- Howl of Azgalor

		-- Archimonde
		[31944] = Defaults(), -- Doomfire
		[31972] = Defaults(), -- Grip of the Legion

	-- Black Temple
		-- Trash
		[34654] = Defaults(), -- Blind
		[39674] = Defaults(), -- Banish
		[41150] = Defaults(), -- Fear
		[41168] = Defaults(), -- Sonic Strike

		-- High Warlord Naj'entus
		[39837] = Defaults(), -- Impaling Spine

		-- Teron Gorefiend
		[40239] = Defaults(), -- Incinerate
		[40251] = Defaults(), -- Shadow of Death

		-- Gurtogg Bloodboil
		[40604] = Defaults(), -- Fel Rage
		[40481] = Defaults(), -- Acidic Wound
		[40508] = Defaults(), -- Fel-Acid Breath
		[42005] = Defaults(), -- Bloodboil

		-- Reliquary of Souls
		[41303] = Defaults(), -- Soul Drain
		[41410] = Defaults(), -- Deaden
		[41376] = Defaults(), -- Spite

		-- Mother Shahraz
		[40860] = Defaults(), -- Vile Beam
		[41001] = Defaults(), -- Fatal Attraction

		-- The Illidari Council
		-- Lady Malande
		[41472] = Defaults(), -- Divine Wrath
		-- Veras Darkshadow
		[41485] = Defaults(), -- Deadly Poison

		-- Illidan Stormrage
		[41914] = Defaults(1), -- Parasitic Shadowfiend
		[40585] = Defaults(1), -- Dark Barrage
--		[41032] = Defaults(), -- Shear
		[40932] = Defaults(1), -- Agonizing Flames

	-- Sunwell Plateau
		-- Trash
		[46561] = Defaults(), -- Fear
		[46562] = Defaults(), -- Mind Flay
		[46266] = Defaults(), -- Burn Mana
		[46557] = Defaults(), -- Slaying Shot
		[46560] = Defaults(), -- Shadow Word: Pain
		[46543] = Defaults(), -- Ignite Mana
		[46427] = Defaults(), -- Domination

		-- Kalecgos
		[45032] = Defaults(), -- Curse of Boundless Agony
		[45018] = Defaults(), -- Arcane Buffet

		-- Brutallus
		[46394] = Defaults(), -- Burn
		[45150] = Defaults(), -- Meteor Slash

		-- Felmyst
		[45855] = Defaults(), -- Gas Nova
		[45662] = Defaults(), -- Encapsulate
		[45402] = Defaults(), -- Demonic Vapor
		[45717] = Defaults(), -- Fog of Corruption

		-- The Eredar Twins
		-- Lady Sacrolash
		[45256] = Defaults(), -- Confounding Blow
		[45347] = Defaults(), -- Dark Touched
		[45270] = Defaults(), -- Shadowfury
		-- Grand Warlock Alythess
		[45333] = Defaults(), -- Conflagration
		[46771] = Defaults(), -- Flame Sear
		[45348] = Defaults(), -- Flame Touched

		-- M'uru
		[45996] = Defaults(), -- Darkness

		-- Kil'jaeden
		[45442] = Defaults(), -- Soul Flay
		[45641] = Defaults(), -- Fire Bloom
		[45885] = Defaults(), -- Shadow Spike
		[45737] = Defaults(), -- Flame Dart
	}
}

--Spells that we want to show the duration backwards
E.ReverseTimer = {

}

--BuffWatch
--List of personal spells to show on unitframes as icon
local function ClassBuff(id, point, color, onlyShowMissing, style, displayText, decimalThreshold, textColor, textThreshold, xOffset, yOffset, sizeOverride)
	local r, g, b = unpack(color)
	local r2, g2, b2 = 1, 1, 1
	if textColor then
		r2, g2, b2 = unpack(textColor)
	end

	return {["enabled"] = true, ["id"] = id, ["point"] = point, ["color"] = {["r"] = r, ["g"] = g, ["b"] = b},
	["onlyShowMissing"] = onlyShowMissing, ["style"] = style or "coloredIcon", ["displayText"] = displayText or false, ["decimalThreshold"] = decimalThreshold or 5,
	["textColor"] = {["r"] = r2, ["g"] = g2, ["b"] = b2}, ["textThreshold"] = textThreshold or -1, ["xOffset"] = xOffset or 0, ["yOffset"] = yOffset or 0, ["sizeOverride"] = sizeOverride or 0}
end

G.unitframe.buffwatch = {
	PRIEST = {
		[6788] = ClassBuff(6788, "TOPLEFT", {1, 0, 0}), -- Weakened Soul
		[10060] = ClassBuff(10060 , "RIGHT", {227/255, 23/255, 13/255}), -- Power Infusion
		[25218] = ClassBuff(25218, "BOTTOMRIGHT", {0.81, 0.85, 0.1}), -- Power Word: Shield
		[25222] = ClassBuff(25222, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Renew
		[33076] = ClassBuff(33076, "TOPRIGHT", {0.2, 0.7, 0.2}), -- Prayer of Mending
	},
	DRUID = {
		[26982] = ClassBuff(26982, "TOPRIGHT", {0.8, 0.4, 0.8}), -- Rejuvenation
		[26980] = ClassBuff(26980, "BOTTOMLEFT", {0.2, 0.8, 0.2}), -- Regrowth
		[33763] = ClassBuff(33763, "TOPLEFT", {0.4, 0.8, 0.2}), -- Lifebloom
	},
	PALADIN = {
		[1044] = ClassBuff(1044, "BOTTOMRIGHT", {221/255, 117/255, 0}), -- Blessing of Freedom
		[6940] = ClassBuff(6940, "BOTTOMRIGHT", {227/255, 23/255, 13/255}), -- Blessing of Sacrifice
		[10278] = ClassBuff(10278, "BOTTOMRIGHT", {0.2, 0.2, 1}), -- Blessing of Protection
	},
	SHAMAN = {
		[16237] = ClassBuff(16237, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Ancestral Fortitude
		[32594] = ClassBuff(32594, "TOPRIGHT", {0.2, 0.7, 0.2}), -- Earth Shield
	},
	ROGUE = {},
	MAGE = {},
	WARRIOR = {
		[3411] = ClassBuff(3411, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Intervene
	},
	HUNTER = {}
}

P["unitframe"]["filters"] = {
	["buffwatch"] = {}
}

G.unitframe.ChannelTicks = {
	-- Warlock
	[SpellName(1120)] = 5, -- Drain Soul
	[SpellName(689)] = 5, -- Drain Life
	[SpellName(5138)] = 5, -- Drain Mana
	[SpellName(5740)] = 4, -- Rain of Fire
	[SpellName(755)] = 10, -- Health Funnel
	-- Druid
	[SpellName(44203)] = 4, -- Tranquility
	[SpellName(16914)] = 10, -- Hurricane
	-- Priest
	[SpellName(15407)] = 3, -- Mind Flay
	[SpellName(36447)] = 5, -- Mind Sear
	-- Mage
	[SpellName(5143)] = 5, -- Arcane Missiles
	[SpellName(10)] = 8, -- Blizzard
	[SpellName(12051)] = 4 -- Evocation
}

G.unitframe.AuraBarColors = {
	[SpellName(2825)] = {r = 250/255, g = 146/255, b = 27/255},	-- Bloodlust
	[SpellName(32182)] = {r = 250/255, g = 146/255, b = 27/255} -- Heroism
}

G.unitframe.InvalidSpells = {

}

G.unitframe.DebuffHighlightColors = {
	[SpellName(25771)] = {enable = false, style = "FILL", color = {r = 0.85, g = 0, b = 0, a = 0.85}} -- Forbearance
}