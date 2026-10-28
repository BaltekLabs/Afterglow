return {
	name = "Ilsa",
	entry = {
		{ node = "hello" },
	},
	nodes = {
		hello = {
			text = "Ilsa's Trade Car! Masks, patches, and the only working kettle between here and the Wall. You look like you crawled out of a pipe. Most of my customers did.",
			choices = {
				{ text = "What have you got?", effects = { { openShop = "ilsa" } } },
				{ text = "Where can I go from here?", next = "where" },
				{ text = "Bye, Ilsa." },
			},
		},
		where = {
			text = "Suburbs to the north: ruins, scrap, the odd sleeper. Marsh to the southwest: Mirefall, stilt village, lovely people, terrible smell. And far north past the Wall, the Sporewilds, Hollow Garden, and that dead station everybody whispers about.",
		},
	},
}
