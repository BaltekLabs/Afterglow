local AGREE = {
	{ startQuest = "signal" },
	{ giveItem = "receiver" },
	{ setFlag = "tamsin_agreed" },
}

local function agree(extra)
	local list = table.clone(AGREE)
	for _, e in ipairs(extra or {}) do
		table.insert(list, e)
	end
	return list
end

-- Telling Tamsin also fills in any skipped beats, so the story can be played in any order.
local TOLD = {
	{ startQuest = "signal" },
	{ setFlag = "heard_signal" },
	{ setFlag = "tamsin_agreed" },
	{ setFlag = "told_tamsin" },
	{ credits = 50, when = { { flag = "tamsin_owes_50" } } },
	{ clearFlag = "tamsin_owes_50" },
}

local function told(extra)
	local list = table.clone(TOLD)
	for _, e in ipairs(extra) do
		table.insert(list, e)
	end
	return list
end

local RETURN_UNTOLD = { { flag = "signal_resolved" }, { notFlag = "told_tamsin" } }
local function returning(flag)
	local list = table.clone(RETURN_UNTOLD)
	table.insert(list, { flag = flag })
	return list
end

return {
	name = "Old Tamsin",
	entry = {
		{ when = { { flag = "ledger_broadcast" }, { notFlag = "tamsin_ledger_thanks" } }, node = "ledger_after" },
		{ when = returning("ending_answered"), node = "return_answered" },
		{ when = returning("ending_silence"), node = "return_silence" },
		{ when = returning("ending_core"), node = "return_core" },
		{ when = returning("ending_listen"), node = "return_listen" },
		{ when = { { notFlag = "heard_signal" } }, node = "early" },
		{ when = { { notFlag = "tamsin_agreed" } }, node = "ask" },
		{ when = { { quest = "signal", status = "complete" } }, node = "after" },
		{ node = "waiting" },
	},
	nodes = {
		early = {
			text = "Static & Sons. We fix anything that hums. You're staring at my tower like you've never heard it talk. Stand under the horns a while. You'll hear our ghost.",
			textBy = {
				renn = "...Do I know you? No. Never mind. Stand under the horns a while. You'll hear our ghost.",
			},
			choices = {
				{ text = "Tell me about the ghost.", effects = { { setFlag = "heard_signal" }, { lore = "signal_transcript" }, { startQuest = "signal" } }, next = "ask" },
				{ text = "Just looking around." },
			},
		},

		ask = {
			text = "The Halvorsen broadcast. It comes in from beyond the Veil, and my tower's the only thing old enough to still catch it. Most people stopped hearing it years ago, the way you stop hearing rain.",
			choices = {
				{ text = "Who is Wren Hollis?", next = "wren" },
				{ text = "Why is it still broadcasting?", next = "why" },
				{
					text = "[Renn] I knew Wren Hollis. At Halvorsen.",
					when = { { character = "renn" } },
					effects = { { trust = "tamsin", amount = 1 } },
					next = "renn_knew",
				},
				{ text = "[Ivy] The plants have been leaning toward it.", when = { { character = "ivy" } }, next = "ivy" },
				{ text = "Not my business." },
			},
		},
		why = {
			text = "Ask the Council. They jam every frequency in Veyra, and they've never once touched this one. Strange, isn't it?",
			next = "wren",
		},
		ivy = {
			text = "...Have they now. Wren used to say plants listen better than people. I thought she was being poetic.",
			next = "wren",
		},
		wren = {
			text = "Wren Hollis was my wife. Botanist. She went out to Halvorsen Station the week the Bloom started. Then they sealed the gates, and she never came back.",
			next = "voice",
		},
		renn_knew = {
			text = "...You were at Halvorsen? Then you already know more than I do. Did you... no. Don't tell me. Not yet. Go and see it first.",
			next = "voice",
		},
		voice = {
			text = "Here's the part I don't tell people. That voice is Wren's. She's calling her own name.",
			choices = {
				{ text = "That's impossible.", next = "impossible" },
				{ text = "Have you tried to go out there?", next = "gone" },
			},
		},
		impossible = {
			text = "I've told myself that for fourteen years. Fourteen years of the same eleven minutes.",
			next = "gone",
		},
		gone = {
			text = "Out? Nobody goes out. The Council sealed the gates and put up the Veil, and the Enforcers will drag you back by your collar if you so much as ask. But you look like someone who goes places they shouldn't.",
			next = "offer",
		},
		offer = {
			text = "Take this receiver. It pulls the signal out of the noise and points toward it. If you ever find a way past the Wall, find whatever is broadcasting. Tell me what it is, even if it's nothing.",
			choices = {
				{ text = "I'll find it.", effects = agree({ { trust = "tamsin", amount = 2 } }), next = "thanks" },
				{
					text = "[Mara] I'll take the case. No charge.",
					when = { { character = "mara" } },
					effects = agree({ { trust = "tamsin", amount = 3 } }),
					next = "thanks",
				},
				{ text = "What's in it for me?", next = "pay" },
				{ text = "I'll think about it." },
			},
		},
		pay = {
			text = "Fair question. I've got fifty credits put by. They're yours when you come back with an answer.",
			choices = {
				{ text = "Deal.", effects = agree({ { setFlag = "tamsin_owes_50" } }), next = "thanks" },
				{ text = "Keep your money. I'll go.", effects = agree({ { trust = "tamsin", amount = 3 } }), next = "thanks" },
			},
		},
		thanks = {
			text = "I can't tell you how to get out. Nobody can, officially. But people in the Rust talk about the old storm sewers running under the Wall. Ask around down there, in the back alleys. Quietly.",
		},

		waiting = {
			text = "Any news? ...No. I can see there isn't. The signal's coming from the north, past the Wall. Take your time. It's waited fourteen years.",
			choices = {
				{ text = "Tell me about Wren again.", next = "wren_again" },
				{
					text = "I have something you should broadcast. (Give her Pell's ledger.)",
					when = { { item = "pell_ledger" }, { notFlag = "ledger_resolved" } },
					next = "ledger",
				},
				{ text = "See you, Tamsin." },
			},
		},
		wren_again = {
			text = "She kept a sunflower in a pot on our windowsill. Ordinary. Said everyone needs one thing that's exactly what it looks like.",
		},

		return_silence = {
			text = "The horns went quiet an hour ago. Fourteen years, and then nothing. Half the Grid's lights flickered at the same moment. You did that, didn't you? Tell me.",
			choices = {
				{ text = "It wasn't Wren. The plant learned her voice.", next = "r_truth" },
				{ text = "She's at peace now. The broadcast was her goodbye.", next = "r_lie" },
			},
		},
		return_listen = {
			text = "It's still playing. Same words. You saw it, didn't you? I can see it on your face.",
			choices = {
				{ text = "It wasn't Wren. The plant learned her voice.", next = "r_truth" },
				{ text = "I left it running. It's all that's left of her.", next = "r_left" },
				{ text = "She's at peace now. Let it play.", next = "r_lie" },
			},
		},
		return_core = {
			text = "The signal's gone patchy. Static, mostly. Then a word or two, like someone talking in their sleep.",
			choices = {
				{ text = "I pulled the relay core. It wasn't Wren speaking.", next = "r_truth" },
				{ text = "She's at peace now.", next = "r_lie" },
			},
		},
		return_answered = {
			text = "It said a new name last night. Yours. Then it said 'come home.' What did you do out there?",
			choices = {
				{ text = "I answered it.", next = "r_answered" },
			},
		},
		r_truth = {
			text = "She wrote me a letter, the last week. I never opened it. I think I knew what it would say: if you hear my voice after tonight, it isn't me.\n\nThank you for telling me the truth, {first}.",
			effects = told({ { setFlag = "told_truth" }, { trust = "tamsin", amount = 3 } }),
		},
		r_lie = {
			text = "...Thank you. I don't believe you. But thank you.",
			effects = told({ { setFlag = "told_lie" }, { trust = "tamsin", amount = 1 } }),
		},
		r_left = {
			text = "Then I'll keep listening. Maybe that makes me a fool. But it's eleven minutes of her every eleven minutes, and I'm not ready to give that up.",
			effects = told({ { setFlag = "told_truth" }, { trust = "tamsin", amount = 2 } }),
		},
		r_answered = {
			text = "Then it knows you now. Whatever it is, it's listening for you the way it listened for her.\n\nBe careful whose voice you trust from here on, {first}. Even mine.",
			effects = told({ { setFlag = "told_truth" }, { trust = "tamsin", amount = 2 } }),
		},

		after = {
			text = "The tower's quieter these days. Or the noise is different. Either way, thank you, {first}. Come by whenever you like.",
			choices = {
				{
					text = "I have something you should broadcast. (Give her Pell's ledger.)",
					when = { { item = "pell_ledger" }, { notFlag = "ledger_resolved" } },
					next = "ledger",
				},
				{ text = "Take care, Tamsin." },
			},
		},
		ledger = {
			text = "Council payments. 'Population stabilization.' Names crossed out and marked 'relocated'...\n\nThe tower reaches every radio in Veyra. If I read this out, there's no taking it back. For either of us.",
			choices = {
				{
					text = "Read it out.",
					effects = {
						{ takeItem = "pell_ledger" },
						{ setFlag = "ledger_broadcast" },
						{ setFlag = "ledger_resolved" },
						{ rep = "grid", amount = 10 },
						{ rep = "rust", amount = 5 },
						{ rep = "council", amount = -20 },
					},
					next = "ledger_done",
				},
				{ text = "Not yet." },
			},
		},
		ledger_done = {
			text = "Then let's give them something new to listen to.",
		},
		ledger_after = {
			text = "Enforcers came by twice since the broadcast. Asked about the tower's licence. I told them it predates the Council. Which it does.\n\nWorth it. Every word.",
			effects = { { setFlag = "tamsin_ledger_thanks" }, { trust = "tamsin", amount = 2 } },
		},
	},
}
