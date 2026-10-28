return {
	name = "Foreman Dunmore",
	entry = {
		{ when = { { flag = "parts_delivered" } }, node = "after" },
		{ when = { { quest = "spare_parts", status = "active" }, { item = "rail_part", count = 3 } }, node = "deliver" },
		{ when = { { quest = "spare_parts", status = "active" } }, node = "waiting" },
		{ node = "intro" },
	},
	nodes = {
		intro = {
			text = "Welcome to Rail's End! Last stop on a line that hasn't run in fourteen years. Out of the city sewers, I'd guess? Eleven of us came that way. Sign the board when you're settled.",
			textBy = {
				teo = "An engineer! I can smell grease on a person. You came out of the city? Then you know machines. Look at her. Look at that engine.",
			},
			choices = {
				{ text = "What is this place?", next = "place" },
				{ text = "Can I help?", next = "job" },
				{ text = "Just passing through." },
			},
		},
		place = {
			text = "A train yard that refused to die. We live in the carriages, grow food on the platforms, and trade with anyone who walks in. And one day, that locomotive is going to run again, and we'll go somewhere. Anywhere.",
		},
		job = {
			text = "She needs couplers. The Overgrown Suburbs north of here are full of old rail wagons rusting in the gardens. Pry me three coupler parts and I'll pay you, and Rail's End will remember it.",
			choices = {
				{ text = "I'll find them.", effects = { { startQuest = "spare_parts" } }, next = "careful" },
				{ text = "Maybe later." },
			},
		},
		careful = {
			text = "Mind the houses. Most are empty. Most.",
		},
		waiting = {
			text = "Three couplers, from the wagons in the suburbs. She's waiting. So am I.",
		},
		deliver = {
			text = "Look at those! Proper old-world steel. Hand them over and I'll get to work.",
			choices = {
				{
					text = "Here you go.",
					effects = {
						{ takeItem = "rail_part", count = 3 },
						{ setFlag = "parts_delivered" },
						{ credits = 80 },
						{ rep = "fringe", amount = 15 },
						{ trust = "dunmore", amount = 3 },
					},
					next = "thanks",
				},
			},
		},
		thanks = {
			text = "Eighty credits and the gratitude of the last railway in the world. She'll run. You'll see. And when she does, you've got a seat.",
		},
		after = {
			text = "Couplers are on! Next we need a boiler that doesn't leak, tracks that go somewhere, and a miracle. One thing at a time.",
		},
	},
}
