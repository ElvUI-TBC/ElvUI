local E, L, V, P, G = unpack(ElvUI)
local LSM = LibStub("LibSharedMedia-3.0")
local LBF = LibStub("LibButtonFacade", true)

local _G = _G
local tonumber, pairs, ipairs, error, unpack, select, tostring = tonumber, pairs, ipairs, error, unpack, select, tostring
local assert, type, collectgarbage, pcall, date = assert, type, collectgarbage, pcall, date
local twipe, tinsert, tremove, next = table.wipe, tinsert, tremove, next
local floor = floor
local format, find, match, strrep, len, sub, gsub, strjoin = string.format, string.find, string.match, strrep, string.len, string.sub, string.gsub, strjoin

local UnitGUID = UnitGUID
local CreateFrame = CreateFrame
local GetCVar = GetCVar
local GetFunctionCPUUsage = GetFunctionCPUUsage
local GetTalentTabInfo = GetTalentTabInfo
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local IsInGuild = IsInGuild
local IsInInstance, GetNumPartyMembers, GetNumRaidMembers = IsInInstance, GetNumPartyMembers, GetNumRaidMembers
local RequestBattlefieldScoreData = RequestBattlefieldScoreData
local SendAddonMessage = SendAddonMessage
local NONE = NONE
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local MAX_TALENT_TABS = MAX_TALENT_TABS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

-- Constants
E.LSM = LSM
E.noop = function() end
E.title = format("|cff00b30bE|r|cffC4C4C4lvUI|r")
E.myfaction, E.myLocalizedFaction = UnitFactionGroup("player")
E.myLocalizedClass, E.myclass, E.myClassID = UnitClass("player")
E.myLocalizedRace, E.myrace = UnitRace("player")
E.myname = UnitName("player")
E.myrealm = GetRealmName()
E.version = GetAddOnMetadata("ElvUI", "Version")
E.wowpatch, E.wowbuild = GetBuildInfo() E.wowbuild = tonumber(E.wowbuild)
E.resolution = GetCVar("gxResolution")
E.screenheight = tonumber(match(E.resolution, "%d+x(%d+)"))
E.screenwidth = tonumber(match(E.resolution, "(%d+)x+%d"))
E.isMacClient = IsMacClient()
E.PixelMode = false

--Tables
E.media = {}
E.frames = {}
E.unitFrameElements = {}
E.statusBars = {}
E.texts = {}
E.snapBars = {}
E.RegisteredModules = {}
E.RegisteredInitialModules = {}
E.ModuleCallbacks = {["CallPriority"] = {}}
E.InitialModuleCallbacks = {["CallPriority"] = {}}
E.valueColorUpdateFuncs = {}
E.TexCoords = {.08, .92, .08, .92}
E.CreditsList = {}

E.InversePoints = {
	TOP = "BOTTOM",
	BOTTOM = "TOP",
	TOPLEFT = "BOTTOMLEFT",
	TOPRIGHT = "BOTTOMRIGHT",
	LEFT = "RIGHT",
	RIGHT = "LEFT",
	BOTTOMLEFT = "TOPLEFT",
	BOTTOMRIGHT = "TOPRIGHT",
	CENTER = "CENTER"
}

E.DispelClasses = {
	["PRIEST"] = {
		["Magic"] = true,
		["Disease"] = true
	},
	["SHAMAN"] = {
		["Poison"] = true,
		["Disease"] = true,
	},
	["PALADIN"] = {
		["Poison"] = true,
		["Magic"] = true,
		["Disease"] = true
	},
	["MAGE"] = {
		["Curse"] = true
	},
	["DRUID"] = {
		["Curse"] = true,
		["Poison"] = true
	}
}

E.HealingClasses = {
	PALADIN = 1,
	SHAMAN = 3,
	DRUID = 3,
	PRIEST = {1, 2}
}

E.ClassRole = {
	PALADIN = {
		[1] = "Caster",
		[2] = "Tank",
		[3] = "Melee"
	},
	PRIEST = "Caster",
	WARLOCK = "Caster",
	WARRIOR = {
		[1] = "Melee",
		[2] = "Melee",
		[3] = "Tank"
	},
	HUNTER = "Melee",
	SHAMAN = {
		[1] = "Caster",
		[2] = "Melee",
		[3] = "Caster"
	},
	ROGUE = "Melee",
	MAGE = "Caster",
	DRUID = {
		[1] = "Caster",
		[2] = "Melee",
		[3] = "Caster"
	}
}

E.DEFAULT_FILTER = {}
for filter, tbl in pairs(G.unitframe.aurafilters) do
	E.DEFAULT_FILTER[filter] = tbl.type
end

local colorizedName
function E:ColorizedName(name, arg2)
	local length = len(name)
	for i = 1, length do
		local letter = sub(name, i, i)
		if i == 1 then
			colorizedName = format("|cff00b30b%s", letter)
		elseif i == 2 then
			colorizedName = format("%s|r|cffC4C4C4%s", colorizedName, letter)
		elseif i == length and arg2 then
			colorizedName = format("%s%s|r|cff00b30b:|r", colorizedName, letter)
		else
			colorizedName = colorizedName..letter
		end
	end
	return colorizedName
end

function E:Print(...)
	(_G[self.db.general.messageRedirect] or DEFAULT_CHAT_FRAME):AddMessage(strjoin("", self:ColorizedName("ElvUI", true), ...)) -- I put DEFAULT_CHAT_FRAME as a fail safe.
end

--Workaround for people wanting to use white and it reverting to their class color.
E.PriestColors = {
	r = 0.99,
	g = 0.99,
	b = 0.99
}

local delayedTimer
local delayedFuncs = {}
function E:ShapeshiftDelayedUpdate(func, ...)
	delayedFuncs[func] = {...}

	if delayedTimer then return end

	delayedTimer = E:ScheduleTimer(function()
		for func in pairs(delayedFuncs) do
			func(unpack(delayedFuncs[func]))
		end

		twipe(delayedFuncs)
		delayedTimer = nil
	end, 0.05) 
end

function E:GetPlayerRole()
	if self.HealingClasses[self.myclass] ~= nil and self:CheckTalentTree(self.HealingClasses[E.myclass]) then
		return "HEALER"
	elseif E.Role == "Tank" then
		return "TANK"
	else
		return "DAMAGER"
	end
end

--Basically check if another class border is being used on a class that doesn't match. And then return true if a match is found.
function E:CheckClassColor(r, g, b)
	r, g, b = floor(r*100 + .5) / 100, floor(g*100 + .5) / 100, floor(b*100 + .5) / 100
	local matchFound = false
	for class in pairs(RAID_CLASS_COLORS) do
		if class ~= E.myclass then
			local colorTable = class == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class])
			if colorTable.r == r and colorTable.g == g and colorTable.b == b then
				matchFound = true
			end
		end
	end

	return matchFound
end

function E:GetColorTable(data)
	if not data.r or not data.g or not data.b then
		error("Could not unpack color values.")
	end

	if data.a then
		return {data.r, data.g, data.b, data.a}
	else
		return {data.r, data.g, data.b}
	end
end

function E:UpdateMedia()
	if not self.db.general or not self.private.general then return end --Prevent rare nil value errors

	-- Fonts
	self.media.normFont = LSM:Fetch("font", self.db.general.font)
	self.media.combatFont = LSM:Fetch("font", self.private.general.dmgfont)

	-- Textures
	self.media.blankTex = LSM:Fetch("background", "ElvUI Blank")
	self.media.normTex = LSM:Fetch("statusbar", self.private.general.normTex)
	self.media.glossTex = LSM:Fetch("statusbar", self.private.general.glossTex)

	-- Border Color
	local border = E.db.general.bordercolor
	if self:CheckClassColor(border.r, border.g, border.b) then
		local classColor = E.myclass == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
		E.db.general.bordercolor.r = classColor.r
		E.db.general.bordercolor.g = classColor.g
		E.db.general.bordercolor.b = classColor.b
	end

	self.media.bordercolor = {border.r, border.g, border.b}

	-- UnitFrame Border Color
	border = E.db.unitframe.colors.borderColor
	if self:CheckClassColor(border.r, border.g, border.b) then
		local classColor = E.myclass == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
		E.db.unitframe.colors.borderColor.r = classColor.r
		E.db.unitframe.colors.borderColor.g = classColor.g
		E.db.unitframe.colors.borderColor.b = classColor.b
	end
	self.media.unitframeBorderColor = {border.r, border.g, border.b}

	-- Backdrop Color
	self.media.backdropcolor = E:GetColorTable(self.db.general.backdropcolor)

	-- Backdrop Fade Color
	self.media.backdropfadecolor = E:GetColorTable(self.db.general.backdropfadecolor)

	-- Value Color
	local value = self.db.general.valuecolor

	if self:CheckClassColor(value.r, value.g, value.b) then
		value = E.myclass == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
		self.db.general.valuecolor.r = value.r
		self.db.general.valuecolor.g = value.g
		self.db.general.valuecolor.b = value.b
	end

	self.media.hexvaluecolor = self:RGBToHex(value.r, value.g, value.b)
	self.media.rgbvaluecolor = {value.r, value.g, value.b}

	if LeftChatPanel and LeftChatPanel.tex and RightChatPanel and RightChatPanel.tex then
		LeftChatPanel.tex:SetTexture(E.db.chat.panelBackdropNameLeft)
		local a = E.db.general.backdropfadecolor.a or 0.5
		LeftChatPanel.tex:SetAlpha(a)

		RightChatPanel.tex:SetTexture(E.db.chat.panelBackdropNameRight)
		RightChatPanel.tex:SetAlpha(a)
	end

	self:ValueFuncCall()
	self:UpdateBlizzardFonts()
end

--Update font/texture paths when they are registered by the addon providing them
--This helps fix most of the issues with fonts or textures reverting to default because the addon providing them is loading after ElvUI.
--We use a wrapper to avoid errors in :UpdateMedia because "self" is passed to the function with a value other than ElvUI.
local function LSMCallback()
	E:UpdateMedia()
end
LSM.RegisterCallback(E, "LibSharedMedia_Registered", LSMCallback)

local LBFGroupToTableElement = {
	["ActionBars"] = "actionbar",
	["Auras"] = "auras"
}

function E:LBFCallback(SkinID, _, _, Group)
	if not E.private then return end

	local element = LBFGroupToTableElement[Group]
	if element then
		if E.private[element].lbf.enable then
			E.private[element].lbf.skin = SkinID
		end
	end
end

if LBF then
	LBF:RegisterSkinCallback("ElvUI", E.LBFCallback, E)
end

function E:RequestBGInfo()
	RequestBattlefieldScoreData()
end

function E:PLAYER_ENTERING_WORLD()
	self:ScheduleTimer("CheckRole", 0.01)

	if not self.MediaUpdated then
		self:UpdateMedia()
		self.MediaUpdated = true
	end

	local _, instanceType = IsInInstance()
	if instanceType == "pvp" then
		self.BGTimer = self:ScheduleRepeatingTimer("RequestBGInfo", 5)
		self:RequestBGInfo()
	elseif self.BGTimer then
		self:CancelTimer(self.BGTimer)
		self.BGTimer = nil
	end
end

function E:ValueFuncCall()
	for func in pairs(self.valueColorUpdateFuncs) do
		func(self.media.hexvaluecolor, unpack(self.media.rgbvaluecolor))
	end
end

function E:UpdateFrameTemplates()
	for frame in pairs(self.frames) do
		if frame and frame.template and not frame.ignoreUpdates then
			if not frame.ignoreFrameTemplates then
				frame:SetTemplate(frame.template, frame.glossTex)
			end
		else
			self.frames[frame] = nil
		end
	end

	for frame in pairs(self.unitFrameElements) do
		if frame and frame.template and not frame.ignoreUpdates then
			if not frame.ignoreFrameTemplates then
				frame:SetTemplate(frame.template, frame.glossTex)
			end
		else
			self.unitFrameElements[frame] = nil
		end
	end
end

function E:UpdateBorderColors()
	for frame in pairs(self.frames) do
		if frame and not frame.ignoreUpdates then
			if not frame.ignoreBorderColors then
				if frame.template == "Default" or frame.template == "Transparent" or frame.template == nil then
					frame:SetBackdropBorderColor(unpack(self.media.bordercolor))
				end
			end
		else
			self.frames[frame] = nil
		end
	end

	for frame in pairs(self.unitFrameElements) do
		if frame and not frame.ignoreUpdates then
			if not frame.ignoreBorderColors then
				if frame.template == "Default" or frame.template == "Transparent" or frame.template == nil then
					frame:SetBackdropBorderColor(unpack(self.media.unitframeBorderColor))
				end
			end
		else
			self.unitFrameElements[frame] = nil
		end
	end
end

function E:UpdateBackdropColors()
	for frame in pairs(self.frames) do
		if frame then
			if not frame.ignoreBackdropColors then
				if frame.template == "Default" or frame.template == nil then
					frame:SetBackdropColor(unpack(self.media.backdropcolor))
				elseif frame.template == "Transparent" then
					frame:SetBackdropColor(unpack(self.media.backdropfadecolor))
				end
			end
		else
			self.frames[frame] = nil
		end
	end

	for frame in pairs(self.unitFrameElements) do
		if frame then
			if not frame.ignoreBackdropColors then
				if frame.template == "Default" or frame.template == nil then
					frame:SetBackdropColor(unpack(self.media.backdropcolor))
				elseif frame.template == "Transparent" then
					frame:SetBackdropColor(unpack(self.media.backdropfadecolor))
				end
			end
		else
			self.unitFrameElements[frame] = nil
		end
	end
end

function E:UpdateFontTemplates()
	for text in pairs(self.texts) do
		if text then
			text:FontTemplate(text.font, text.fontSize, text.fontStyle)
		else
			self.texts[text] = nil
		end
	end
end

function E:RegisterStatusBar(statusBar)
	tinsert(self.statusBars, statusBar)
end

function E:UpdateStatusBars()
	for _, statusBar in pairs(self.statusBars) do
		if statusBar and statusBar:IsObjectType("StatusBar") then
			statusBar:SetStatusBarTexture(self.media.normTex)
		elseif statusBar and statusBar:IsObjectType("Texture") then
			statusBar:SetTexture(self.media.normTex)
		end
	end
end

--This frame everything in ElvUI should be anchored to for Eyefinity support.
E.UIParent = CreateFrame("Frame", "ElvUIParent", UIParent)
E.UIParent:SetFrameLevel(UIParent:GetFrameLevel())
E.UIParent:SetPoint("CENTER", UIParent, "CENTER")
E.UIParent:SetSize(UIParent:GetSize())
E.snapBars[#E.snapBars + 1] = E.UIParent

E.HiddenFrame = CreateFrame("Frame")
E.HiddenFrame:Hide()

function E:IsDispellableByMe(debuffType)
	if not self.DispelClasses[self.myclass] then return end

	if self.DispelClasses[self.myclass][debuffType] then
		return true
	end
end

function E:GetTalentSpecInfo(isInspect)
	local maxPoints, specIdx, specName, specIcon = 0, 0

	for i = 1, MAX_TALENT_TABS do
		local name, icon, pointsSpent = GetTalentTabInfo(i, isInspect)
		if maxPoints < pointsSpent then
			maxPoints = pointsSpent
			specIdx = i
			specName = name
			specIcon = icon
		end
	end

	if not specName then
		specName = NONE
	end
	if not specIcon then
		specIcon = "Interface\\Icons\\INV_Misc_QuestionMark"
	end

	return specIdx, specName, specIcon
end

function E:CheckTalentTree(tree)
	local talentTree = self.TalentTree
	if not talentTree then return false end

	if type(tree) == "number" then
		return tree == talentTree
	elseif type(tree) == "table" then
		for _, index in pairs(tree) do
			return index == talentTree
		end
	end
end

function E:CheckRole()
	local talentTree = self:GetTalentSpecInfo()
	local role

	if type(self.ClassRole[self.myclass]) == "string" then
		role = self.ClassRole[self.myclass]
	elseif talentTree then
		if self.myclass == "DRUID" and talentTree == 2 then
			role = select(5, GetTalentInfo(talentTree, 22)) > 0 and "Tank" or "Melee"
		else
			role = self.ClassRole[self.myclass][talentTree]
		end
	end

	if not role then role = "Melee" end

	if self.Role ~= role then
		self.Role = role
		self.TalentTree = talentTree
		self.callbacks:Fire("RoleChanged")
	end
end

function E:IncompatibleAddOn(addon, module)
	E.PopupDialogs["INCOMPATIBLE_ADDON"].button1 = addon
	E.PopupDialogs["INCOMPATIBLE_ADDON"].button2 = "ElvUI "..module
	E.PopupDialogs["INCOMPATIBLE_ADDON"].addon = addon
	E.PopupDialogs["INCOMPATIBLE_ADDON"].module = module
	E:StaticPopup_Show("INCOMPATIBLE_ADDON", addon, module)
end

function E:CheckIncompatible()
	if E.global.ignoreIncompatible then return end

	if IsAddOnLoaded("SnowfallKeyPress") and E.private.actionbar.enable then
		E.private.actionbar.keyDown = true
		E:IncompatibleAddOn("SnowfallKeyPress", "ActionBar")
	end

	if IsAddOnLoaded("Chatter") and E.private.chat.enable then
		E:IncompatibleAddOn("Chatter", "Chat")
	end
	if IsAddOnLoaded("Prat") and E.private.chat.enable then
		E:IncompatibleAddOn("Prat", "Chat")
	end

	if IsAddOnLoaded("Aloft") and E.private.nameplates.enable then
		E:IncompatibleAddOn("Aloft", "NamePlates")
	end
end

function E:IsFoolsDay()
	if find(date(), "04/01/") and not E.global.aprilFools then
		return true
	else
		return false
	end
end

function E:CopyTable(currentTable, defaultTable)
	if type(currentTable) ~= "table" then currentTable = {} end

	if type(defaultTable) == "table" then
		for option, value in pairs(defaultTable) do
			if type(value) == "table" then
				value = self:CopyTable(currentTable[option], value)
			end

			currentTable[option] = value
		end
	end

	return currentTable
end

function E:RemoveEmptySubTables(tbl)
	if type(tbl) ~= "table" then
		E:Print("Bad argument #1 to 'RemoveEmptySubTables' (table expected)")
		return
	end

	for k, v in pairs(tbl) do
		if type(v) == "table" then
			if next(v) == nil then
				tbl[k] = nil
			else
				self:RemoveEmptySubTables(v)
			end
		end
	end
end

--Compare 2 tables and remove duplicate key/value pairs
--param cleanTable : table you want cleaned
--param checkTable : table you want to check against.
--return : a copy of cleanTable with duplicate key/value pairs removed
function E:RemoveTableDuplicates(cleanTable, checkTable)
	if type(cleanTable) ~= "table" then
		E:Print("Bad argument #1 to 'RemoveTableDuplicates' (table expected)")
		return
	end
	if type(checkTable) ~= "table" then
		E:Print("Bad argument #2 to 'RemoveTableDuplicates' (table expected)")
		return
	end

	local cleaned = {}
	for option, value in pairs(cleanTable) do
		if type(value) == "table" and checkTable[option] and type(checkTable[option]) == "table" then
			cleaned[option] = self:RemoveTableDuplicates(value, checkTable[option])
		else
			-- Add unique data to our clean table
			if cleanTable[option] ~= checkTable[option] then
				cleaned[option] = value
			end
		end
	end

	--Clean out empty sub-tables
	self:RemoveEmptySubTables(cleaned)

	return cleaned
end

--Compare 2 tables and remove blacklisted key/value pairs
--param cleanTable : table you want cleaned
--param blacklistTable : table you want to check against.
--return : a copy of cleanTable with blacklisted key/value pairs removed
function E:FilterTableFromBlacklist(cleanTable, blacklistTable)
	if type(cleanTable) ~= "table" then
		E:Print("Bad argument #1 to 'FilterTableFromBlacklist' (table expected)")
		return
	end
	if type(blacklistTable) ~=  "table" then
		E:Print("Bad argument #2 to 'FilterTableFromBlacklist' (table expected)")
		return
	end

	local cleaned = {}
	for option, value in pairs(cleanTable) do
		if type(value) == "table" and blacklistTable[option] and type(blacklistTable[option]) == "table" then
			cleaned[option] = self:FilterTableFromBlacklist(value, blacklistTable[option])
		else
			-- Filter out blacklisted keys
			if blacklistTable[option] ~= true then
				cleaned[option] = value
			end
		end
	end

	--Clean out empty sub-tables
	self:RemoveEmptySubTables(cleaned)

	return cleaned
end

function E:TableToLuaString(inTable)
	if type(inTable) ~= "table" then
		E:Print("Invalid argument #1 to E:TableToLuaString (table expected)")
		return
	end

	local ret = "{\n"
	local function recurse(table, level)
		for i, v in pairs(table) do
			ret = ret..strrep("    ", level).."["
			if type(i) == "string" then
				ret = ret.."\""..i.."\""
			else
				ret = ret..i
			end
			ret = ret.."] = "

			if type(v) == "number" then
				ret = ret..v..",\n"
			elseif type(v) == "string" then
				ret = ret.."\""..v:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\"", "\\\""):gsub("\124", "\124\124").."\",\n"
			elseif type(v) == "boolean" then
				if v then
					ret = ret.."true,\n"
				else
					ret = ret.."false,\n"
				end
			elseif type(v) == "table" then
				ret = ret.."{\n"
				recurse(v, level + 1)
				ret = ret..strrep("    ", level).."},\n"
			else
				ret = ret.."\""..tostring(v).."\",\n"
			end
		end
	end

	if inTable then
		recurse(inTable, 1)
	end
	ret = ret.."}"

	return ret
end

local profileFormat = {
	["profile"] = "E.db",
	["private"] = "E.private",
	["global"] = "E.global",
	["filters"] = "E.global",
	["styleFilters"] = "E.global"
}

local lineStructureTable = {}

function E:ProfileTableToPluginFormat(inTable, profileType)
	local profileText = profileFormat[profileType]
	if not profileText then return end

	twipe(lineStructureTable)
	local returnString = ""
	local lineStructure = ""
	local sameLine = false

	local function buildLineStructure()
		local str = profileText
		for _, v in ipairs(lineStructureTable) do
			if type(v) == "string" then
				str = str.."[\""..v.."\"]"
			else
				str = str.."["..v.."]"
			end
		end

		return str
	end

	local function recurse(tbl)
		lineStructure = buildLineStructure()
		for k, v in pairs(tbl) do
			if not sameLine then
				returnString = returnString..lineStructure
			end

			returnString = returnString.."["

			if type(k) == "string" then
				returnString = returnString.."\""..k.."\""
			else
				returnString = returnString..k
			end

			if type(v) == "table" then
				tinsert(lineStructureTable, k)
				sameLine = true
				returnString = returnString.."]"
				recurse(v)
			else
				sameLine = false
				returnString = returnString.."] = "

				if type(v) == "number" then
					returnString = returnString..v.."\n"
				elseif type(v) == "string" then
					returnString = returnString.."\""..v:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\"", "\\\""):gsub("\124", "\124\124").."\"\n"
				elseif type(v) == "boolean" then
					if v then
						returnString = returnString.."true\n"
					else
						returnString = returnString.."false\n"
					end
				else
					returnString = returnString.."\""..tostring(v).."\"\n"
				end
			end
		end

		tremove(lineStructureTable)
		lineStructure = buildLineStructure()
	end

	if inTable and profileType then
		recurse(inTable)
	end

	return returnString
end

function E:StringSplitMultiDelim(s, delim)
	assert(type (delim) == "string" and len(delim) > 0, "bad delimiter")

	local start = 1
	local t = {}  -- results table

	-- find each instance of a string followed by the delimiter
	while(true) do
		local pos = find(s, delim, start, true) -- plain find

		if not pos then
			break
		end

		tinsert(t, sub(s, start, pos - 1))
		start = pos + len(delim)
	end -- while

	-- insert final one (after last delimiter)
	tinsert(t, sub(s, start))

	return unpack(t)
end

local SendMessageTimer -- prevent setting multiple timers at once
function E:SendMessage()
	local numRaid, numParty = GetNumRaidMembers(), GetNumPartyMembers()
	if numRaid > 1 then
		local _, instanceType = IsInInstance()
		if instanceType == "pvp" then
			SendAddonMessage("ELVUI_VERSIONCHK", E.version, "BATTLEGROUND")
		else
			SendAddonMessage("ELVUI_VERSIONCHK", E.version, "RAID")
		end
	elseif numParty > 0 then
		SendAddonMessage("ELVUI_VERSIONCHK", E.version, "PARTY")
	elseif IsInGuild() then
		SendAddonMessage("ELVUI_VERSIONCHK", E.version, "GUILD")
	end

	SendMessageTimer = nil
end

local SendRecieveGroupSize = 0
local function SendRecieve(_, event, prefix, message, _, sender)
	if event == "CHAT_MSG_ADDON" then
		if sender == E.myname then return end

		if prefix == "ELVUI_VERSIONCHK" then
			local msg, ver = tonumber(message), tonumber(E.version)
			if msg and (msg > ver) then -- you're outdated D:
				if not E.recievedOutOfDateMessage then
					E:Print(L["ElvUI is out of date. You can download the newest version from https://github.com/ElvUI-TBC/ElvUI/"])

					if msg and ((msg - ver) >= 0.01) then
						E:StaticPopup_Show("ELVUI_UPDATE_AVAILABLE")
					end

					E.recievedOutOfDateMessage = true
				end
			elseif msg and (msg < ver) then -- Send Message Back if you intercept and are higher revision
				if not SendMessageTimer then
					SendMessageTimer = E:ScheduleTimer("SendMessage", 10)
				end
			end
		end
	elseif event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
		local numRaid, numParty = GetNumRaidMembers(), GetNumPartyMembers() + 1
		local num = numRaid > 0 and numRaid or numParty
		if num ~= SendRecieveGroupSize then
			if num > 1 and num > SendRecieveGroupSize then
				if not SendMessageTimer then
					SendMessageTimer = E:ScheduleTimer("SendMessage", 10)
				end
			end
			SendRecieveGroupSize = num
		end
	elseif not SendMessageTimer then
		SendMessageTimer = E:ScheduleTimer("SendMessage", 10)
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("RAID_ROSTER_UPDATE")
f:RegisterEvent("PARTY_MEMBERS_CHANGED")
f:RegisterEvent("CHAT_MSG_ADDON")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", SendRecieve)

function E:UpdateAll(ignoreInstall)
	E.private = E.charSettings.profile
	E.db = E.data.profile
	E.global = E.data.global
	E.db.theme = nil
	E.db.install_complete = nil

	E:DBConversions()

	local ActionBars = E:GetModule("ActionBars")
	local AFK = E:GetModule("AFK")
	local Auras = E:GetModule("Auras")
	local Bags = E:GetModule("Bags")
	local Blizzard = E:GetModule("Blizzard")
	local Chat = E:GetModule("Chat")
	local DataBars = E:GetModule("DataBars")
	local DataTexts = E:GetModule("DataTexts")
	local Layout = E:GetModule("Layout")
	local Minimap = E:GetModule("Minimap")
	local NamePlates = E:GetModule("NamePlates")
	local Threat = E:GetModule("Threat")
	local Tooltip = E:GetModule("Tooltip")
	local Totems = E:GetModule("Totems")
	local UnitFrames = E:GetModule("UnitFrames")

	ActionBars.db = E.db.actionbar
	Auras.db = E.db.auras
	Bags.db = E.db.bags
	Chat.db = E.db.chat
	DataBars.db = E.db.databars
	DataTexts.db = E.db.datatexts
	NamePlates.db = E.db.nameplates
	Threat.db = E.db.general.threat
	Tooltip.db = E.db.tooltip
	Totems.db = E.db.general.totems
	UnitFrames.db = E.db.unitframe

	E:SetMoversPositions()

	E:UpdateMedia()
	E:UpdateBorderColors()
	E:UpdateBackdropColors()
	E:UpdateFrameTemplates()
	E:UpdateStatusBars()
	E:UpdateCooldownSettings("all")

	Layout:ToggleChatPanels()
	Layout:BottomPanelVisibility()
	Layout:TopPanelVisibility()
	Layout:SetDataPanelStyle()

	if E.private.actionbar.enable then
		ActionBars:ToggleDesaturation()
		ActionBars:UpdateButtonSettings()
		ActionBars:UpdateMicroPositionDimensions()
	end

	AFK:Toggle()

	if E.private.bags.enable then
		Bags:Layout()
		Bags:Layout(true)
		Bags:SizeAndPositionBagBar()
		Bags:UpdateCountDisplay()
		Bags:UpdateItemLevelDisplay()
	end

	if E.private.chat.enable then
		Chat:PositionChat(true)
		Chat:SetupChat()
		Chat:UpdateAnchors()
		Chat:Panels_ColorUpdate()
	end

	DataBars:EnableDisable_ExperienceBar()
	DataBars:EnableDisable_ReputationBar()
	DataBars:UpdateDataBarDimensions()

	DataTexts:LoadDataTexts()

	if E.private.general.minimap.enable then
		Minimap:UpdateSettings()
	end

	if E.private.nameplates.enable then
		NamePlates:ConfigureAll()
		NamePlates:StyleFilterInitializeAllFilters()
	end

	Threat:ToggleEnable()
	Threat:UpdatePosition()

	Totems:PositionAndSize()
	Totems:ToggleEnable()

	if E.private.unitframe.enable then
		UnitFrames:Update_AllFrames()
	end

	if E.RefreshGUI then
		E:RefreshGUI()
	end

	if not (self.private.install_complete or ignoreInstall) then
		E:Install()
	end

	collectgarbage("collect")
end

function E:ResetAllUI()
	self:ResetMovers()

	if E.db.lowresolutionset then
		E:SetupResolution(true)
	end

	if E.db.layoutSet then
		E:SetupLayout(E.db.layoutSet, true)
	end
end

function E:ResetUI(...)
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end

	if ... == "" or ... == " " or ... == nil then
		E:StaticPopup_Show("RESETUI_CHECK")
		return
	end

	self:ResetMovers(...)
end

function E:RegisterModule(name, loadFunc)
	--New method using callbacks
	if loadFunc and type(loadFunc) == "function" then
		if self.initialized then
			loadFunc()
		else
			if self.ModuleCallbacks[name] then
				--Don't allow a registered module name to be overwritten
				E:Print("Invalid argument #1 to E:RegisterModule (module name:", name, "is already registered, please use a unique name)")
				return
			end

			--Add module name to registry
			self.ModuleCallbacks[name] = true
			self.ModuleCallbacks.CallPriority[#self.ModuleCallbacks.CallPriority + 1] = name

			--Register loadFunc to be called when event is fired
			E:RegisterCallback(name, loadFunc, E:GetModule(name))
		end
	else
		if self.initialized then
			self:GetModule(name):Initialize()
		else
			self.RegisteredModules[#self.RegisteredModules + 1] = name
		end
	end
end

function E:RegisterInitialModule(name, loadFunc)
	--New method using callbacks
	if loadFunc and type(loadFunc) == "function" then
		if self.InitialModuleCallbacks[name] then
			--Don't allow a registered module name to be overwritten
			E:Print("Invalid argument #1 to E:RegisterInitialModule (module name:", name, "is already registered, please use a unique name)")
			return
		end

		--Add module name to registry
		self.InitialModuleCallbacks[name] = true
		self.InitialModuleCallbacks.CallPriority[#self.InitialModuleCallbacks.CallPriority + 1] = name

		--Register loadFunc to be called when event is fired
		E:RegisterCallback(name, loadFunc, E:GetModule(name))
	else
		self.RegisteredInitialModules[#self.RegisteredInitialModules + 1] = name
	end
end

function E:InitializeInitialModules()
	--Fire callbacks for any module using the new system
	for index, moduleName in ipairs(self.InitialModuleCallbacks.CallPriority) do
		self.InitialModuleCallbacks[moduleName] = nil
		self.InitialModuleCallbacks.CallPriority[index] = nil
		E.callbacks:Fire(moduleName)
	end

	--Old deprecated initialize method, we keep it for any plugins that may need it
	for _, module in pairs(E.RegisteredInitialModules) do
		module = self:GetModule(module, true)
		if module and module.Initialize then
			local _, catch = pcall(module.Initialize, module)
			if catch and GetCVar("scriptErrors") == "1" then
				ScriptErrorsFrame_OnError(catch, false)
			end
		end
	end
end

function E:RefreshModulesDB()
	local UF = self:GetModule("UnitFrames")
	twipe(UF.db)
	UF.db = self.db.unitframe
end

function E:InitializeModules()
	--Fire callbacks for any module using the new system
	for index, moduleName in ipairs(self.ModuleCallbacks.CallPriority) do
		self.ModuleCallbacks[moduleName] = nil
		self.ModuleCallbacks.CallPriority[index] = nil
		E.callbacks:Fire(moduleName)
	end

	--Old deprecated initialize method, we keep it for any plugins that may need it
	for _, module in pairs(E.RegisteredModules) do
		module = self:GetModule(module)
		if module.Initialize then
			local _, catch = pcall(module.Initialize, module)

			if catch and GetCVar("scriptErrors") == "1" then
				ScriptErrorsFrame_OnError(catch, false)
			end
		end
	end
end

--DATABASE CONVERSIONS
function E:DBConversions()
	--Make sure default filters use the correct filter type
	for filter, filterType in pairs(E.DEFAULT_FILTER) do
		E.global.unitframe.aurafilters[filter].type = filterType
	end

	--Combat & Resting Icon options update
	if E.db.unitframe.units.player.combatIcon ~= nil then
		E.db.unitframe.units.player.CombatIcon.enable = E.db.unitframe.units.player.combatIcon
		E.db.unitframe.units.player.combatIcon = nil
	end
	if E.db.unitframe.units.player.restIcon ~= nil then
		E.db.unitframe.units.player.RestIcon.enable = E.db.unitframe.units.player.restIcon
		E.db.unitframe.units.player.restIcon = nil
	end

	--Convert old private cooldown setting to profile setting
	if E.private.cooldown and (E.private.cooldown.enable ~= nil) then
		E.db.cooldown.enable = E.private.cooldown.enable
		E.private.cooldown.enable = nil
		E.private.cooldown = nil
	end

	if not E.db.chat.panelColorConverted then
		local color = E.db.general.backdropfadecolor
		E.db.chat.panelColor = {r = color.r, g = color.g, b = color.b, a = color.a}
		E.db.chat.panelColorConverted = true
	end

	--Vendor Greys option is now in bags table
	if E.db.general.vendorGrays then
		E.db.bags.vendorGrays.enable = E.db.general.vendorGrays
		E.db.general.vendorGrays = nil
		E.db.general.vendorGraysDetails = nil
	end
end

local CPU_USAGE = {}
local function CompareCPUDiff(showall, module, minCalls)
	local greatestUsage, greatestCalls, greatestName, newName, newFunc
	local greatestDiff, lastModule, mod, newUsage, calls, differance = 0

	for name, oldUsage in pairs(CPU_USAGE) do
		newName, newFunc = name:match("^([^:]+):(.+)$")
		if not newFunc then
			E:Print("CPU_USAGE:", name, newFunc)
		else
			if newName ~= lastModule then
				mod = E:GetModule(newName, true) or E
				lastModule = newName
			end
			newUsage, calls = GetFunctionCPUUsage(mod[newFunc], true)
			differance = newUsage - oldUsage
			if showall and (calls > minCalls) then
				E:Print('Name('..name..')  Calls('..calls..') Diff('..(differance > 0 and format("%.3f", differance) or 0)..')')
			end
			if (differance > greatestDiff) and calls > minCalls then
				greatestName, greatestUsage, greatestCalls, greatestDiff = name, newUsage, calls, differance
			end
		end
	end

	if greatestName then
		E:Print(greatestName.. " had the CPU usage difference of: "..(greatestUsage > 0 and format("%.3f", greatestUsage) or 0).."ms. And has been called ".. greatestCalls.." times.")
	else
		E:Print("CPU Usage: No CPU Usage differences found.")
	end

	twipe(CPU_USAGE)
end

function E:GetTopCPUFunc(msg)
	if not GetCVarBool("scriptProfile") then
		E:Print("For `/cpuusage` to work, you need to enable script profiling via: `/console scriptProfile 1` then reload. Disable after testing by setting it back to 0.")
		return
	end

	local module, showall, delay, minCalls = msg:match("^(%S+)%s*(%S*)%s*(%S*)%s*(.*)$")
	local checkCore, mod = (not module or module == "") and "E"

	showall = (showall == "true" and true) or false
	delay = (delay == "nil" and nil) or tonumber(delay) or 5
	minCalls = (minCalls == "nil" and nil) or tonumber(minCalls) or 15

	twipe(CPU_USAGE)
	if module == "all" then
		for moduName, modu in pairs(self.modules) do
			for funcName, func in pairs(modu) do
				if (funcName ~= "GetModule") and (type(func) == "function") then
					CPU_USAGE[moduName..":"..funcName] = GetFunctionCPUUsage(func, true)
				end
			end
		end
	else
		if not checkCore then
			mod = self:GetModule(module, true)
			if not mod then
				self:Print(module.." not found, falling back to checking core.")
				mod, checkCore = self, "E"
			end
		else
			mod = self
		end

		for name, func in pairs(mod) do
			if (name ~= "GetModule") and type(func) == "function" then
				CPU_USAGE[(checkCore or module)..":"..name] = GetFunctionCPUUsage(func, true)
			end
		end
	end

	self:Delay(delay, CompareCPUDiff, showall, module, minCalls)
	self:Print("Calculating CPU Usage differences (module: "..(checkCore or module)..", showall: "..tostring(showall)..", minCalls: "..tostring(minCalls)..", delay: "..tostring(delay)..")")
end

function E:Initialize(loginFrame)
	twipe(self.db)
	twipe(self.global)
	twipe(self.private)

	local AceDB = LibStub("AceDB-3.0")

	self.myguid = UnitGUID("player")
	self.data = AceDB:New("ElvDB", self.DF)
	self.data.RegisterCallback(self, "OnProfileChanged", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileCopied", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileReset", "OnProfileReset")
	self.charSettings = AceDB:New("ElvPrivateDB", self.privateVars)
	self.private = self.charSettings.profile
	self.db = self.data.profile
	self.global = self.data.global
	self:CheckIncompatible()
	self:DBConversions()

	self:ScheduleTimer("CheckRole", 0.01)

	self:UIScale("PLAYER_LOGIN", loginFrame)

	if not E.db.general.cropIcon then
		E.TexCoords = {0, 1, 0, 1}
	end

	self:LoadCommands() --Load Commands
	self:InitializeModules() --Load Modules
	self:LoadMovers() --Load Movers
	self:UpdateCooldownSettings("all")
	self.initialized = true

	if self.private.install_complete == nil then
		self:Install()
	end

--	if not find(date(), "04/01/") then
--		E.global.aprilFools = nil
--	end

	if self:HelloKittyFixCheck() then
		self:HelloKittyFix()
	end

	self:UpdateMedia()
	self:UpdateFrameTemplates()
	self:UpdateBorderColors()
	self:UpdateBackdropColors()
	self:UpdateStatusBars()

	self:RegisterEvent("PLAYER_TALENT_UPDATE", "CheckRole")
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", "CheckRole")
	self:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS", "UIScale")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	if self.db.general.kittys then
		self:CreateKittys()
		self:Delay(5, self.Print, self, L["Type /hellokitty to revert to old settings."])
	end

	self:Tutorials()
	self:GetModule("Minimap"):UpdateSettings()
	self:RefreshModulesDB()
	collectgarbage("collect")

	if self.db.general.loginmessage then
		self:Print(select(2, E:GetModule("Chat").FindURL(format(L["LOGIN_MSG"], self.media.hexvaluecolor, self.media.hexvaluecolor, self.version)))..".")
	end
end