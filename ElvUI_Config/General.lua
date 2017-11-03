local E, L, V, P, G = unpack(ElvUI);
local CC = E:GetModule("ClassCache")

E.Options.args.general = {
	type = "group",
	name = L["General"],
	order = 1,
	childGroups = "tab",
	get = function(info) return E.db.general[ info[#info] ]; end,
	set = function(info, value) E.db.general[ info[#info] ] = value; end,
	args = {
		versionCheck = {
			order = 1,
			type = "toggle",
			name = L["Version Check"],
			get = function(info) return E.global.general.versionCheck; end,
			set = function(info, value) E.global.general.versionCheck = value; end
		},
		spacer = {
			order = 2,
			type = "description",
			name = "",
			width = "full",
		},
		intro = {
			order = 3,
			type = "description",
			name = L["ELVUI_DESC"],
		},
		general = {
			order = 4,
			type = "group",
			name = L["General"],
			args = {
				generalHeader = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				pixelPerfect = {
					order = 2,
					type = "toggle",
					name = L["Thin Border Theme"],
					desc = L["The Thin Border Theme option will change the overall apperance of your UI. Using Thin Border Theme is a slight performance increase over the traditional layout."],
					get = function(info) return E.private.general.pixelPerfect; end,
					set = function(info, value) E.private.general.pixelPerfect = value; E:StaticPopup_Show("PRIVATE_RL"); end
				},
				interruptAnnounce = {
					order = 3,
					type = "select",
					name = L["Announce Interrupts"],
					desc = L["Announce when you interrupt a spell to the specified chat channel."],
					values = {
						["NONE"] = NONE,
						["SAY"] = SAY,
						["PARTY"] = L["Party Only"],
						["RAID"] = L["Party / Raid"],
						["RAID_ONLY"] = L["Raid Only"],
						["EMOTE"] = CHAT_MSG_EMOTE
					}
				},
				autoRepair = {
					order = 4,
					type = "select",
					name = L["Auto Repair"],
					desc = L["Automatically repair using the following method when visiting a merchant."],
					values = {
						["NONE"] = NONE,
						["GUILD"] = GUILD,
						["PLAYER"] = PLAYER
					}
				},
				autoAcceptInvite = {
					order = 5,
					type = "toggle",
					name = L["Accept Invites"],
					desc = L["Automatically accept invites from guild/friends."]
				},
				vendorGrays = {
					order = 6,
					type = "toggle",
					name = L["Vendor Grays"],
					desc = L["Automatically vendor gray items when visiting a vendor."]
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
					name = L["Multi-Monitor Support"],
					desc = L["Attempt to support eyefinity/nvidia surround."],
					type = "toggle",
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
				raidUtility = {
					order = 17,
					type = "toggle",
					name = RAID_CONTROL,
					desc = L["Enables the ElvUI Raid Control panel."],
					get = function(info) return E.private.general.raidUtility end,
					set = function(info, value) E.private.general.raidUtility = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				autoScale = {
					order = 18,
					name = L["Auto Scale"],
					desc = L["Automatically scale the User Interface based on your screen resolution"],
					type = "toggle",
					get = function(info) return E.global.general.autoScale; end,
					set = function(info, value) E.global.general[ info[#info] ] = value; E:StaticPopup_Show("GLOBAL_RL") end
				},
				minUiScale = {
					order = 19,
					type = "range",
					name = L["Lowest Allowed UI Scale"],
					min = 0.32, max = 0.64, step = 0.01,
					get = function(info) return E.global.general.minUiScale; end,
					set = function(info, value) E.global.general.minUiScale = value; E:StaticPopup_Show("GLOBAL_RL"); end
				},
				numberPrefixStyle = {
					order = 20,
					type = "select",
					name = L["Number Prefix"],
					get = function(info) return E.db.general.numberPrefixStyle; end,
					set = function(info, value) E.db.general.numberPrefixStyle = value; E:StaticPopup_Show("CONFIG_RL"); end,
					values = {
						["METRIC"] = "k, M, G",
						["ENGLISH"] = "K, M, B",
						["CHINESE"] = "W, Y"
					}
				},
				classCacheHeader = {
					order = 51,
					type = "header",
					name = L["Class Cache"]
				},
				classCacheEnable = {
					order = 52,
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable class caching to colorize names in chat and nameplates."],
					get = function(info) return E.private.general.classCache end,
					set = function(info, value)
						E.private.general.classCache = value
						CC:ToggleModule()
					end
				},
				classCacheStoreInDB = {
					order = 53,
					type = "toggle",
					name = L["Store cache in DB"],
					desc = L["If cache stored in DB it will be available between game sessions but increase memory usage.\nIn other way it will be wiped on relog or UI reload."],
					get = function(info) return E.db.general.classCacheStoreInDB end,
					set = function(info, value)
						E.db.general.classCacheStoreInDB = value
						CC:SwitchCacheType()
					end,
					disabled = function() return not E.private.general.classCache end
				},
				classCacheRequestInfo = {
					order = 54,
					type = "toggle",
					name = L["Request info for class cache"],
					desc = L["Use LibWho to cache class info"],
					get = function(info) return E.db.general.classCacheRequestInfo end,
					set = function(info, value)
						E.db.general.classCacheRequestInfo = value
					end,
					disabled = function() return not E.private.general.classCache end
				},
				wipeClassCacheGlobal = {
					order = 55,
					type = "execute",
					name = L["Wipe DB Cache"],
					func = function()
						CC:WipeCache(true)
						GameTooltip:Hide()
					end,
					disabled = function() return not CC:GetCacheSize(true) end
				},
				wipeClassCacheLocal = {
					order = 56,
					type = "execute",
					name = L["Wipe Session Cache"],
					func = function()
						CC:WipeCache()
						GameTooltip:Hide()
					end,
					disabled = function() return not CC:GetCacheSize() end
				}
			}
		},
		media = {
			order = 5,
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
				fontSize = {
					order = 2,
					type = "range",
					name = L["Font Size"],
					desc = L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"],
					min = 4, max = 33, step = 1,
					set = function(info, value) E.db.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end
				},
				font = {
					order = 3,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Default Font"],
					desc = L["The font that the core of the UI will use."],
					values = AceGUIWidgetLSMlists.font,
					set = function(info, value) E.db.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
				},
				applyFontToAll = {
					order = 4,
					type = "execute",
					name = L["Apply Font To All"],
					desc = L["Applies the font and font size settings throughout the entire user interface. Note: Some font size settings will be skipped due to them having a smaller font size by default."],
					func = function() E:StaticPopup_Show("APPLY_FONT_WARNING"); end
				},
				dmgfont = {
					order = 5,
					type = "select", dialogControl = "LSM30_Font",
					name = L["CombatText Font"],
					desc = L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return E.private.general[ info[#info] ]; end,
					set = function(info, value) E.private.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); E:StaticPopup_Show("PRIVATE_RL"); end
				},
				namefont = {
					order = 6,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Name Font"],
					desc = L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return E.private.general[ info[#info] ]; end,
					set = function(info, value) E.private.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); E:StaticPopup_Show("PRIVATE_RL"); end
				},
				replaceBlizzFonts = {
					order = 7,
					type = "toggle",
					name = L["Replace Blizzard Fonts"],
					desc = L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI config. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."],
					get = function(info) return E.private.general[ info[#info] ]; end,
					set = function(info, value) E.private.general[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end
				},
				texturesHeaderSpacing = {
					order = 8,
					type = "description",
					name = " "
				},
				texturesHeader = {
					order = 9,
					type = "header",
					name = L["Textures"]
				},
				normTex = {
					order = 10,
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
					order = 11,
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
					order = 12,
					type = "execute",
					name = L["Apply Texture To All"],
					desc = L["Applies the primary texture to all statusbars."],
					func = function()
						local texture = E.private.general.normTex;
						E.db.unitframe.statusbar = texture;
						E:UpdateAll(true);
					end
				},
				colorsHeaderSpacing = {
					order = 13,
					type = "description",
					name = " "
				},
				colorsHeader = {
					order = 14,
					type = "header",
					name = L["Colors"]
				},
				bordercolor = {
					type = "color",
					order = 15,
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
					type = "color",
					order = 32,
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
					type = "color",
					order = 33,
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
					type = "color",
					order = 34,
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
		totems = {
			order = 6,
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
		cooldown = {
			type = "group",
			order = 7,
			name = L["Cooldown Text"],
			get = function(info)
				local t = E.db.cooldown[ info[#info] ];
				local d = P.cooldown[info[#info]];
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
			end,
			set = function(info, r, g, b)
				E.db.cooldown[ info[#info] ] = {};
				local t = E.db.cooldown[ info[#info] ];
				t.r, t.g, t.b = r, g, b;
				E:UpdateCooldownSettings();
			end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Cooldown Text"]
				},
				enable = {
					type = "toggle",
					order = 2,
					name = L["Enable"],
					desc = L["Display cooldown text on anything with the cooldown spiral."],
					get = function(info) return E.private.cooldown[ info[#info] ]; end,
					set = function(info, value) E.private.cooldown[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end
				},
				threshold = {
					type = "range",
					order = 3,
					name = L["Low Threshold"],
					desc = L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"],
					min = -1, max = 20, step = 1,
					get = function(info) return E.db.cooldown[ info[#info] ]; end,
					set = function(info, value)
						E.db.cooldown[ info[#info] ] = value;
						E:UpdateCooldownSettings();
					end
				},
				expiringColor = {
					order = 4,
					type = "color",
					name = L["Expiring"],
					desc = L["Color when the text is about to expire"]
				},
				secondsColor = {
					order = 5,
					type = "color",
					name = L["Seconds"],
					desc = L["Color when the text is in the seconds format."]
				},
				minutesColor = {
					order = 6,
					type = "color",
					name = L["Minutes"],
					desc = L["Color when the text is in the minutes format."]
				},
				hoursColor = {
					order = 7,
					type = "color",
					name = L["Hours"],
					desc = L["Color when the text is in the hours format."]
				},
				daysColor = {
					order = 8,
					type = "color",
					name = L["Days"],
					desc = L["Color when the text is in the days format."]
				}
			}
		},
		chatBubbles = {
			order = 8,
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
						["disabled"] = L["Disabled"]
					}
				},
				spacer = {
					order = 3,
					type = "description",
					name = ""
				},
				font = {
					order = 4,
					type = "select",
					name = L["Font"],
					dialogControl = "LSM30_Font",
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return E.private.general.chatBubbleFont; end,
					set = function(info, value) E.private.general.chatBubbleFont = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					disabled = function() return E.private.general.chatBubbles == "disabled"; end
				},
				fontSize = {
					order = 5,
					type = "range",
					name = L["Font Size"],
					get = function(info) return E.private.general.chatBubbleFontSize; end,
					set = function(info, value) E.private.general.chatBubbleFontSize = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					min = 4, max = 33, step = 1,
					disabled = function() return E.private.general.chatBubbles == "disabled"; end
				},
				fontOutline = {
					order = 6,
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
		watchFrame = {
			order = 9,
			type = "group",
			name = L["Watch Frame"],
			get = function(info) return E.db.general[ info[#info] ]; end,
			set = function(info, value) E.db.general[ info[#info] ] = value; end,
			args = {
				watchFrameHeader = {
					order = 1,
					type = "header",
					name = L["Watch Frame"],
				},
				watchFrameHeight = {
					order = 2,
					type = "range",
					name = L["Watch Frame Height"],
					desc = L["Height of the watch tracker. Increase size to be able to see more objectives."],
					min = 400, max = E.screenheight, step = 1,
					set = function(info, value) E.db.general[ info[#info] ] = value; E:GetModule("Blizzard"):SetWatchFrameHeight(); end
				}
			}
		},
		threatGroup = {
			order = 10,
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
					set = function(info, value) E.db.general.threat.position = value; E:GetModule("Threat"):UpdatePosition() end
				},
				threatTextSize = {
					order = 5,
					type = "range",
					min = 6, max = 22, step = 1,
					name = L["Font Size"],
					get = function(info) return E.db.general.threat.textSize end,
					set = function(info, value) E.db.general.threat.textSize = value; E:GetModule("Threat"):UpdatePosition() end
				}
			}
		}
	}
};