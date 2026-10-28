--[[
	Quests are stage machines. A stage completes when its `completeWhen` conditions pass,
	then moves to `next` (or finishes the quest when `next` is nil).
	`marker` names a waypoint part, or "NPC:<id>" to point at a character.

	Nothing here is forced: quests only start when the player stumbles into them, and every
	stage checks world flags, so doing things "out of order" simply skips stages ahead.
]]
return {
	signal = {
		name = "The Signal",
		kind = "main",
		description = "For fourteen years, the Static Tower has relayed a broadcast from Halvorsen Station calling for a woman named Wren Hollis. Someone should find out who is still calling.",
		start = "listen",
		stages = {
			listen = {
				objective = "Listen to the broadcast at the foot of the Static Tower.",
				marker = "M_TowerSpeaker",
				completeWhen = { { flag = "heard_signal" } },
				next = "tamsin",
			},
			tamsin = {
				objective = "Ask Old Tamsin at Static & Sons about the broadcast.",
				marker = "NPC:tamsin",
				completeWhen = { { flag = "tamsin_agreed" } },
				next = "escape",
			},
			escape = {
				objective = "Get out of Veyra. The gates are sealed, so find another way.",
				hint = "Nobody is allowed to leave the city. People in the Rust talk about the old storm sewers under the back alleys.",
				completeWhen = { { flag = "left_city" } },
				next = "station",
			},
			station = {
				objective = "Follow the signal north through the Sporewilds to Halvorsen Station.",
				hint = "The north sewer outflow opens into the Sporewilds. Spore clouds hurt without a filter mask. Rooted are rare, but move quietly near them.",
				marker = "M_StationGate",
				completeWhen = { { flag = "visited_deadzone" } },
				next = "inside",
			},
			inside = {
				objective = "Find a way into Halvorsen Station.",
				hint = "The doors need a keycard. The old gatehouse might have one.",
				marker = "M_StationDoor",
				completeWhen = { { flag = "station_open" } },
				next = "relay",
			},
			relay = {
				objective = "Find the source of the signal inside the station.",
				marker = "M_Transmitter",
				completeWhen = { { flag = "signal_resolved" } },
				next = "return",
			},
			["return"] = {
				objective = "Return to Old Tamsin at the Static Tower.",
				marker = "NPC:tamsin",
				completeWhen = { { flag = "told_tamsin" } },
				onComplete = { { chapterComplete = true } },
			},
		},
	},

	seeds = {
		name = "Seeds for Hollow Garden",
		kind = "side",
		description = "Everything Bram plants comes up glowing. He wants seeds for a plain, honest plant, which nobody has seen since before the Bloom.",
		start = "find",
		stages = {
			find = {
				objective = "Search the ruined greenhouse northeast of Hollow Garden for living seeds.",
				hint = "Something sleeps by the greenhouse door. Walk soft.",
				marker = "M_Sunflower",
				completeWhen = { { item = "seed_packet" } },
				next = "deliver",
			},
			deliver = {
				objective = "Bring the seeds to Bram in Hollow Garden, or find another buyer.",
				marker = "NPC:bram",
				completeWhen = { { flag = "seeds_resolved" } },
			},
		},
	},

	cellrun = {
		name = "Cell Run",
		kind = "job",
		description = "Kessler needs three Vesper cells moved from the Ascent depot to the Static Tower generator. Easy money, he says.",
		start = "pickup",
		stages = {
			pickup = {
				objective = "Collect Vesper cells from the crate in the Ascent depot yard.",
				marker = "M_CellCrate",
				completeWhen = { { item = "vesper_cell", count = 3 } },
				next = "deliver",
			},
			deliver = {
				objective = "Install the cells in the generator at the foot of the Static Tower.",
				marker = "M_Generator",
				completeWhen = { { flag = "cells_delivered" } },
				next = "paid",
			},
			paid = {
				objective = "Collect your pay from Kessler.",
				marker = "NPC:kessler",
				completeWhen = { { flag = "cellrun_paid" } },
			},
		},
	},

	loose_ends = {
		name = "Loose Ends",
		kind = "side",
		description = "Vane, the Rust's quietest contractor, wants a paper ledger kept by Councillor's aide Orrin Pell. What happens to Pell afterwards depends on who ends up holding it.",
		start = "get",
		stages = {
			get = {
				objective = "Get into Orrin Pell's apartment in the Grid and find his ledger.",
				hint = "Pell's door is locked. A hacker, a lockpick, or Pell's own key would open it. He drinks at The Wick at night.",
				marker = "M_PellDoor",
				completeWhen = { { item = "pell_ledger" } },
				next = "decide",
			},
			decide = {
				objective = "Decide who gets the ledger: Vane, Pell, or the whole city.",
				hint = "Vane waits at The Drip in the Rust. Pell is in the Grid. Tamsin owns a radio tower.",
				completeWhen = { { flag = "ledger_resolved" } },
			},
		},
	},

	spare_parts = {
		name = "Spare Parts",
		kind = "side",
		description = "Rail's End is trying to get an old locomotive moving again. Foreman Dunmore needs coupler parts from the wrecks in the Overgrown Suburbs.",
		start = "collect",
		stages = {
			collect = {
				objective = "Pry three coupler parts from the scrap in the Overgrown Suburbs.",
				hint = "Look for rusted rail wagons among the ruined houses.",
				marker = "M_Suburbs",
				completeWhen = { { item = "rail_part", count = 3 } },
				next = "deliver",
			},
			deliver = {
				objective = "Bring the coupler parts to Dunmore at Rail's End.",
				marker = "NPC:dunmore",
				completeWhen = { { flag = "parts_delivered" } },
			},
		},
	},
}
