return {
	name = "Kettle",
	entry = {
		{ when = { { time = "night" } }, node = "late" },
		{ node = "hello" },
	},
	nodes = {
		hello = {
			text = "Welcome to Kettle's! Bots built, bots fixed, bots adopted. Every one of these was headed for the scrapper until I got my hands on it. Looking for a friend? Friends with sensors, I mean.",
			textBy = {
				teo = "Teo Marsh! Powerhouse boy! I still have that servo you sold me. Best servo in the Rust. Looking for a friend?",
			},
			choices = {
				{ text = "Let's see the bots.", effects = { { openShop = "botshop" } } },
				{ text = "Where do you get them?", next = "source" },
				{ text = "Just looking." },
			},
		},
		late = {
			text = "Shop's technically closed, but the bots don't sleep, so neither do I. Want a look?",
			choices = {
				{ text = "Let's see the bots.", effects = { { openShop = "botshop" } } },
				{ text = "Another time." },
			},
		},
		source = {
			text = "Enforcer scrap, mostly. They decommission patrol units every year and dump them down here, like the Rust is a bin. I give them a second life. The K9s still remember how to sniff out Rooted. Handy, if you were ever going somewhere with Rooted. Which you aren't. Because nobody leaves.",
		},
	},
}
