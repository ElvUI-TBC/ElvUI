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
local function ClassBuff(id, point, color, anyUnit, onlyShowMissing, style, displayText, decimalThreshold, textColor, textThreshold, xOffset, yOffset, sizeOverride)
	local r, g, b = unpack(color);
	local r2, g2, b2 = 1, 1, 1;
	if(textColor) then
		r2, g2, b2 = unpack(textColor);
	end

	return {["enabled"] = true, ["id"] = id, ["point"] = point, ["color"] = {["r"] = r, ["g"] = g, ["b"] = b},
	["anyUnit"] = anyUnit, ["onlyShowMissing"] = onlyShowMissing, ["style"] = style or "coloredIcon", ["displayText"] = displayText or false, ["decimalThreshold"] = decimalThreshold or 5,
	["textColor"] = {["r"] = r2, ["g"] = g2, ["b"] = b2}, ["textThreshold"] = textThreshold or -1, ["xOffset"] = xOffset or 0, ["yOffset"] = yOffset or 0, ["sizeOverride"] = sizeOverride or 0};
end

G.unitframe.buffwatch = {
	PRIEST = {
		[6788] = ClassBuff(6788, "TOPLEFT", {1, 0, 0}, true), -- Ослабленная душа
		[10060] = ClassBuff(10060 , "RIGHT", {227/255, 23/255, 13/255}), -- Придание сил
		[48066] = ClassBuff(48066, "BOTTOMRIGHT", {0.81, 0.85, 0.1}, true), -- Слово силы: Щит
		[48068] = ClassBuff(48068, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Обновление
		[48111] = ClassBuff(48111, "TOPRIGHT", {0.2, 0.7, 0.2}), -- Молитва восстановления
	},
	DRUID = {
		[48441] = ClassBuff(48441, "TOPRIGHT", {0.8, 0.4, 0.8}), -- Омоложение
		[48443] = ClassBuff(48443, "BOTTOMLEFT", {0.2, 0.8, 0.2}), -- Восстановление
		[48451] = ClassBuff(48451, "TOPLEFT", {0.4, 0.8, 0.2}), -- Жизнецвет
		[53251] = ClassBuff(53251, "BOTTOMRIGHT", {0.8, 0.4, 0}), -- Буйный рост
	},
	PALADIN = {
		[1038] = ClassBuff(1038, "BOTTOMRIGHT", {238/255, 201/255, 0}, true), -- Длань спасения
		[1044] = ClassBuff(1044, "BOTTOMRIGHT", {221/255, 117/255, 0}, true), -- Длань свободы
		[6940] = ClassBuff(6940, "BOTTOMRIGHT", {227/255, 23/255, 13/255}, true), -- Длань жертвенности
		[10278] = ClassBuff(10278, "BOTTOMRIGHT", {0.2, 0.2, 1}, true), -- Длань защиты
		[53563] = ClassBuff(53563, "TOPLEFT", {0.7, 0.3, 0.7}), -- Частица Света
		[53601] = ClassBuff(53601, "TOPRIGHT", {0.4, 0.7, 0.2}), -- Священный щит
	},
	SHAMAN = {
		[16237] = ClassBuff(16237, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Стойкость предков
		[49284] = ClassBuff(49284, "TOPRIGHT", {0.2, 0.7, 0.2}), -- Щит земли
		[52000] = ClassBuff(52000, "BOTTOMRIGHT", {0.7, 0.4, 0}), -- Жизнь земли
		[61301] = ClassBuff(61301, "TOPLEFT", {0.7, 0.3, 0.7}), -- Быстрина
	},
	ROGUE = {
		[57933] = ClassBuff(57933, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Маленькие хитрости
	},
	MAGE = {
		[54646] = ClassBuff(54646, "TOPRIGHT", {0.2, 0.2, 1}), -- Магическая консетрация
	},
	WARRIOR = {
		[3411] = ClassBuff(3411, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Вмешательство
		[59665] = ClassBuff(59665, "TOPLEFT", {0.2, 0.2, 1}), -- Бдительность
	},
	DEATHKNIGHT = {
		[49016] = ClassBuff(49016, "TOPRIGHT", {227/255, 23/255, 13/255}) -- Истерия
	},
	HUNTER = {}
};

P["unitframe"]["filters"] = {
	["buffwatch"] = {}
};

G.unitframe.ChannelTicks = {
	-- Чернокнижник
	[SpellName(1120)] = 5, -- Похищение души
	[SpellName(689)] = 5, -- Похищение жизни
	[SpellName(5138)] = 5, -- Похищение маны
	[SpellName(5740)] = 4, -- Огненный ливень
	[SpellName(755)] = 10, -- Канал здоровья
	-- Друид
	[SpellName(44203)] = 4, -- Спокойствие
	[SpellName(16914)] = 10, -- Гроза
	-- Жрец
	[SpellName(15407)] = 3, -- Пытка разума
	[SpellName(48045)] = 5, -- Искушение разума
	[SpellName(47540)] = 3, -- Исповедь
	-- Маг
	[SpellName(5143)] = 5, -- Чародейские стрелы
	[SpellName(10)] = 8, -- Снежная буря
	[SpellName(12051)] = 4 -- Прилив сил
};

G.unitframe.AuraBarColors = {
	[SpellName(2825)] = {r = 250/255, g = 146/255, b = 27/255},	-- Жажда крови
	[SpellName(32182)] = {r = 250/255, g = 146/255, b = 27/255} -- Героизм
};

G.unitframe.InvalidSpells = {

};

G.unitframe.DebuffHighlightColors = {
	[SpellName(25771)] = {enable = false, style = "FILL", color = { r = 0.85, g = 0, b = 0, a = 0.85 }}
};

G.oldBuffWatch = {
	PRIEST = {
		ClassBuff(6788, "TOPLEFT", {1, 0, 0}, true), -- Ослабленная душа
		ClassBuff(10060 , "RIGHT", {227/255, 23/255, 13/255}), -- Придание сил
		ClassBuff(48066, "BOTTOMRIGHT", {0.81, 0.85, 0.1}, true), -- Слово силы: Щит
		ClassBuff(48068, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Обновление
		ClassBuff(48111, "TOPRIGHT", {0.2, 0.7, 0.2}), -- Молитва восстановления
	},
	DRUID = {
		ClassBuff(48441, "TOPRIGHT", {0.8, 0.4, 0.8}), -- Омоложение
		ClassBuff(48443, "BOTTOMLEFT", {0.2, 0.8, 0.2}), -- Востановление
		ClassBuff(48451, "TOPLEFT", {0.4, 0.8, 0.2}), -- Жизнецвет
		ClassBuff(53251, "BOTTOMRIGHT", {0.8, 0.4, 0}), -- Буйный рост
	},
	PALADIN = {
		ClassBuff(1038, "BOTTOMRIGHT", {238/255, 201/255, 0}, true), -- Длань спасения
		ClassBuff(1044, "BOTTOMRIGHT", {221/255, 117/255, 0}, true), -- Длань свободы
		ClassBuff(6940, "BOTTOMRIGHT", {227/255, 23/255, 13/255}, true), -- Длань жертвенности
		ClassBuff(10278, "BOTTOMRIGHT", {0.2, 0.2, 1}, true), -- Длань защиты
		ClassBuff(53563, "TOPLEFT", {0.7, 0.3, 0.7}), -- Частица Света
		ClassBuff(53601, "TOPRIGHT", {0.4, 0.7, 0.2}), -- Священный щит
	},
	SHAMAN = {
		ClassBuff(16237, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Стойкость предков
		ClassBuff(49284, "TOPRIGHT", {0.2, 0.7, 0.2}), -- Щит земли
		ClassBuff(52000, "BOTTOMRIGHT", {0.7, 0.4, 0}), -- Жизнь земли
		ClassBuff(61301, "TOPLEFT", {0.7, 0.3, 0.7}), -- Быстрина
	},
	ROGUE = {
		ClassBuff(57933, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Маленькие хитрости
	},
	MAGE = {
		ClassBuff(54646, "TOPRIGHT", {0.2, 0.2, 1}), -- Магическая концентрация
	},
	WARRIOR = {
		ClassBuff(3411, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Вмешательство
		ClassBuff(59665, "TOPLEFT", {0.2, 0.2, 1}), -- Бдительность
	},
	DEATHKNIGHT = {
		ClassBuff(49016, "TOPRIGHT", {227/255, 23/255, 13/255}) -- Истерия
	}
};