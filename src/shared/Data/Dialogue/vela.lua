return {
	name = "Vela",
	entry = {
		{ when = { { flag = "caught_stealing_vela" }, { notFlag = "vela_forgave" } }, node = "angry" },
		{ when = { { time = "day" } }, node = "closed" },
		{ node = "open" },
	},
	nodes = {
		closed = {
			text = "Stall's closed, love. Come back after dark. That's when the Rust wakes up.",
		},
		open = {
			text = "Vela's! Hot glowbowls, filter masks, mend patches. Prices fair, questions extra.",
			textBy = {
				juno = "Juno! Still alive? Good. Runners are my best customers. What do you need?",
				sable = "Sable. You still owe me for the last mask. ...Kidding. Mostly. What do you need?",
			},
			choices = {
				{ text = "Show me what you've got.", effects = { { openShop = "vela" } } },
				{ text = "What's the word in the Rust?", next = "rumor" },
				{ text = "Just looking." },
			},
		},
		rumor = {
			text = "Word is somebody's been cutting the welds on the old storm grates. Runners slipping out through the sewers, coming back with glowing mud on their boots. Masks are selling like noodles.\n\nYou didn't hear that from me.",
			effects = { { setFlag = "heard_sewer_rumor" } },
			choices = {
				{ text = "Show me what you've got.", effects = { { openShop = "vela" } } },
				{ text = "Thanks." },
			},
		},
		angry = {
			text = "You. You lifted from my crate. Pay me back forty and maybe I forget your face.",
			choices = {
				{
					text = "[40 credits] Here. I'm sorry.",
					when = { { credits = 40 } },
					effects = { { credits = -40 }, { setFlag = "vela_forgave" }, { trust = "vela", amount = 2 } },
					next = "forgiven",
				},
				{ text = "Never touched it.", effects = { { trust = "vela", amount = -1 } } },
			},
		},
		forgiven = {
			text = "Fine. We're square. Don't make me regret it.",
		},
	},
}
