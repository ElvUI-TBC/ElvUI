local E, L, V, P, G = unpack(ElvUI)
local TT = E:GetModule("Tooltip")
local LSM = E.LSM

local _G = _G
local tonumber, tostring = tonumber, tostring

local GameTooltipStatusBar = _G["GameTooltipStatusBar"]

E.Options.args.tooltip = {
	type = "group",
	name = L["Tooltip"],
	childGroups = "tab",
	get = function(info) return E.db.tooltip[ info[#info] ] end,
	set = function(info, value) E.db.tooltip[ info[#info] ] = value end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["TOOLTIP_DESC"]
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.tooltip[ info[#info] ] end,
			set = function(info, value) E.private.tooltip[ info[#info] ] = value E:StaticPopup_Show("PRIVATE_RL") end
		},
		general = {
			order = 3,
			type = "group",
			name = L["General"],
			disabled = function() return not E.Tooltip end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"]
				},
				cursorAnchor = {
					order = 2,
					type = "toggle",
					name = L["Cursor Anchor"],
					desc = L["Should tooltip be anchored to mouse cursor"]
				},
				targetInfo = {
					order = 3,
					type = "toggle",
					name = L["Target Info"],
					desc = L["When in a raid group display if anyone in your raid is targeting the current tooltip unit."]
				},
				playerTitles = {
					order = 4,
					type = "toggle",
					name = L["Player Titles"],
					desc = L["Display player titles."]
				},
				guildRanks = {
					order = 5,
					type = "toggle",
					name = L["Guild Ranks"],
					desc = L["Display guild ranks if a unit is guilded."]
				},
				inspectInfo = {
					order = 6,
					type = "toggle",
					name = L["Inspect Info"],
					desc = L["Display the players talent spec and item level in the tooltip, this may not immediately update when mousing over a unit."],
				},
				itemPrice = {
					order = 7,
					type = "toggle",
					name = L["Item Price"],
					desc = L["Display vendor sell value on item tooltips."],
					set = function(info, value)
						E.db.tooltip[info[#info]] = value
						E:GetModule("Tooltip_ItemPrice"):UpdateSettings()
					end
				},
				spellID = {
					order = 8,
					type = "toggle",
					name = L["Spell/Item IDs"],
					desc = L["Display the spell or item ID when mousing over a spell or item tooltip."]
				},
				itemLevel = {
					order = 9,
					type = "toggle",
					name = L["Item Level"],
					desc = L["Display the item level when mousing over a item."]
				},
				spacer = {
					order = 10,
					type = "description",
					name = ""
				},
				itemCount = {
					order = 11,
					type = "select",
					name = L["Item Count"],
					desc = L["Display how many of a certain item you have in your possession."],
					values = {
						["BAGS_ONLY"] = L["Bags Only"],
						["BANK_ONLY"] = L["Bank Only"],
						["BOTH"] = L["Both"],
						["NONE"] = L["None"]
					}
				},
				colorAlpha = {
					order = 12,
					type = "range",
					name = L["Opacity"],
					isPercent = true,
					min = 0, max = 1, step = 0.01
				},
				fontGroup = {
					order = 13,
					type = "group",
					name = L["Tooltip Font Settings"],
					guiInline = true,
					args = {
						font = {
							order = 1,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
							get = function(info) return E.db.tooltip.font end,
							set = function(info, value) E.db.tooltip.font = value TT:SetTooltipFonts() end
						},
						fontOutline = {
							order = 2,
							type = "select",
							name = L["Font Outline"],
							values = {
								["NONE"] = L["None"],
								["OUTLINE"] = "OUTLINE",
								["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
								["THICKOUTLINE"] = "THICKOUTLINE"
							},
							get = function(info) return E.db.tooltip.fontOutline end,
							set = function(info, value) E.db.tooltip.fontOutline = value TT:SetTooltipFonts() end,
						},
						spacer = {
							order = 3,
							type = "description",
							name = ""
						},
						headerFontSize = {
							order = 4,
							type = "range",
							name = L["Header Font Size"],
							min = 4, max = 33, step = 1,
							get = function(info) return E.db.tooltip.headerFontSize end,
							set = function(info, value) E.db.tooltip.headerFontSize = value TT:SetTooltipFonts() end
						},
						textFontSize = {
							order = 5,
							type = "range",
							name = L["Text Font Size"],
							min = 4, max = 33, step = 1,
							get = function(info) return E.db.tooltip.textFontSize end,
							set = function(info, value) E.db.tooltip.textFontSize = value TT:SetTooltipFonts() end
						},
						smallTextFontSize = {
							order = 6,
							type = "range",
							name = L["Comparison Font Size"],
							desc = L["This setting controls the size of text in item comparison tooltips."],
							min = 4, max = 33, step = 1,
							get = function(info) return E.db.tooltip.smallTextFontSize end,
							set = function(info, value) E.db.tooltip.smallTextFontSize = value TT:SetTooltipFonts() end
						}
					}
				},
				factionColors = {
					order = 13,
					type = "group",
					name = L["Custom Faction Colors"],
					guiInline = true,
					args = {
						useCustomFactionColors = {
							order = 0,
							type = "toggle",
							name = L["Custom Faction Colors"],
							get = function(info) return E.db.tooltip.useCustomFactionColors end,
							set = function(info, value) E.db.tooltip.useCustomFactionColors = value end
						}
					},
					get = function(info)
						local t = E.db.tooltip.factionColors[tonumber(info[#info])]
						local d = P.tooltip.factionColors[tonumber(info[#info])]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local t = E.db.tooltip.factionColors[tonumber(info[#info])]
						t.r, t.g, t.b = r, g, b
					end
				}
			}
		},
		visibility = {
			order = 4,
			type = "group",
			name = L["Visibility"],
			get = function(info) return E.db.tooltip.visibility[ info[#info] ] end,
			set = function(info, value) E.db.tooltip.visibility[ info[#info] ] = value end,
			disabled = function() return not E.Tooltip end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Visibility"]
				},
				actionbars = {
					order = 2,
					type = "select",
					name = L["ActionBars"],
					desc = L["Choose when you want the tooltip to show. If a modifer is chosen, then you need to hold that down to show the tooltip."],
					values = {
						["ALL"] = L["Always Hide"],
						["NONE"] = L["Never Hide"],
						["SHIFT"] = L["Shift Key"],
						["ALT"] = L["ALT-Key"],
						["CTRL"] = L["CTRL-Key"]
					}
				},
				bags = {
					order = 3,
					type = "select",
					name = L["Bags/Bank"],
					desc = L["Choose when you want the tooltip to show. If a modifer is chosen, then you need to hold that down to show the tooltip."],
					values = {
						["ALL"] = L["Always Hide"],
						["NONE"] = L["Never Hide"],
						["SHIFT"] = L["Shift Key"],
						["ALT"] = L["ALT-Key"],
						["CTRL"] = L["CTRL-Key"]
					}
				},
				unitFrames = {
					order = 4,
					type = "select",
					name = L["UnitFrames"],
					desc = L["Choose when you want the tooltip to show. If a modifer is chosen, then you need to hold that down to show the tooltip."],
					values = {
						["ALL"] = L["Always Hide"],
						["NONE"] = L["Never Hide"],
						["SHIFT"] = L["Shift Key"],
						["ALT"] = L["ALT-Key"],
						["CTRL"] = L["CTRL-Key"]
					}
				},
				combat = {
					order = 5,
					type = "toggle",
					name = L["Combat"],
					desc = L["Hide tooltip while in combat."]
				}
			}
		},
		healthBar = {
			order = 5,
			type = "group",
			name = L["Health Bar"],
			get = function(info) return E.db.tooltip.healthBar[ info[#info] ] end,
			set = function(info, value) E.db.tooltip.healthBar[ info[#info] ] = value end,
			disabled = function() return not E.Tooltip end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Health Bar"]
				},
				height = {
					order = 2,
					type = "range",
					name = L["Height"],
					min = 1, max = 15, step = 1,
					set = function(info, value) E.db.tooltip.healthBar.height = value GameTooltipStatusBar:Height(value) end
				},
				statusPosition = {
					order = 3,
					type = "select",
					name = L["Position"],
					values = {
						["BOTTOM"] = L["Bottom"],
						["TOP"] = L["Top"]
					}
				},
				text = {
					order = 4,
					type = "toggle",
					name = L["Text"],
					set = function(info, value) E.db.tooltip.healthBar.text = value if(value) then GameTooltipStatusBar.text:Show(); else GameTooltipStatusBar.text:Hide() end end
				},
				font = {
					order = 5,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
					set = function(info, value)
						E.db.tooltip.healthBar.font = value
						GameTooltipStatusBar.text:FontTemplate(LSM:Fetch("font", E.db.tooltip.healthBar.font), E.db.tooltip.healthBar.fontSize, E.db.tooltip.healthBar.fontOutline)
					end,
					disabled = function() return not E.db.tooltip.healthBar.text end
				},
				fontSize = {
					order = 6,
					type = "range",
					name = L["Font Size"],
					min = 4, max = 33, step = 1,
					set = function(info, value)
						E.db.tooltip.healthBar.fontSize = value
						GameTooltipStatusBar.text:FontTemplate(LSM:Fetch("font", E.db.tooltip.healthBar.font), E.db.tooltip.healthBar.fontSize, E.db.tooltip.healthBar.fontOutline)
					end,
					disabled = function() return not E.db.tooltip.healthBar.text end
				},
				fontOutline = {
					order = 7,
					type = "select",
					name = L["Font Outline"],
					values = {
						["NONE"] = L["None"],
						["OUTLINE"] = "OUTLINE",
						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE"
					},
					set = function(info, value)
						E.db.tooltip.healthBar.fontOutline = value
						GameTooltipStatusBar.text:FontTemplate(LSM:Fetch("font", E.db.tooltip.healthBar.font), E.db.tooltip.healthBar.fontSize, E.db.tooltip.healthBar.fontOutline)
					end,
					disabled = function() return not E.db.tooltip.healthBar.text end
				}
			}
		}
	}
}

for i = 1, 8 do
	E.Options.args.tooltip.args.general.args.factionColors.args[""..i] = {
		order = i,
		type = "color",
		hasAlpha = false,
		name = _G["FACTION_STANDING_LABEL"..i],
		disabled = function() return not E.Tooltip or not E.db.tooltip.useCustomFactionColors end,
	}
end