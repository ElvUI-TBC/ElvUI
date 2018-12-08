local E, L, V, P, G = unpack(ElvUI)
local mod = E:GetModule("DataBars")

E.Options.args.databars = {
	type = "group",
	name = L["DataBars"],
	childGroups = "tab",
	get = function(info) return E.db.databars[ info[#info] ]; end,
	set = function(info, value) E.db.databars[ info[#info] ] = value; end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["DATABAR_DESC"]
		},
		spacer = {
			order = 2,
			type = "description",
			name = ""
		},
		experience = {
			order = 3,
			type = "group",
			name = L["XP Bar"],
			get = function(info) return mod.db.experience[ info[#info] ] end,
			set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:UpdateExperienceDimensions() end,
			args = {
				header = {
 					order = 1,
					type = "header",
					name = L["XP Bar"]
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:EnableDisable_ExperienceBar() end
				},
				mouseover = {
					order = 3,
					type = "toggle",
					name = L["Mouseover"],
					disabled = function() return not mod.db.experience.enable end
				},
				hideAtMaxLevel = {
					order = 4,
					type = "toggle",
					name = L["Hide At Max Level"],
					set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:UpdateExperience() end,
					disabled = function() return not mod.db.experience.enable end
				},
				hideInCombat = {
					order = 5,
					type = "toggle",
					name = L["Hide in Combat"],
					set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:UpdateExperience() end,
					disabled = function() return not mod.db.experience.enable end
				},
				spacer = {
					order = 6,
					type = "description",
					name = ""
				},
				orientation = {
					order = 7,
					type = "select",
					name = L["Statusbar Fill Orientation"],
					desc = L["Direction the bar moves on gains/losses"],
					values = {
						["HORIZONTAL"] = L["Horizontal"],
						["VERTICAL"] = L["Vertical"]
					},
					disabled = function() return not mod.db.experience.enable end
				},
				width = {
					order = 8,
					type = "range",
					name = L["Width"],
					min = 5, max = ceil(GetScreenWidth() or 800), step = 1,
					disabled = function() return not mod.db.experience.enable end
				},
				height = {
					order = 9,
					type = "range",
					name = L["Height"],
					min = 5, max = ceil(GetScreenHeight() or 800), step = 1,
					disabled = function() return not mod.db.experience.enable end
				},
				font = {
					order = 10,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
					disabled = function() return not mod.db.experience.enable end
				},
				textSize = {
					order = 11,
					type = "range",
					name = L["Font Size"],
					min = 6, max = 22, step = 1,
					disabled = function() return not mod.db.experience.enable end
				},
				fontOutline = {
					order = 12,
					type = "select",
					name = L["Font Outline"],
					values = {
						["NONE"] = L["None"],
						["OUTLINE"] = "OUTLINE",
						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE"
					},
					disabled = function() return not mod.db.experience.enable end
				},
				textFormat = {
					order = 13,
					type = "select",
					name = L["Text Format"],
					width = "double",
					values = {
						NONE = L["None"],
						PERCENT = L["Percent"],
						CUR = L["Current"],
						REM = L["Remaining"],
						CURMAX = L["Current - Max"],
						CURPERC = L["Current - Percent"],
						CURREM = L["Current - Remaining"],
						CURPERCREM = L["Current - Percent (Remaining)"],
					},
					set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:UpdateExperience() end,
					disabled = function() return not mod.db.experience.enable end
				}
			}
		},
		reputation = {
			order = 4,
			type = "group",
			name = L["Reputation"],
			get = function(info) return mod.db.reputation[ info[#info] ] end,
			set = function(info, value) mod.db.reputation[ info[#info] ] = value; mod:UpdateReputationDimensions() end,
			args = {
				header = {
 					order = 1,
					type = "header",
					name = L["Reputation"]
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) mod.db.reputation[ info[#info] ] = value; mod:EnableDisable_ReputationBar() end
				},
				mouseover = {
					order = 3,
					type = "toggle",
					name = L["Mouseover"],
					disabled = function() return not mod.db.reputation.enable end
				},
				hideInCombat = {
					order = 4,
					type = "toggle",
					name = L["Hide in Combat"],
					set = function(info, value) mod.db.reputation[ info[#info] ] = value; mod:UpdateReputation() end,
					disabled = function() return not mod.db.reputation.enable end
				},
				spacer = {
					order = 5,
					type = "description",
					name = ""
				},
				orientation = {
					order = 6,
					type = "select",
					name = L["Statusbar Fill Orientation"],
					desc = L["Direction the bar moves on gains/losses"],
					values = {
						["HORIZONTAL"] = L["Horizontal"],
						["VERTICAL"] = L["Vertical"]
					},
					disabled = function() return not mod.db.reputation.enable end
				},
				width = {
					order = 7,
					type = "range",
					name = L["Width"],
					min = 5, max = ceil(GetScreenWidth() or 800), step = 1,
					disabled = function() return not mod.db.reputation.enable end
				},
				height = {
					order = 8,
					type = "range",
					name = L["Height"],
					min = 5, max = ceil(GetScreenHeight() or 800), step = 1,
					disabled = function() return not mod.db.reputation.enable end
				},
				font = {
					order = 9,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
					disabled = function() return not mod.db.reputation.enable end
				},
				textSize = {
					order = 10,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
					disabled = function() return not mod.db.reputation.enable end
				},
				fontOutline = {
					order = 11,
					type = "select",
					name = L["Font Outline"],
					values = {
						["NONE"] = L["None"],
						["OUTLINE"] = "OUTLINE",
						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE"
					},
					disabled = function() return not mod.db.reputation.enable end
				},
				textFormat = {
					order = 12,
					type = "select",
					name = L["Text Format"],
					width = "double",
					values = {
						NONE = L["None"],
						CUR = L["Current"],
						REM = L["Remaining"],
						PERCENT = L["Percent"],
						CURMAX = L["Current - Max"],
						CURPERC = L["Current - Percent"],
						CURREM = L["Current - Remaining"],
						CURPERCREM = L["Current - Percent (Remaining)"],
					},
					set = function(info, value) mod.db.reputation[ info[#info] ] = value; mod:UpdateReputation() end,
					disabled = function() return not mod.db.reputation.enable end
				}
			}
		}
	}
}