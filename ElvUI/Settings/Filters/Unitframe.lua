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
		[SpellName(99)] = Defaults(),		-- Demoralizing Roar
		[SpellName(339)] = Defaults(),		-- Entangling Roots
		[SpellName(2637)] = Defaults(),		-- Hibernate
		[SpellName(5211)] = Defaults(),		-- Bash
		[SpellName(9005)] = Defaults(),		-- Pounce
		[SpellName(22570)] = Defaults(),	-- Maim
		[SpellName(33786)] = Defaults(),	-- Cyclone
		[SpellName(45334)] = Defaults(),	-- Feral Charge Effect
	-- Hunter
		[SpellName(1513)] = Defaults(),		-- Scare Beast
		[SpellName(3355)] = Defaults(),		-- Freezing Trap Effect
		[SpellName(19386)] = Defaults(),	-- Wyvern Sting
		[SpellName(19410)] = Defaults(),	-- Improved Concussive Shot
		[SpellName(19503)] = Defaults(),	-- Scatter Shot
		[SpellName(24394)] = Defaults(),	-- Intimidation
		[SpellName(34490)] = Defaults(),	-- Silencing Shot
	-- Mage
		[SpellName(118)] = Defaults(),		-- Polymorph
		[SpellName(122)] = Defaults(),		-- Frost Nova
		[SpellName(18469)] = Defaults(),	-- Counterspell - Silenced
		[SpellName(31589)] = Defaults(),	-- Slow
		[SpellName(31661)] = Defaults(),	-- Dragon's Breath
		[SpellName(33395)] = Defaults(),	-- Freeze
	-- Paladin
		[SpellName(853)] = Defaults(),		-- Hammer of Justice
		[SpellName(10326)] = Defaults(),	-- Turn Evil
		[SpellName(20066)] = Defaults(),	-- Repentance
		[SpellName(31935)] = Defaults(),	-- Avenger's Shield
	-- Priest
		[SpellName(605)] = Defaults(),		-- Mind Control
		[SpellName(8122)] = Defaults(),		-- Psychic Scream
		[SpellName(9484)] = Defaults(),		-- Shackle Undead
		[SpellName(15487)] = Defaults(),	-- Silence
	-- Rogue
		[SpellName(408)] = Defaults(),		-- Kidney Shot
		[SpellName(1330)] = Defaults(),		-- Garrote - Silence
		[SpellName(1776)] = Defaults(),		-- Gouge
		[SpellName(1833)] = Defaults(),		-- Cheap Shot
		[SpellName(2094)] = Defaults(),		-- Blind
		[SpellName(6770)] = Defaults(),		-- Sap
		[SpellName(18425)] = Defaults(),	-- Kick - Silenced
	-- Shaman
		[SpellName(3600)] = Defaults(),		-- Earthbind
		[SpellName(8056)] = Defaults(),		-- Frost Shock
		[SpellName(39796)] = Defaults(),	-- Stoneclaw Stun
	-- Warlock
		[SpellName(710)] = Defaults(),		-- Banish
		[SpellName(5782)] = Defaults(),		-- Fear
		[SpellName(6358)] = Defaults(),		-- Seduction
		[SpellName(6789)] = Defaults(),		-- Death Coil
		[SpellName(17928)] = Defaults(),	-- Howl of Terror
		[SpellName(24259)] = Defaults(),	-- Spell Lock
		[SpellName(30283)] = Defaults(),	-- Shadowfury
	-- Warrior
		[SpellName(676)] = Defaults(),		-- Disarm
		[SpellName(7922)] = Defaults(),		-- Charge Stun
		[SpellName(12809)] = Defaults(),	-- Concussion Blow
		[SpellName(18498)] = Defaults(),	-- Shield Bash - Silenced
		[SpellName(20511)] = Defaults(),	-- Intimidating Shout
	-- Racial
		[SpellName(25046)] = Defaults(),	-- Arcane Torrent
		[SpellName(20549)] = Defaults(),	-- War Stomp
	}
}

G.unitframe.aurafilters["TurtleBuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Mage
		[SpellName(45438)] = Defaults(5),	-- Ice Block
	-- Priest
		[SpellName(33206)] = Defaults(3),	-- Pain Suppression
	-- Warlock

	-- Druid
		[SpellName(22812)] = Defaults(2),	-- Barkskin
--		[SpellName(34496)] = Defaults(),	-- Survival Instincts
	-- Hunter
		[SpellName(19263)] = Defaults(5),	-- Deterrence
	-- Rogue
		[SpellName(5277)] = Defaults(5),	-- Evasion
		[SpellName(31224)] = Defaults(),	-- Cloak of Shadows
		[SpellName(45182)] = Defaults(),	-- Cheating Death
	-- Shaman
		[SpellName(30823)] = Defaults(),	-- Shamanistic Rage
	-- Paladin
		[SpellName(498)] = Defaults(2),		-- Divine Protection
		[SpellName(642)] = Defaults(5),		-- Divine Shield
		[SpellName(1022)] = Defaults(5),	-- Blessing of Protection
		[SpellName(6940)] = Defaults(),		-- Blessing of Sacrifice
		[SpellName(31821)] = Defaults(3),	-- Aura Mastery
	-- Warrior
		[SpellName(871)] = Defaults(3),		-- Shield Wall
	}
}

G.unitframe.aurafilters["PlayerBuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Mage
		[SpellName(12042)] = Defaults(),	-- Arcane Power
		[SpellName(12051)] = Defaults(),	-- Evocation
		[SpellName(12472)] = Defaults(),	-- Icy Veins
		[SpellName(32612)] = Defaults(),	-- Invisibility
		[SpellName(45438)] = Defaults(),	-- Ice Block
	-- Priest
		[SpellName(6346)] = Defaults(),		-- Fear Ward
		[SpellName(10060)] = Defaults(),	-- Power Infusion
		[SpellName(20711)] = Defaults(),	-- Spirit of Redemption
		[SpellName(33206)] = Defaults(),	-- Pain Suppression
	-- Warlock

	-- Druid
		[SpellName(1850)] = Defaults(),		-- Dash
		[SpellName(22812)] = Defaults(),	-- Barkskin
	-- Hunter
		[SpellName(3045)] = Defaults(),		-- Rapid Fire
		[SpellName(5384)] = Defaults(),		-- Feign Death
		[SpellName(19263)] = Defaults(),	-- Deterrence
	-- Rogue
		[SpellName(2983)] = Defaults(),		-- Sprint
		[SpellName(5277)] = Defaults(),		-- Evasion
		[SpellName(11327)] = Defaults(),	-- Vanish
		[SpellName(13750)] = Defaults(),	-- Adrenaline Rush
		[SpellName(31224)] = Defaults(),	-- Cloak of Shadows
		[SpellName(45182)] = Defaults(),	-- Cheating Death
	-- Shaman
		[SpellName(2825)] = Defaults(),		-- Bloodlust
		[SpellName(8178)] = Defaults(),		-- Grounding Totem Effect
		[SpellName(16166)] = Defaults(),	-- Elemental Mastery
		[SpellName(16188)] = Defaults(),	-- Nature's Swiftness
		[SpellName(16191)] = Defaults(),	-- Mana Tide
		[SpellName(30823)] = Defaults(),	-- Shamanistic Rage
		[SpellName(32182)] = Defaults(),	-- Heroism
	-- Paladin
		[SpellName(498)] = Defaults(),		-- Divine Protection
		[SpellName(1022)] = Defaults(),		-- Blessing of Protection
		[SpellName(1044)] = Defaults(),		-- Blessing of Freedom
		[SpellName(6940)] = Defaults(),		-- Blessing of Sacrifice
		[SpellName(31821)] = Defaults(),	-- Aura Mastery
		[SpellName(31842)] = Defaults(),	-- Divine Illumination
		[SpellName(31850)] = Defaults(),	-- Ardent Defender
		[SpellName(31884)] = Defaults(),	-- Avenging Wrath
	-- Warrior
		[SpellName(871)] = Defaults(),		-- Shield Wall
		[SpellName(1719)] = Defaults(),		-- Recklessness
		[SpellName(3411)] = Defaults(),		-- Intervene
		[SpellName(12292)] = Defaults(),	-- Death Wish
		[SpellName(12975)] = Defaults(),	-- Last Stand
		[SpellName(18499)] = Defaults(),	-- Berserker Rage
		[SpellName(23920)] = Defaults(),	-- Spell Reflection
	-- Racial
		[SpellName(20594)] = Defaults(),	-- Stoneform
		[SpellName(28880)] = Defaults(),	-- Gift of the Naaru
		[SpellName(20572)] = Defaults(),	-- Blood Fury
		[SpellName(26297)] = Defaults()		-- Berserking
	}
}

G.unitframe.aurafilters["Blacklist"] = {
	["type"] = "Blacklist",
	["spells"] = {
		[SpellName(6788)] = Defaults(),		-- Weakened Soul
		[SpellName(8326)] = Defaults(),		-- Ghost
		[SpellName(8733)] = Defaults(),		-- Blessing of Blackfathom
		[SpellName(15007)] = Defaults(),	-- Resurrection Sickness
		[SpellName(23445)] = Defaults(),	-- Evil Twin
		[SpellName(24755)] = Defaults(),	-- Tricked or Treated
		[SpellName(25771)] = Defaults(),	-- Forbearance
		[SpellName(26013)] = Defaults(),	-- Deserter
		[SpellName(36032)] = Defaults(),	-- Arcane Blast
		[SpellName(36893)] = Defaults(),	-- Transporter Malfunction
		[SpellName(36900)] = Defaults(),	-- Soul Split: Evil!
		[SpellName(36901)] = Defaults(),	-- Soul Split: Good
		[SpellName(41425)] = Defaults(),	-- Hypothermia
	}
}

G.unitframe.aurafilters["Whitelist"] = {
	["type"] = "Whitelist",
	["spells"] = {
		[SpellName(1022)] = Defaults(),		-- Blessing of Protection
		[SpellName(1490)] = Defaults(),		-- Curse of the Elements
		[SpellName(2825)] = Defaults(),		-- Bloodlust
		[SpellName(12051)] = Defaults(),	-- Evocation
		[SpellName(18708)] = Defaults(),	-- Fel Domination
		[SpellName(29166)] = Defaults(),	-- Innervate
		[SpellName(31821)] = Defaults(),	-- Aura Mastery
		[SpellName(32182)] = Defaults(),	-- Heroism
	-- Turtling abilities
		[SpellName(871)] = Defaults(),		-- Shield Wall
		[SpellName(19263)] = Defaults(),	-- Deterrence
		[SpellName(22812)] = Defaults(),	-- Barkskin
		[SpellName(31224)] = Defaults(),	-- Cloak of Shadows
		[SpellName(33206)] = Defaults(),	-- Pain Suppression
	-- Immunities
		[SpellName(642)] = Defaults(),		-- Divine Shield
		[SpellName(45438)] = Defaults(),	-- Ice Block
	-- Offensive
		[SpellName(12292)] = Defaults(),	-- Death Wish
		[SpellName(31884)] = Defaults(),	-- Avenging Wrath
		[SpellName(34471)] = Defaults()		-- The Beast Within
	}
}

G.unitframe.aurafilters["RaidDebuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Karazhan
		-- Moroes
		[SpellName(37066)] = Defaults(),	-- Garrote
		-- Maiden of Virtue
		[SpellName(29522)] = Defaults(),	-- Holy Fire
		[SpellName(29511)] = Defaults(),	-- Repentance
		-- The Opera Event: The Big Bad Wolf
		[SpellName(30753)] = Defaults(),	-- Red Riding Hood
		-- Terestian Illhoof
		[SpellName(30115)] = Defaults(),	-- Sacrifice
		-- Prince Malchezaar
		[SpellName(30843)] = Defaults(),	-- Enfeeble

	-- Zul'Aman
		-- Nalorakk
		[SpellName(42389)] = Defaults(),	-- Mangle
		-- Akil'zon
		[SpellName(43657)] = Defaults(),	-- Electrical Storm
		[SpellName(43622)] = Defaults(),	-- Static Disruption
		-- Jan'alai
		[SpellName(43299)] = Defaults(),	-- Flame Buffet
		-- Halazzi
		[SpellName(43303)] = Defaults(),	-- Flame Shock
		-- Hexxlord Jin'Zakk
		[SpellName(43613)] = Defaults(),	-- Cold Stare
		[SpellName(43501)] = Defaults(),	-- Siphon Soul
		-- Zul'jin
		[SpellName(43093)] = Defaults(),	-- Grievous Throw
		[SpellName(43095)] = Defaults(),	-- Creeping Paralysis
		[SpellName(43150)] = Defaults(),	-- Claw Rage

	-- Serpentshrine Cavern
		-- Trash
		[SpellName(39042)] = Defaults(),	-- Rampant Infection
		[SpellName(39044)] = Defaults(),	-- Serpentshrine Parasite
		-- Hydross the Unstable
		[SpellName(38235)] = Defaults(),	-- Water Tomb
		[SpellName(38246)] = Defaults(),	-- Vile Sludge
		-- Leotheras the Blind
		[SpellName(37676)] = Defaults(),	-- Insidious Whisper
		[SpellName(37641)] = Defaults(),	-- Whirlwind
		[SpellName(37749)] = Defaults(),	-- Consuming Madness
		-- Morogrim Tidewalker
		[SpellName(37850)] = Defaults(),	-- Watery Grave
		-- Lady Vashj
		[SpellName(38280)] = Defaults(),	-- Static Charge

	-- The Eye (Tempest Keep)
		-- Trash
		[SpellName(37123)] = Defaults(),	-- Saw Blade
		[SpellName(37120)] = Defaults(),	-- Fragmentation Bomb
		[SpellName(37118)] = Defaults(),	-- Shell Shock
		-- High Astromancer Solarian
		[SpellName(42783)] = Defaults(),	-- Wrath of the Astromancer
		-- Kael'thas Sunstrider
		[SpellName(36798)] = Defaults(),	-- Mind Control
		[SpellName(37027)] = Defaults(),	-- Remote Toy

	-- Hyjal Summit
		-- Rage Winterchill
		[SpellName(31249)] = Defaults(),	-- Icebolt
		-- Anetheron
		[SpellName(31306)] = Defaults(),	-- Carrion Swarm
		[SpellName(31298)] = Defaults(),	-- Sleep
		-- Azgalor
		[SpellName(31347)] = Defaults(),	-- Doom
		[SpellName(31341)] = Defaults(),	-- Unquenchable Flames
		[SpellName(31344)] = Defaults(),	-- Howl of Azgalor
		-- Archimonde
		[SpellName(31944)] = Defaults(),	-- Doomfire
		[SpellName(31972)] = Defaults(),	-- Grip of the Legion

	-- Black Temple
		-- Trash
		[SpellName(34654)] = Defaults(),	-- Blind
		[SpellName(39674)] = Defaults(),	-- Banish
		[SpellName(41150)] = Defaults(),	-- Fear
		[SpellName(41168)] = Defaults(),	-- Sonic Strike
		-- High Warlord Naj'entus
		[SpellName(39837)] = Defaults(),	-- Impaling Spine
		-- Teron Gorefiend
		[SpellName(40239)] = Defaults(),	-- Incinerate
		[SpellName(40251)] = Defaults(),	-- Shadow of Death
		-- Gurtogg Bloodboil
		[SpellName(40604)] = Defaults(),	-- Fel Rage
		[SpellName(40481)] = Defaults(),	-- Acidic Wound
		[SpellName(40508)] = Defaults(),	-- Fel-Acid Breath
		[SpellName(42005)] = Defaults(),	-- Bloodboil
		-- Reliquary of Souls
		[SpellName(41303)] = Defaults(),	-- Soul Drain
		[SpellName(41410)] = Defaults(),	-- Deaden
		[SpellName(41376)] = Defaults(),	-- Spite
		-- Mother Shahraz
		[SpellName(40860)] = Defaults(),	-- Vile Beam
		[SpellName(41001)] = Defaults(),	-- Fatal Attraction
		-- The Illidari Council
		-- Lady Malande
		[SpellName(41472)] = Defaults(),	-- Divine Wrath
		-- Veras Darkshadow
		[SpellName(41485)] = Defaults(),	-- Deadly Poison
		-- Illidan Stormrage
		[SpellName(41914)] = Defaults(1),	-- Parasitic Shadowfiend
		[SpellName(40585)] = Defaults(1),	-- Dark Barrage
--		[SpellName(41032)] = Defaults(),	-- Shear
		[SpellName(40932)] = Defaults(1),	-- Agonizing Flames

	-- Sunwell Plateau
		-- Trash
		[SpellName(46561)] = Defaults(),	-- Fear
		[SpellName(46562)] = Defaults(),	-- Mind Flay
		[SpellName(46266)] = Defaults(),	-- Burn Mana
		[SpellName(46557)] = Defaults(),	-- Slaying Shot
		[SpellName(46560)] = Defaults(),	-- Shadow Word: Pain
		[SpellName(46543)] = Defaults(),	-- Ignite Mana
		[SpellName(46427)] = Defaults(),	-- Domination
		-- Kalecgos
		[SpellName(45032)] = Defaults(),	-- Curse of Boundless Agony
		[SpellName(45018)] = Defaults(),	-- Arcane Buffet
		-- Brutallus
		[SpellName(46394)] = Defaults(),	-- Burn
		[SpellName(45150)] = Defaults(),	-- Meteor Slash
		-- Felmyst
		[SpellName(45855)] = Defaults(),	-- Gas Nova
		[SpellName(45662)] = Defaults(),	-- Encapsulate
		[SpellName(45402)] = Defaults(),	-- Demonic Vapor
		[SpellName(45717)] = Defaults(),	-- Fog of Corruption
		-- The Eredar Twins
		-- Lady Sacrolash
		[SpellName(45256)] = Defaults(),	-- Confounding Blow
		[SpellName(45347)] = Defaults(),	-- Dark Touched
		[SpellName(45270)] = Defaults(),	-- Shadowfury
		-- Grand Warlock Alythess
		[SpellName(45333)] = Defaults(),	-- Conflagration
		[SpellName(46771)] = Defaults(),	-- Flame Sear
		[SpellName(45348)] = Defaults(),	-- Flame Touched
		-- M'uru
		[SpellName(45996)] = Defaults(),	-- Darkness
		-- Kil'jaeden
		[SpellName(45442)] = Defaults(),	-- Soul Flay
		[SpellName(45641)] = Defaults(),	-- Fire Bloom
		[SpellName(45885)] = Defaults(),	-- Shadow Spike
		[SpellName(45737)] = Defaults(),	-- Flame Dart
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

	return {
		["enabled"] = true,
		["id"] = id,
		["point"] = point,
		["color"] = {
			["r"] = r, ["g"] = g, ["b"] = b
		},
		["onlyShowMissing"] = onlyShowMissing,
		["style"] = style or "coloredIcon",
		["displayText"] = displayText or false,
		["decimalThreshold"] = decimalThreshold or 5,
		["textColor"] = {
			["r"] = r2, ["g"] = g2, ["b"] = b2
		},
		["textThreshold"] = textThreshold or -1,
		["xOffset"] = xOffset or 0,
		["yOffset"] = yOffset or 0,
		["sizeOverride"] = sizeOverride or 0
	}
end

G.unitframe.buffwatch = {
	PRIEST = {
		[6788] = ClassBuff(6788, "TOPLEFT", {1, 0, 0}),					-- Weakened Soul
		[10060] = ClassBuff(10060 , "RIGHT", {0.89, 0.09, 0.05}),		-- Power Infusion
		[25218] = ClassBuff(25218, "BOTTOMRIGHT", {0.81, 0.85, 0.1}),	-- Power Word: Shield
		[25222] = ClassBuff(25222, "BOTTOMLEFT", {0.4, 0.7, 0.2}),		-- Renew
		[33076] = ClassBuff(33076, "TOPRIGHT", {0.2, 0.7, 0.2}),		-- Prayer of Mending
	},
	DRUID = {
		[26982] = ClassBuff(26982, "TOPRIGHT", {0.8, 0.4, 0.8}),		-- Rejuvenation
		[26980] = ClassBuff(26980, "BOTTOMLEFT", {0.2, 0.8, 0.2}),		-- Regrowth
		[33763] = ClassBuff(33763, "TOPLEFT", {0.4, 0.8, 0.2}),			-- Lifebloom
	},
	PALADIN = {
		[1044] = ClassBuff(1044, "BOTTOMRIGHT", {0.86, 0.45, 0}),		-- Blessing of Freedom
		[6940] = ClassBuff(6940, "BOTTOMRIGHT", {0.89, 0.09, 0.05}),	-- Blessing of Sacrifice
		[10278] = ClassBuff(10278, "BOTTOMRIGHT", {0.2, 0.2, 1}),		-- Blessing of Protection
	},
	SHAMAN = {
		[16237] = ClassBuff(16237, "BOTTOMLEFT", {0.4, 0.7, 0.2}),		-- Ancestral Fortitude
		[32594] = ClassBuff(32594, "TOPRIGHT", {0.2, 0.7, 0.2}),		-- Earth Shield
	},
	WARRIOR = {
		[3411] = ClassBuff(3411, "TOPRIGHT", {0.89, 0.09, 0.05}),		-- Intervene
	},
	PET = {
		[1539] = ClassBuff(1539, "TOPLEFT", {0.81, 0.85, 0.1}),			-- Feed Pet
		[33976] = ClassBuff(33976, "TOPRIGHT", {0.2, 0.8, 0.2})			-- Mend Pet
	},
	ROGUE = {},
	MAGE = {},
	HUNTER = {},
	WARLOCK = {},
}

P["unitframe"]["filters"] = {
	["buffwatch"] = {}
}

G.unitframe.ChannelTicks = {
	-- Warlock
	[SpellName(1120)] = 5,		-- Drain Soul
	[SpellName(689)] = 5,		-- Drain Life
	[SpellName(5138)] = 5,		-- Drain Mana
	[SpellName(5740)] = 4,		-- Rain of Fire
	[SpellName(755)] = 10,		-- Health Funnel
	[SpellName(1949)] = 15,		-- Hellfire
	-- Druid
	[SpellName(44203)] = 4,		-- Tranquility
	[SpellName(16914)] = 10,	-- Hurricane
	-- Priest
	[SpellName(15407)] = 3,		-- Mind Flay
	[SpellName(36447)] = 5,		-- Mind Sear
	-- Mage
	[SpellName(5143)] = 5,		-- Arcane Missiles
	[SpellName(10)] = 8,		-- Blizzard
	[SpellName(12051)] = 4,		-- Evocation
	-- Hunter
	[SpellName(27022)] = 6,		-- Volley
}

G.unitframe.AuraBarColors = {
	[SpellName(2825)] = {r = 0.98, g = 0.57, b = 0.10},	-- Bloodlust
	[SpellName(32182)] = {r = 0.98, g = 0.57, b = 0.10}	-- Heroism
}

G.unitframe.InvalidSpells = {

}

G.unitframe.DebuffHighlightColors = {
	[SpellName(25771)] = {enable = false, style = "FILL", color = {r = 0.85, g = 0, b = 0, a = 0.85}} -- Forbearance
}