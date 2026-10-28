--[[
	Named NPCs and ambient residents.
	schedule: list of { from, to, at } in in-game hours; `at` is a waypoint name. Slots may wrap midnight.
	patrol:   list of waypoints walked in a loop (used instead of schedule).
	dialogue: id in Data/Dialogue (defaults to the NPC id); false means no conversation.
	barks:    lines said aloud to nearby players. Strings, or { text, time = "day"|"night" }.
	witness:  false means this NPC never reports theft.
	Colors are hex strings so story data stays engine-agnostic (Color3.fromHex in code).
]]
local function rgb(r, g, b)
	return string.format("#%02x%02x%02x", r, g, b)
end

local function resident(name, role, patrol, barks, colors)
	return {
		name = name,
		role = role,
		dialogue = false,
		skin = colors[1],
		torso = colors[2],
		legs = colors[3],
		accent = colors[4],
		patrol = patrol,
		patrolPause = 5,
		barks = barks,
	}
end

return {
	-- The Grid ---------------------------------------------------------------------
	tamsin = {
		name = "Old Tamsin",
		role = "Radio keeper, Static & Sons",
		faction = "grid",
		skin = rgb(176, 130, 104),
		torso = rgb(88, 70, 60),
		legs = rgb(46, 42, 48),
		accent = rgb(255, 176, 72),
		height = 0.95,
		schedule = {
			{ from = 7, to = 22, at = "Tamsin_Shop" },
			{ from = 22, to = 7, at = "Tamsin_Home" },
		},
		barks = { "Eleven minutes. Always eleven minutes.", { text = "Radios fixed, hearts not.", time = "day" } },
	},
	kessler = {
		name = "Kessler",
		role = "Foreman, Ascent Grid Depot",
		faction = "ascent",
		skin = rgb(222, 186, 160),
		torso = rgb(210, 216, 228),
		legs = rgb(60, 66, 80),
		accent = rgb(120, 200, 255),
		schedule = {
			{ from = 8, to = 19, at = "Kessler_Desk" },
			{ from = 19, to = 8, at = "Kessler_Bar" },
		},
		barks = { { text = "Ascent Biotech. Power, plants, progress.", time = "day" }, { text = "Off the clock. Ask me tomorrow.", time = "night" } },
	},
	marigold = {
		name = "Marigold",
		role = "Owner, Marigold's Menagerie",
		faction = "grid",
		skin = rgb(240, 200, 170),
		torso = rgb(240, 150, 60),
		legs = rgb(70, 60, 50),
		accent = rgb(255, 210, 90),
		schedule = {
			{ from = 8, to = 20, at = "Marigold_Shop" },
			{ from = 20, to = 8, at = "Marigold_Home" },
		},
		barks = { "Every creature deserves someone.", { text = "Puppies! Kittens! Mildly glowing foxes!", time = "day" } },
	},
	pell = {
		name = "Orrin Pell",
		role = "Aide to the Council",
		faction = "council",
		skin = rgb(230, 200, 180),
		torso = rgb(40, 40, 60),
		legs = rgb(30, 30, 40),
		accent = rgb(255, 224, 138),
		schedule = {
			{ from = 8, to = 19, at = "Pell_Street" },
			{ from = 19, to = 8, at = "Pell_Wick" },
		},
		barks = { "Not now. I have a meeting.", { text = "One more. Then home. Then... one more.", time = "night" } },
	},

	-- The Rust ---------------------------------------------------------------------
	okafor = {
		name = "Sgt. Okafor",
		role = "Enforcer, North Gate",
		faction = "council",
		skin = rgb(92, 62, 46),
		torso = rgb(52, 60, 78),
		legs = rgb(34, 36, 44),
		accent = rgb(255, 80, 90),
		height = 1.05,
		schedule = { { from = 0, to = 24, at = "Okafor_Post" } },
		barks = { "The gate is sealed. The gate is always sealed.", { text = "Hear that hum beyond the Veil? Don't.", time = "night" } },
	},
	vela = {
		name = "Vela",
		role = "Night market vendor, Lantern Row",
		faction = "rust",
		skin = rgb(204, 160, 120),
		torso = rgb(140, 40, 110),
		legs = rgb(30, 30, 40),
		accent = rgb(255, 80, 190),
		schedule = {
			{ from = 16, to = 4, at = "Vela_Stall" },
			{ from = 4, to = 16, at = "Vela_Home" },
		},
		barks = { { text = "Glowbowls! Hot glowbowls!", time = "night" }, { text = "Filters, patches, noodles. Come see!", time = "night" } },
	},
	pike = {
		name = "Pike",
		role = "Rust drifter",
		faction = "rust",
		skin = rgb(110, 74, 54),
		torso = rgb(84, 92, 70),
		legs = rgb(60, 50, 44),
		accent = rgb(200, 200, 120),
		schedule = {
			{ from = 6, to = 22, at = "Pike_Alley" },
			{ from = 22, to = 6, at = "Pike_Market" },
		},
		barks = { "Pike listens. Pike always listens.", "Spare a credit for a man with nothing but stories?" },
	},
	glitch = {
		name = "Glitch",
		role = "Hacker, black-market broker",
		faction = "rust",
		skin = rgb(200, 170, 150),
		torso = rgb(30, 30, 36),
		legs = rgb(24, 24, 30),
		accent = rgb(60, 240, 255),
		schedule = { { from = 0, to = 24, at = "Glitch_Den" } },
		barks = { "Everything's for sale. Especially secrets.", "Your firewall called. It's crying." },
	},
	kettle = {
		name = "Kettle",
		role = "Roboticist, Kettle's Bot Shop",
		faction = "rust",
		skin = rgb(150, 110, 90),
		torso = rgb(120, 90, 50),
		legs = rgb(60, 50, 40),
		accent = rgb(255, 176, 72),
		height = 0.9,
		schedule = {
			{ from = 9, to = 23, at = "Kettle_Shop" },
			{ from = 23, to = 9, at = "Kettle_Back" },
		},
		barks = { "If it beeps, I can fix it. If it bites, I made it.", "Mind the spider. She's friendly. Mostly." },
	},
	vane = {
		name = "Vane",
		role = "Contractor, The Drip",
		faction = "rust",
		skin = rgb(190, 150, 130),
		torso = rgb(20, 20, 24),
		legs = rgb(20, 20, 24),
		accent = rgb(180, 30, 50),
		height = 1.05,
		witness = false,
		schedule = {
			{ from = 18, to = 6, at = "Vane_Booth" },
			{ from = 6, to = 18, at = "Vane_Alley" },
		},
		barks = { "...", { text = "Sit down or keep walking.", time = "night" } },
	},

	-- The Crown --------------------------------------------------------------------
	hale = {
		name = "Councillor Hale",
		role = "Council of Veyra",
		faction = "council",
		skin = rgb(236, 210, 190),
		torso = rgb(240, 236, 226),
		legs = rgb(200, 190, 170),
		accent = rgb(255, 224, 138),
		schedule = { { from = 0, to = 24, at = "Hale_Hall" } },
		barks = { "Fourteen years of light. Remember that.", "The Veil keeps us safe." },
	},

	-- The Outlands -----------------------------------------------------------------
	bram = {
		name = "Bram",
		role = "Gardener, Hollow Garden",
		faction = "fringe",
		skin = rgb(196, 150, 112),
		torso = rgb(80, 110, 70),
		legs = rgb(70, 56, 40),
		accent = rgb(120, 230, 140),
		height = 1.05,
		schedule = {
			{ from = 6, to = 20, at = "Bram_Garden" },
			{ from = 20, to = 6, at = "Bram_Fire" },
		},
		barks = { { text = "Glowing again. Everything comes up glowing.", time = "day" }, "Keep your voice down near the roots." },
	},
	lune = {
		name = "Mother Lune",
		role = "Keeper of the Hollow shrine",
		faction = "fringe",
		skin = rgb(160, 120, 96),
		torso = rgb(200, 196, 180),
		legs = rgb(150, 140, 120),
		accent = rgb(90, 255, 200),
		schedule = { { from = 0, to = 24, at = "Lune_Shrine" } },
		barks = { "The Memory is listening.", "Walk softly, and be remembered kindly." },
	},
	dunmore = {
		name = "Foreman Dunmore",
		role = "Head of Rail's End",
		faction = "fringe",
		skin = rgb(120, 84, 60),
		torso = rgb(60, 70, 90),
		legs = rgb(50, 44, 40),
		accent = rgb(255, 150, 60),
		height = 1.1,
		schedule = {
			{ from = 6, to = 21, at = "Dunmore_Yard" },
			{ from = 21, to = 6, at = "Dunmore_Car" },
		},
		barks = { "She'll run again. You'll see.", "Mind the rails. Old habit." },
	},
	ilsa = {
		name = "Ilsa",
		role = "Trader, Rail's End",
		faction = "fringe",
		skin = rgb(230, 190, 160),
		torso = rgb(110, 60, 90),
		legs = rgb(50, 40, 40),
		accent = rgb(255, 120, 200),
		schedule = { { from = 0, to = 24, at = "Ilsa_Car" } },
		barks = { "Fair trades only. Mostly fair.", "Came out of the sewers, did you? Smells like it." },
	},
	reed = {
		name = "Old Reed",
		role = "Fisherman, Mirefall",
		faction = "fringe",
		skin = rgb(140, 100, 80),
		torso = rgb(70, 80, 70),
		legs = rgb(60, 60, 50),
		accent = rgb(140, 220, 200),
		height = 0.95,
		schedule = { { from = 0, to = 24, at = "Reed_Dock" } },
		barks = { "Fish are biting. Something else is too.", "Mind the reeds after dark." },
	},

	-- Patrols and ambient residents -------------------------------------------------
	enforcer_gate = resident("Enforcer", "Council Enforcer", { "Enf_Gate_1", "Enf_Gate_2", "Enf_Gate_3" }, { "Move along, citizen.", "No loitering by the gate." }, { rgb(220, 190, 160), rgb(30, 34, 46), rgb(30, 34, 46), rgb(255, 80, 90) }),
	enforcer_ph = resident("Enforcer", "Powerhouse Guard", { "Enf_PH_1", "Enf_PH_2", "Enf_PH_3", "Enf_PH_4" }, { "Powerhouse perimeter. Turn back.", "Turrets are live." }, { rgb(160, 120, 100), rgb(30, 34, 46), rgb(30, 34, 46), rgb(255, 80, 90) }),
	enforcer_crown = resident("Enforcer", "Crown Security", { "Enf_Crown_1", "Enf_Crown_2" }, { "Residents and guests only.", "Lovely evening, sir. Madam." }, { rgb(240, 210, 190), rgb(220, 220, 230), rgb(40, 40, 50), rgb(255, 224, 138) }),
	warden = resident("Ascent Warden", "Depot security", { "Warden_1", "Warden_2", "Warden_3", "Warden_4" }, { "Restricted area.", "Depot's closed to the public." }, { rgb(230, 190, 160), rgb(30, 36, 50), rgb(30, 36, 50), rgb(120, 200, 255) }),
	rust_a = resident("Rust Local", "The Rust", { "Res_Rust_A1", "Res_Rust_A2", "Res_Rust_A3" }, { "Did you hear the Static Tower last night? Louder.", "Somebody saw a Rooted in the sewers. Rooted! In the city!", "Rent's up again. Course it is." }, { rgb(150, 100, 76), rgb(90, 60, 50), rgb(50, 46, 40), rgb(255, 120, 60) }),
	rust_b = resident("Rust Local", "The Rust", { "Res_Rust_B1", "Res_Rust_B2", "Res_Rust_B3" }, { "Glitch can get you anything. For a price.", "Don't make eye contact with anyone in The Drip.", "Sky's up there somewhere, they tell me." }, { rgb(240, 200, 170), rgb(60, 90, 110), rgb(40, 40, 50), rgb(60, 240, 255) }),
	grid_a = resident("Grid Commuter", "The Grid", { "Res_Grid_A1", "Res_Grid_A2", "Res_Grid_A3", "Res_Grid_A4" }, { "Late again. The lifts were packed.", "Planters are leaning funny this week.", "Did you see the new holo ads? Ascent's everywhere." }, { rgb(240, 200, 170), rgb(60, 90, 140), rgb(40, 40, 50), rgb(255, 230, 120) }),
	grid_b = resident("Grid Commuter", "The Grid", { "Res_Grid_B1", "Res_Grid_B2", "Res_Grid_B3" }, { "Fourteen years of light, they keep saying.", "My kid wants a glow fox. Have you SEEN the price?", "Don't look down. Never look down." }, { rgb(110, 74, 54), rgb(150, 70, 60), rgb(50, 46, 40), rgb(120, 230, 255) }),
	crown_a = resident("Crown Resident", "The Crown", { "Res_Crown_1", "Res_Crown_2", "Res_Crown_3" }, { "The gala is going to be divine.", "I've never been below the Grid. Why would I?", "Is that a Rust accent? How quaint." }, { rgb(250, 220, 200), rgb(250, 245, 235), rgb(220, 200, 160), rgb(255, 224, 138) }),
	hollow_a = resident("Hollow Villager", "Hollow Garden", { "Res_Hollow_1", "Res_Hollow_2", "Res_Hollow_3" }, { "Another city runner? Welcome.", "The Glow was loud last night." }, { rgb(190, 150, 120), rgb(90, 110, 70), rgb(70, 56, 40), rgb(120, 230, 140) }),
	rails_a = resident("Rail's End Hand", "Rail's End", { "Res_Rails_1", "Res_Rails_2" }, { "Grease, grease and more grease.", "Dunmore thinks that engine's going to run. Bless him." }, { rgb(130, 90, 70), rgb(60, 70, 90), rgb(50, 44, 40), rgb(255, 150, 60) }),
	mire_a = resident("Mirefall Fisher", "Mirefall", { "Res_Mire_1", "Res_Mire_2" }, { "Watch your step on the boards.", "Saw lights in the reeds again." }, { rgb(160, 120, 100), rgb(70, 90, 80), rgb(60, 60, 50), rgb(140, 220, 200) }),
}
