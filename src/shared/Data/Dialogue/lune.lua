return {
	name = "Mother Lune",
	entry = {
		{ when = { { item = "relay_core" }, { notFlag = "core_resolved" } }, node = "core" },
		{ when = { { flag = "ending_answered" } }, node = "after_answered" },
		{ when = { { flag = "signal_resolved" } }, node = "after" },
		{ node = "intro" },
	},
	nodes = {
		intro = {
			text = "You've come from the city. You smell of wires and sewers. Sit, if you like. The Glow is listening anyway.",
			textBy = {
				juno = "Little Juno. You've grown sharp edges in that city. Sit. The Glow remembers you, even if you've tried to forget it.",
				renn = "A Halvorsen man. Don't look so surprised. The Memory recognizes its gardeners. Sit, if you like.",
				ivy = "A gardener of the tame green. Your plants in the city are deaf, child. Ours are not. Sit, and listen with me.",
			},
			choices = {
				{ text = "What is the Glow?", next = "glow" },
				{ text = "Listening?", next = "listen" },
				{ text = "[Teo] I've heard something like it. In the Powerhouse.", when = { { character = "teo" } }, next = "teo" },
				{ text = "Goodbye." },
			},
		},
		glow = {
			text = "Veyra calls it Vesper and burns it for light. We call it the Memory. It keeps what it touches: sugars, songs, people.\n\nThe Rot was never a sickness. It was the Memory learning to hold us too tightly.",
			choices = {
				{ text = "And the plants in the city?", next = "civic" },
				{ text = "Thank you." },
			},
		},
		civic = {
			text = "Pruned. Gelded. Made quiet. Your city's plants are safe because they cannot remember anything. But the city keeps the mother of them all locked in a tower, and she remembers everything.",
		},
		listen = {
			text = "The Halvorsen voice. You've heard it. Tell me, does it sound like something that wants to be found... or something that is looking?",
		},
		teo = {
			text = "Then you have stood closer to her than any of us. The mother of the Memory, caged in light. She is singing to the north, and the north is singing back. That is your broadcast, child.",
		},
		core = {
			text = "You carry its voice in your hands. Give it to us. We will bury it in the deep roots and let the Memory rest.",
			choices = {
				{
					text = "Take it.",
					effects = {
						{ takeItem = "relay_core" },
						{ setFlag = "core_to_fringe" },
						{ setFlag = "core_resolved" },
						{ rep = "fringe", amount = 20 },
						{ rep = "ascent", amount = -5 },
					},
					next = "core_taken",
				},
				{ text = "Not yet." },
			},
		},
		core_taken = {
			text = "The Hollow thanks you. When the roots go quiet tonight, you will know it is resting.",
		},
		after = {
			text = "The roots are restless. Something changed at the station. Whatever you chose, the Memory felt it.",
		},
		after_answered = {
			text = "You spoke to it. I can hear it in the roots: a new name, passed from tree to tree. Yours.\n\nBe gentle with what you've woken.",
		},
	},
}
