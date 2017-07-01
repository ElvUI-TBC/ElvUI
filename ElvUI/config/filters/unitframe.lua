local E, L, V, P, G = unpack(ElvUI);

local print, unpack = print, unpack;

local GetSpellInfo = GetSpellInfo;

local function SpellName(id)
	local name, _, _, _, _, _, _, _, _ = GetSpellInfo(id);
	if(not name) then
		print("|cff1784d1ElvUI:|r SpellID is not valid: "..id..". Please check for an updated version, if none exists report to ElvUI author.");
		return "Impale";
	else
		return name;
	end
end

local function Defaults(priorityOverride)
	return {["enable"] = true, ["priority"] = priorityOverride or 0, ["stackThreshold"] = 0};
end

G.unitframe.aurafilters = {};

G.unitframe.aurafilters["CCDebuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {

	}
};

G.unitframe.aurafilters["TurtleBuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {

	}
};

G.unitframe.aurafilters["PlayerBuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {

	}
};

G.unitframe.aurafilters["Blacklist"] = {
	["type"] = "Blacklist",
	["spells"] = {

	}
};

G.unitframe.aurafilters["Whitelist"] = {
	["type"] = "Whitelist",
	["spells"] = {

	}
};

G.unitframe.aurafilters["RaidDebuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {

	}
};

--Spells that we want to show the duration backwards
E.ReverseTimer = {

}

--BuffWatch
--List of personal spells to show on unitframes as icon
local function ClassBuff(id, point, color, onlyShowMissing, style, displayText, decimalThreshold, textColor, textThreshold, xOffset, yOffset, sizeOverride)
	local r, g, b = unpack(color);
	local r2, g2, b2 = 1, 1, 1;
	if(textColor) then
		r2, g2, b2 = unpack(textColor);
	end

	return {["enabled"] = true, ["id"] = id, ["point"] = point, ["color"] = {["r"] = r, ["g"] = g, ["b"] = b},
	["onlyShowMissing"] = onlyShowMissing, ["style"] = style or "coloredIcon", ["displayText"] = displayText or false, ["decimalThreshold"] = decimalThreshold or 5,
	["textColor"] = {["r"] = r2, ["g"] = g2, ["b"] = b2}, ["textThreshold"] = textThreshold or -1, ["xOffset"] = xOffset or 0, ["yOffset"] = yOffset or 0, ["sizeOverride"] = sizeOverride or 0};
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
};

P["unitframe"]["filters"] = {
	["buffwatch"] = {}
};

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
	-- [SpellName(47540)] = 3, -- Penance
	-- Mage
	[SpellName(5143)] = 5, -- Arcane Missiles
	[SpellName(10)] = 8, -- Blizzard
	[SpellName(12051)] = 4 -- Evocation
};

G.unitframe.AuraBarColors = {
	[SpellName(2825)] = {r = 250/255, g = 146/255, b = 27/255},	-- Bloodlust
	[SpellName(32182)] = {r = 250/255, g = 146/255, b = 27/255} -- Heroism
};

G.unitframe.InvalidSpells = {

};

G.unitframe.DebuffHighlightColors = {
	[SpellName(25771)] = {enable = false, style = "FILL", color = {r = 0.85, g = 0, b = 0, a = 0.85}} -- Forbearance
};