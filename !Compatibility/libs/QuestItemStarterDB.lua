local MAJOR_VERSION = "QuestItemStarterDB"
local MINOR_VERSION = 90000 + tonumber(string.match("$Revision: 1 $", "%d+"))

local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

lib.QuestItemStarterIDs = {
	"1307",		-- Gold Pickup Schedule
	"1357",		-- Captain Sanders' Treasure Map
	"1962",		-- Glowing Shadowhide Pendant
	"1971",		-- Furlbrow's Deed
	"1972",		-- Westfall Deed
	"2794",		-- An Old History Book
	"2837",		-- Thurman's Letter
	"2839",		-- A Letter to Yvette
	"2874",		-- An Unsent Letter
	"3082",		-- Dargol's Skull
	"3317",		-- A Talking Head
	"3668",		-- Assassin's Contract
	"3706",		-- Ensorcelled Parchment
	"3985",		-- Monogrammed Sash
	"4056",		-- Cortello's Riddle
	"4098",		-- Carefully Folded Note
	"4433",		-- Waterlogged Envelope
	"4613",		-- Corroded Black Box
	"4614",		-- Pendant of Myzrael
	"4854",		-- Demon Scarred Cloak
	"4881",		-- Aged Envelope
	"4903",		-- Eye of Burning Shadow
	"4926",		-- Chen's Empty Keg
	"5102",		-- Owatanka's Tailspike
	"5103",		-- Washte Pawne's Feather
	"5099",		-- Hoof of Lakota'mani
	"5138",		-- Harvester's Head
	"5179",		-- Moss-Twined Heart
	"5352",		-- Book: The Powers Below
	"5790",		-- Lonebrow's Journal
	"5877",		-- Cracked Silithid Carapace
	"6172",		-- Lost Supplies
	"6196",		-- Noboru's Cudgel
	"6497",		-- Simple Parchment
	"6775",		-- Tome of Divinity
	"6776",		-- Tome of Valor
	"6916",		-- Tome of Divinity
	"7666",		-- Shattered Necklace
	"8244",		-- Flawless Draenethyst Sphere
	"8524",		-- Model 4711-FTZ Power Source
	"8623",		-- OOX-17/TN Distress Beacon
	"8704",		-- OOX-09/HL Distress Beacon
	"8705",		-- OOX-22/FE Distress Beacon
	"9250",		-- Ship Schedule
	"9254",		-- Cuergo's Treasure Map
	"9326",		-- Grime-Encrusted Ring
	"9370",		-- Gordunni Scroll
	"10000",	-- Margol's Horn
	"10441",	-- Glowing Shard
	"10454",	-- Essence of Eranikus
	"10589",	-- Oathstone of Ysera's Dragonflight
	"10593",	-- Imperfect Draenethyst Fragment
	"10621",	-- Runed Scroll
	"11116",	-- A Mangled Journal
	"11463",	-- Undelivered Parcel
	"11668",	-- Flute of Xavaric
	"11818",	-- Grimesilt Outhouse Key
	"12563",	-- Warlord Goretooth's Command
	"12564",	-- Assassination Note
	"12558",	-- Blue-feathered Necklace
	"12771",	-- Empty Firewater Flask
	"12780",	-- General Drakkisath's Command
	"12842",	-- Crudely-Written Log
	"13140",	-- Blood Red Key
	"13250",	-- Head of Balnazzar
	"13920",	-- Healthy Dragon Scale
	"14646",	-- Goldshire Gift Voucher
	"14647",	-- Kharanos Gift Voucher
	"14648",	-- Dolanaar Gift Voucher
	"14649",	-- Razor Hill Gift Voucher
	"14650",	-- Bloodhoof Village Gift Voucher
	"14651",	-- Brill Gift Voucher
	"16303",	-- Ursangous' Paw
	"16304",	-- Shadumbra's Head
	"16305",	-- Sharptalon's Claw
	"16408",	-- Befouled Water Globe
	"16790",	-- Damp Note
	"16782",	-- Strange Water Globe
	"17008",	-- Small Scroll
	"17126",	-- Elegant Letter
	"18356",	-- Garona: A Study on Stealth and Treachery
	"18357",	-- Codex of Defense
	"18358",	-- The Arcanist's Cookbook
	"18359",	-- The Light and How to Swing It
	"18360",	-- Harnessing Shadows
	"18361",	-- The Greatest Race of Hunters
	"18362",	-- Holy Bologna: What the Light Won't Tell You
	"18363",	-- Frost Shock and You
	"18364",	-- The Emerald Dream
	"18401",	-- Foror's Compendium of Dragon Slaying
	"18422",	-- Head of Onyxia
	"18423",	-- Head of Onyxia
	"18565",	-- Vessel of Rebirth DEPRECATED
	"18628",	-- Thorium Brotherhood Contract
	"18703",	-- Ancient Petrified Leaf
	"18706",	-- Arena Master
	"18769",	-- Enchanted Thorium Platemail
	"18770",	-- Enchanted Thorium Platemail
	"18771",	-- Enchanted Thorium Platemail
	"18950",	-- Chambermaid Pillaclencher's Pillow
	"18972",	-- Perfect Yeti Hide
	"18969",	-- Pristine Yeti Hide
	"18987",	-- Blackhand's Command
	"19002",	-- Head of Nefarian
	"19003",	-- Head of Nefarian
	"19802",	-- Heart of Hakkar
	"19016",	-- Vessel of Rebirth
	"19018",	-- Dormant Wind Kissed Blade
	"19228",	-- Beasts Deck
	"19267",	-- Elementals Deck
	"19257",	-- Warlords Deck
	"19277",	-- Portals Deck
	"19423",	-- Sayge's Fortune #23
	"19424",	-- Sayge's Fortune #24
	"19443",	-- Sayge's Fortune #25
	"19452",	-- Sayge's Fortune #27
	"20310",	-- Flayed Demon Skin
	"20461",	-- Brann Bronzebeard's Lost Letter
	"20483",	-- Tainted Arcane Sliver
	"20644",	-- Nightmare Engulfed Object
	"20741",	-- Deadwood Ritual Totem
	"20742",	-- Winterfall Ritual Totem
	"20765",	-- Incriminating Documents
	"20806",	-- Logistics Task Briefing X
	"20807",	-- Logistics Task Briefing I
	"20938",	-- Falconwing Square Gift Voucher
	"20939",	-- Logistics Task Briefing II
	"20940",	-- Logistics Task Briefing III
	"20941",	-- Combat Task Briefing XII
	"20942",	-- Combat Task Briefing III
	"20943",	-- Tactical Task Briefing X
	"20944",	-- Tactical Task Briefing IX
	"20945",	-- Tactical Task Briefing II
	"20947",	-- Tactical Task Briefing IV
	"20948",	-- Tactical Task Briefing V
	"20949",	-- Magical Ledger
	"21165",	-- Tactical Task Briefing VI
	"21166",	-- Tactical Task Briefing VII
	"21167",	-- Tactical Task Briefing VIII
	"21220",	-- Head of Ossirian the Unscarred
	"21221",	-- Eye of C'Thun
	"21230",	-- Ancient Qiraji Artifact
	"21245",	-- Tactical Task Briefing I
	"21248",	-- Combat Task Briefing IV
	"21249",	-- Combat Task Briefing V
	"21250",	-- Combat Task Briefing VI
	"21251",	-- Combat Task Briefing VII
	"21252",	-- Combat Task Briefing VIII
	"21253",	-- Combat Task Briefing IX
	"21255",	-- Combat Task Briefing X
	"21256",	-- Combat Task Briefing XI
	"21257",	-- Logistics Task Briefing IV
	"21258",	-- Logistics Task Briefing IV
	"21259",	-- Logistics Task Briefing V
	"21260",	-- Logistics Task Briefing VI
	"21261",	-- Logistics Task Briefing VI
	"21262",	-- Logistics Task Briefing VIII
	"21263",	-- Logistics Task Briefing VII
	"21264",	-- Logistics Task Briefing VII
	"21265",	-- Logistics Task Briefing IX
	"21378",	-- Logistics Task Briefing I
	"21379",	-- Logistics Task Briefing II
	"21380",	-- Logistics Task Briefing III
	"21381",	-- Logistics Task Briefing IX
	"21382",	-- Logistics Task Briefing V
	"21384",	-- Logistics Task Briefing VIII
	"21385",	-- Logistics Task Briefing X
	"21514",	-- Logistics Task Briefing XI
	"21749",	-- Combat Task Briefing I
	"21750",	-- Combat Task Briefing II
	"21751",	-- Tactical Task Briefing III
	"21776",	-- Captain Kelisendra's Lost Rutters
	"22520",	-- The Phylactery of Kel'Thuzad
	"22597",	-- The Lady's Necklace
	"22600",	-- Craftsman's Writ - Dense Weightstone
	"22601",	-- Craftsman's Writ - Imperial Plate Chest
	"22602",	-- Craftsman's Writ - Volcanic Hammer
	"22603",	-- Craftsman's Writ - Huge Thorium Battleaxe
	"22604",	-- Craftsman's Writ - Radiant Circlet
	"22605",	-- Craftsman's Writ - Wicked Leather Headband
	"22606",	-- Craftsman's Writ - Rugged Armor Kit
	"22607",	-- Craftsman's Writ - Wicked Leather Belt
	"22608",	-- Craftsman's Writ - Runic Leather Pants
	"22609",	-- Craftsman's Writ - Brightcloth Pants
	"22610",	-- Craftsman's Writ - Runecloth Boots
	"22611",	-- Craftsman's Writ - Runecloth Bag
	"22612",	-- Craftsman's Writ - Runecloth Robe
	"22613",	-- Craftsman's Writ - Goblin Sapper Charge
	"22614",	-- Craftsman's Writ - Thorium Grenade
	"22615",	-- Craftsman's Writ - Gnomish Battle Chicken
	"22616",	-- Craftsman's Writ - Thorium Tube
	"22617",	-- Craftsman's Writ - Major Mana Potion
	"22618",	-- Craftsman's Writ - Major Healing Potion
	"22620",	-- Craftsman's Writ - Greater Arcane Protection Potion
	"22621",	-- Craftsman's Writ - Potion of Petrification
	"22622",	-- Craftsman's Writ - Stonescale Eel
	"22623",	-- Craftsman's Writ - Plated Armorfish
	"22624",	-- Craftsman's Writ - Lightning Eel
	"22719",	-- Omarion's Handbook
	"22727",	-- Frame of Atiesh
	"22723",	-- A Letter from the Keeper of the Rolls
	"22888",	-- Azure Watch Gift Voucher
	"22970",	-- A Bloodstained Envelope
	"22977",	-- A Torn Letter
	"22972",	-- A Careworn Note
	"22973",	-- A Crumpled Missive
	"22974",	-- A Ragged Page
	"22975",	-- A Smudged Document
	"23179",	-- Flame of Orgrimmar
	"23180",	-- Flame of Thunder Bluff
	"23181",	-- Flame of the Undercity
	"23182",	-- Flame of Stormwind
	"23183",	-- Flame of Ironforge
	"23184",	-- Flame of Darnassus
	"23228",	-- Old Whitebark's Pendant
	"23249",	-- Amani Invasion Plans
	"23338",	-- Eroded Leather Case
	"23580",	-- Avruu's Orb
	"23678",	-- Faintly Glowing Crystal
	"23759",	-- Rune Covered Tablet
	"23777",	-- Diabolical Plans
	"23797",	-- Diabolical Plans
	"23837",	-- Weathered Treasure Map
	"23850",	-- Gurf's Dignity
	"23870",	-- Red Crystal Pendant
	"23890",	-- Ominous Letter
	"23892",	-- Ominous Letter
	"23900",	-- Tzerak's Armor Plate
	"23910",	-- Blood Elf Communication
	"24132",	-- A Letter from the Admiral
	"24330",	-- Drain Schematics
	"24367",	-- Orders from Lady Vashj
	"24407",	-- Uncatalogued Species
	"24414",	-- Blood Elf Plans
	"24483",	-- Withered Basidium
	"24484",	-- Withered Basidium
	"24504",	-- Howling Wind
	"24558",	-- Murkblood Invasion Plans
	"24559",	-- Murkblood Invasion Plans
	"25459",	-- "Count" Ungula's Mandible
	"25705",	-- Luanga's Orders
	"25706",	-- Luanga's Orders
	"28552",	-- A Mysterious Tome
	"29233",	-- Dathric's Blade
	"29234",	-- Belmara's Tome
	"29235",	-- Luminrath's Mantle
	"29236",	-- Cohlien's Cap
	"29476",	-- Crimson Crystal Shard
	"29589",	-- Burning Legion Missive
	"29738",	-- Vial of Void Horror Ooze
	"30431",	-- Thunderlord Clan Artifact
	"30756",	-- Illidari-Bane Shard
	"30579",	-- Illidari-Bane Shard
	"31120",	-- Meeting Note
	"31239",	-- Primed Key Mold
	"31241",	-- Primed Key Mold
	"31345",	-- The Journal of Val'zareq
	"31363",	-- Gorgrom's Favor
	"31384",	-- Damaged Mask
	"31489",	-- Orb of the Grishna
	"31707",	-- Cabal Orders
	"31890",	-- Blessings Deck
	"31891",	-- Storms Deck
	"31907",	-- Furies Deck
	"31914",	-- Lunacy Deck
	"32385",	-- Magtheridon's Head
	"32386",	-- Magtheridon's Head
	"32405",	-- Verdant Sphere
	"32523",	-- Ishaal's Almanac
	"32621",	-- Partially Digested Hand
	"32726",	-- Murkblood Escape Plans
	"33102",	-- Blood of Zul'jin
	"33114",	-- Sealed Letter
	"33115",	-- Sealed Letter
	"33978",	-- "Honorary Brewer" Hand Stamp
	"34028",	-- "Honorary Brewer" Hand Stamp
	"34469",	-- Strange Engine Part
	"35568",	-- Flame of Silvermoon
	"35569",	-- Flame of the Exodar
	"35723",	-- Shards of Ahune
	"37571",	-- "Brew of the Month" Club Membership Form
	"37599",	-- "Brew of the Month" Club Membership Form
	"38280",	-- Direbrew's Dire Brew
	"38281",	-- Direbrew's Dire Brew
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