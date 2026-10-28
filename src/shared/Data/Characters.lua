--[[
	Playable protagonists. Each changes their ability, where they start in the city, dialogue
	options, and which doors and secrets they can reach. None of them lock out the main story.
	`start` is the checkpoint waypoint they begin at.
]]
return {
	order = { "mara", "juno", "ivy", "sable", "renn", "dex", "silas", "teo" },

	list = {
		mara = {
			id = "mara",
			name = "Mara Quell",
			short = "Mara",
			gender = "female",
			title = "The Investigator",
			color = "#ffb048",
			bio = "A Civic Security detective until she asked who really started the Ascent warehouse fire. Mara still carries the badge they forgot to collect, and the habit of noticing what other people step over.",
			perks = {
				"INSIGHT [Q]: reveal clues and hidden objects nearby",
				"Old badge: officials sometimes still talk to her",
				"Finds secrets the others walk past",
			},
			ability = { id = "insight", name = "Insight", cooldown = 14, duration = 25, radius = 90 },
			startCredits = 40,
			startItems = { old_badge = 1 },
			start = "CP_Grid",
			intro = {
				"Six months without a badge. Six months of nobody hiring a detective who asks about Ascent.",
				"Somewhere up on the Static Tower, a dead woman is asking a question of her own.",
			},
		},

		juno = {
			id = "juno",
			name = "Juno Ash",
			short = "Juno",
			gender = "female",
			title = "The Runner",
			color = "#5affc8",
			bio = "Born outside the Wall, smuggled in as a child the year the Veil went up. Juno runs packages through the Rust for anyone who pays, and she still breathes spores like ordinary air.",
			perks = {
				"DASH [Q]: burst forward out of trouble",
				"Spore-tolerant: immune to spore clouds",
				"Knows the Rust's back alleys and its people",
			},
			ability = { id = "dash", name = "Dash", cooldown = 5, power = 100 },
			speedMultiplier = 1.1,
			startCredits = 25,
			startItems = { runner_gloves = 1 },
			start = "CP_Rust",
			intro = {
				"Too many walls. Not enough sky. Down in the Rust there's never any sky at all.",
				"But you remember the forests outside. And the old sewers still remember the way.",
			},
		},

		ivy = {
			id = "ivy",
			name = "Ivy Sol",
			short = "Ivy",
			gender = "female",
			title = "The Greenkeeper",
			color = "#9aff6a",
			bio = "Ivy tends the civic plants, the safe bioengineered strains that clean Veyra's air and feed its people. She knows every leaf in the city, and lately the leaves have started turning toward the north.",
			perks = {
				"BLOOM [Q]: calm Rooted and clear spores around you",
				"Plants speak to her, and the Fringe recognizes her",
				"Reads the difference between civic and wild growth",
			},
			ability = { id = "bloom", name = "Bloom", cooldown = 30, duration = 20, radius = 45 },
			startCredits = 35,
			startItems = { pruning_shears = 1 },
			start = "CP_Grid",
			intro = {
				"Every planter in the Grid leans the same way this week. North, toward the Wall.",
				"Toward the broadcast from the Static Tower that nobody else seems to hear anymore.",
			},
		},

		sable = {
			id = "sable",
			name = "Sable Quinn",
			short = "Sable",
			gender = "female",
			title = "The Fixer",
			color = "#ff5a8c",
			bio = "Raised in the Rust and trained by the most careful killer in Veyra, Sable walked away from contract work to broker favors instead. Everyone owes her something. She'd like to keep it that way.",
			perks = {
				"CLOAK [Q]: unseen by turrets, guards and Rooted for a moment",
				"Lockpicking: opens doors marked as pickable",
				"The Rust underworld treats her as one of its own",
			},
			ability = { id = "cloak", name = "Cloak", cooldown = 25, duration = 10 },
			startCredits = 80,
			startItems = { lockpicks = 1 },
			start = "CP_Rust",
			intro = {
				"Vane taught you two things: never take a job you don't understand, and never stay in one place.",
				"Tonight the whole city is talking about a ghost on the Static Tower. That's a job nobody understands.",
			},
		},

		renn = {
			id = "renn",
			name = "Dr. Ilya Renn",
			short = "Ilya",
			gender = "male",
			title = "The Researcher",
			color = "#968cff",
			bio = "Fourteen years ago, Ilya Renn was a junior botanist at Halvorsen Station. He has spent every year since pretending he wasn't there the night it all began. The Static Tower has other plans.",
			perks = {
				"ANALYZE [Q]: sense Rooted and Vesper growth through walls",
				"Halvorsen access: old codes still open old doors",
				"Remembers what the official history leaves out",
			},
			ability = { id = "analyze", name = "Analyze", cooldown = 12, duration = 9, radius = 160 },
			startCredits = 60,
			startItems = { halvorsen_badge = 1 },
			start = "CP_Grid",
			intro = {
				"You swore you'd never listen to that frequency again.",
				"But the Static Tower is playing her voice, and you have never been able to stop listening.",
			},
		},

		dex = {
			id = "dex",
			name = "Dex Varga",
			short = "Dex",
			gender = "male",
			title = "The Hacker",
			color = "#3cf0ff",
			bio = "Dex grew up wiring stolen power into Rust apartments and graduated to stealing everything else. There is no lock in Veyra he can't talk to, and no Council firewall he hasn't laughed at.",
			perks = {
				"HACK [Q]: open hackable locks, spoof lifts, blind turrets",
				"Splices electronic doors just by trying them",
				"Glitch's crew owes him favors",
			},
			ability = { id = "hack", name = "Hack", cooldown = 6, radius = 22 },
			startCredits = 30,
			startItems = { cyberdeck = 1 },
			start = "CP_Rust",
			intro = {
				"Someone patched a new signal into the old Static Tower feed. Same voice, fresh static. Live.",
				"Nobody patches a ghost. You want to know who's on the other end.",
			},
		},

		silas = {
			id = "silas",
			name = "Silas Crane",
			short = "Silas",
			gender = "male",
			title = "The Heir",
			color = "#ffe08a",
			bio = "Heir to a Crown family that built half the Powerhouse. Silas left the gala circuit after he saw what his father signed. He kept his clearance, his grappling rig, and his doubts.",
			perks = {
				"GRAPPLE [Q]: launch to wherever you're looking",
				"Crown clearance: the Crown Lift opens for him",
				"Councillors still take his calls",
			},
			ability = { id = "grapple", name = "Grapple", cooldown = 3, range = 150, speed = 130 },
			startCredits = 200,
			startItems = { signet_ring = 1 },
			start = "CP_Crown",
			intro = {
				"From the Crown you can see the whole city glowing. You can also see the Wall, and the Veil above it.",
				"Father says it keeps the Sporewilds out. Tonight the Static Tower is saying something else.",
			},
		},

		teo = {
			id = "teo",
			name = "Teo Marsh",
			short = "Teo",
			gender = "male",
			title = "The Technician",
			color = "#ff8a3c",
			bio = "Eight years keeping the Powerhouse running, until a maintenance shift took him close enough to the Mother Strain to hear it hum his name. Teo quit the next day. The nightmares didn't.",
			perks = {
				"OVERLOAD [Q]: EMP that shuts down turrets nearby",
				"Maintenance codes: can open the Powerhouse hatch",
				"Knows how the city's power really flows",
			},
			ability = { id = "overload", name = "Overload", cooldown = 25, duration = 15, radius = 140 },
			startCredits = 50,
			startItems = { powerhouse_badge = 1 },
			start = "CP_Grid",
			intro = {
				"The Powerhouse hums under everything. You stopped hearing it the day you quit. Almost.",
				"Tonight the Static Tower hums back, in a voice you've heard before.",
			},
		},
	},
}
