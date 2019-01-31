local E, L, V, P, G = unpack(ElvUI)

local select, unpack, assert, tonumber, type = select, unpack, assert, tonumber, type
local abs, ceil, floor, modf, mod = math.abs, math.ceil, math.floor, math.modf, mod
local format, strfind, strsub, strupper, gsub, gmatch, utf8sub = format, strfind, strsub, strupper, gsub, gmatch, string.utf8sub
local tinsert, tremove = tinsert, tremove

local GetScreenWidth, GetScreenHeight = GetScreenWidth, GetScreenHeight
local CreateFrame = CreateFrame

--Return short value of a number
function E:ShortValue(v)
	local shortValueDec = format("%%.%df", E.db.general.decimalLength or 1)
	local value = abs(v)
	if E.db.general.numberPrefixStyle == "METRIC" then
		if value >= 1e12 then
			return format(shortValueDec.."T", v / 1e12)
		elseif value >= 1e9 then
			return format(shortValueDec.."G", v / 1e9)
		elseif value >= 1e6 then
			return format(shortValueDec.."M", v / 1e6)
		elseif value >= 1e3 then
			return format(shortValueDec.."k", v / 1e3)
		else
			return format("%.0f", v)
		end
	elseif E.db.general.numberPrefixStyle == "CHINESE" then
		if value >= 1e8 then
			return format(shortValueDec.."Y", v / 1e8)
		elseif value >= 1e4 then
			return format(shortValueDec.."W", v / 1e4)
		else
			return format("%.0f", v)
		end
	elseif E.db.general.numberPrefixStyle == "KOREAN" then
		if value >= 1e8 then
			return format(shortValueDec.."억", v / 1e8)
		elseif value >= 1e4 then
			return format(shortValueDec.."만", v / 1e4)
		elseif value >= 1e3 then
			return format(shortValueDec.."천", v / 1e3)
		else
			return format("%.0f", v)
		end
	elseif E.db.general.numberPrefixStyle == "GERMAN" then
		if value >= 1e12 then
			return format(shortValueDec.."Bio", v / 1e12)
		elseif value >= 1e9 then
			return format(shortValueDec.."Mrd", v / 1e9)
		elseif value >= 1e6 then
			return format(shortValueDec.."Mio", v / 1e6)
		elseif value >= 1e3 then
			return format(shortValueDec.."Tsd", v / 1e3)
		else
			return format("%.0f", v)
		end
	else
		if value >= 1e12 then
			return format(shortValueDec.."T", v / 1e12)
		elseif value >= 1e9 then
			return format(shortValueDec.."B", v / 1e9)
		elseif value >= 1e6 then
			return format(shortValueDec.."M", v / 1e6)
		elseif value >= 1e3 then
			return format(shortValueDec.."K", v / 1e3)
		else
			return format("%.0f", v)
		end
	end
end

function E:IsEvenNumber(num)
	return num % 2 == 0
end

function E:ColorGradient(perc, ...)
	if perc >= 1 then
		return select(select("#", ...) - 2, ...)
	elseif perc <= 0 then
		return ...
	end

	local num = select("#", ...) / 3
	local segment, relperc = modf(perc*(num - 1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3) + 1, ...)

	return r1 + (r2 - r1)*relperc, g1 + (g2 - g1)*relperc, b1 + (b2 - b1)*relperc
end

function E:Round(num, idp)
	if idp and idp > 0 then
		local mult = 10 ^ idp
		return floor(num * mult + 0.5) / mult
	end
	return floor(num + 0.5)
end

function E:Truncate(v, decimals)
	return v - (v % (0.1 ^ (decimals or 0)))
end

function E:RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 1
	g = g <= 1 and g >= 0 and g or 1
	b = b <= 1 and b >= 0 and b or 1
	return format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

function E:HexToRGB(hex)
	local rhex, ghex, bhex = strsub(hex, 1, 2), strsub(hex, 3, 4), strsub(hex, 5, 6)
	return tonumber(rhex, 16), tonumber(ghex, 16), tonumber(bhex, 16)
end

function E:FramesOverlap(frameA, frameB)
	if not frameA or not frameB then return end

	local sA, sB = frameA:GetEffectiveScale(), frameB:GetEffectiveScale()
	if not sA or not sB then return end

	local frameALeft, frameARight, frameABottom, frameATop = frameA:GetLeft(), frameA:GetRight(), frameA:GetBottom(), frameA:GetTop()
	local frameBLeft, frameBRight, frameBBottom, frameBTop = frameB:GetLeft(), frameB:GetRight(), frameB:GetBottom(), frameB:GetTop()
	if not (frameALeft and frameARight and frameABottom and frameATop) then return end
	if not (frameBLeft and frameBRight and frameBBottom and frameBTop) then return end

	return ((frameALeft*sA) < (frameBRight*sB)) and ((frameBLeft*sB) < (frameARight*sA)) and ((frameABottom*sA) < (frameBTop*sB)) and ((frameBBottom*sB) < (frameATop*sA))
end

function E:GetScreenQuadrant(frame)
	local x, y = frame:GetCenter()
	local screenWidth = GetScreenWidth()
	local screenHeight = GetScreenHeight()
	local point

	if not frame:GetCenter() then
		return "UNKNOWN", frame:GetName()
	end

	if (x > (screenWidth / 3) and x < (screenWidth / 3)*2) and y > (screenHeight / 3)*2 then
		point = "TOP"
	elseif x < (screenWidth / 3) and y > (screenHeight / 3)*2 then
		point = "TOPLEFT"
	elseif x > (screenWidth / 3)*2 and y > (screenHeight / 3)*2 then
		point = "TOPRIGHT"
	elseif (x > (screenWidth / 3) and x < (screenWidth / 3)*2) and y < (screenHeight / 3) then
		point = "BOTTOM"
	elseif x < (screenWidth / 3) and y < (screenHeight / 3) then
		point = "BOTTOMLEFT"
	elseif x > (screenWidth / 3)*2 and y < (screenHeight / 3) then
		point = "BOTTOMRIGHT"
	elseif x < (screenWidth / 3) and (y > (screenHeight / 3) and y < (screenHeight / 3)*2) then
		point = "LEFT"
	elseif x > (screenWidth / 3)*2 and y < (screenHeight / 3)*2 and y > (screenHeight / 3) then
		point = "RIGHT"
	else
		point = "CENTER"
	end

	return point
end

function E:GetXYOffset(position, override)
	local default = E.Spacing
	local x, y = override or default, override or default

	if position == "TOP" then
		return 0, y
	elseif position == "TOPLEFT" then
		return x, y
	elseif position == "TOPRIGHT" then
		return -x, y
	elseif position == "BOTTOM" then
		return 0, -y
	elseif position == "BOTTOMLEFT" then
		return x, -y
	elseif position == "BOTTOMRIGHT" then
		return -x, -y
	elseif position == "LEFT" then
		return -x, 0
	elseif position == "RIGHT" then
		return x, 0
	elseif position == "CENTER" then
		return 0, 0
	end
end

local gftStyles = {
	-- keep percents in this table with `PERCENT` in the key, and `%.1f%%` in the value somewhere.
	-- we use these two things to follow our setting for decimal length. they need to be EXACT.
	["CURRENT"] = "%s",
	["CURRENT_MAX"] = "%s - %s",
	["CURRENT_PERCENT"] = "%s - %.1f%%",
	["CURRENT_MAX_PERCENT"] = "%s - %s | %.1f%%",
	["PERCENT"] = "%.1f%%",
	["DEFICIT"] = "-%s"
}

function E:GetFormattedText(style, min, max)
	assert(gftStyles[style], "Invalid format style: "..style)
	assert(min, "You need to provide a current value. Usage: E:GetFormattedText(style, min, max)")
	assert(max, "You need to provide a maximum value. Usage: E:GetFormattedText(style, min, max)")

	if max == 0 then max = 1 end

	local gftUseStyle
	local gftDec = E.db.general.decimalLength or 1
	if (gftDec ~= 1) and strfind(style, "PERCENT") then
		gftUseStyle = gsub(gftStyles[style], "%%%.1f%%%%", "%%."..gftDec.."f%%%%")
	else
		gftUseStyle = gftStyles[style]
	end

	if style == "DEFICIT" then
		local gftDeficit = max - min
		return ((gftDeficit > 0) and format(gftUseStyle, E:ShortValue(gftDeficit))) or ""
	elseif style == "PERCENT" then
		return format(gftUseStyle, min / max * 100)
	elseif style == "CURRENT" or ((style == "CURRENT_MAX" or style == "CURRENT_MAX_PERCENT" or style == "CURRENT_PERCENT") and min == max) then
		return format(gftStyles.CURRENT, E:ShortValue(min))
	elseif style == "CURRENT_MAX" then
		return format(gftUseStyle,  E:ShortValue(min), E:ShortValue(max))
	elseif style == "CURRENT_PERCENT" then
		return format(gftUseStyle, E:ShortValue(min), min / max * 100)
	elseif style == "CURRENT_MAX_PERCENT" then
		return format(gftUseStyle, E:ShortValue(min), E:ShortValue(max), min / max * 100)
	end
end

function E:ShortenString(str, numChars, dots)
	local bytes = #str
	if bytes <= numChars then
		return str
	else
		local len, pos = 0, 1
		while(pos <= bytes) do
			len = len + 1
			local c = str:byte(pos)
			if c > 0 and c <= 127 then
				pos = pos + 1
			elseif c >= 192 and c <= 223 then
				pos = pos + 2
			elseif c >= 224 and c <= 239 then
				pos = pos + 3
			elseif c >= 240 and c <= 247 then
				pos = pos + 4
			end
			if len == numChars then break end
		end

		if len == numChars and pos <= bytes then
			return strsub(str, 1, pos - 1)..(dots and "..." or "")
		else
			return str
		end
	end
end

function E:AbbreviateString(str, allUpper)
	local newString = ""
	for word in gmatch(str, "[^%s]+") do
		word = utf8sub(word, 1, 1) --get only first letter of each word
		if allUpper then word = strupper(word) end
		newString = newString..word
	end

	return newString
end

local waitTable = {}
local waitFrame
function E:Delay(delay, func, ...)
	if (type(delay) ~= "number") or (type(func) ~= "function") then
		return false
	end
	if waitFrame == nil then
		waitFrame = CreateFrame("Frame","WaitFrame", E.UIParent)
		waitFrame:SetScript("onUpdate",function (_, elapse)
			local i, count = 1, #waitTable
			while i <= count do
				local waitRecord = tremove(waitTable,i)
				local waitDelay = tremove(waitRecord,1)
				local waitFunc = tremove(waitRecord,1)
				local waitParams = tremove(waitRecord,1)
				if waitDelay > elapse then
					tinsert(waitTable,i,{waitDelay-elapse,waitFunc,waitParams})
					i = i + 1
				else
					count = count - 1
					waitFunc(unpack(waitParams))
				end
			end
		end)
	end
	tinsert(waitTable, {delay, func, {...}})
	return true
end

function E:StringTitle(str)
	return gsub(str, "(.)", strupper, 1)
end

E.TimeThreshold = 3

E.TimeColors = { -- aura time colors for days, hours, minutes, seconds, fadetimer
	[0] = "|cffeeeeee",
	[1] = "|cffeeeeee",
	[2] = "|cffeeeeee",
	[3] = "|cffeeeeee",
	[4] = "|cfffe0000",
	[5] = "|cff909090", --mmss
	[6] = "|cff707070", --hhmm
}

E.TimeFormats = { -- short and long aura time formats
	[0] = {"%dd", "%dd"},
	[1] = {"%dh", "%dh"},
	[2] = {"%dm", "%dm"},
	[3] = {"%ds", "%d"},
	[4] = {"%.1fs", "%.1f"},
	[5] = {"%d:%02d", "%d:%02d"}, --mmss
	[6] = {"%d:%02d", "%d:%02d"}, --hhmm
}

local DAY, HOUR, MINUTE = 86400, 3600, 60
local DAYISH, HOURISH, MINUTEISH = HOUR * 23.5, MINUTE * 59.5, 59.5
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5

function E:GetTimeInfo(s, threshhold, hhmm, mmss)
	if s < MINUTE then
		if s >= threshhold then
			return floor(s), 3, 0.51
		else
			return s, 4, 0.051
		end
	elseif s < HOUR then
		if mmss and s < mmss then
			return s/MINUTE, 5, 0.51, s%MINUTE
		else
			local minutes = floor((s/MINUTE)+.5)
			if hhmm and s < (hhmm * MINUTE) then
				return s/HOUR, 6, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH), minutes%MINUTE
			else
				return ceil(s / MINUTE), 2, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
			end
		end
	elseif s < DAY then
		if mmss and s < mmss then
			return s/MINUTE, 5, 0.51, s%MINUTE
		elseif hhmm and s < (hhmm * MINUTE) then
			local minutes = floor((s/MINUTE)+.5)
			return s/HOUR, 6, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH), minutes%MINUTE
		else
			local hours = floor((s/HOUR)+.5)
			return ceil(s / HOUR), 1, hours > 1 and (s - (hours*HOUR - HALFHOURISH)) or (s - HOURISH)
		end
	else
		local days = floor((s/DAY)+.5)
		return ceil(s / DAY), 0, days > 1 and (s - (days*DAY - HALFDAYISH)) or (s - DAYISH)
	end
end

local COLOR_COPPER, COLOR_SILVER, COLOR_GOLD = "|cffeda55f", "|cffc7c7cf", "|cffffd700"
local ICON_COPPER = "|TInterface\\AddOns\\ElvUI\\media\\textures\\UI-CopperIcon:16:16|t"
local ICON_SILVER = "|TInterface\\AddOns\\ElvUI\\media\\textures\\UI-SilverIcon:16:16|t"
local ICON_GOLD = "|TInterface\\AddOns\\ElvUI\\media\\textures\\UI-GoldIcon:16:16|t"

function E:FormatMoney(amount, style, textonly)
	local coppername = textonly and L.copperabbrev or ICON_COPPER
	local silvername = textonly and L.silverabbrev or ICON_SILVER
	local goldname = textonly and L.goldabbrev or ICON_GOLD

	local value = abs(amount)
	local gold = floor(value / 10000)
	local silver = floor(mod(value / 100, 100))
	local copper = floor(mod(value, 100))

	if not style or style == "SMART" then
		local str = ""
		if gold > 0 then str = format("%d%s%s", gold, goldname, (silver > 0 or copper > 0) and " " or "") end
		if silver > 0 then str = format("%s%d%s%s", str, silver, silvername, copper > 0 and " " or "") end
		if copper > 0 or value == 0 then str = format("%s%d%s", str, copper, coppername) end
		return str
	end

	if style == "FULL" then
		if gold > 0 then
			return format("%d%s %d%s %d%s", gold, goldname, silver, silvername, copper, coppername)
		elseif silver > 0 then
			return format("%d%s %d%s", silver, silvername, copper, coppername)
		else
			return format("%d%s", copper, coppername)
		end
	elseif style == "SHORT" then
		if gold > 0 then
			return format("%.1f%s", amount / 10000, goldname)
		elseif silver > 0 then
			return format("%.1f%s", amount / 100, silvername)
		else
			return format("%d%s", amount, coppername)
		end
	elseif style == "SHORTINT" then
		if gold > 0 then
			return format("%d%s", gold, goldname)
		elseif silver > 0 then
			return format("%d%s", silver, silvername)
		else
			return format("%d%s", copper, coppername)
		end
	elseif style == "CONDENSED" then
		if gold > 0 then
			return format("%s%d|r.%s%02d|r.%s%02d|r", COLOR_GOLD, gold, COLOR_SILVER, silver, COLOR_COPPER, copper)
		elseif silver > 0 then
			return format("%s%d|r.%s%02d|r", COLOR_SILVER, silver, COLOR_COPPER, copper)
		else
			return format("%s%d|r", COLOR_COPPER, copper)
		end
	elseif style == "BLIZZARD" then
		if gold > 0 then
			return format("%s%s %d%s %d%s", gold, goldname, silver, silvername, copper, coppername)
		elseif silver > 0 then
			return format("%d%s %d%s", silver, silvername, copper, coppername)
		else
			return format("%d%s", copper, coppername)
		end
	end

	return self:FormatMoney(amount, "SMART")
end