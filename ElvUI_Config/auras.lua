local E, L, V, P, G, _ = unpack(ElvUI);
local A = E:GetModule("Auras")

E.Options.args.auras = {
	type = "group",
	name = L["Auras"],
	childGroups = "tab",
	get = function(info) return E.db.auras[ info[#info] ] end,
	set = function(info, value) E.db.auras[ info[#info] ] = value; end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["AURAS_DESC"],
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.auras[ info[#info] ] end,
			set = function(info, value) E.private.auras[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end
		},
		general = {
			order = 3,
			type = "group",
			name = L["General"],
			get = function(info) return E.db.auras[ info[#info] ] end,
			set = function(info, value) E.db.auras[ info[#info] ] = value; A:BuffFrame_Update(); end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["General"]
				},
				size = {
					order = 1,
					type = "range",
					name = L["Size"],
					desc = L["Set the size of the individual auras."],
					min = 20, max = 60, step = 1,
				},
				perRow = {
					order = 2,
					type = "range",
					name = L["Wrap After"],
					desc = L["Begin a new row or column after this many auras."],
					min = 2, max = 25, step = 1,
				},
				spacing = {
					order = 3,
					type = "range",
					name = L["Auras Spacing"],
					desc = L["The spacing between auras."],
					min = 0, max = 30, step = 1,
				},
				fadeThreshold = {
					order = 4,
					type = "range",
					name = L["Fade Threshold"],
					desc = L["Threshold before text changes red, goes into decimal form, and the icon will fade. Set to -1 to disable."],
					min = -1, max = 30, step = 1,
				},
			},
		},
		reminder = {
			type = "group",
			order = 4,
			name = L["Reminder"],
			get = function(info) return E.db.general.reminder[ info[#info] ] end,
			set = function(info, value) E.db.general.reminder[ info[#info] ] = value; E:GetModule("ReminderBuffs"):UpdateSettings(); end,
			disabled = function() return not E.private.general.minimap.enable end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Reminder"]
				},
				enable = {
					order = 1,
					name = L["Enable"],
					desc = L["Display reminder bar on the minimap."],
					type = "toggle",
					set = function(info, value) E.db.general.reminder[ info[#info] ] = value; E:GetModule("Minimap"):UpdateSettings(); end
				},
				generalGroup = {
					order = 2,
					type = "group",
					guiInline = true,
					name = L["General"],
					disabled = function() return not E.db.general.reminder.enable end,
					args = {
						durations = {
							order = 1,
							name = L["Remaining Time"],
							type = "toggle"
						},
						reverse = {
							order = 2,
							name = L["Reverse Style"],
							desc = L["When enabled active buff icons will light up instead of becoming darker, while inactive buff icons will become darker instead of being lit up."],
							type = "toggle"
						},
						position = {
							order = 3,
							type = "select",
							name = L["Position"],
							set = function(info, value) E.db.general.reminder[ info[#info] ] = value; E:GetModule("ReminderBuffs"):UpdatePosition(); end,
							values = {
								["LEFT"] = L["Left"],
								["RIGHT"] = L["Right"]
							},
						},
					},
				},
				fontGroup = {
					order = 3,
					type = "group",
					guiInline = true,
					name = L["Font"],
					disabled = function() return not E.db.general.reminder.enable or not E.db.general.reminder.durations end,
					args = {
						font = {
							type = "select", dialogControl = "LSM30_Font",
							order = 1,
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font
						},
						fontSize = {
							order = 2,
							name = L["Font Size"],
							type = "range",
							min = 6, max = 22, step = 1
						},
						fontOutline = {
							order = 3,
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							type = "select",
							values = {
								["NONE"] = L["None"],
								["OUTLINE"] = "OUTLINE",
								["MONOCHROME"] = (not E.isMacClient) and "MONOCHROME" or nil,
								["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
								["THICKOUTLINE"] = "THICKOUTLINE"
							},
						},
					},
				},
			},
		},
		font = {
			order = 5,
			type = "group",
			name = L["Font"],
			get = function(info) return E.db.auras[ info[#info] ] end,
			set = function(info, value) E.db.auras[ info[#info] ] = value; A:BuffFrame_Update(); end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Font"]
				},
				font = {
					type = "select", dialogControl = "LSM30_Font",
					order = 4,
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				fontSize = {
					order = 5,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				fontOutline = {
					order = 6,
					name = L["Font Outline"],
					desc = L["Set the font outline."],
					type = "select",
					values = {
						["NONE"] = L["None"],
						["OUTLINE"] = "OUTLINE",
						["MONOCHROME"] = "MONOCHROME",
						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE",
					},
				},
				timeXOffset = {
					order = 5,
					type = "range",
					name = L["Time xOffset"],
					min = -60, max = 60, step = 1
				},
				timeYOffset = {
					order = 6,
					type = "range",
					name = L["Time yOffset"],
					min = -60, max = 60, step = 1
				},
				countXOffset = {
					order = 7,
					type = "range",
					name = L["Count xOffset"],
					min = -60, max = 60, step = 1
				},
				countYOffset = {
					order = 8,
					name = L["Count yOffset"],
					type = "range",
					min = -60, max = 60, step = 1
				},
			},
		},
	},
}