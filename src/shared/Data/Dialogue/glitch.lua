return {
	name = "Glitch",
	entry = {
		{ when = { { flag = "met_glitch" } }, node = "again" },
		{ node = "intro" },
	},
	nodes = {
		intro = {
			text = "Don't touch anything. Half of it's stolen and the other half's armed. Name's Glitch. I sell what the Council says doesn't exist: passes, keys, and the truth, if you can afford it.",
			textBy = {
				dex = "DEX. Dex Varga in my den. Did you finally come to pay back the forty you owe me, or are you here to show off that garbage deck again?",
				sable = "Sable Quinn. Vane's little shadow. If you're here on business, I'm unarmed. If you're here to shop, welcome.",
			},
			next = "again",
		},
		again = {
			text = "What'll it be?",
			choices = {
				{ text = "Show me the goods.", effects = { { openShop = "glitch" } } },
				{ text = "What's in the Powerhouse?", next = "powerhouse" },
				{ text = "Why does nobody leave the city?", next = "veil" },
				{ text = "How do I get to the Crown?", next = "crown" },
				{ text = "[Dex] Let's trade notes on the Static Tower feed.", when = { { character = "dex" } }, next = "dex" },
				{ text = "Later." },
			},
		},
		powerhouse = {
			text = "The Mother Strain. The real stuff, the wild stuff, the plant that made the Rooted. Not the tame green junk on your balcony. They keep her in a cage of light and milk her for power. Turrets on every face. Hatch on the south side if you're stupid. I sell keycards for stupid people.",
		},
		veil = {
			text = "Official answer: the Sporewilds will kill you. Real answer? I cracked a Council relay once. The Powerhouse output drops every time somebody dies or slips out. They don't keep us in to keep us safe. They keep us in because we're the battery.",
			effects = { { setFlag = "glitch_battery" } },
		},
		crown = {
			text = "Crown Lift, off the east Sky Road. Needs clearance. You can be born rich, or you can buy one of my passes. Two hundred. Looks better than the real thing.",
		},
		dex = {
			text = "Same voice, fresh static, right? I traced the carrier too. It doesn't just come in, Dex. The Powerhouse answers it. Every eleven minutes, a handshake through the Veil. Something out there and something in here are talking.",
			effects = { { trust = "glitch", amount = 1 } },
		},
	},
}
