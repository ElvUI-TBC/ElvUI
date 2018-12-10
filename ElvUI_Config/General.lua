local E, L, V, P, G = unpack(ElvUI)
local CC = E:GetModule("ClassCache")

local _G = _G

local FCF_GetNumActiveChatFrames = FCF_GetNumActiveChatFrames

_G.GetLocale = function() return GAME_LOCALE end

local function GetChatWindowInfo()
	local ChatTabInfo = {}
	for i = 1, FCF_GetNumActiveChatFrames() do
		if i ~= 2 then
			ChatTabInfo["ChatFrame"..i] = _G["ChatFrame"..i.."Tab"]:GetText()
		end
	end

	return ChatTabInfo
end

E.Options.args.general = {
	order = 1,
	type = "group",
	name = L["General"],
	childGroups = "tab",
	get = function(info) return E.db.general[ info[#info] ]; end,
	set = function(info, value) E.db.general[ info[#info] ] = value; end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["ELVUI_DESC"],
		},
		general = {
			order = 2,
			type = "group",
			name = L["General"],
			args = {
				generalHeader = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				messageRedirect = {
					order = 2,
					type = "select",
					name = L["Chat Output"],
					desc = L["This selects the Chat Frame to use as the output of ElvUI messages."],
					values = GetChatWindowInfo()
				},
				interruptAnnounce = {
					order = 3,
					type = "select",
					name = L["Announce Interrupts"],
					desc = L["Announce when you interrupt a spell to the specified chat channel."],
					values = {
						["NONE"] = L["None"],
						["SAY"] = L["Say"],
						["PARTY"] = L["Party Only"],
						["RAID"] = L["Party / Raid"],
						["RAID_ONLY"] = L["Raid Only"],
						["EMOTE"] = L["Emote"]
					}
				},
				autoRepair = {
					order = 4,
					type = "select",
					name = L["Auto Repair"],
					desc = L["Automatically repair using the following method when visiting a merchant."],
					values = {
						["NONE"] = L["None"],
						["GUILD"] = L["Guild"],
						["PLAYER"] = L["Player"]
					}
				},
				pixelPerfect = {
					order = 5,
					type = "toggle",
					name = L["Thin Border Theme"],
					desc = L["The Thin Border Theme option will change the overall apperance of your UI. Using Thin Border Theme is a slight performance increase over the traditional layout."],
					get = function(info) return E.private.general.pixelPerfect; end,
					set = function(info, value) E.private.general.pixelPerfect = value; E:StaticPopup_Show("PRIVATE_RL"); end
				},
				autoAcceptInvite = {
					order = 6,
					type = "toggle",
					name = L["Accept Invites"],
					desc = L["Automatically accept invites from guild/friends."]
				},
				autoRoll = {
					order = 7,
					type = "toggle",
					name = L["Auto Greed/DE"],
					desc = L["Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level."],
					disabled = function() return not E.private.general.lootRoll; end
				},
				loot = {
					order = 8,
					type = "toggle",
					name = L["Loot"],
					desc = L["Enable/Disable the loot frame."],
					get = function(info) return E.private.general.loot; end,
					set = function(info, value) E.private.general.loot = value; E:StaticPopup_Show("PRIVATE_RL"); end
				},
				lootRoll = {
					order = 9,
					type = "toggle",
					name = L["Loot Roll"],
					desc = L["Enable/Disable the loot roll frame."],
					get = function(info) return E.private.general.lootRoll; end,
					set = function(info, value) E.private.general.lootRoll = value; E:StaticPopup_Show("PRIVATE_RL"); end
				},
				eyefinity = {
					order = 10,
					type = "toggle",
					name = L["Multi-Monitor Support"],
					desc = L["Attempt to support eyefinity/nvidia surround."],
					get = function(info) return E.global.general.eyefinity; end,
					set = function(info, value) E.global.general[ info[#info] ] = value; E:StaticPopup_Show("GLOBAL_RL"); end
				},
				hideErrorFrame = {
					order = 11,
					type = "toggle",
					name = L["Hide Error Text"],
					desc = L["Hides the red error text at the top of the screen while in combat."]
				},
				taintLog = {
					order = 12,
					type = "toggle",
					name = L["Log Taints"],
					desc = L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."]
				},
				bottomPanel = {
					order = 13,
					type = "toggle",
					name = L["Bottom Panel"],
					desc = L["Display a panel across the bottom of the screen. This is for cosmetic only."],
					get = function(info) return E.db.general.bottomPanel; end,
					set = function(info, value) E.db.general.bottomPanel = value; E:GetModule("Layout"):BottomPanelVisibility(); end
				},
				topPanel = {
					order = 14,
					type = "toggle",
					name = L["Top Panel"],
					desc = L["Display a panel across the top of the screen. This is for cosmetic only."],
					get = function(info) return E.db.general.topPanel; end,
					set = function(info, value) E.db.general.topPanel = value; E:GetModule("Layout"):TopPanelVisibility(); end
				},
				afk = {
					order = 15,
					type = "toggle",
					name = L["AFK Mode"],
					desc = L["When you go AFK display the AFK screen."],
					get = function(info) return E.db.general.afk; end,
					set = function(info, value) E.db.general.afk = value; E:GetModule("AFK"):Toggle(); end
				},
				enhancedPvpMessages = {
					order = 16,
					type = "toggle",
					name = L["Enhanced PVP Messages"],
					desc = L["Display battleground messages in the middle of the screen."],
				},
				autoScale = {
					order = 17,
					type = "toggle",
					name = L["Auto Scale"],
					desc = L["Automatically scale the User Interface based on your screen resolution"],
					get = function(info) return E.global.general.autoScale; end,
					set = function(info, value) E.global.general[ info[#info] ] = value; E:StaticPopup_Show("GLOBAL_RL") end
				},
				spacer = {
					order = 18,
					type = "description",
					name = ""
				},
				minUiScale = {
					order = 19,
					type = "range",
					name = L["Lowest Allowed UI Scale"],
					min = 0.32, max = 0.64, step = 0.01,
					get = function(info) return E.global.general.minUiScale; end,
					set = function(info, value) E.global.general.minUiScale = value; E:StaticPopup_Show("GLOBAL_RL"); end
				},
				decimalLength = {
					order = 20,
					type = "range",
					name = L["Decimal Length"],
					desc = L["Controls the amount of decimals used in values displayed on elements like NamePlates and UnitFrames."],
					min = 0, max = 4, step = 1,
					get = function(info) return E.db.general.decimalLength end,
					set = function(info, value) E.db.general.decimalLength = value; E:StaticPopup_Show("GLOBAL_RL") end
				},
				numberPrefixStyle = {
					order = 21,
					type = "select",
					name = L["Unit Prefix Style"],
					desc = L["The unit prefixes you want to use when values are shortened in ElvUI. This is mostly used on UnitFrames."],
					get = function(info) return E.db.general.numberPrefixStyle; end,
					set = function(info, value) E.db.general.numberPrefixStyle = value; E:StaticPopup_Show("CONFIG_RL"); end,
					values = {
						["METRIC"] = "Metric (k, M, G)",
						["ENGLISH"] = "English (K, M, B)",
						["CHINESE"] = "Chinese (W, Y)",
						["KOREAN"] = "Korean (천, 만, 억)",
						["GERMAN"] = "German (Tsd, Mio, Mrd)"
					}
				},
				GameLocale = {
					order = 22,
					type = "select",
					name = L["Change Language"],
					desc = L["Change the ElvUI option to a different language."],
					get = function(info) return GAME_LOCALE end,
					set = function(info, value) GAME_LOCALE = value E:StaticPopup_Show("PRIVATE_RL") end,
					values = {
						["enUS"] = "English (enUS/enGB)",
						["esES"] = "Spanish (esES/esMX)",
						["ptBR"] = "Portuguese (ptBR)",
						["frFR"] = "French (frFR)",
						["deDE"] = "German (deDE)",
						["koKR"] = "Korean (koKR)",
						["zhCN"] = "Chinese (zhCN)",
						["zhTW"] = "Taiwanese (zhTW)",
						["ruRU"] = "Russian (ruRU)"
					}
				}
			}
		},
		media = {
			order = 3,
			type = "group",
			name = L["Media"],
			get = function(info) return E.db.general[ info[#info] ]; end,
			set = function(info, value) E.db.general[ info[#info] ] = value end,
			args = {
				fontHeader = {
					order = 1,
					type = "header",
					name = L["Fonts"]
				},
				font = {
					order = 2,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Default Font"],
					desc = L["The font that the core of the UI will use."],
					values = AceGUIWidgetLSMlists.font,
					set = function(info, value) E.db.general[ info[#info] ] = value E:UpdateMedia() E:UpdateFontTemplates() end
				},
				fontSize = {
					order = 3,
					type = "range",
					name = L["Font Size"],
					desc = L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"],
					min = 4, max = 33, step = 1,
					set = function(info, value) E.db.general[ info[#info] ] = value E:UpdateMedia() E:UpdateFontTemplates() end
				},
				fontStyle = {
					order = 4,
					type = "select",
					name = L["Font Outline"],
					values = {
						["NONE"] = L["None"],
						["OUTLINE"] = "OUTLINE",
						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE"
					},
					set = function(info, value) E.db.general[ info[#info] ] = value E:UpdateMedia() E:UpdateFontTemplates() end
				},
				applyFontToAll = {
					order = 5,
					type = "execute",
					name = L["Apply Font To All"],
					desc = L["Applies the font and font size settings throughout the entire user interface. Note: Some font size settings will be skipped due to them having a smaller font size by default."],
					func = function() E:StaticPopup_Show("APPLY_FONT_WARNING"); end
				},
				dmgfont = {
					order = 6,
					type = "select", dialogControl = "LSM30_Font",
					name = L["CombatText Font"],
					desc = L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return E.private.general[ info[#info] ]; end,
					set = function(info, value) E.private.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); E:StaticPopup_Show("PRIVATE_RL"); end
				},
				namefont = {
					order = 7,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Name Font"],
					desc = L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return E.private.general[ info[#info] ]; end,
					set = function(info, value) E.private.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); E:StaticPopup_Show("PRIVATE_RL"); end
				},
				replaceBlizzFonts = {
					order = 8,
					type = "toggle",
					name = L["Replace Blizzard Fonts"],
					desc = L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI config. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."],
					get = function(info) return E.private.general[ info[#info] ]; end,
					set = function(info, value) E.private.general[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end
				},
				texturesHeaderSpacing = {
					order = 9,
					type = "description",
					name = " "
				},
				texturesHeader = {
					order = 10,
					type = "header",
					name = L["Textures"]
				},
				normTex = {
					order = 11,
					type = "select", dialogControl = "LSM30_Statusbar",
					name = L["Primary Texture"],
					desc = L["The texture that will be used mainly for statusbars."],
					values = AceGUIWidgetLSMlists.statusbar,
					get = function(info) return E.private.general[ info[#info] ]; end,
					set = function(info, value)
						local previousValue = E.private.general[ info[#info] ];
						E.private.general[ info[#info] ] = value;

						if(E.db.unitframe.statusbar == previousValue) then
							E.db.unitframe.statusbar = value;
							E:UpdateAll(true);
						else
							E:UpdateMedia();
							E:UpdateStatusBars();
						end
					end
				},
				glossTex = {
					order = 12,
					type = "select", dialogControl = "LSM30_Statusbar",
					name = L["Secondary Texture"],
					desc = L["This texture will get used on objects like chat windows and dropdown menus."],
					values = AceGUIWidgetLSMlists.statusbar,
					get = function(info) return E.private.general[ info[#info] ]; end,
					set = function(info, value)
						E.private.general[ info[#info] ] = value;
						E:UpdateMedia();
						E:UpdateFrameTemplates();
					end
				},
				applyTextureToAll = {
					order = 13,
					type = "execute",
					name = L["Apply Texture To All"],
					desc = L["Applies the primary texture to all statusbars."],
					func = function()
						local texture = E.private.general.normTex;
						E.db.unitframe.statusbar = texture;
						E:UpdateAll(true);
					end
				},
				cropIcon = {
					order = 14,
					type = "toggle",
					name = L["Crop Icons"],
					desc = L["This is for Customized Icons in your Interface/Icons folder."],
					get = function(info) return E.db.general[ info[#info] ] end,
					set = function(info, value) E.db.general[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				colorsHeaderSpacing = {
					order = 15,
					type = "description",
					name = " "
				},
				colorsHeader = {
					order = 16,
					type = "header",
					name = L["Colors"]
				},
				bordercolor = {
					order = 17,
					type = "color",
					name = L["Border Color"],
					desc = L["Main border color of the UI."],
					hasAlpha = false,
					get = function(info)
						local t = E.db.general[ info[#info] ];
						local d = P.general[info[#info]];
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
					end,
					set = function(info, r, g, b)
						local t = E.db.general[ info[#info] ];
						t.r, t.g, t.b = r, g, b;
						E:UpdateMedia();
						E:UpdateBorderColors();
					end,
				},
				backdropcolor = {
					order = 18,
					type = "color",
					name = L["Backdrop Color"],
					desc = L["Main backdrop color of the UI."],
					hasAlpha = false,
					get = function(info)
						local t = E.db.general[ info[#info] ];
						local d = P.general[info[#info]];
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
					end,
					set = function(info, r, g, b)
						local t = E.db.general[ info[#info] ];
						t.r, t.g, t.b = r, g, b;
						E:UpdateMedia();
						E:UpdateBackdropColors();
					end
				},
				backdropfadecolor = {
					order = 19,
					type = "color",
					name = L["Backdrop Faded Color"],
					desc = L["Backdrop color of transparent frames"],
					hasAlpha = true,
					get = function(info)
						local t = E.db.general[ info[#info] ];
						local d = P.general[info[#info]];
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a;
					end,
					set = function(info, r, g, b, a)
						local t = E.db.general[ info[#info] ];
						t.r, t.g, t.b, t.a = r, g, b, a;
						E:UpdateMedia();
						E:UpdateBackdropColors();
					end
				},
				valuecolor = {
					order = 20,
					type = "color",
					name = L["Value Color"],
					desc = L["Color some texts use."],
					hasAlpha = false,
					get = function(info)
						local t = E.db.general[ info[#info] ];
						local d = P.general[info[#info]];
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
					end,
					set = function(info, r, g, b, a)
						local t = E.db.general[ info[#info] ];
						t.r, t.g, t.b, t.a = r, g, b, a;
						E:UpdateMedia();
					end
				}
			}
		},
		classCache = {
			order = 4,
			type = "group",
			name = L["Class Cache"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Class Cache"]
				},
				classCacheEnable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable class caching to colorize names in chat and nameplates."],
					get = function(info) return E.private.general.classCache end,
					set = function(info, value)
						E.private.general.classCache = value
						CC:ToggleModule()
					end
				},
				classCacheRequestInfo = {
					order = 3,
					type = "toggle",
					name = L["Request info for class cache"],
					desc = L["Use LibWho to cache class info"],
					get = function(info) return E.db.general.classCacheRequestInfo end,
					set = function(info, value)
						E.db.general.classCacheRequestInfo = value
					end,
					disabled = function() return not E.private.general.classCache end
				},
				cache = {
					order = 4,
					type = "group",
					name = L["Cache"],
					guiInline = true,
					args = {
						classCacheStoreInDB = {
							order = 1,
							type = "toggle",
							name = L["Store cache in DB"],
							desc = L["If cache stored in DB it will be available between game sessions but it will increase memory usage.\nIn other way it will be wiped on relog or UI reload."],
							get = function(info) return E.db.general.classCacheStoreInDB end,
							set = function(info, value)
								E.db.general.classCacheStoreInDB = value
								CC:SwitchCacheType()
							end,
							disabled = function() return not E.private.general.classCache end
						},
						wipeClassCacheGlobal = {
							order = 2,
							type = "execute",
							name = L["Wipe DB Cache"],
							buttonElvUI = true,
							func = function()
								CC:WipeCache(true)
								GameTooltip:Hide()
							end,
							disabled = function() return not CC:GetCacheSize(true) end
						},
						wipeClassCacheLocal = {
							order = 3,
							type = "execute",
							name = L["Wipe Session Cache"],
							buttonElvUI = true,
							func = function()
								CC:WipeCache()
								GameTooltip:Hide()
							end,
							disabled = function() return not CC:GetCacheSize() end
						}
					}
				}
			}
		},
		totems = {
			order = 5,
			type = "group",
			name = L["Totem Bar"],
			get = function(info) return E.db.general.totems[ info[#info] ]; end,
			set = function(info, value) E.db.general.totems[ info[#info] ] = value; E:GetModule("Totems"):PositionAndSize(); end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Totem Bar"]
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.totems[ info[#info] ] = value; E:GetModule("Totems"):ToggleEnable(); end
				},
				size = {
					order = 3,
					type = "range",
					name = L["Button Size"],
					min = 24, max = 60, step = 1
				},
				spacing = {
					order = 4,
					type = "range",
					name = L["Button Spacing"],
					min = 1, max = 10, step = 1
				},
				sortDirection = {
					order = 5,
					type = "select",
					name = L["Sort Direction"],
					values = {
						["ASCENDING"] = L["Ascending"],
						["DESCENDING"] = L["Descending"]
					}
				},
				growthDirection = {
					order = 6,
					type = "select",
					name = L["Bar Direction"],
					values = {
						["VERTICAL"] = L["Vertical"],
						["HORIZONTAL"] = L["Horizontal"]
					}
				}
			}
		},
		chatBubbles = {
			order = 6,
			type = "group",
			name = L["Chat Bubbles"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Chat Bubbles"]
				},
				style = {
					order = 2,
					type = "select",
					name = L["Chat Bubbles Style"],
					desc = L["Skin the blizzard chat bubbles."],
					get = function(info) return E.private.general.chatBubbles; end,
					set = function(info, value) E.private.general.chatBubbles = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					values = {
						["backdrop"] = L["Skin Backdrop"],
						["nobackdrop"] = L["Remove Backdrop"],
						["backdrop_noborder"] = L["Skin Backdrop (No Borders)"],
						["disabled"] = L["Disable"]
					}
				},
				name = {
					order = 3,
					type = "toggle",
					name = L["Chat Bubble Names"],
					desc = L["Display the name of the unit on the chat bubble."],
					get = function(info) return E.private.general.chatBubbleName end,
					set = function(info, value) E.private.general.chatBubbleName = value; E:StaticPopup_Show("PRIVATE_RL") end,
					disabled = function() return E.private.general.chatBubbles == "nobackdrop" or E.private.general.chatBubbles == "disabled" end
				},
				spacer = {
					order = 4,
					type = "description",
					name = ""
				},
				font = {
					order = 5,
					type = "select",
					name = L["Font"],
					dialogControl = "LSM30_Font",
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return E.private.general.chatBubbleFont; end,
					set = function(info, value) E.private.general.chatBubbleFont = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					disabled = function() return E.private.general.chatBubbles == "disabled"; end
				},
				fontSize = {
					order = 6,
					type = "range",
					name = L["Font Size"],
					get = function(info) return E.private.general.chatBubbleFontSize; end,
					set = function(info, value) E.private.general.chatBubbleFontSize = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					min = 4, max = 33, step = 1,
					disabled = function() return E.private.general.chatBubbles == "disabled"; end
				},
				fontOutline = {
					order = 7,
					type = "select",
					name = L["Font Outline"],
					get = function(info) return E.private.general.chatBubbleFontOutline end,
					set = function(info, value) E.private.general.chatBubbleFontOutline = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					disabled = function() return E.private.general.chatBubbles == "disabled" end,
					values = {
						["NONE"] = L["None"],
						["OUTLINE"] = "OUTLINE",
						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE",
					}
				}
			}
		},
		threatGroup = {
			order = 7,
			type = "group",
			name = L["Threat"],
			args = {
				threatHeader = {
					order = 1,
					type = "header",
					name = L["Threat"]
				},
				threatLibStatus = {
					order = 2,
					type = "description",
					image = function() return E:GetModule("Threat"):GetLibStatus() and READY_CHECK_READY_TEXTURE or READY_CHECK_NOT_READY_TEXTURE, 30, 26 end,
					name = function()
						if E:GetModule("Threat"):GetLibStatus() then
							return L["Library Threat-2.0 found."]
						else
							return L["Library Threat-2.0 not found. If you want to use Threat module install Omen or separate Threat-2.0 library."]
						end
					end
				},
				threatEnable = {
					order = 3,
					type = "toggle",
					name = L["Enable"],
					get = function(info) return E.db.general.threat.enable end,
					set = function(info, value) E.db.general.threat.enable = value; E:GetModule("Threat"):ToggleEnable() end
				},
				threatPosition = {
					order = 4,
					type = "select",
					name = L["Position"],
					desc = L["Adjust the position of the threat bar to either the left or right datatext panels."],
					values = {
						["LEFTCHAT"] = L["Left Chat"],
						["RIGHTCHAT"] = L["Right Chat"]
					},
					get = function(info) return E.db.general.threat.position end,
					set = function(info, value) E.db.general.threat.position = value; E:GetModule("Threat"):UpdatePosition() end,
					disabled = function() return not E.db.general.threat.enable end
				},
				spacer = {
					order = 5,
					type = "description",
					name = ""
				},
				threatTextfont = {
					order = 6,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return E.db.general.threat.textfont end,
					set = function(info, value) E.db.general.threat.textfont = value; E:GetModule("Threat"):UpdatePosition() end,
					disabled = function() return not E.db.general.threat.enable end
				},
				threatTextSize = {
					order = 7,
					type = "range",
					name = L["Font Size"],
					min = 6, max = 22, step = 1,
					get = function(info) return E.db.general.threat.textSize; end,
					set = function(info, value) E.db.general.threat.textSize = value E:GetModule("Threat"):UpdatePosition() end,
					disabled = function() return not E.db.general.threat.enable end
				},
				threatTextOutline = {
					order = 8,
					type = "select",
					name = L["Font Outline"],
					desc = L["Set the font outline."],
					values = {
						["NONE"] = L["None"],
						["OUTLINE"] = "OUTLINE",
						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE"
					},
					get = function(info) return E.db.general.threat.textOutline end,
					set = function(info, value) E.db.general.threat.textOutline = value E:GetModule("Threat"):UpdatePosition() end,
					disabled = function() return not E.db.general.threat.enable end
				}
			}
		}
	}
}