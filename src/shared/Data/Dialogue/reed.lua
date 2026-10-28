return {
	name = "Old Reed",
	entry = {
		{ node = "hello" },
	},
	nodes = {
		hello = {
			text = "Mind the boards; the third one's rotten. Welcome to Mirefall. We fish, we mend nets, we don't ask where folks came from. Sit a spell?",
			choices = {
				{ text = "Are there Rooted out here?", next = "rooted" },
				{ text = "Why live on a marsh?", next = "marsh" },
				{ text = "I should move on." },
			},
		},
		rooted = {
			text = "Hardly any now. They stand where the roots took 'em and they sleep. But the marsh moves the roots, see, and sometimes it moves a sleeper with it. My granddaughter wrote it all down. Here, take a copy.",
			effects = { { lore = "mirefall_drowned", read = true } },
		},
		marsh = {
			text = "The wild roots don't like standing water. Too cold, too quiet. So the Glow mostly leaves us be. Mostly. And the fish taste like fish. You know what that's worth these days?",
		},
	},
}
