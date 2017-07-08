local function FuBar2Broker()
	local MAJOR_VERSION = "FuBarPlugin-2.0"
	local MINOR_VERSION = 999999 + 1

	local broker = LibStub("LibDataBroker-1.1")

	local tablet
	local Dewdrop

	local FuBarPlugin = AceLibrary("AceOO-2.0").Mixin({
		"GetTitle",
		"GetName",
		"GetCategory",
		"SetFontSize",
		"GetFrame",
		"Show",
		"Hide",
		"GetPanel",
		"IsTextColored",
		"ToggleTextColored",
		"IsMinimapAttached",
		"ToggleMinimapAttached",
		"Update",
		"UpdateDisplay",
		"UpdateData",
		"UpdateTooltip",
		"SetIcon",
		"GetIcon",
		"CheckWidth",
		"SetText",
		"GetText",
		"IsIconShown",
		"ToggleIconShown",
		"ShowIcon",
		"HideIcon",
		"IsTextShown",
		"ToggleTextShown",
		"ShowText",
		"HideText",
		"IsTooltipDetached",
		"ToggleTooltipDetached",
		"DetachTooltip",
		"ReattachTooltip",
		"GetDefaultPosition",
		"SetPanel",
		"IsLoadOnDemand",
		"IsDisabled",
		"CreateBasicPluginFrame",
		"CreatePluginChildFrame",
		"OpenMenu",
		"AddImpliedMenuOptions",
		"UpdateText",
	})

	local fakeFunc = function()
		return false
	end

	local fakeFuncTrue = function()
		return true
	end

	FuBarPlugin.GetName = fakeFunc
	FuBarPlugin.GetCategory = fakeFunc
	FuBarPlugin.SetFontSize = fakeFunc
	FuBarPlugin.GetFrame = fakeFunc
	FuBarPlugin.Show = fakeFunc
	FuBarPlugin.Hide = fakeFunc
	FuBarPlugin.GetPanel = fakeFunc
	FuBarPlugin.IsTextColored = fakeFuncTrue
	FuBarPlugin.ToggleTextColored = fakeFunc
	FuBarPlugin.IsMinimapAttached = fakeFunc
	FuBarPlugin.ToggleMinimapAttached = fakeFunc
	FuBarPlugin.GetIcon = fakeFunc
	FuBarPlugin.CheckWidth = fakeFunc
	FuBarPlugin.GetText = fakeFunc
	FuBarPlugin.IsIconShown = fakeFuncTrue
	FuBarPlugin.ToggleIconShown = fakeFunc
	FuBarPlugin.ShowIcon = fakeFunc
	FuBarPlugin.HideIcon = fakeFunc
	FuBarPlugin.IsTextShown = fakeFuncTrue
	FuBarPlugin.ToggleTextShown = fakeFunc
	FuBarPlugin.ShowText = fakeFunc
	FuBarPlugin.HideText = fakeFunc
	FuBarPlugin.IsTooltipDetached = fakeFunc
	FuBarPlugin.ToggleTooltipDetached = fakeFunc
	FuBarPlugin.DetachTooltip = fakeFunc
	FuBarPlugin.ReattachTooltip = fakeFunc
	FuBarPlugin.GetDefaultPosition = fakeFunc
	FuBarPlugin.SetPanel = fakeFunc
	FuBarPlugin.IsLoadOnDemand = fakeFunc
	FuBarPlugin.IsDisabled = fakeFunc
	FuBarPlugin.CreateBasicPluginFrame = fakeFunc
	FuBarPlugin.CreatePluginChildFrame = fakeFunc
	FuBarPlugin.AddImpliedMenuOptions = fakeFunc
	FuBarPlugin.UpdateTooltip = fakeFunc

	local brokerPlugins = {}
	local folderNames = {}
	local tablets = {}
	local currentTip = {}

	function FuBarPlugin:OnEmbedInitialize(addon)
		local name = addon:ToString()
		local frame = CreateFrame("Frame")
		local icon = frame:CreateTexture(name .. "Icon", "ARTWORK")
		local text = frame:CreateFontString(name .. "Text", "ARTWORK")

		addon.frame = frame
		addon.text = text
	end

	-- ONLY PUT ADDONS ON THIS LIST THAT ARE IN FACT QUICKLAUNCHERS
	-- THIS MEANS ADDONS THAT DOES NOT PROVIDE ANY TEXT BUT THEIR NAME
	-- FOR EXAMPLE, VIOLATION OR CLOSETGNOME ARE NOT QUICKLAUNCHERS, THEY BOTH DYNAMICALLY UPDATE THEIR TEXT.
	-- FUBAR2BROKER WILL DETECT THIS BY LOOKING FOR THE ADDON METHOD addon.OnTextUpdate and addon.OnTooltipUpdate, (FOR EXAMPLE ORA2 DOESN'T HAVE THESE FUNCTIONS)
	-- THIS MEANS THAT ONLY IN **VERY RARE** CASES SHOULD AN ADDON BE ADDED TO THIS LIST
	-- THIS COULD BE ADDONS THAT DOESN'T HAVE .OnTextUpdate BUT STILL PROVIDES .OnTooltipUpdate, BUT THE TOOLTIP IS QUITE REDUNDANT (EXAMPLE: PRAT)
	--
	-- REMEMBER THAT DISPLAY ADDONS MUST GET THE LAUNCHER NAME ITSELF FROM THE TOC INFO API OR USE .LABEL!

	local quickLaunchers = {
		["ag_UnitFrames"] = true,
		["Bartender3"] = true,
		["Prat"] = true,
	}

	function FuBarPlugin:OnEmbedEnable(addon)
		if brokerPlugins[addon] then return end
		local name = addon:ToString()
		if broker.proxystorage[name] then
			DEFAULT_CHAT_FRAME:AddMessage("FuBar2Broker: Broker plugin " .. (name or "unknown") .. " already exists, aborting. This is most likely due to the addon attempting to create both a native Broker plugin and a FuBar plugin.")
			return
		end
		local brokerIcon = addon.icon or addon.hasIcon
		local brokerPlugin
		local pluginType = (not (addon.OnTextUpdate or addon.UpdateText ~= FuBarPlugin.UpdateText) or quickLaunchers[name]) and "launcher" or "data source"
		if brokerIcon then
			if type(brokerIcon) ~= "string" then
				brokerIcon = "Interface\\AddOns\\"
			end
		end
		brokerPlugin = broker:NewDataObject(name, {type = pluginType, icon = brokerIcon, label = name, tocname = folderNames[addon]})
		if not brokerPlugin then
			DEFAULT_CHAT_FRAME:AddMessage("FuBar2Broker: Failed to create data object for FuBar plugin " .. (name or "unknown") .. ", aborting. This is most likely due to the addon attempting to create both a native Broker plugin and a FuBar plugin.")
			return
		end

		brokerPlugins[addon] = brokerPlugin

		addon:SetIcon(addon.icon or addon.hasIcon)

		if addon.OnDoubleClick then
			DEFAULT_CHAT_FRAME:AddMessage("FuBar2Broker: Plugin " .. name .. " implements an OnDoubleClick() handler; if your Broker display does not implement OnDoubleClick(), please middle-click the plugin instead to simulate a double click.")

			brokerPlugin.OnDoubleClick = function(frame, button)
				addon.OnDoubleClick(addon, button)
			end
		end

		brokerPlugin.OnClick = function(frame, button)
			if button == "RightButton" and addon.OnMenuRequest then
				FuBarPlugin:OpenMenu(frame, addon)
			elseif button == "MiddleButton" and addon.OnDoubleClick then
				addon.OnDoubleClick(addon, button)
			elseif addon.OnClick then
				addon.OnClick(addon, button)
			end
		end

		brokerPlugin.OnEnter = function(frame)
			addon.frame = frame
			if not addon.blizzardTooltip and not tablets[frame] then
				FuBarPlugin:TabletRegister(frame, addon)
				tablets[frame] = true
			end
			FuBarPlugin:OpenTooltip(frame, addon, true)
			currentTip[addon] = frame
		end

		brokerPlugin.OnLeave = function(frame)
			if addon.blizzardTooltip then
				GameTooltip:Hide()
			end
		end

		addon.UpdateTooltip = function()
			if currentTip[addon] and ((addon.blizzardTooltip and GameTooltip:GetOwner() == currentTip[addon] or not addon.blizzardTooltip)) then
				FuBarPlugin:OpenTooltip(currentTip[addon], addon)
			end
		end

		addon:Update()
	end

	function FuBarPlugin:OnProfileEnable()
		self:Update()
	end

	function FuBarPlugin:OnInstanceInit(target)
		local folderName
		for i = 6, 3, -1 do
			folderName = debugstack(i, 1, 0):match("\\AddOns\\(.*)\\")
			if folderName then
				break
			end
		end
		target.folderName = folderName
		folderNames[target] = folderName
	end

	local fakeOption = {
		hidden = function()
			return true
		end,
		type = "text",
		set = fakeFunc,
		get = fakeFunc,
		desc = "nil",
		name = "nil",
		usage = "nil",
	}

	function FuBarPlugin:GetAceOptionsDataTable()
		return {
			icon = fakeOption,
			text = fakeOption,
			colorText = fakeOption,
			detachTooltip = fakeOption,
			lockTooltip = fakeOption,
			position = fakeOption,
			minimapAttach = fakeOption,
			hide = fakeOption,
		}
	end

	function FuBarPlugin:SetIcon(path)
		if brokerPlugins[self] then
			if type(path) ~= "string" then
				path = format("Interface\\AddOns\\%s\\icon", folderNames[self] or self.folderName)
			elseif not path:find("^Interface[\\/]") then
				path = format("Interface\\AddOns\\%s\\%s", folderNames[self] or self.folderName, path)
			end
			brokerPlugins[self].icon = path
		end
	end

	function FuBarPlugin:SetText(text)
		if brokerPlugins[self] then
			brokerPlugins[self].text = text
		end
	end

	function FuBarPlugin:GetTitle()
		local name = self.title or self.name
		return name
	end

	function FuBarPlugin:Update()
		self:UpdateData()

		-- only call UpdateText() if plugin is a data source, as launchers do/should not have a text field
		local brokerPlugin = brokerPlugins[self]
		if brokerPlugin and brokerPlugin.type == "data source" then
			self:UpdateText()
		end

		self:UpdateTooltip()
	end

	function FuBarPlugin:UpdateText()
		if type(self.OnTextUpdate) == "function" then
			self:OnTextUpdate()
		else
			self:SetText(self:ToString())
		end
	end

	function FuBarPlugin:UpdateData()
		if type(self.OnDataUpdate) == "function" then
			self:OnDataUpdate()
		end
	end

	function FuBarPlugin:UpdateDisplay()
		self:UpdateText()
		self:UpdateTooltip()
	end

	function FuBarPlugin:OpenMenu(frame, addon)
		if not Dewdrop then
			Dewdrop = LibStub:GetLibrary("Dewdrop-2.0", true)
		end
		if not Dewdrop then
			return
		end
		if not Dewdrop:IsRegistered(frame) then
			if type(addon.OnMenuRequest) == "table" and (not addon.OnMenuRequest.handler or addon.OnMenuRequest.handler == frame) and addon.OnMenuRequest.type == "group" then
				Dewdrop:InjectAceOptionsTable(frame, addon.OnMenuRequest)
			end
			Dewdrop:Register(frame,
				"children", type(addon.OnMenuRequest) == "table" and addon.OnMenuRequest or function(level, value, valueN_1, valueN_2, valueN_3, valueN_4)
					if level == 1 then
						Dewdrop:AddLine(
							"text", addon:GetTitle(),
							"isTitle", true
						)
					end
					if addon.OnMenuRequest then
						addon:OnMenuRequest(level, value, false, valueN_1, valueN_2, valueN_3, valueN_4)
					end
				end,
				"point", function(frame)
					local x, y = frame:GetCenter()
					local leftRight
					if x < GetScreenWidth() / 2 then
						leftRight = "LEFT"
					else
						leftRight = "RIGHT"
					end
					if y < GetScreenHeight() / 2 then
						return "BOTTOM" .. leftRight, "TOP" .. leftRight
					else
						return "TOP" .. leftRight, "BOTTOM" .. leftRight
					end
				end,
				"dontHook", true
			)
		end
		Dewdrop:Open(frame)
	end

	function FuBarPlugin:TabletRegister(frame, addon)
		if not tablet then
			tablet = LibStub:GetLibrary("Tablet-2.0", true)
		end
		if not tablet then
			return
		end
		tablet:Register(frame,
			"children", function()
				tablet:SetTitle(addon:GetTitle())
				if type(addon.OnTooltipUpdate) == "function" then
					addon:OnTooltipUpdate()
				end
			end,
			"point", function(frame)
				if frame:GetTop() > GetScreenHeight() / 2 then
					local x = frame:GetCenter()
					if x < GetScreenWidth() / 3 then
						return "TOPLEFT", "BOTTOMLEFT"
					elseif x < GetScreenWidth() * 2 / 3 then
						return "TOP", "BOTTOM"
					else
						return "TOPRIGHT", "BOTTOMRIGHT"
					end
				else
					local x = frame:GetCenter()
					if x < GetScreenWidth() / 3 then
						return "BOTTOMLEFT", "TOPLEFT"
					elseif x < GetScreenWidth() * 2 / 3 then
						return "BOTTOM", "TOP"
					else
						return "BOTTOMRIGHT", "TOPRIGHT"
					end
				end
			end,
			"clickable", addon.clickableTooltip,
			"hideWhenEmpty", addon.tooltipHiddenWhenEmpty,
			"dontHook", true
		)
	end

	function FuBarPlugin:OpenTooltip(frame, addon, openTooltip)
		if not tablet then
			tablet = LibStub:GetLibrary("Tablet-2.0", true)
		end
		if addon.blizzardTooltip then
			local anchor
			if frame:GetTop() > GetScreenHeight() / 2 then
				local x = frame:GetCenter()
				if x < GetScreenWidth() / 2 then
					anchor = "ANCHOR_BOTTOMRIGHT"
				else
					anchor = "ANCHOR_BOTTOMLEFT"
				end
			else
				local x = frame:GetCenter()
				if x < GetScreenWidth() / 2 then
					anchor = "ANCHOR_TOPLEFT"
				else
					anchor = "ANCHOR_TOPRIGHT"
				end
			end
			GameTooltip:SetOwner(frame, anchor)
			if type(addon.OnTooltipUpdate) == "function" then
				addon:OnTooltipUpdate()
			end
			GameTooltip:Show()
		elseif tablet then
			if openTooltip then tablet:Open(frame) end
			tablet:Refresh(frame)
		end
	end

	local function activate(self, oldLib, oldDeactivate)
		FuBarPlugin = self

		FuBarPlugin.activate(self, oldLib, oldDeactivate)

		if oldLib then
			for k, v in pairs(oldLib) do
				oldLib[k] = self[k]
			end
		end

		if oldDeactivate then
			oldDeactivate(oldLib)
		end
	end

	AceLibrary:Register(FuBarPlugin, MAJOR_VERSION, MINOR_VERSION, activate)
end

local function OnEvent(self, event, addonName)
	if AceLibrary and AceLibrary:HasInstance("AceOO-2.0") then
		self:UnregisterEvent("ADDON_LOADED")
		self:SetScript("OnEvent", nil)

		FuBar2Broker()
	end
end

if AceLibrary and AceLibrary:HasInstance("AceOO-2.0") then
	FuBar2Broker()
else
	local f = CreateFrame("Frame")
	f:SetScript("OnEvent", OnEvent)
	f:RegisterEvent("ADDON_LOADED")
end