return {
	name = "Orrin Pell",
	entry = {
		{ when = { { flag = "ledger_broadcast" } }, node = "ruined" },
		{ when = { { flag = "ledger_to_vane" } }, node = "fired" },
		{ when = { { flag = "ledger_to_pell" } }, node = "grateful" },
		{ when = { { item = "pell_ledger" } }, node = "caught" },
		{ when = { { time = "night" } }, node = "drunk" },
		{ node = "busy" },
	},
	nodes = {
		busy = {
			text = "Orrin Pell, Office of the Council. If you have a complaint, there is a form. If you have a question, there is also a form. Good day.",
			choices = {
				{ text = "What does the Council actually do?", next = "council" },
				{ text = "Good day." },
			},
		},
		council = {
			text = "Keep the lights on, keep the Veil up, keep everyone inside safe. Three jobs. We do all three superbly. Fourteen years of light. Is that all?",
		},
		drunk = {
			text = "Another one? No. No, I've had... You know what the worst part is? I do the books. I do ALL the books. I know where every credit goes. Every name. Every... never mind. Never mind. Go home.",
			choices = {
				{ text = "Every name?", next = "names" },
				{ text = "Go home, Pell." },
			},
		},
		names = {
			text = "Keep it on paper, they said. Paper can't be hacked. Keep it in the apartment. Keep the key under... no. No, I'm not telling you where I keep the key. That would be very stupid.",
			effects = { { setFlag = "pell_key_hint" } },
		},
		caught = {
			text = "That's... that's my ledger. Where did you... Please. Please. If that gets out, I'm finished. If Vane gets it, I'm worse than finished. Give it back and I'll make it worth your while. I can get you into the Crown. Real clearance. Real money.",
			choices = {
				{
					text = "Take it back. (Return the ledger.)",
					effects = {
						{ takeItem = "pell_ledger" },
						{ setFlag = "ledger_to_pell" },
						{ setFlag = "ledger_resolved" },
						{ credits = 100 },
						{ giveItem = "crown_pass", when = { { noItem = "crown_pass" } } },
						{ rep = "council", amount = 10 },
						{ trust = "pell", amount = 4 },
					},
					next = "returned",
				},
				{ text = "Not a chance." },
			},
		},
		returned = {
			text = "Thank you. Thank you. Here: a hundred credits, and a Crown guest pass. A real one. Use it before I sober up and regret this.",
		},
		grateful = {
			text = "You. My guardian angel. Please never speak to me in public.",
		},
		fired = {
			text = "They let me go this morning. 'Restructuring.' Nobody's said 'relocated' yet. I keep checking behind me.",
		},
		ruined = {
			text = "You put it on the radio. Every radio in the city. My mother heard it. My MOTHER. ...And the strange thing is, I feel lighter. Isn't that strange?",
		},
	},
}
