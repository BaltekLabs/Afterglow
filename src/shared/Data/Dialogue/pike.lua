return {
	name = "Pike",
	entry = {
		{ when = { { loreCategory = "adeyemi", count = 5 }, { notFlag = "pike_revealed" } }, node = "letters" },
		{ when = { { notFlag = "heard_sewer_rumor" } }, node = "sewers" },
		{ node = "idle" },
	},
	nodes = {
		idle = {
			text = "Spare a credit? No? Then spare a minute. Nobody listens to Pike, but Pike listens to everyone.",
			textBy = {
				juno = "Runner! You smell like the outside. Spare a credit for old Pike?",
			},
			choices = {
				{ text = "What have you heard?", next = "rumor" },
				{ text = "[5 credits] Here.", when = { { credits = 5 } }, effects = { { credits = -5 }, { trust = "pike", amount = 1 } }, next = "thanks" },
				{ text = "Not today." },
			},
		},
		rumor = {
			text = "The Static Tower ghost's been louder this month. Enforcers doubled at the Powerhouse. And the Greenkeepers keep turning planters that won't stay turned.\n\nPike says everything remembers. Most things just don't say so.",
		},
		thanks = {
			text = "Bless you. Here's one for free: Glitch, two blocks east of the Drip, sells passes to the Crown. Fake ones. Good fakes.",
		},
		sewers = {
			text = "Looking for a way out? Everyone is, eventually. See that manhole behind Pike? Old storm sewer. North pipe comes out in the woods past the Wall. South pipe comes out in the marsh.\n\nGrates used to be welded. Used to be.",
			effects = { { setFlag = "heard_sewer_rumor" }, { trust = "pike", amount = 1 } },
		},
		letters = {
			text = "What's that you're carrying? ...That's my mum's handwriting. Kemi Adeyemi. And that's my dad's.\n\nI was Tobi, once. Before the Okafors took me in. Before the Wall.",
			choices = {
				{
					text = "These belong to you. (Give him the letters.)",
					effects = {
						{ setFlag = "pike_revealed" },
						{ setFlag = "gave_letters" },
						{ trust = "pike", amount = 5 },
						{ rep = "rust", amount = 5 },
					},
					next = "letters_given",
				},
				{ text = "I'm keeping them.", effects = { { setFlag = "pike_revealed" }, { trust = "pike", amount = -2 } }, next = "letters_kept" },
			},
		},
		letters_given = {
			text = "She said the plants could sing. I thought it was a bedtime story.\n\n...Thank you. I'll read them slow.",
		},
		letters_kept = {
			text = "...Right. Of course. Finders keepers. That's the Rust.",
		},
	},
}
