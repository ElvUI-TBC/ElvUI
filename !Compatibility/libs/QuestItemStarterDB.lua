local MAJOR_VERSION = "QuestItemStarterDB"
local MINOR_VERSION = 90000 + tonumber(string.match("$Revision: 1 $", "%d+"))

local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

lib.QuestItemStarterIDs = {
	[1307]	= {ITEM = "1307",	QUEST = "123"},		-- Item : Gold Pickup Schedule - Quest: The Collector (A)
	[1357]	= {ITEM = "1357",	QUEST = "136"},		-- Item : Captain Sanders' Treasure Map - Quest: Captain Sanders' Hidden Treasure
	[1962]	= {ITEM = "1962",	QUEST = "178"},		-- Item : Glowing Shadowhide Pendant - Quest: Theocritus' Retrieval (A)
	[1972]	= {ITEM = "1972",	QUEST = "184"},		-- Item : Westfall Deed - Quest: Furlbrow's Deed (A)
	[2794]	= {ITEM = "2794",	QUEST = "337"},		-- Item : An Old History Book - Quest: An Old History Book (A)
	[2839]	= {ITEM = "2839",	QUEST = "361"},		-- Item : A Letter to Yvette - Quest: A Letter Undelivered (H)
	[2874]	= {ITEM = "2874",	QUEST = "373"},		-- Item : An Unsent Letter - Quest: The Unsent Letter (A)
	[3317]	= {ITEM = "3317",	QUEST = "460"},		-- Item : A Talking Head - Quest: Resting in Pieces
	[3668]	= {ITEM = "3668",	QUEST = "522"},		-- Item : Assassin's Contract - Quest: Assassin's Contract (A)
	[3706]	= {ITEM = "3706",	QUEST = "551"},		-- Item : Ensorcelled Parchment - Quest: The Ensorcelled Parchment (A)
	[3985]	= {ITEM = "3985",	QUEST = "8552"},	-- Item : Monogrammed Sash - Quest: The Monogrammed Sash
	[4056]	= {ITEM = "4056",	QUEST = "624"},		-- Item : Cortello's Riddle - Quest: Cortello's Riddle
	[4098]	= {ITEM = "4098",	QUEST = "594"},		-- Item : Carefully Folded Note - Quest: Message in a Bottle
	[4433]	= {ITEM = "4433",	QUEST = "637"},		-- Item : Waterlogged Envelope - Quest: Sully Balloo's Letter (A)
	[4613]	= {ITEM = "4613",	QUEST = "708"},		-- Item : Corroded Black Box - Quest: The Black Box (A)
	[4614]	= {ITEM = "4614",	QUEST = "635"},		-- Item : Pendant of Myzrael - Quest: Crystal in the Mountains
	[4854]	= {ITEM = "4854",	QUEST = "770"},		-- Item : Demon Scarred Cloak - Quest: The Demon Scarred Cloak
	[4881]	= {ITEM = "4881",	QUEST = "830"},		-- Item : Aged Envelope - Quest: The Admiral's Orders (H)
	[4903]	= {ITEM = "4903",	QUEST = "832"},		-- Item : Eye of Burning Shadow - Quest: Burning Shadows (H)
	[4926]	= {ITEM = "4926",	QUEST = "819"},		-- Item : Chen's Empty Keg - Quest: Chen's Empty Keg (H)
	[5099]	= {ITEM = "5099",	QUEST = "883"},		-- Item : Hoof of Lakota'mani - Quest: Lakota'mani (H)
	[5102]	= {ITEM = "5102",	QUEST = "884"},		-- Item : Owatanka's Tailspike - Quest: Owatanka (H)
	[5103]	= {ITEM = "5103",	QUEST = "885"},		-- Item : Washte Pawne - Quest: Washte Pawne (H)
	[5138]	= {ITEM = "5138",	QUEST = "897"},		-- Item : Harvester's Head - Quest: The Harvester (H)
	[5179]	= {ITEM = "5179",	QUEST = "927"},		-- Item : Moss-Twined Heart - Quest: The Moss-twined Heart
	[5352]	= {ITEM = "5352",	QUEST = "968"},		-- Item : Book: The Powers Below - Quest: The Powers Below (A)
	[5791]	= {ITEM = "5791",	QUEST = "1100"},	-- Item : Henrig Lonebrow's Journal - Quest: Lonebrow's Journal (A)
	[5877]	= {ITEM = "5877",	QUEST = "1148"},	-- Item : Cracked Silithid Carapace - Quest: Parts of the Swarm (H)
	[6172]	= {ITEM = "6172",	QUEST = "1423"},	-- Item : Lost Supplies - Quest: The Lost Supplies (A)
	[6196]	= {ITEM = "6196",	QUEST = "1392"},	-- Item : Noboru's Cudgel - Quest: Noboru the Cudgel
	[6497]	= {ITEM = "6497",	QUEST = "2383"},	-- Item : Simple Parchment - Quest: Simple Parchment (H)
	[6775]	= {ITEM = "6775",	QUEST = "1642"},	-- Item : Tome of Divinity - Quest: The Tome of Divinity (A)
	[6776]	= {ITEM = "6776",	QUEST = "1649"},	-- Item : Tome of Valor - Quest: The Tome of Valor (A)
	[6916]	= {ITEM = "6916",	QUEST = "1646"},	-- Item : Tome of Divinity - Quest: The Tome of Divinity (A)
	[7666]	= {ITEM = "7666",	QUEST = "2198"},	-- Item : Shattered Necklace - Quest: The Shattered Necklace (A)
	[8524]	= {ITEM = "8524",	QUEST = "654"},		-- Item : Model 4711-FTZ Power Source - Quest: Tanaris Field Sampling (H)
	[8623]	= {ITEM = "8623",	QUEST = "351"},		-- Item : OOX-17/TN Distress Beacon - Quest: Find OOX-17/TN!
	[8704]	= {ITEM = "8704",	QUEST = "485"},		-- Item : OOX-09/HL Distress Beacon - Quest: Find OOX-09/HL!
	[8705]	= {ITEM = "8705",	QUEST = "2766"},	-- Item : OOX-22/FE Distress Beacon - Quest: Find OOX-22/FE!
	[9250]	= {ITEM = "9250",	QUEST = "2876"},	-- Item : Ship Schedule - Quest: Ship Schedules
	[9254]	= {ITEM = "9254",	QUEST = "2882"},	-- Item : Cuergo's Treasure Map - Quest: Cuergo's Gold
	[9326]	= {ITEM = "9326",	QUEST = "2945"},	-- Item : Grime-Encrusted Ring - Quest: Grime-Encrusted Ring
	[9370]	= {ITEM = "9370",	QUEST = "2978"},	-- Item : Gordunni Scroll - Quest: The Gordunni Scroll (H)
	[10000]	= {ITEM = "10000",	QUEST = "3181"},	-- Item : Margol's Horn - Quest: The Horn of the Beast (A)
	[10441]	= {ITEM = "10441",	QUEST = "6981"},	-- Item : Glowing Shard - Quest: The Glowing Shard
	[10454]	= {ITEM = "10454",	QUEST = "3373"},	-- Item : Essence of Eranikus - Quest: The Essence of Eranikus
	[10589]	= {ITEM = "10589",	QUEST = "3374"},	-- Item : Oathstone of Ysera's Dragonflight - Quest: The Essence of Eranikus
	[10621]	= {ITEM = "10621",	QUEST = "3513"},	-- Item : Runed Scroll - Quest: The Runed Scroll (H)
	[11116]	= {ITEM = "11116",	QUEST = "3884"},	-- Item : A Mangled Journal - Quest: Williden's Journal
	[11463]	= {ITEM = "11463",	QUEST = "4281"},	-- Item : Undelivered Parcel - Quest: Thalanaar Delivery (A)
	[11668]	= {ITEM = "11668",	QUEST = "939"},		-- Item : Flute of Xavaric - Quest: Flute of Xavaric (A)
	[11818]	= {ITEM = "11818",	QUEST = "4451"},	-- Item : Grimesilt Outhouse Key - Quest: The Key to Freedom
	[12563]	= {ITEM = "12563",	QUEST = "4903"},	-- Item : Warlord Goretooth's Command - Quest: Warlord's Command (H)
	[12564]	= {ITEM = "12564",	QUEST = "4881"},	-- Item : Assassination Note - Quest: Assassination Plot (H)
	[12558]	= {ITEM = "12558",	QUEST = "4882"},	-- Item : Blue-feathered Necklace - Quest: Guarding Secrets (H)
	[12771]	= {ITEM = "12771",	QUEST = "5083"},	-- Item : Empty Firewater Flask - Quest: Winterfall Firewater
	[12780]	= {ITEM = "12780",	QUEST = "5089"},	-- Item : General Drakkisath's Command - Quest: General Drakkisath's Command (A)
	[12842]	= {ITEM = "12842",	QUEST = "5123"},	-- Item : Crudely-Written Log - Quest: The Final Piece
	[13140]	= {ITEM = "13140",	QUEST = "5202"},	-- Item : Blood Red Key - Quest: A Strange Red Key
	[13250]	= {ITEM = "13250",	QUEST = "5262"},	-- Item : Head of Balnazzar - Quest: The Truth Comes Crashing Down
	[13920]	= {ITEM = "13920",	QUEST = "5582"},	-- Item : Healthy Dragon Scale - Quest: Healthy Dragon Scale
	[14646]	= {ITEM = "14646",	QUEST = "5805"},	-- Item : Goldshire Gift Voucher - Quest: Welcome! (A)
	[14647]	= {ITEM = "14647",	QUEST = "5841"},	-- Item : Kharanos Gift Voucher - Quest: Welcome! (A)
	[14648]	= {ITEM = "14648",	QUEST = "5842"},	-- Item : Dolanaar Gift Voucher - Quest: Welcome! (A)
	[14649]	= {ITEM = "14649",	QUEST = "5843"},	-- Item : Razor Hill Gift Voucher - Quest: Welcome! (H)
	[14650]	= {ITEM = "14650",	QUEST = "5844"},	-- Item : Bloodhoof Village Gift Voucher - Quest: Welcome! (H)
	[14651]	= {ITEM = "14651",	QUEST = "5847"},	-- Item : Brill Gift Voucher - Quest: Welcome! (H)
	[16303]	= {ITEM = "16303",	QUEST = "23"},		-- Item : Ursangous' Paw - Quest: Ursangous's Paw (H)
	[16304]	= {ITEM = "16304",	QUEST = "24"},		-- Item : Shadumbra's Head - Quest: Shadumbra's Head (H)
	[16305]	= {ITEM = "16305",	QUEST = "2"},		-- Item : Sharptalon's Claw - Quest: Sharptalon's Claw (H)
	[16408]	= {ITEM = "16408",	QUEST = "1918"},	-- Item : Befouled Water Globe - Quest: The Befouled Element (H)
	[16790]	= {ITEM = "16790",	QUEST = "6564"},	-- Item : Damp Note - Quest: Allegiance to the Old Gods (H)
	[16782]	= {ITEM = "16782",	QUEST = "6922"},	-- Item : Strange Water Globe - Quest: Baron Aquanis (H)
	[17008]	= {ITEM = "17008",	QUEST = "6522"},	-- Item : Small Scroll - Quest: An Unholy Alliance (H)
	[17126]	= {ITEM = "17126",	QUEST = "6681"},	-- Item : Elegant Letter - Quest: The Manor, Ravenholdt
	[18356]	= {ITEM = "18356",	QUEST = "7498"},	-- Item : Garona: A Study on Stealth and Treachery - Quest: Garona: A Study on Stealth and Treachery
	[18357]	= {ITEM = "18357",	QUEST = "7499"},	-- Item : Codex of Defense - Quest: Codex of Defense
	[18358]	= {ITEM = "18358",	QUEST = "7500"},	-- Item : The Arcanist's Cookbook - Quest: The Arcanist's Cookbook
	[18359]	= {ITEM = "18359",	QUEST = "7501"},	-- Item : The Light and How to Swing It - Quest: The Light and How To Swing It
	[18360]	= {ITEM = "18360",	QUEST = "7502"},	-- Item : Harnessing Shadows - Quest: Harnessing Shadows
	[18361]	= {ITEM = "18361",	QUEST = "7503"},	-- Item : The Greatest Race of Hunters - Quest: The Greatest Race of Hunters
	[18362]	= {ITEM = "18362",	QUEST = "7504"},	-- Item : Holy Bologna: What the Light Won't Tell You - Quest: Holy Bologna: What the Light Won't Tell You
	[18363]	= {ITEM = "18363",	QUEST = "7505"},	-- Item : Frost Shock and You - Quest: Frost Shock and You
	[18364]	= {ITEM = "18364",	QUEST = "7506"},	-- Item : The Emerald Dream - Quest: The Emerald Dream...
	[18401]	= {ITEM = "18401",	QUEST = "7507"},	-- Item : Foror's Compendium of Dragon Slaying - Quest: Foror's Compendium
	[18422]	= {ITEM = "18422",	QUEST = "7490"},	-- Item : Head of Onyxia - Quest: Victory for the Horde (H)
	[18423]	= {ITEM = "18423",	QUEST = "7495"},	-- Item : Head of Onyxia - Quest: Victory for the Alliance (A)
	[18565]	= {ITEM = "18565",	QUEST = "7522"},	-- Item : Vessel of Rebirth DEPRECATED - Quest: Examine the Vessel
	[18628]	= {ITEM = "18628",	QUEST = "7604"},	-- Item : Thorium Brotherhood Contract - Quest: A Binding Contract
	[18703]	= {ITEM = "18703",	QUEST = "7632"},	-- Item : Ancient Petrified Leaf - Quest: The Ancient Leaf
	[18706]	= {ITEM = "18706",	QUEST = "7810"},	-- Item : Arena Master - Quest: Arena Master
	[18769]	= {ITEM = "18769",	QUEST = "7649"},	-- Item : Enchanted Thorium Platemail - Quest: Enchanted Thorium Platemail: Volume I
	[18770]	= {ITEM = "18770",	QUEST = "7650"},	-- Item : Enchanted Thorium Platemail - Quest: Enchanted Thorium Platemail: Volume II
	[18771]	= {ITEM = "18771",	QUEST = "7651"},	-- Item : Enchanted Thorium Platemail - Quest: Enchanted Thorium Platemail: Volume III
	[18950]	= {ITEM = "18950",	QUEST = "7704"},	-- Item : Chambermaid Pillaclencher's Pillow - Quest: Look at the Size of It!
	[18972]	= {ITEM = "18972",	QUEST = "7738"},	-- Item : Perfect Yeti Hide - Quest: Perfect Yeti Hide (H)
	[18969]	= {ITEM = "18969",	QUEST = "7735"},	-- Item : Pristine Yeti Hide - Quest: Pristine Yeti Hide (A)
	[18987]	= {ITEM = "18987",	QUEST = "7761"},	-- Item : Blackhand's Command - Quest: Blackhand's Command
	[19002]	= {ITEM = "19002",	QUEST = "7783"},	-- Item : Head of Nefarian - Quest: The Lord of Blackrock (H)
	[19003]	= {ITEM = "19003",	QUEST = "7781"},	-- Item : Head of Nefarian - Quest: The Lord of Blackrock (A)
	[19802]	= {ITEM = "19802",	QUEST = "8183"},	-- Item : Heart of Hakkar - Quest: The Heart of Hakkar
	[19016]	= {ITEM = "19016",	QUEST = "7785"},	-- Item : Vessel of Rebirth - Quest: Examine the Vessel
	[19018]	= {ITEM = "19018",	QUEST = "7787"},	-- Item : Dormant Wind Kissed Blade - Quest: Rise, Thunderfury!
	[19228]	= {ITEM = "19228",	QUEST = "7907"},	-- Item : Beasts Deck - Quest: Darkmoon Beast Deck
	[19267]	= {ITEM = "19267",	QUEST = "7929"},	-- Item : Elementals Deck - Quest: Darkmoon Elementals Deck
	[19257]	= {ITEM = "19257",	QUEST = "7928"},	-- Item : Warlords Deck - Quest: Darkmoon Warlords Deck
	[19277]	= {ITEM = "19277",	QUEST = "7927"},	-- Item : Portals Deck - Quest: Darkmoon Portals Deck
	[19423]	= {ITEM = "19423",	QUEST = "7937"},	-- Item : Sayge's Fortune #23 - Quest: Your Fortune Awaits You...
	[19424]	= {ITEM = "19424",	QUEST = "7938"},	-- Item : Sayge's Fortune #24 - Quest: Your Fortune Awaits You...
	[19443]	= {ITEM = "19443",	QUEST = "7944"},	-- Item : Sayge's Fortune #25 - Quest: Your Fortune Awaits You...
	[19452]	= {ITEM = "19452",	QUEST = "7945"},	-- Item : Sayge's Fortune #27 - Quest: Your Fortune Awaits You...
	[20310]	= {ITEM = "20310",	QUEST = "1480"},	-- Item : Flayed Demon Skin - Quest: The Corrupter (H)
	[20461]	= {ITEM = "20461",	QUEST = "8308"},	-- Item : Brann Bronzebeard's Lost Letter - Quest: Brann Bronzebeard's Lost Letter
	[20483]	= {ITEM = "20483",	QUEST = "8338"},	-- Item : Tainted Arcane Sliver - Quest: Tainted Arcane Sliver (H)
	[20644]	= {ITEM = "20644",	QUEST = "8446"},	-- Item : Nightmare Engulfed Object - Quest: Shrouded in Nightmare
	[20741]	= {ITEM = "20741",	QUEST = "8470"},	-- Item : Deadwood Ritual Totem - Quest: Deadwood Ritual Totem
	[20742]	= {ITEM = "20742",	QUEST = "8471"},	-- Item : Winterfall Ritual Totem - Quest: Winterfall Ritual Totem
	[20765]	= {ITEM = "20765",	QUEST = "8482"},	-- Item : Incriminating Documents - Quest: Incriminating Documents (H)
	[20806]	= {ITEM = "20806",	QUEST = "8496"},	-- Item : Logistics Task Briefing X - Quest: Bandages for the Field
	[20807]	= {ITEM = "20807",	QUEST = "8497"},	-- Item : Logistics Task Briefing I - Quest: Desert Survival Kits
	[20938]	= {ITEM = "20938",	QUEST = "8547"},	-- Item : Falconwing Square Gift Voucher - Quest: Welcome! (H)
	[20939]	= {ITEM = "20939",	QUEST = "8540"},	-- Item : Logistics Task Briefing II - Quest: Boots for the Guard
	[20940]	= {ITEM = "20940",	QUEST = "8541"},	-- Item : Logistics Task Briefing III - Quest: Grinding Stones for the Guard
	[20941]	= {ITEM = "20941",	QUEST = "8501"},	-- Item : Combat Task Briefing XII - Quest: Target: Hive'Ashi Stingers
	[20942]	= {ITEM = "20942",	QUEST = "8502"},	-- Item : Combat Task Briefing III - Quest: Target: Hive'Ashi Workers
	[20943]	= {ITEM = "20943",	QUEST = "8498"},	-- Item : Tactical Task Briefing X - Quest: Twilight Battle Orders
	[20944]	= {ITEM = "20944",	QUEST = "8740"},	-- Item : Tactical Task Briefing IX - Quest: Twilight Marauders
	[20945]	= {ITEM = "20945",	QUEST = "8537"},	-- Item : Tactical Task Briefing II - Quest: Crimson Templar
	[20947]	= {ITEM = "20947",	QUEST = "8535"},	-- Item : Tactical Task Briefing IV - Quest: Hoary Templar
	[20948]	= {ITEM = "20948",	QUEST = "8538"},	-- Item : Tactical Task Briefing V - Quest: The Four Dukes
	[20949]	= {ITEM = "20949",	QUEST = "8575"},	-- Item : Magical Ledger - Quest: Azuregos's Magical Ledger
	[21165]	= {ITEM = "21165",	QUEST = "8534"},	-- Item : Tactical Task Briefing VI - Quest: Hive'Zora Scout Report
	[21166]	= {ITEM = "21166",	QUEST = "8738"},	-- Item : Tactical Task Briefing VII - Quest: Hive'Regal Scout Report
	[21167]	= {ITEM = "21167",	QUEST = "8739"},	-- Item : Tactical Task Briefing VIII - Quest: Hive'Ashi Scout Report
	[21220]	= {ITEM = "21220",	QUEST = "8791"},	-- Item : Head of Ossirian the Unscarred - Quest: The Fall of Ossirian
	[21221]	= {ITEM = "21221",	QUEST = "8801"},	-- Item : Eye of C'Thun - Quest: C'Thun's Legacy
	[21230]	= {ITEM = "21230",	QUEST = "8784"},	-- Item : Ancient Qiraji Artifact - Quest: Secrets of the Qiraji
	[21245]	= {ITEM = "21245",	QUEST = "8737"},	-- Item : Tactical Task Briefing I - Quest: Azure Templar
	[21248]	= {ITEM = "21248",	QUEST = "8773"},	-- Item : Combat Task Briefing IV - Quest: Target: Hive'Zora Reavers
	[21249]	= {ITEM = "21249",	QUEST = "8539"},	-- Item : Combat Task Briefing V - Quest: Target: Hive'Zora Hive Sisters
	[21250]	= {ITEM = "21250",	QUEST = "8772"},	-- Item : Combat Task Briefing VI - Quest: Target: Hive'Zora Waywatchers
	[21251]	= {ITEM = "21251",	QUEST = "8687"},	-- Item : Combat Task Briefing VII - Quest: Target: Hive'Zora Tunnelers
	[21252]	= {ITEM = "21252",	QUEST = "8774"},	-- Item : Combat Task Briefing VIII - Quest: Target: Hive'Regal Ambushers
	[21253]	= {ITEM = "21253",	QUEST = "8775"},	-- Item : Combat Task Briefing IX - Quest: Target: Hive'Regal Spitfires
	[21255]	= {ITEM = "21255",	QUEST = "8776"},	-- Item : Combat Task Briefing X - Quest: Target: Hive'Regal Slavemakers
	[21256]	= {ITEM = "21256",	QUEST = "8777"},	-- Item : Combat Task Briefing XI - Quest: Target: Hive'Regal Burrowers
	[21257]	= {ITEM = "21257",	QUEST = "8778"},	-- Item : Logistics Task Briefing IV - Quest: The Ironforge Brigade Needs Explosives! (A)
	[21258]	= {ITEM = "21258",	QUEST = "8785"},	-- Item : Logistics Task Briefing IV - Quest: The Orgrimmar Legion Needs Mojo! (H)
	[21259]	= {ITEM = "21259",	QUEST = "8779"},	-- Item : Logistics Task Briefing V - Quest: Scrying Materials
	[21260]	= {ITEM = "21260",	QUEST = "8781"},	-- Item : Logistics Task Briefing VI - Quest: Arms for the Field (A)
	[21261]	= {ITEM = "21261",	QUEST = "8786"},	-- Item : Logistics Task Briefing VI - Quest: Arms for the Field (H)
	[21262]	= {ITEM = "21262",	QUEST = "8782"},	-- Item : Logistics Task Briefing VIII - Quest: Uniform Supplies
	[21263]	= {ITEM = "21263",	QUEST = "8780"},	-- Item : Logistics Task Briefing VII - Quest: Armor Kits for the Field (A)
	[21264]	= {ITEM = "21264",	QUEST = "8787"},	-- Item : Logistics Task Briefing VII - Quest: Armor Kits for the Field (H)
	[21265]	= {ITEM = "21265",	QUEST = "8783"},	-- Item : Logistics Task Briefing IX - Quest: Extraordinary Materials
	[21378]	= {ITEM = "21378",	QUEST = "8804"},	-- Item : Logistics Task Briefing I - Quest: Desert Survival Kits
	[21379]	= {ITEM = "21379",	QUEST = "8805"},	-- Item : Logistics Task Briefing II - Quest: Boots for the Guard
	[21380]	= {ITEM = "21380",	QUEST = "8806"},	-- Item : Logistics Task Briefing III - Quest: Grinding Stones for the Guard
	[21381]	= {ITEM = "21381",	QUEST = "8809"},	-- Item : Logistics Task Briefing IX - Quest: Extraordinary Materials
	[21382]	= {ITEM = "21382",	QUEST = "8807"},	-- Item : Logistics Task Briefing V - Quest: Scrying Materials
	[21384]	= {ITEM = "21384",	QUEST = "8808"},	-- Item : Logistics Task Briefing VIII - Quest: Uniform Supplies
	[21385]	= {ITEM = "21385",	QUEST = "8810"},	-- Item : Logistics Task Briefing X - Quest: Bandages for the Field
	[21514]	= {ITEM = "21514",	QUEST = "8829"},	-- Item : Logistics Task Briefing XI - Quest: The Ultimate Deception
	[21749]	= {ITEM = "21749",	QUEST = "8770"},	-- Item : Combat Task Briefing I - Quest: Target: Hive'Ashi Defenders
	[21750]	= {ITEM = "21750",	QUEST = "8771"},	-- Item : Combat Task Briefing II - Quest: Target: Hive'Ashi Sandstalkers
	[21751]	= {ITEM = "21751",	QUEST = "8536"},	-- Item : Tactical Task Briefing III - Quest: Earthen Templar
	[21776]	= {ITEM = "21776",	QUEST = "8887"},	-- Item : Captain Kelisendra's Lost Rutters - Quest: Captain Kelisendra's Lost Rutters (H)
	[22520]	= {ITEM = "22520",	QUEST = "9120"},	-- Item : The Phylactery of Kel'Thuzad - Quest: The Fall of Kel'Thuzad
	[22597]	= {ITEM = "22597",	QUEST = "9175"},	-- Item : The Lady's Necklace - Quest: The Lady's Necklace (H)
	[22600]	= {ITEM = "22600",	QUEST = "9178"},	-- Item : Craftsman's Writ - Dense Weightstone - Quest: Craftsman's Writ - Dense Weightstone
	[22601]	= {ITEM = "22601",	QUEST = "9179"},	-- Item : Craftsman's Writ - Imperial Plate Chest - Quest: Craftsman's Writ - Imperial Plate Chest
	[22602]	= {ITEM = "22602",	QUEST = "9181"},	-- Item : Craftsman's Writ - Volcanic Hammer - Quest: Craftsman's Writ - Volcanic Hammer
	[22603]	= {ITEM = "22603",	QUEST = "9182"},	-- Item : Craftsman's Writ - Huge Thorium Battleaxe - Quest: Craftsman's Writ - Huge Thorium Battleaxe
	[22604]	= {ITEM = "22604",	QUEST = "9183"},	-- Item : Craftsman's Writ - Radiant Circlet - Quest: Craftsman's Writ - Radiant Circlet
	[22605]	= {ITEM = "22605",	QUEST = "9184"},	-- Item : Craftsman's Writ - Wicked Leather Headband - Quest: Craftsman's Writ - Wicked Leather Headband
	[22606]	= {ITEM = "22606",	QUEST = "9185"},	-- Item : Craftsman's Writ - Rugged Armor Kit - Quest: Craftsman's Writ - Rugged Armor Kit
	[22607]	= {ITEM = "22607",	QUEST = "9186"},	-- Item : Craftsman's Writ - Wicked Leather Belt - Quest: Craftsman's Writ - Wicked Leather Belt
	[22608]	= {ITEM = "22608",	QUEST = "9187"},	-- Item : Craftsman's Writ - Runic Leather Pants - Quest: Craftsman's Writ - Runic Leather Pants
	[22609]	= {ITEM = "22609",	QUEST = "9188"},	-- Item : Craftsman's Writ - Brightcloth Pants - Quest: Craftsman's Writ - Brightcloth Pants
	[22610]	= {ITEM = "22610",	QUEST = "9190"},	-- Item : Craftsman's Writ - Runecloth Boots - Quest: Craftsman's Writ - Runecloth Boots
	[22611]	= {ITEM = "22611",	QUEST = "9191"},	-- Item : Craftsman's Writ - Runecloth Bag - Quest: Craftsman's Writ - Runecloth Bag
	[22612]	= {ITEM = "22612",	QUEST = "9194"},	-- Item : Craftsman's Writ - Runecloth Robe - Quest: Craftsman's Writ - Runecloth Robe
	[22613]	= {ITEM = "22613",	QUEST = "9195"},	-- Item : Craftsman's Writ - Goblin Sapper Charge - Quest: Craftsman's Writ - Goblin Sapper Charge
	[22614]	= {ITEM = "22614",	QUEST = "9196"},	-- Item : Craftsman's Writ - Thorium Grenade - Quest: Craftsman's Writ - Thorium Grenade
	[22615]	= {ITEM = "22615",	QUEST = "9197"},	-- Item : Craftsman's Writ - Gnomish Battle Chicken - Quest: Craftsman's Writ - Gnomish Battle Chicken
	[22616]	= {ITEM = "22616",	QUEST = "9198"},	-- Item : Craftsman's Writ - Thorium Tube - Quest: Craftsman's Writ - Thorium Tube
	[22617]	= {ITEM = "22617",	QUEST = "9200"},	-- Item : Craftsman's Writ - Major Mana Potion - Quest: Craftsman's Writ - Major Mana Potion
	[22618]	= {ITEM = "22618",	QUEST = "9202"},	-- Item : Craftsman's Writ - Major Healing Potion - Quest: Craftsman's Writ - Major Healing Potion
	[22620]	= {ITEM = "22620",	QUEST = "9201"},	-- Item : Craftsman's Writ - Greater Arcane Protection Potion - Quest: Craftsman's Writ - Greater Arcane Protection Potion
	[22621]	= {ITEM = "22621",	QUEST = "9203"},	-- Item : Craftsman's Writ - Potion of Petrification - Quest: Craftsman's Writ - Potion of Petrification
	[22622]	= {ITEM = "22622",	QUEST = "9204"},	-- Item : Craftsman's Writ - Stonescale Eel - Quest: Craftsman's Writ - Stonescale Eel
	[22623]	= {ITEM = "22623",	QUEST = "9205"},	-- Item : Craftsman's Writ - Plated Armorfish - Quest: Craftsman's Writ - Plated Armorfish
	[22624]	= {ITEM = "22624",	QUEST = "9206"},	-- Item : Craftsman's Writ - Lightning Eel - Quest: Craftsman's Writ - Lightning Eel
	[22719]	= {ITEM = "22719",	QUEST = "9233"},	-- Item : Omarion's Handbook - Quest: Omarion's Handbook
	[22727]	= {ITEM = "22727",	QUEST = "9250"},	-- Item : Frame of Atiesh - Quest: Frame of Atiesh
	[22723]	= {ITEM = "22723",	QUEST = "9247"},	-- Item : A Letter from the Keeper of the Rolls - Quest: A Letter from the Keeper of the Rolls
	[22888]	= {ITEM = "22888",	QUEST = "9278"},	-- Item : Azure Watch Gift Voucher - Quest: Welcome! (A)
	[22970]	= {ITEM = "22970",	QUEST = "9301"},	-- Item : A Bloodstained Envelope - Quest: Envelope from the Front
	[22977]	= {ITEM = "22977",	QUEST = "9295"},	-- Item : A Torn Letter - Quest: Letter from the Front
	[22972]	= {ITEM = "22972",	QUEST = "9299"},	-- Item : A Careworn Note - Quest: Note from the Front
	[22973]	= {ITEM = "22973",	QUEST = "9302"},	-- Item : A Crumpled Missive - Quest: Missive from the Front
	[22974]	= {ITEM = "22974",	QUEST = "9300"},	-- Item : A Ragged Page - Quest: Page from the Front
	[22975]	= {ITEM = "22975",	QUEST = "9304"},	-- Item : A Smudged Document - Quest: Document from the Front
	[23179]	= {ITEM = "23179",	QUEST = "9324"},	-- Item : Flame of Orgrimmar - Quest: Stealing Orgrimmar's Flame (A)
	[23180]	= {ITEM = "23180",	QUEST = "9325"},	-- Item : Flame of Thunder Bluff - Quest: Stealing Thunder Bluff's Flame (A)
	[23181]	= {ITEM = "23181",	QUEST = "9326"},	-- Item : Flame of the Undercity - Quest: Stealing the Undercity's Flame (A)
	[23182]	= {ITEM = "23182",	QUEST = "9330"},	-- Item : Flame of Stormwind - Quest: Stealing Stormwind's Flame (H)
	[23183]	= {ITEM = "23183",	QUEST = "9331"},	-- Item : Flame of Ironforge - Quest: Stealing Ironforge's Flame (H)
	[23184]	= {ITEM = "23184",	QUEST = "9332"},	-- Item : Flame of Darnassus - Quest: Stealing Darnassus's Flame (H)
	[23228]	= {ITEM = "23228",	QUEST = "8474"},	-- Item : Old Whitebark's Pendant - Quest: Old Whitebark's Pendant (H)
	[23249]	= {ITEM = "23249",	QUEST = "9360"},	-- Item : Amani Invasion Plans - Quest: Amani Invasion (H)
	[23338]	= {ITEM = "23338",	QUEST = "9373"},	-- Item : Eroded Leather Case - Quest: Missing Missive
	[23580]	= {ITEM = "23580",	QUEST = "9418"},	-- Item : Avruu's Orb - Quest: Avruu's Orb
	[23678]	= {ITEM = "23678",	QUEST = "9455"},	-- Item : Faintly Glowing Crystal - Quest: Strange Findings (A)
	[23759]	= {ITEM = "23759",	QUEST = "9514"},	-- Item : Rune Covered Tablet - Quest: Rune Covered Tablet (A)
	[23777]	= {ITEM = "23777",	QUEST = "9520"},	-- Item : Diabolical Plans - Quest: Diabolical Plans (A)
	[23797]	= {ITEM = "23797",	QUEST = "9535"},	-- Item : Diabolical Plans - Quest: Diabolical Plans (H)
	[23837]	= {ITEM = "23837",	QUEST = "9550"},	-- Item : Weathered Treasure Map - Quest: A Map to Where? (A)
	[23850]	= {ITEM = "23850",	QUEST = "9564"},	-- Item : Gurf's Dignity - Quest: Gurf's Dignity (A)
	[23870]	= {ITEM = "23870",	QUEST = "9576"},	-- Item : Red Crystal Pendant - Quest: Cruelfin's Necklace (A)
	[23890]	= {ITEM = "23890",	QUEST = "9587"},	-- Item : Ominous Letter - Quest: Dark Tidings (A)
	[23892]	= {ITEM = "23892",	QUEST = "9588"},	-- Item : Ominous Letter - Quest: Dark Tidings (H)
	[23900]	= {ITEM = "23900",	QUEST = "9594"},	-- Item : Tzerak's Armor Plate - Quest: Signs of the Legion (A)
	[23910]	= {ITEM = "23910",	QUEST = "9616"},	-- Item : Blood Elf Communication - Quest: Bandits! (A)
	[24132]	= {ITEM = "24132",	QUEST = "9672"},	-- Item : A Letter from the Admiral - Quest: The Bloodcurse Legacy (A)
	[24330]	= {ITEM = "24330",	QUEST = "9731"},	-- Item : Drain Schematics - Quest: Drain Schematics
	[24367]	= {ITEM = "24367",	QUEST = "9764"},	-- Item : Orders from Lady Vashj - Quest: Orders from Lady Vashj
	[24407]	= {ITEM = "24407",	QUEST = "9875"},	-- Item : Uncatalogued Species - Quest: Uncatalogued Species
	[24414]	= {ITEM = "24414",	QUEST = "9798"},	-- Item : Blood Elf Plans - Quest: Blood Elf Plans (A)
	[24483]	= {ITEM = "24483",	QUEST = "9827"},	-- Item : Withered Basidium - Quest: Withered Basidium (A)
	[24484]	= {ITEM = "24484",	QUEST = "9828"},	-- Item : Withered Basidium - Quest: Withered Basidium (H)
	[24504]	= {ITEM = "24504",	QUEST = "9861"},	-- Item : Howling Wind - Quest: The Howling Wind
	[24558]	= {ITEM = "24558",	QUEST = "9872"},	-- Item : Murkblood Invasion Plans - Quest: Murkblood Invaders (H)
	[24559]	= {ITEM = "24559",	QUEST = "9871"},	-- Item : Murkblood Invasion Plans - Quest: Murkblood Invaders (A)
	[25459]	= {ITEM = "25459",	QUEST = "9911"},	-- Item : "Count" Ungula's Mandible - Quest: The Count of the Marshes
	[25705]	= {ITEM = "25705",	QUEST = "9984"},	-- Item : Luanga's Orders - Quest: Host of the Hidden City
	[25706]	= {ITEM = "25706",	QUEST = "9985"},	-- Item : Luanga's Orders - Quest: Host of the Hidden City
	[28552]	= {ITEM = "28552",	QUEST = "10229"},	-- Item : A Mysterious Tome - Quest: Decipher the Tome (H)
	[29233]	= {ITEM = "29233",	QUEST = "10182"},	-- Item : Dathric's Blade - Quest: Battle-Mage Dathric
	[29234]	= {ITEM = "29234",	QUEST = "10305"},	-- Item : Belmara's Tome - Quest: Abjurist Belmara
	[29235]	= {ITEM = "29235",	QUEST = "10306"},	-- Item : Luminrath's Mantle - Quest: Conjurer Luminrath
	[29236]	= {ITEM = "29236",	QUEST = "10307"},	-- Item : Cohlien's Cap - Quest: Cohlien Frostweaver
	[29476]	= {ITEM = "29476",	QUEST = "10134"},	-- Item : Crimson Crystal Shard - Quest: Crimson Crystal Clue
	[29588]	= {ITEM = "29588",	QUEST = "10395"},	-- Item : Burning Legion Missive - Quest: The Dark Missive (A)
	[29590]	= {ITEM = "29590",	QUEST = "10393"},	-- Item : Burning Legion Missive - Quest: Vile Plans (H)
	[29738]	= {ITEM = "29738",	QUEST = "10413"},	-- Item : Vial of Void Horror Ooze - Quest: The Horrors of Pollution
	[30431]	= {ITEM = "30431",	QUEST = "10524"},	-- Item : Thunderlord Clan Artifact - Quest: Thunderlord Clan Artifacts (H)
	[30756]	= {ITEM = "30756",	QUEST = "10621"},	-- Item : Illidari-Bane Shard - Quest: Illidari-Bane Shard (A)
	[30579]	= {ITEM = "30579",	QUEST = "10623"},	-- Item : Illidari-Bane Shard - Quest: Illidari-Bane Shard (H)
	[31120]	= {ITEM = "31120",	QUEST = "10719"},	-- Item : Meeting Note - Quest: Did You Get The Note?
	[31239]	= {ITEM = "31239",	QUEST = "10754"},	-- Item : Primed Key Mold - Quest: Entry Into the Citadel (A)
	[31241]	= {ITEM = "31241",	QUEST = "10755"},	-- Item : Primed Key Mold - Quest: Entry Into the Citadel (H)
	[31345]	= {ITEM = "31345",	QUEST = "10793"},	-- Item : The Journal of Val'zareq - Quest: The Journal of Val'zareq: Portends of War
	[31363]	= {ITEM = "31363",	QUEST = "10797"},	-- Item : Gorgrom's Favor - Quest: Favor of the Gronn (A)
	[31384]	= {ITEM = "31384",	QUEST = "10810"},	-- Item : Damaged Mask - Quest: Damaged Mask
	[31489]	= {ITEM = "31489",	QUEST = "10825"},	-- Item : Orb of the Grishna - Quest: The Truth Unorbed
	[31707]	= {ITEM = "31707",	QUEST = "10880"},	-- Item : Cabal Orders - Quest: Cabal Orders
	[31890]	= {ITEM = "31890",	QUEST = "10938"},	-- Item : Blessings Deck - Quest: Darkmoon Blessings Deck
	[31891]	= {ITEM = "31891",	QUEST = "10939"},	-- Item : Storms Deck - Quest: Darkmoon Storms Deck
	[31907]	= {ITEM = "31907",	QUEST = "10940"},	-- Item : Furies Deck - Quest: Darkmoon Furies Deck
	[31914]	= {ITEM = "31914",	QUEST = "10941"},	-- Item : Lunacy Deck - Quest: Darkmoon Lunacy Deck
	[32385]	= {ITEM = "32385",	QUEST = "11002"},	-- Item : Magtheridon's Head - Quest: The Fall of Magtheridon (A)
	[32386]	= {ITEM = "32386",	QUEST = "11003"},	-- Item : Magtheridon's Head - Quest: The Fall of Magtheridon (H)
	[32405]	= {ITEM = "32405",	QUEST = "11007"},	-- Item : Verdant Sphere - Quest: Kael'thas and the Verdant Sphere
	[32523]	= {ITEM = "32523",	QUEST = "11021"},	-- Item : Ishaal's Almanac - Quest: Ishaal's Almanac
	[32621]	= {ITEM = "32621",	QUEST = "11041"},	-- Item : Partially Digested Hand - Quest: A Job Unfinished...
	[32726]	= {ITEM = "32726",	QUEST = "11081"},	-- Item : Murkblood Escape Plans - Quest: The Great Murkblood Revolt
	[33102]	= {ITEM = "33102",	QUEST = "11178"},	-- Item : Blood of Zul'jin - Quest: Blood of the Warlord
	[33114]	= {ITEM = "33114",	QUEST = "11185"},	-- Item : Sealed Letter - Quest: The Apothecary's Letter (A)
	[33115]	= {ITEM = "33115",	QUEST = "11186"},	-- Item : Sealed Letter - Quest: Signs of Treachery? (H)
	[33978]	= {ITEM = "33978",	QUEST = "11400"},	-- Item : "Honorary Brewer" Hand Stamp - Quest: Brewfest Riding Rams (A)
	[34028]	= {ITEM = "34028",	QUEST = "11419"},	-- Item : "Honorary Brewer" Hand Stamp - Quest: Brewfest Riding Rams (H)
	[34469]	= {ITEM = "34469",	QUEST = "11531"},	-- Item : Strange Engine Part - Quest: Strange Engine Part (A)
	[35568]	= {ITEM = "35568",	QUEST = "11935"},	-- Item : Flame of Silvermoon - Quest: Stealing Silvermoon's Flame (A)
	[35569]	= {ITEM = "35569",	QUEST = "11933"},	-- Item : Flame of the Exodar - Quest: Stealing the Exodar's Flame (H)
	[35723]	= {ITEM = "35723",	QUEST = "11972"},	-- Item : Shards of Ahune - Quest: Shards of Ahune
}

-- For some reason these are tagged as quest items. They are not.
lib.InvalidQuestItemIDs = {
	"20076",	-- Zandalar Signet of Mojo
	"20078",	-- Zandalar Signet of Serenity
	"20077",	-- Zandalar Signet of Might
	"23545",	-- Power of the Scourge
	"23547",	-- Resilience of the Scourge
	"23548",	-- Might of the Scourge
	"23549",	-- Fortitude of the Scourge
	"28886",	-- Greater Inscription of Discipline
	"28887",	-- Greater Inscription of Faith
	"28888",	-- Greater Inscription of Vengeance
	"28889",	-- Greater Inscription of Warding
	"29186",	-- Glyph of the Defender
	"29189",	-- Glyph of Renewal
	"29190",	-- Glyph of Renewal
	"29191",	-- Glyph of Power
	"29192",	-- Glyph of Ferocity
	"30846",	-- Glyph of the Outcast
	"35728",	-- Greater Inscription of the Blade
	"35729",	-- Greater Inscription of the Knight
	"35730",	-- Greater Inscription of the Oracle
	"35731",	-- Greater Inscription of the Orb
}