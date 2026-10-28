-- Vendors. Stock entries sell an `item` or a `companion`.
return {
	vela = {
		name = "Vela's Night Stall",
		npc = "vela",
		stock = {
			{ item = "glowbowl", price = 8 },
			{ item = "mend_patch", price = 25 },
			{ item = "filter_mask", price = 80 },
		},
	},
	glitch = {
		name = "Glitch's Black Market",
		npc = "glitch",
		stock = {
			{ item = "mend_patch", price = 30 },
			{ item = "crown_pass", price = 200 },
			{ item = "powerhouse_keycard", price = 250 },
		},
	},
	petshop = {
		name = "Marigold's Menagerie",
		npc = "marigold",
		stock = {
			{ companion = "alley_cat", price = 45 },
			{ companion = "crow", price = 50 },
			{ companion = "mutt", price = 60 },
			{ companion = "glow_fox", price = 140 },
		},
	},
	botshop = {
		name = "Kettle's Bot Shop",
		npc = "kettle",
		stock = {
			{ companion = "scrap_spider", price = 80 },
			{ companion = "clockcat", price = 100 },
			{ companion = "drone", price = 110 },
			{ companion = "k9", price = 160 },
		},
	},
	ilsa = {
		name = "Ilsa's Trade Car",
		npc = "ilsa",
		stock = {
			{ item = "mend_patch", price = 20 },
			{ item = "filter_mask", price = 60 },
		},
	},
}
