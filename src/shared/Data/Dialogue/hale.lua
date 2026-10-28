return {
	name = "Councillor Hale",
	entry = {
		{ when = { { flag = "ledger_broadcast" }, { notFlag = "hale_ledger" } }, node = "ledger" },
		{ when = { { flag = "ending_silence" }, { notFlag = "hale_silence" } }, node = "silence" },
		{ node = "hello" },
	},
	nodes = {
		hello = {
			text = "Welcome to the Council Spire. We so rarely see new faces up here. The Crown is a privilege, you know. Every light below us exists because of decisions made in this room.",
			textBy = {
				silas = "Silas. Your father asks after you constantly. He says you've been 'slumming in the Grid.' Is that what this is?",
			},
			choices = {
				{ text = "Why are the gates sealed?", next = "gates" },
				{ text = "What powers the Powerhouse?", next = "power" },
				{ text = "[Silas] I saw what my father signed. Directive 9.", when = { { character = "silas" } }, next = "silas" },
				{ text = "Have you heard the Static Tower broadcast?", next = "broadcast" },
				{ text = "Thank you, Councillor." },
			},
		},
		gates = {
			text = "Because outside is death. The Sporewilds, the Rot, the Rooted. Every citizen who has tried to leave has been lost. The Veil is the kindest thing we have ever built.",
			choices = {
				{ text = "[Glitch's theory] Or because people are the battery.", when = { { flag = "glitch_battery" } }, next = "battery" },
				{ text = "I see." },
			},
		},
		battery = {
			text = "...That is a very Rust way of putting a very complicated civic arrangement. I'd be careful repeating it. The Enforcers are less nuanced than I am.",
			effects = { { rep = "council", amount = -5 } },
		},
		power = {
			text = "Vesper, refined and contained. The same plant that ended the old world now lights the new one. Poetic, isn't it? The details are classified, but rest assured, it is perfectly safe. For those of us inside.",
		},
		broadcast = {
			text = "An old recording on an old frequency. Harmless. We leave it alone because removing it would be more disruptive than ignoring it. Much like the Rust.",
		},
		silas = {
			text = "Then you understand more than most. Your father didn't create the arrangement, Silas. He inherited it, as you will. The question isn't whether it's fair. It's whether you'd rather the lights went out.",
			effects = { { trust = "hale", amount = -1 } },
		},
		ledger = {
			text = "That broadcast. Payments, names, 'relocated.' Do you know how many Enforcers I had to put on the streets tonight? The Grid is asking questions. The Rust is asking louder ones.\n\nWhoever did that has made the city less safe. I hope they're proud.",
			effects = { { setFlag = "hale_ledger" } },
		},
		silence = {
			text = "Thirty percent. We lost thirty percent of our output in one night and nobody in this building can tell me why. The Mother Strain is... agitated. If you know anything about the north relay, you'd be wise to tell me.",
			effects = { { setFlag = "hale_silence" } },
		},
	},
}
