return {
	name = "Marigold",
	entry = {
		{ node = "hello" },
	},
	nodes = {
		hello = {
			text = "Welcome to Marigold's Menagerie! Real fur, real feathers, real hearts. Everyone in the Grid needs someone waiting at home. Or following them around. Both are fine!",
			textBy = {
				ivy = "Ivy! My favorite Greenkeeper! The glow fox kits keep chewing your civic ferns, sorry. Looking for a companion?",
				silas = "Oh! A Crown customer! We have a lovely glow fox. Very fashionable up there, I hear.",
			},
			choices = {
				{ text = "Let's see the animals.", effects = { { openShop = "petshop" } } },
				{ text = "A glowing fox?", next = "fox" },
				{ text = "Just visiting." },
			},
		},
		fox = {
			text = "Ascent bred them from civic stock, fur and all. Perfectly safe, very affectionate, and you'll never lose one in the dark. They do stare at the north wall sometimes. Foxes, you know. Funny little things.",
		},
	},
}
