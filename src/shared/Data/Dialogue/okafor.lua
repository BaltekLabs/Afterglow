return {
	name = "Sgt. Okafor",
	entry = {
		{ when = { { flag = "gave_letters" }, { notFlag = "okafor_thanked" } }, node = "letters" },
		{ when = { { flag = "left_city" } }, node = "back" },
		{ node = "gate" },
	},
	nodes = {
		gate = {
			text = "North Gate. It's sealed, citizen. It has been sealed for fourteen years and it will be sealed when you're old. Council orders.",
			textBy = {
				mara = "Quell. Heard they took your badge. Doesn't matter either way: this gate is sealed. Council orders.",
				silas = "Mr. Crane. With respect, sir, I don't care whose son you are. This gate is sealed. Your father signed the order.",
			},
			choices = {
				{ text = "Why won't they let anyone out?", next = "why" },
				{ text = "What's beyond the Wall?", next = "outside" },
				{ text = "[Mara] Badge 4471. I'm working a case outside.", when = { { character = "mara" } }, next = "mara_badge" },
				{ text = "[40 credits] What would it take to open it?", when = { { credits = 40 } }, next = "bribe" },
				{ text = "What about the old sewers?", when = { { flag = "heard_sewer_rumor" } }, next = "sewers" },
				{ text = "Just looking." },
			},
		},
		why = {
			text = "The Sporewilds. The Rot. The Rooted. Pick whichever poster you like.\n\n...Between us? I've stopped asking. Asking gets people 'relocated.'",
		},
		outside = {
			text = "Trees that glow, air that bites, and the Rooted: what's left of the people the Rot took. They're rare now, mostly asleep where the roots caught them. Mostly.",
		},
		mara_badge = {
			text = "Doesn't matter if it's real. Nobody gets through. Not Enforcers, not detectives, not Councillors. Nobody.\n\nBut I always liked you, Quell. So: if you ever do find yourself outside, I never saw you leave.",
			effects = { { trust = "okafor", amount = 1 } },
		},
		bribe = {
			text = "Put that away before somebody sees you and we both get relocated. There's no amount. The gate doesn't open. It's welded, citizen. From the outside.",
			effects = { { trust = "okafor", amount = -1 } },
		},
		sewers = {
			text = "Sewers? Rats and worse. If I ever caught someone down there, I'd have to report it.\n\nSo I don't go down there. Ever. Especially not at night.",
			effects = { { trust = "okafor", amount = 1 } },
		},
		back = {
			text = "You've got mud on your boots. Glowing mud. ...I don't want to know. I didn't see it. Go home and wash that off before someone else does.",
		},
		letters = {
			text = "Tobi came by. Pike, I mean. He showed me the letters you found. He's been carrying that silence for fourteen years. My mother took him in the week the Wall went up.\n\nThank you. I owe you one.",
			effects = {
				{ setFlag = "okafor_thanked" },
				{ trust = "okafor", amount = 3 },
				{ rep = "council", amount = 3 },
			},
		},
	},
}
