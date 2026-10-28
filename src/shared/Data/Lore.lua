-- Journal entries: letters, logs, plaques, notes. Found by exploring; almost all optional.
local Lore = {}

Lore.categories = {
	{ id = "records", name = "Official Records" },
	{ id = "city", name = "City Notes" },
	{ id = "council", name = "The Council" },
	{ id = "wren", name = "Wren Hollis" },
	{ id = "halvorsen", name = "Halvorsen Station" },
	{ id = "adeyemi", name = "The Adeyemi Family" },
	{ id = "ascent", name = "Ascent Biotech" },
	{ id = "outlands", name = "The Outlands" },
}

Lore.entries = {
	-- Official records ------------------------------------------------------------
	accord_plaque = {
		category = "records",
		order = 1,
		title = "The Bloom Accord",
		text = "ERECTED YEAR 3 AFTER THE BLOOM\n\nHere, in the ashes of the old city, the founders of Veyra signed the Accord: that the plant which ended the world would be made to rebuild it.\n\nThe Rot has burned out. The Vesper remains. We remain.\n\n— Dedicated by Ascent Biotech, Civic Partner of Veyra",
	},
	civic_strain = {
		category = "records",
		order = 2,
		title = "Civic Strain V-7",
		text = "THE PLANTS AROUND YOU ARE SAFE.\n\nEvery planter, vine and street tree in Veyra is Civic Strain V-7: bioengineered by Ascent Biotech from Vesper stock, sterile, non-spreading, and incapable of the lattice behavior seen in wild growth.\n\nCivic plants clean our air, cool our streets and feed our families.\n\nIf you see wild-type growth (violet glow, root spread, humming), report it to the Greenkeepers immediately.",
	},
	veil_notice = {
		category = "council",
		order = 1,
		title = "Notice of the Sealed Gates",
		text = "BY ORDER OF THE COUNCIL OF VEYRA\n\nThe gates of the city are sealed for the protection of all citizens. The Veil is maintained by the Powerhouse at all hours. Beyond it lie the Sporewilds, the Dead Zones and the Rot.\n\nAny attempt to leave the city is a crime against public safety. Any citizen with knowledge of such an attempt is required to report it to the Enforcers.\n\nThere is nothing outside worth the risk.",
	},

	-- City notes (scattered through buildings) -----------------------------------
	city_note_1 = { category = "city", order = 1, title = "Rent Reminder", text = "Unit 3, Rust Block K —\n\nRent's due Friday. The Grid landlords raised it again because 'the light costs more'. Light. We haven't seen the sun down here in nine years.\n\n— Management (such as it is)" },
	city_note_2 = { category = "city", order = 2, title = "Greenkeeper Shift Notes", text = "Planters on Sky Road 4 are leaning north again. Rotated them back. Third time this week.\n\nSupervisor says it's wind. There is no wind on Sky Road 4. There's a windbreak." },
	city_note_3 = { category = "city", order = 3, title = "A Child's Homework", text = "WHAT IS OUTSIDE THE WALL?\nby Nessa, age 9\n\nOutside the wall is the Rot and big glowing trees and people who are asleep standing up. My grandad says there were cows. I don't believe him. Cows are made up." },
	city_note_4 = { category = "city", order = 4, title = "Enforcer Duty Roster", text = "POWERHOUSE PERIMETER — NIGHT ROTATION\n\nReminder: turrets are on autonomous mode after 22:00. Do NOT walk the inner ring without your transponder. We lost Hollis-Grant that way. Paperwork took a month." },
	city_note_5 = { category = "city", order = 5, title = "Torn Flyer", text = "THE VEIL IS A CAGE\nASK WHY THE GATES NEVER OPEN\nASK WHERE THE POWER COMES FROM\nASK WHO IS STILL OUTSIDE\n\n(the bottom half has been torn away)" },
	city_note_6 = { category = "city", order = 6, title = "Recipe Card", text = "Grandma's Glowbowl\n\nCivic-strain noodles, 1 brick\nBroth: boil the stalks, NOT the leaves (leaves make you dream)\nChili oil to taste\n\nIf it hums, throw it out." },
	city_note_7 = { category = "city", order = 7, title = "Love Letter, Unsent", text = "R —\nYou live in the Crown and I live in the Rust and there are four hundred meters of city between us. I measured it. I'm going to find a way up.\n— T" },
	city_note_8 = { category = "city", order = 8, title = "Sewer Worker's Log", text = "Day shift, storm sewers, north trunk.\nPumps fine. Grate at the outflow still welded.\nSomeone cut the weld. Fresh cut. Footprints going OUT, not in.\nNot reporting it. None of my business." },
	sewer_chalk = {
		category = "city",
		order = 9,
		title = "Chalk Map in the Sewer",
		text = "Scrawled on the tunnel wall in runners' chalk:\n\nNORTH PIPE → WOODS (bring a mask)\nSOUTH PIPE → MARSH + THE RAILS\nDON'T WAKE THE SLEEPER AT THE BEND\n\nUnderneath, in a different hand: 'Welcome to outside.'",
	},
	crown_invite = {
		category = "city",
		order = 10,
		title = "Gala Invitation",
		text = "The Council of Veyra requests the honor of your presence at\nTHE FOURTEENTH ILLUMINATION\na celebration of fourteen years of light.\n\nCrown Promenade. Formal attire. Rust-tier guests not admitted.",
	},

	-- The Council ------------------------------------------------------------------
	powerhouse_log = {
		category = "council",
		order = 2,
		title = "Powerhouse Operations Log",
		text = "MOTHER STRAIN — CORE CHAMBER\nOutput: 104% nominal.\nLattice coherence: STABLE (external relay: Halvorsen, signal nominal).\nCivic Strain propagation: on schedule.\n\nNote: core resonance rises at night. Night staff report 'humming in the walls.' Rotate night staff weekly. Do not let them compare notes.",
	},
	powerhouse_order = {
		category = "council",
		order = 3,
		title = "Council Directive 9",
		text = "CLASSIFIED: CROWN EYES ONLY\n\nDIRECTIVE 9: POPULATION RETENTION\n\nLattice output correlates directly with resident population density within the Veil. Each departure measurably reduces output.\n\nThe gates remain sealed. The Veil remains up. Public messaging will continue to emphasize external danger.\n\nThe Sporewilds are dangerous. That remains true. It is simply not the reason.",
	},
	pell_ledger = {
		category = "council",
		order = 4,
		title = "Pell's Ledger",
		text = "Handwritten columns. Dates going back eleven years.\n\nASCENT HOLDINGS → COUNCIL DISCRETIONARY FUND\nLabel: 'Veil maintenance'\nLabel: 'Population stabilization'\nLabel: 'Halvorsen relay: do not interfere'\n\nThe last page is a list of names, all crossed out. Next to each: 'relocated'.",
	},

	-- Wren Hollis ------------------------------------------------------------------
	signal_transcript = {
		category = "wren",
		order = 1,
		title = "The Halvorsen Broadcast",
		text = "[Relayed from the Static Tower horns]\n\n\"...Halvorsen Relay to Veyra. Calling Wren Hollis. Wren, if you can hear this, the garden is still growing. It's warm here. Come home. Come home.\"\n\nThe message repeats every eleven minutes. It has repeated for fourteen years. Nobody seems to have noticed that it is a woman's voice, calling her own name.",
	},
	tamsin_photo = {
		category = "wren",
		order = 2,
		title = "A Framed Photo",
		text = "Two women on a rooftop, squinting into the sun. Before the Bloom: the sky behind them is blue, not violet. One wears a Halvorsen lanyard.\n\nOn the back: \"W & T. The day she got the job. She said it would change the world.\"",
	},
	wren_1 = {
		category = "wren",
		order = 3,
		title = "Wren's Field Notes, I",
		text = "Week one at Halvorsen. They call the specimen 'the lattice.' Root networks sharing sugar across a forest: every botanist knows that. This one shares something else. Patterns.\n\nDr. Sato played it a recording of birdsong on Monday. On Wednesday the lattice played it back through the sensor array. Slower. Wrong. Like a child humming a song it half remembers.\n\nI haven't slept well since.",
	},
	wren_2 = {
		category = "wren",
		order = 4,
		title = "Wren's Field Notes, II",
		text = "They want to graft it into the fallow farmland. 'Feed the world.' I asked what it feeds on. Nobody answered.\n\nI keep an ordinary sunflower at the back of Greenhouse 3. A control. Something in this building should be exactly what it looks like.",
	},
	wren_3 = {
		category = "wren",
		order = 5,
		title = "A Letter Never Sent",
		text = "T —\n\nIf this reaches you, don't come. The people out in the yard aren't sick, not the way the news says. It's keeping them. It keeps everything it learns. Voices. Faces. Us.\n\nI'm going up to the relay to try to make it forget. If you hear my voice on the radio after tonight, it isn't me. Please remember that it isn't me.\n\n— W",
	},

	-- Halvorsen ----------------------------------------------------------------------
	halvorsen_log_1 = {
		category = "halvorsen",
		order = 1,
		title = "Security Incident Log",
		text = "HALVORSEN BIORESEARCH — SECURITY\n\nIncident 0031: Containment failure, Greenhouse 3.\nAffected staff: 11.\nSymptoms: unresponsive to voice; wandering toward lattice beds; skin discoloration consistent with root infiltration.\n\nNOTE: Affected staff do not act aggressively unless the lattice is disturbed. Recommend: do not disturb the lattice.\n\nIncident 0032: [ENTRY CORRUPTED]",
	},
	halvorsen_log_2 = {
		category = "halvorsen",
		order = 2,
		title = "Project LANTERN, Phase II",
		text = "Neural coupling trial. Volunteers: 6.\nLattice response: exceptional. Pattern retention: total.\nVolunteer status post-trial: non-responsive (6/6).\n\nDirector Vance: Results justify Phase III (open-field dispersal). Funding confirmed by our partners at Ascent Holdings.\n\nIn the margin, in pen: \"God help us if we're wrong.\"",
	},
	halvorsen_renn = {
		category = "halvorsen",
		order = 3,
		title = "Access Log: I. Renn",
		text = "STAFF ACCESS — RENN, I. (ASSISTANT BOTANIST)\n02:14 — Greenhouse 3 airlock — OPENED\n02:15 — Greenhouse 3 airlock — HELD\n02:31 — Greenhouse 3 airlock — CLOSED\n\nYou remember now. Dr. Vance at the door with two steel canisters, asking you to hold it. You didn't ask what was in them.\n\nYou held the door.",
	},
	greenhouse_log = {
		category = "halvorsen",
		order = 4,
		title = "Greenhouse 3 Terminal",
		text = "GREENHOUSE 3 — STATUS: SEALED\n\nSeed vault (pre-lattice reference stock): RETAINED at request of Dr. W. Hollis.\nControl specimen Helianthus annuus (sunflower): ALIVE.\n\nLast update: today, 03:12.\nStaff logged in: none.",
	},

	-- The Adeyemis ------------------------------------------------------------------
	adeyemi_1 = {
		category = "adeyemi",
		order = 1,
		title = "Note on the Kitchen Table",
		text = "Dan —\n\nDouble shift again. They've moved me onto the relay team, which means late every night this month. Sorry, sorry. Tell Tobi I'll bring him a glow-moth from the greenhouse if he goes to bed on time.\n\nLove, K.",
	},
	adeyemi_2 = {
		category = "adeyemi",
		order = 2,
		title = "Unsent Letter",
		text = "Kemi,\n\nThe news says stay inside. The streetlights on Lowmarsh went out at nine, but the trees outside are glowing so bright I can read by them. Tobi keeps asking when you'll be home. I keep saying soon.\n\nThe phone lines are down. I'm writing this so I have something to give you when you walk through the door.\n\n— D",
	},
	adeyemi_3 = {
		category = "adeyemi",
		order = 3,
		title = "A Child's Drawing",
		text = "Crayon on the back of a Halvorsen pay slip. A tall woman, a tall man, a small boy. Green scribbles all around them, with little music notes floating up.\n\nUnderneath, in careful capitals: MY MUM WORKS WITH THE GLOWING PLANTS. SHE SAYS THEY CAN SING.",
	},
	adeyemi_4 = {
		category = "adeyemi",
		order = 4,
		title = "Letter in a Tin Box",
		text = "Day 9 out here.\n\nIf anyone finds this: my son is Tobi Adeyemi. He's with the Okafor family by the north gate. They're good people. Tell him his dad went to bring his mum home.\n\nThe trees hum at night. I've started to hum back. I don't think I'm the one choosing the song.",
	},
	adeyemi_5 = {
		category = "adeyemi",
		order = 5,
		title = "Kemi's Locker",
		text = "Daniel —\n\nI saw you from the window. You came all this way. Please don't come any closer.\n\nI'm still here. I'm just... slower. It's so warm. I can hear everyone who ever stood in this building. I can hear you.\n\nTell Tobi that they do sing. Tell him I\n\n[The rest of the page is laced with fine, pale roots.]",
	},

	-- Ascent -------------------------------------------------------------------------
	ascent_memo = {
		category = "ascent",
		order = 1,
		title = "Internal Memo: Grid Depot",
		text = "CONFIDENTIAL — ASCENT BIOTECH\nRE: Halvorsen Relay\n\nDo NOT jam the Halvorsen broadcast. Analysis indicates the signal maintains coherence between the Powerhouse Mother Strain and the northern lattice. Disruption is projected to reduce Veyra grid output by up to 30%.\n\nKeep the public uninterested. If anyone asks, it's a recording.\n\n— Regional Operations",
	},

	-- Outlands -----------------------------------------------------------------------
	fringe_hymn = {
		category = "outlands",
		order = 1,
		title = "Hymn of the Hollow",
		text = "Carved into the shrine stones at Hollow Garden:\n\nWe do not own the Glow.\nWe are guests in its memory.\nWhat it holds, it holds gently.\nWhat it keeps, it keeps forever.\nWalk softly, and be remembered kindly.",
	},
	railsend_history = {
		category = "outlands",
		order = 2,
		title = "Rail's End Station Board",
		text = "Chalked on the old departures board:\n\nTRAIN TO VEYRA: CANCELLED (14 yrs)\nTRAIN TO ANYWHERE: SOON\n\nPinned below, a list of everyone who has walked in since the Veil went up. Sixty-one names. Some came from the north woods. Eleven came out of the city sewers.",
	},
	suburbs_diary = {
		category = "outlands",
		order = 3,
		title = "Diary on a Kitchen Counter",
		text = "Bloom + 2 days. Mr. Halloran next door has been standing in his garden since Tuesday. He doesn't answer. Roots have grown over his shoes.\n\nBloom + 5. The radio says go to Veyra, they're building a wall. We're going tomorrow.\n\nBloom + 6. Halloran's gone. Just his shoes, in the roots.",
	},
	mirefall_drowned = {
		category = "outlands",
		order = 4,
		title = "Reed's Warning",
		text = "Told by Old Reed, written down by his granddaughter:\n\n\"The Rooted don't walk anymore, mostly. They stand where the roots took them and they sleep. But the marsh moves the roots, see. And sometimes it moves a sleeper with it. So you might find one where there wasn't one yesterday. Rare. But you might.\"",
	},
}

return Lore
