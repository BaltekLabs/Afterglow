--[[
	Things in the world the player can use. The world builder tags a part with InteractId = <key>.

	action / object   prompt text ("Read" / "Letter")
	hold              seconds to hold the key (default 0)
	once              can only be used once per player
	perInstance       with `once`: tracked per placed copy (part attribute "Key"), not per id
	hidden            prompt only appears while revealed by Insight (Mara's ability)
	showWhen          conditions for the prompt to appear at all (evaluated on the client)
	requires          conditions to use it; otherwise `failText` is shown
	lore              journal entry unlocked and opened in the reader
	loreAttribute     like `lore`, but read from the part's "Lore" attribute (scattered notes)
	effects           effect list (see Story.lua)
	dialogue          opens a dialogue (Data/Dialogue/<id>)
	lift              opens the lift menu for the part's "LiftId" (Data/Lifts.lua)
	door              a locked door; part attributes decide who can open it (see Interaction.lua)
	steal             { radius, success = effects, caught = effects, bark } — witnessed by any NPC within radius
]]
local SEWER_EXIT = { notify = "You climb up through the manhole into the Rust.", kind = "info" }

return {
	-- Generic, placed many times ------------------------------------------------------
	lift = { action = "Call lift", object = "Lift", lift = true },
	locked_door = { action = "Open", object = "Locked door", door = true, distance = 7 },
	stash = {
		action = "Search",
		object = "Loose panel",
		once = true,
		perInstance = true,
		effects = { { randomCredits = { 6, 45 } } },
	},
	city_note = { action = "Read", object = "Note", loreAttribute = true },

	-- The Grid --------------------------------------------------------------------------
	tower_speaker = { action = "Listen", object = "Broadcast Horns", dialogue = "tower_speaker" },
	accord_plaque = { action = "Read", object = "Bronze Plaque", lore = "accord_plaque" },
	civic_plaque = { action = "Read", object = "Greenkeeping Sign", lore = "civic_strain" },
	tamsin_photo = { action = "Look", object = "Framed Photo", lore = "tamsin_photo" },

	tower_generator = {
		action = "Install cells",
		object = "Tower Generator",
		hold = 1,
		requires = { { quest = "cellrun", stage = "deliver" }, { item = "vesper_cell", count = 3 } },
		failText = "The generator's cell bays are empty. It needs Vesper cells.",
		effects = {
			{ takeItem = "vesper_cell", count = 3 },
			{ setFlag = "cells_delivered" },
			{ notify = "The generator shudders, then hums. The tower's beacons brighten.", kind = "info" },
		},
	},
	cell_crate = {
		action = "Take cells",
		object = "Ascent Cell Crate",
		once = true,
		requires = { { quest = "cellrun", stage = "pickup" } },
		failText = "Sealed with an Ascent depot lock.",
		effects = { { giveItem = "vesper_cell", count = 3 } },
	},
	ascent_memo = { action = "Read", object = "Office Terminal", hidden = true, lore = "ascent_memo" },

	apt_letter_1 = { action = "Read", object = "Note", lore = "adeyemi_1" },
	apt_letter_2 = { action = "Read", object = "Letter", lore = "adeyemi_2" },
	apt_drawing = { action = "Look", object = "Folded Paper", lore = "adeyemi_3" },

	pell_mailbox = {
		action = "Search",
		object = "Pell's Mailbox",
		-- Appears once drunk Pell lets slip where the key is, or immediately for a detective.
		showWhen = { { any = { { flag = "pell_key_hint" }, { character = "mara" } } } },
		once = true,
		effects = { { giveItem = "pell_key" }, { notify = "Taped under the mailbox lid: a brass key.", kind = "info" } },
	},
	pell_ledger = {
		action = "Take",
		object = "Paper Ledger",
		once = true,
		effects = { { giveItem = "pell_ledger" }, { lore = "pell_ledger", read = true } },
	},

	-- The Rust ---------------------------------------------------------------------------
	veil_notice = { action = "Read", object = "Council Notice", lore = "veil_notice" },
	vela_crate = {
		action = "Take (steal)",
		object = "Vela's Supply Crate",
		hold = 1.2,
		once = true,
		steal = {
			radius = 30,
			bark = "Hey! Thief! I know your face!",
			success = {
				{ giveItem = "mend_patch", count = 2 },
				{ giveItem = "glowbowl", count = 1 },
				{ setFlag = "stole_from_vela" },
				{ notify = "Nobody saw. You pocket the supplies.", kind = "info" },
			},
			caught = {
				{ setFlag = "caught_stealing_vela" },
				{ trust = "vela", amount = -3 },
				{ rep = "rust", amount = -5 },
				{ notify = "You were seen. The Rust will remember.", kind = "warn" },
			},
		},
	},

	-- Sewers: manholes in Rust back alleys, ladders below, outflows outside the Wall.
	manhole_1 = { action = "Climb down", object = "Manhole", hold = 0.8, effects = { { teleport = "Sewer_M1" } } },
	manhole_2 = { action = "Climb down", object = "Manhole", hold = 0.8, effects = { { teleport = "Sewer_M2" } } },
	manhole_3 = { action = "Climb down", object = "Manhole", hold = 0.8, effects = { { teleport = "Sewer_M3" } } },
	ladder_1 = { action = "Climb up", object = "Ladder", effects = { { teleport = "Manhole_1" }, SEWER_EXIT } },
	ladder_2 = { action = "Climb up", object = "Ladder", effects = { { teleport = "Manhole_2" }, SEWER_EXIT } },
	ladder_3 = { action = "Climb up", object = "Ladder", effects = { { teleport = "Manhole_3" }, SEWER_EXIT } },
	sewer_chalk = { action = "Read", object = "Chalk Map", lore = "sewer_chalk" },
	outflow_north_exit = {
		action = "Squeeze out",
		object = "Outflow Grate (cut)",
		hold = 1.2,
		effects = {
			{ setFlag = "took_sewers" },
			{ teleport = "Outflow_N" },
			{ checkpoint = "CP_Outflow_N" },
			{ notify = "You crawl out of the pipe. Above you, for the first time, there is sky.", kind = "info" },
		},
	},
	outflow_south_exit = {
		action = "Squeeze out",
		object = "Outflow Grate (cut)",
		hold = 1.2,
		effects = {
			{ setFlag = "took_sewers" },
			{ teleport = "Outflow_S" },
			{ checkpoint = "CP_Outflow_S" },
			{ notify = "You crawl out into a reed marsh. The Wall looms behind you.", kind = "info" },
		},
	},
	outflow_north_enter = { action = "Crawl in", object = "Storm Outflow", hold = 1, effects = { { teleport = "Sewer_North_End" } } },
	outflow_south_enter = { action = "Crawl in", object = "Storm Outflow", hold = 1, effects = { { teleport = "Sewer_South_End" } } },

	-- The Powerhouse ---------------------------------------------------------------------
	powerhouse_hatch = {
		action = "Open hatch",
		object = "Maintenance Hatch",
		hold = 1.5,
		requires = { { any = { { character = "teo" }, { character = "dex" }, { item = "powerhouse_keycard" } } } },
		failText = "MAINTENANCE ACCESS ONLY. A technician's code, a forged keycard, or a good hacker could open this.",
		effects = {
			{ setFlag = "entered_powerhouse" },
			{ teleport = "PH_Inside" },
			{ notify = "The hatch seals behind you. The hum is everywhere now.", kind = "info" },
		},
	},
	powerhouse_exit = { action = "Leave", object = "Maintenance Hatch", effects = { { teleport = "PH_Outside" } } },
	powerhouse_log = { action = "Read", object = "Core Terminal", lore = "powerhouse_log" },
	powerhouse_order = {
		action = "Decrypt",
		object = "Council Terminal",
		requires = { { any = { { character = "teo" }, { character = "dex" }, { character = "silas" } } } },
		failText = "ENCRYPTED. Council clearance, maintenance codes, or serious hacking required.",
		lore = "powerhouse_order",
	},

	-- The Crown ----------------------------------------------------------------------------
	crown_invite = { action = "Read", object = "Gala Invitation", lore = "crown_invite" },

	-- Outlands -----------------------------------------------------------------------------
	wren_satchel = { action = "Search", object = "Mud-caked Satchel", lore = "wren_1" },
	camp_letter = { action = "Open", object = "Tin Box", lore = "adeyemi_4" },
	lune_shrine = { action = "Read", object = "Shrine Stones", lore = "fringe_hymn" },
	greenhouse_note = { action = "Read", object = "Clipboard", lore = "wren_2" },
	greenhouse_terminal = { action = "Read", object = "Greenhouse Terminal", lore = "greenhouse_log" },
	greenhouse_sunflower = {
		action = "Gather seeds",
		object = "A Living Sunflower",
		hold = 1,
		once = true,
		effects = {
			{ giveItem = "seed_packet" },
			{ setFlag = "found_sunflower" },
			{ notify = "Green leaves. A yellow face. No glow at all. You fill a packet with seeds.", kind = "info" },
		},
	},
	railsend_board = { action = "Read", object = "Departures Board", lore = "railsend_history" },
	suburbs_diary = { action = "Read", object = "Diary", lore = "suburbs_diary" },
	scrap_1 = { action = "Pry loose", object = "Rusted Wagon", hold = 1.5, once = true, effects = { { giveItem = "rail_part" } } },
	scrap_2 = { action = "Pry loose", object = "Rusted Wagon", hold = 1.5, once = true, effects = { { giveItem = "rail_part" } } },
	scrap_3 = { action = "Pry loose", object = "Rusted Wagon", hold = 1.5, once = true, effects = { { giveItem = "rail_part" } } },

	-- Halvorsen ----------------------------------------------------------------------------
	gatehouse_locker = {
		action = "Search",
		object = "Security Locker",
		once = true,
		effects = {
			{ giveItem = "station_keycard" },
			{ notify = "Behind a rotted uniform: a keycard, still on its lanyard.", kind = "info" },
		},
	},
	station_door_panel = {
		action = "Use",
		object = "Door Panel",
		hold = 0.8,
		showWhen = { { notFlag = "station_open" } },
		requires = { { any = { { item = "station_keycard" }, { character = "renn" }, { character = "dex" } } } },
		failText = "ACCESS DENIED. Staff keycard required.",
		effects = {
			{
				notify = "You type your old access code. It still works. In fourteen years, nobody revoked it.",
				kind = "info",
				when = { { character = "renn" } },
			},
			{ notify = "The panel blinks green. The doors grind open.", kind = "info", when = { { notCharacter = "renn" } } },
			{ setFlag = "station_open" },
		},
	},
	station_vent = {
		action = "Crawl in",
		object = "Loose Vent Cover",
		hidden = true,
		hold = 1.5,
		showWhen = { { notFlag = "station_open" } },
		effects = {
			{ teleport = "Station_Lobby" },
			{ setFlag = "station_open" },
			{ notify = "You crawl through the ducts and drop into the lobby, then unbar the doors from inside.", kind = "info" },
		},
	},
	term_lobby = { action = "Read", object = "Security Terminal", lore = "halvorsen_log_1" },
	term_lab_b = { action = "Read", object = "Lab Terminal", lore = "halvorsen_log_2" },
	term_lab_a = {
		action = "Log in",
		object = "Staff Terminal",
		requires = { { character = "renn" } },
		failText = "LOGIN REQUIRED. Halvorsen staff credentials only.",
		lore = "halvorsen_renn",
	},
	station_letter = { action = "Open", object = "Staff Locker", lore = "adeyemi_5" },
	relay_note = { action = "Read", object = "Folded Letter", lore = "wren_3" },
	relay_transmitter = { action = "Approach", object = "Halvorsen Relay", dialogue = "transmitter" },
}
