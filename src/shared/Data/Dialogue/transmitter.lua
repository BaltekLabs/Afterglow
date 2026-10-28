local RESOLVE = { setFlag = "signal_resolved" }

return {
	name = "Halvorsen Relay",
	entry = {
		{ when = { { flag = "signal_resolved" } }, node = "done" },
		{ node = "approach" },
	},
	nodes = {
		approach = {
			speaker = "Halvorsen Relay",
			text = "The transmitter is barely a machine anymore. Roots braid through the housing and pulse in time with the voice: \"...calling Wren Hollis. Come home.\"\n\nThe console shows the recording's timestamp. It reads TODAY.",
			-- Players can find the station before ever hearing the city broadcast.
			effects = { { startQuest = "signal" }, { setFlag = "heard_signal" }, { lore = "signal_transcript" } },
			choices = {
				{ text = "Tear out the roots. End the broadcast.", next = "silence_confirm" },
				{ text = "Leave it. It's all that's left of her.", next = "leave" },
				{ text = "Pull the relay core and take the signal with you.", next = "take" },
				{
					text = "[Renn] Lean into the microphone. Answer it.",
					when = { { character = "renn" } },
					next = "answer",
				},
				{ text = "Step back." },
			},
		},
		silence_confirm = {
			speaker = "Halvorsen Relay",
			text = "You grip the roots. They're warm, like a wrist. Somewhere in the building the lights dim, and far to the south, Veyra's grid shivers.",
			choices = {
				{ text = "Do it.", next = "silence" },
				{ text = "Wait.", next = "approach" },
			},
		},
		silence = {
			speaker = "Halvorsen Relay",
			text = "The roots tear like wet paper. The voice stops in the middle of a word.\n\nFor the first time in fourteen years, Halvorsen is quiet.",
			effects = {
				RESOLVE,
				{ setFlag = "ending_silence" },
				{ rep = "fringe", amount = -5 },
			},
		},
		leave = {
			speaker = "Halvorsen Relay",
			text = "You leave the voice to its loop. \"...the garden is still growing...\"\n\nFor a moment it almost sounds grateful.",
			effects = {
				RESOLVE,
				{ setFlag = "ending_listen" },
				{ rep = "fringe", amount = 5 },
			},
		},
		take = {
			speaker = "Halvorsen Relay",
			text = "The core slides free, heavy and humming. The broadcast breaks into static, but not silence. Something in the roots is still trying to speak.",
			effects = {
				RESOLVE,
				{ setFlag = "ending_core" },
				{ giveItem = "relay_core" },
				{ notify = "Kessler would pay for this. Mother Lune would bury it.", kind = "info" },
			},
		},
		answer = {
			speaker = "Ilya Renn",
			text = "You press the talk key. \"This is Ilya Renn. Wren isn't coming home.\"\n\nThe roots stop pulsing. The speaker crackles. In Wren's voice, slowly, it says:",
			next = "answer2",
		},
		answer2 = {
			speaker = "Halvorsen Relay",
			text = "\"Ilya. You held the door.\"\n\n\"We keep everything. Come home, Ilya.\"\n\nThe broadcast starts again, and now it is calling your name.",
			effects = {
				RESOLVE,
				{ setFlag = "ending_answered" },
				{ rep = "fringe", amount = 5 },
			},
		},
		done = {
			speaker = "Halvorsen Relay",
			text = "The relay hums softly. You've done what you came here to do.",
		},
	},
}
