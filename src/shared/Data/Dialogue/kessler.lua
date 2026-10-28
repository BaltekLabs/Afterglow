return {
	name = "Kessler",
	entry = {
		{ when = { { flag = "ending_silence" }, { notFlag = "kessler_grid" } }, node = "grid" },
		{ when = { { flag = "trespassed_ascent" }, { notFlag = "kessler_warned" } }, node = "warned" },
		{ when = { { quest = "cellrun", stage = "paid" } }, node = "pay" },
		{ when = { { item = "relay_core" }, { notFlag = "core_resolved" } }, node = "core" },
		{ when = { { item = "seed_packet" }, { quest = "seeds", status = "active" }, { notFlag = "seeds_resolved" } }, node = "seeds" },
		{ when = { { quest = "cellrun", status = "active" } }, node = "job_wait" },
		{ node = "hello" },
	},
	nodes = {
		hello = {
			text = "Ascent Biotech, Grid Depot. Power, plants, progress. What can I do for you?",
			textBy = {
				mara = "Detective Quell. Sorry, former detective. Thought we'd seen the last of you. What can Ascent do for you?",
				ivy = "A Greenkeeper! Love what you people do with our Civic Strain. What can Ascent do for you?",
				silas = "Mr. Crane! An honor. Your father's a great friend of the company. What can I do for you?",
			},
			choices = {
				{ text = "Got any work?", when = { { quest = "cellrun", status = "none" } }, next = "job" },
				{ text = "What does Ascent actually do?", next = "ascent" },
				{ text = "Can Ascent get someone outside the Wall?", next = "outside" },
				{ text = "Nothing." },
			},
		},
		outside = {
			text = "Outside? Ha. Ascent grows plants, friend. The Council handles the Veil. And between you and me, nobody at Ascent wants to go outside. We've seen the samples.",
		},
		job = {
			text = "Three Vesper cells from the crate in the yard, into the generator at the base of the Static Tower. Sixty credits. I'll clear you through the yard so the wardens don't toss you out.",
			choices = {
				{ text = "I'll do it.", effects = { { startQuest = "cellrun" }, { setFlag = "ascent_access" } }, next = "job_ok" },
				{ text = "Pass." },
			},
		},
		job_ok = {
			text = "Don't drop them. They don't explode. They do... hum.",
		},
		job_wait = {
			text = "Cells go in the tower generator. Clock's ticking, friend.",
		},
		pay = {
			text = "Generator's purring. Sixty credits, as promised. Come back any time you need honest work.",
			effects = { { credits = 60 }, { setFlag = "cellrun_paid" }, { rep = "ascent", amount = 5 } },
		},
		ascent = {
			text = "We keep the lights on. Literally. The Powerhouse runs on Vesper, and every planter in this city is our Civic Strain. Clean air, cool streets, full bellies. You're welcome.",
			choices = {
				{ text = "[Renn] Better than Halvorsen did?", when = { { character = "renn" } }, next = "renn_jab" },
				{ text = "[Teo] And the Mother Strain? Is that 'civic' too?", when = { { character = "teo" } }, next = "teo_jab" },
				{ text = "Sounds like a monopoly.", next = "monopoly" },
				{ text = "Right." },
			},
		},
		renn_jab = {
			text = "...Halvorsen was a tragedy. Ascent was a funding partner, not the operator. It's on the plaque in Meridian Plaza, if you like reading.",
		},
		teo_jab = {
			text = "Where did you hear that name? ...That's Council business, friend. Powerhouse business. I sell planters.",
		},
		monopoly = {
			text = "Sounds like civilization, friend.",
		},
		warned = {
			text = "Before anything else: you were in my yard without clearance. Do it again and Ascent security will remember your face.",
			effects = { { setFlag = "kessler_warned" } },
			next = "hello",
		},
		core = {
			text = "Is that a relay core? From Halvorsen? How did you even... never mind. Three hundred credits. No questions, no paperwork.",
			choices = {
				{
					text = "Sold.",
					effects = {
						{ takeItem = "relay_core" },
						{ credits = 300 },
						{ rep = "ascent", amount = 15 },
						{ rep = "fringe", amount = -5 },
						{ setFlag = "core_to_ascent" },
						{ setFlag = "core_resolved" },
					},
					next = "core_sold",
				},
				{ text = "Not for sale." },
			},
		},
		core_sold = {
			text = "Pleasure. Ascent thanks you. And you were never outside, understood?",
		},
		seeds = {
			text = "Wait. Are those pre-Bloom seeds? Do you know what our gene lab would pay for a clean genome? A hundred and fifty credits, right now.",
			choices = {
				{
					text = "Deal.",
					effects = {
						{ takeItem = "seed_packet" },
						{ credits = 150 },
						{ rep = "ascent", amount = 10 },
						{ rep = "fringe", amount = -10 },
						{ trust = "bram", amount = -3 },
						{ setFlag = "seeds_to_ascent" },
						{ setFlag = "seeds_resolved" },
					},
					next = "seeds_sold",
				},
				{ text = "They're promised to someone." },
			},
		},
		seeds_sold = {
			text = "Smart. Sentiment doesn't keep the lights on.",
		},
		grid = {
			text = "Grid output dropped thirty percent last night. Half the city went dark for an hour. Someone tampered with the Halvorsen relay, which is outside the Veil, which is impossible.\n\nYou wouldn't know anything about that.",
			effects = { { setFlag = "kessler_grid" }, { rep = "ascent", amount = -10 } },
			choices = {
				{ text = "Why would a dead station power Veyra?", next = "grid_why" },
				{ text = "Never heard of it." },
			},
		},
		grid_why = {
			text = "I'm a foreman, not a botanist. I just know which questions get people relocated. That's one of them.",
		},
	},
}
