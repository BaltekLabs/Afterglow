local function resolve(extra)
	local list = { { takeItem = "pell_ledger" }, { setFlag = "ledger_resolved" } }
	for _, e in ipairs(extra) do
		table.insert(list, e)
	end
	return list
end

return {
	name = "Vane",
	entry = {
		{ when = { { flag = "ledger_resolved" } }, node = "done" },
		{ when = { { quest = "loose_ends", status = "active" }, { item = "pell_ledger" } }, node = "deliver" },
		{ when = { { quest = "loose_ends", status = "active" } }, node = "waiting" },
		{ node = "intro" },
	},
	nodes = {
		intro = {
			text = "...",
			textBy = {
				sable = "Sable. You look well. Freelance suits you. I have a job, if you've kept your hands clean enough to want it.",
			},
			choices = {
				{ text = "You're Vane.", next = "vane" },
				{ text = "[Sable] What job?", when = { { character = "sable" } }, next = "job" },
				{ text = "Sorry. Wrong booth." },
			},
		},
		vane = {
			text = "And you're someone who sits down without being asked. Bold. I'm in the business of removing problems, quietly. Sometimes the problem is a person. Tonight the problem is a book.",
			next = "job",
		},
		job = {
			text = "Orrin Pell. Aide to the Council. He keeps a paper ledger in his Grid apartment, because paper can't be hacked. Bring it to me. Two hundred credits, and no one gets hurt. Unless you make that necessary.",
			choices = {
				{ text = "I'll get it.", effects = { { startQuest = "loose_ends" } }, next = "accept" },
				{ text = "What's in it?", next = "contents" },
				{ text = "Not my kind of work." },
			},
		},
		contents = {
			text = "Proof. Of what, I'm not paid to wonder. But my client is very interested in what the Council has been buying from Ascent, and who has been 'relocated' to pay for it.",
			choices = {
				{ text = "I'll get it.", effects = { { startQuest = "loose_ends" } }, next = "accept" },
				{ text = "Pass." },
			},
		},
		accept = {
			text = "Pell drinks at The Wick most nights. His apartment's locked, old brass, very traditional. He's careless with keys. Come back with the ledger, or don't come back.",
		},
		waiting = {
			text = "The ledger. Pell's apartment. The Grid. I don't repeat myself a third time.",
		},
		deliver = {
			text = "You have it. Good. Hand it over.",
			choices = {
				{
					text = "Here.",
					effects = resolve({
						{ credits = 200 },
						{ setFlag = "ledger_to_vane" },
						{ rep = "rust", amount = 10 },
						{ rep = "council", amount = -5 },
					}),
					next = "paid",
				},
				{ text = "I'm keeping it for now.", next = "keep" },
			},
		},
		paid = {
			text = "Two hundred, as agreed. Pell will find his career has ended. Only his career. I'm not a monster; I'm a professional.",
		},
		keep = {
			text = "Then you're holding something that gets people relocated. Choose quickly who you give it to. Paper burns.",
		},
		done = {
			text = "Our business is concluded. Sit if you want. Don't talk.",
		},
	},
}
