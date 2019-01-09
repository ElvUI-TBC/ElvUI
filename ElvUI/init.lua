ElvUI = {}

local _G = _G
local pairs, unpack = pairs, unpack
local wipe = wipe
local format, strsplit = string.format, string.split

local CreateFrame = CreateFrame
local GetAddOnInfo = GetAddOnInfo
local GetAddOnMetadata = GetAddOnMetadata
local HideUIPanel = HideUIPanel
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local LoadAddOn = LoadAddOn
local ReloadUI = ReloadUI
local GameMenuFrame = GameMenuFrame
local GameMenuButtonLogout = GameMenuButtonLogout
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT

BINDING_HEADER_ELVUI = GetAddOnMetadata("ElvUI", "Title")

local AddOnName, Engine = "ElvUI", ElvUI
local AddOn = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")

AddOn.callbacks = AddOn.callbacks or LibStub("CallbackHandler-1.0"):New(AddOn)

-- Defaults
AddOn.DF = {}
AddOn.DF.profile = {}
AddOn.DF.global = {}
AddOn.privateVars = {}
AddOn.privateVars.profile = {}

AddOn.Options = {
	type = "group",
	name = AddOnName,
	args = {},
}

local Locale = LibStub("AceLocale-3.0"):GetLocale(AddOnName, false)
Engine[1] = AddOn
Engine[2] = Locale
Engine[3] = AddOn.privateVars.profile
Engine[4] = AddOn.DF.profile
Engine[5] = AddOn.DF.global

_G[AddOnName] = Engine
local tcopy = table.copy
function AddOn:OnInitialize()
	if not ElvCharacterDB then
		ElvCharacterDB = {}
	end

	ElvCharacterData = nil --Depreciated
	ElvPrivateData = nil --Depreciated
	ElvData = nil --Depreciated

	self.db = tcopy(self.DF.profile, true)
	self.global = tcopy(self.DF.global, true)
	if ElvDB then
		if ElvDB.global then
			self:CopyTable(self.global, ElvDB.global)
		end

		local profileKey
		if ElvDB.profileKeys then
			profileKey = ElvDB.profileKeys[self.myname.." - "..self.myrealm]
		end

		if profileKey and ElvDB.profiles and ElvDB.profiles[profileKey] then
			self:CopyTable(self.db, ElvDB.profiles[profileKey])
		end
	end

	self.private = tcopy(self.privateVars.profile, true)
	if ElvPrivateDB then
		local profileKey
		if ElvPrivateDB.profileKeys then
			profileKey = ElvPrivateDB.profileKeys[self.myname.." - "..self.myrealm]
		end

		if profileKey and ElvPrivateDB.profiles and ElvPrivateDB.profiles[profileKey] then
			self:CopyTable(self.private, ElvPrivateDB.profiles[profileKey])
		end
	end

	if self.private.general.pixelPerfect then
		self.Border = self.mult
		self.Spacing = 0
		self.PixelMode = true
	end

	self:UIScale()
	self:UpdateMedia()

	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	--self:RegisterEvent("PLAYER_LOGIN", "Initialize")
	self:Contruct_StaticPopups()
	self:InitializeInitialModules()

	if IsAddOnLoaded("Tukui") then
		self:StaticPopup_Show("TUKUI_ELVUI_INCOMPATIBLE")
	end

	local GameMenuButton = CreateFrame("Button", nil, GameMenuFrame, "GameMenuButtonTemplate")
	GameMenuButton:Size(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight())

	GameMenuButton:SetText(self.title)
	GameMenuButton:SetScript("OnClick", function()
		AddOn:ToggleConfig()
		HideUIPanel(GameMenuFrame)
	end)
	GameMenuFrame[AddOnName] = GameMenuButton

	GameMenuButtonRatings:HookScript("OnShow", function(self)
		GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + self:GetHeight())
	end)
	GameMenuButtonRatings:HookScript("OnHide", function(self)
		GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() - self:GetHeight())
	end)

	GameMenuFrame:HookScript("OnShow", function()
		if not GameMenuFrame.isElvUI then
			GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight() + 17)
			GameMenuFrame.isElvUI = true
		end
		local _, relTo = GameMenuButtonLogout:GetPoint()
		if relTo ~= GameMenuFrame[AddOnName] then
			GameMenuFrame[AddOnName]:ClearAllPoints()
			GameMenuFrame[AddOnName]:Point("TOPLEFT", relTo, "BOTTOMLEFT", 0, -1)
			GameMenuButtonLogout:ClearAllPoints()
			GameMenuButtonLogout:Point("TOPLEFT", GameMenuFrame[AddOnName], "BOTTOMLEFT", 0, -16)
		end
	end)

	if AddOn.private.skins.blizzard.enable ~= true or AddOn.private.skins.blizzard.misc ~= true then return end

	local S = AddOn:GetModule("Skins")
	S:HandleButton(GameMenuButton)
end

local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function(self)
	AddOn:Initialize(self)
end)

function AddOn:PLAYER_REGEN_ENABLED()
	self:ToggleConfig()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

function AddOn:PLAYER_REGEN_DISABLED()
	local err = false

	if IsAddOnLoaded("ElvUI_Config") then
		local ACD = LibStub("AceConfigDialog-3.0-ElvUI")

		if ACD.OpenFrames[AddOnName] then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
			ACD:Close(AddOnName)
			err = true
		end
	end

	if self.CreatedMovers then
		for name in pairs(self.CreatedMovers) do
			if _G[name] and _G[name]:IsShown() then
				err = true
				_G[name]:Hide()
			end
		end
	end

	if err == true then
		self:Print(ERR_NOT_IN_COMBAT)
	end
end

function AddOn:ResetProfile()
	local profileKey
	if ElvPrivateDB.profileKeys then
		profileKey = ElvPrivateDB.profileKeys[self.myname.." - "..self.myrealm]
	end

	if profileKey and ElvPrivateDB.profiles and ElvPrivateDB.profiles[profileKey] then
		ElvPrivateDB.profiles[profileKey] = nil
	end

	ElvCharacterDB = nil
	ReloadUI()
end

function AddOn:OnProfileReset()
	self:StaticPopup_Show("RESET_PROFILE_PROMPT")
end

local pageNodes = {}
function AddOn:ToggleConfig(msg)
	if InCombatLockdown() then
		self:Print(ERR_NOT_IN_COMBAT)
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	if not IsAddOnLoaded("ElvUI_Config") then
		local _, _, _, _, _, reason = GetAddOnInfo("ElvUI_Config")
		if reason ~= "MISSING" and reason ~= "DISABLED" then
			self.GUIFrame = false
			LoadAddOn("ElvUI_Config")
			--For some reason, GetAddOnInfo reason is "DEMAND_LOADED" even if the addon is disabled.
			--Workaround: Try to load addon and check if it is loaded right after.
			if not IsAddOnLoaded("ElvUI_Config") then
				self:Print("|cffff0000Error -- Addon 'ElvUI_Config' not found or is disabled.|r")
				return
			end
			if GetAddOnMetadata("ElvUI_Config", "Version") ~= "1.01" then
				self:StaticPopup_Show("CLIENT_UPDATE_REQUEST")
			end
		else
			self:Print("|cffff0000Error -- Addon 'ElvUI_Config' not found or is disabled.|r")
			return
		end
	end

	local ACD = LibStub("AceConfigDialog-3.0-ElvUI")
	local ConfigOpen = ACD.OpenFrames[AddOnName]

	local pages, msgStr
	if msg and msg ~= "" then
		pages = {strsplit(",", msg)}
		msgStr = msg:gsub(",","\001")
	end

	local mode = "Close"
	if not ConfigOpen or (pages ~= nil) then
		if pages ~= nil then
			local pageCount, index, mainSel = #pages
			if pageCount > 1 then
				wipe(pageNodes)
				index = 0

				local main, mainNode, mainSelStr, sub, subNode, subSel
				for i = 1, pageCount do
					if i == 1 then
						main = pages[i] and ACD.Status and ACD.Status.ElvUI
						mainSel = main and main.status and main.status.groups and main.status.groups.selected
						mainSelStr = mainSel and ("^"..mainSel:gsub("([%(%)%.%%%+%-%*%?%[%^%$])","%%%1").."\001")
						mainNode = main and main.children and main.children[pages[i]]
						pageNodes[index + 1], pageNodes[index + 2] = main, mainNode
					else
						sub = pages[i] and pageNodes[i] and ((i == pageCount and pageNodes[i]) or pageNodes[i].children[pages[i]])
						subSel = sub and sub.status and sub.status.groups and sub.status.groups.selected
						subNode = (mainSelStr and msgStr:match(mainSelStr..pages[i]:gsub("([%(%)%.%%%+%-%*%?%[%^%$])","%%%1").."$") and (subSel and subSel == pages[i])) or ((i == pageCount and not subSel) and mainSel and mainSel == msgStr)
						pageNodes[index + 1], pageNodes[index + 2] = sub, subNode
					end
					index = index + 2
				end
			else
				local main = pages[1] and ACD.Status and ACD.Status.ElvUI
				mainSel = main and main.status and main.status.groups and main.status.groups.selected
			end

			if ConfigOpen and ((not index and mainSel and mainSel == msg) or (index and pageNodes and pageNodes[index])) then
				mode = "Close"
			else
				mode = "Open"
			end
		else
			mode = "Open"
		end
	end
	ACD[mode](ACD, AddOnName)

	if pages and (mode == "Open") then
		ACD:SelectGroup(AddOnName, unpack(pages))
	end

	if mode == "Open" then
		ElvConfigToggle.text:SetTextColor(unpack(self.media.rgbvaluecolor))
		PlaySound("igMainMenuOpen")
	else
		ElvConfigToggle.text:SetTextColor(1, 1, 1)
		PlaySound("igMainMenuClose")
	end

	GameTooltip:Hide() --Just in case you're mouseovered something and it closes.
end