return {
	name = "Static Tower",
	entry = {
		{ node = "broadcast" },
	},
	nodes = {
		broadcast = {
			speaker = "Halvorsen Relay",
			text = "The horns on the Static Tower crackle, and a woman's voice rolls down over the street, calm and close:\n\n\"...Halvorsen Relay to Veyra. Calling Wren Hollis. Wren, if you can hear this, the garden is still growing. It's warm here. Come home. Come home.\"",
			effects = { { setFlag = "heard_signal" }, { lore = "signal_transcript" }, { startQuest = "signal" } },
			choices = {
				{ text = "[Renn] You know that voice.", when = { { character = "renn" } }, next = "renn" },
				{ text = "[Mara] Note the details.", when = { { character = "mara" } }, next = "mara" },
				{ text = "[Dex] Trace the feed.", when = { { character = "dex" } }, next = "dex" },
				{ text = "[Teo] That hum underneath it...", when = { { character = "teo" } }, next = "teo" },
				{ text = "Keep listening.", next = "loop" },
				{ text = "Walk away." },
			},
		},
		renn = {
			speaker = "Ilya Renn",
			text = "Dr. Wren Hollis. Your old supervisor. She went up to the relay room the night everything ended, and she never came down.\n\nShe's calling her own name.",
			next = "loop",
		},
		mara = {
			speaker = "Mara Quell",
			text = "Same words, same breath before 'come home.' A loop. But the static changes every time. Something out past the Wall is still transmitting this live.",
			next = "loop",
		},
		dex = {
			speaker = "Dex Varga",
			text = "You jack into the tower's junction box. The feed doesn't come from inside the city at all. It comes in from the north, through the Veil, on an old Halvorsen frequency. And the Powerhouse is listening to it too.",
			next = "loop",
		},
		teo = {
			speaker = "Teo Marsh",
			text = "Under the voice there's a low, slow hum. You know that hum. You spent eight years next to it in the Powerhouse core.",
			next = "loop",
		},
		loop = {
			speaker = "Halvorsen Relay",
			text = "The message ends. A pause. It begins again, word for word.\n\nA hand-painted sign on the tower's base reads: STATIC & SONS. ASK FOR TAMSIN.",
		},
	},
}
