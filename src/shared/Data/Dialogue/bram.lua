local GIVE_SEEDS = {
	{ takeItem = "seed_packet" },
	{ setFlag = "seeds_resolved" },
	{ setFlag = "seeds_to_fringe" },
}

local function give(extra)
	local list = table.clone(GIVE_SEEDS)
	for _, e in ipairs(extra) do
		table.insert(list, e)
	end
	return list
end

local GENEROUS = give({
	{ rep = "fringe", amount = 20 },
	{ trust = "bram", amount = 4 },
	-- Order matters: check for an existing mask before handing one over.
	{ credits = 40, when = { { item = "filter_mask" } } },
	{ giveItem = "filter_mask", when = { { noItem = "filter_mask" } } },
})

return {
	name = "Bram",
	entry = {
		{ when = { { flag = "seeds_to_ascent" } }, node = "betrayed" },
		{ when = { { flag = "seeds_to_fringe" } }, node = "after" },
		{ when = { { quest = "seeds", status = "active" }, { item = "seed_packet" } }, node = "deliver" },
		{ when = { { quest = "seeds", status = "active" } }, node = "waiting" },
		{ when = { { quest = "seeds", status = "none" }, { item = "seed_packet" } }, node = "surprise" },
		{ node = "intro" },
	},
	nodes = {
		intro = {
			text = "Welcome to Hollow Garden. Out of the city sewers, are you? Most of us came the same way. Mind the plots; that's dinner, someday. Everything we plant comes up glowing. Tastes like copper and dreams.\n\nI'd give anything for one seed that grows a plain, honest plant.",
			textBy = {
				juno = "Juno Ash! The city didn't swallow you after all. Your old bunk's still here. Garden's the same as ever: everything comes up glowing.\n\nI'd give anything for one seed that grows a plain, honest plant.",
				ivy = "A Greenkeeper? Out here? Your city plants are engineered never to spread. Ours spread like gossip. Everything we plant comes up glowing.\n\nI'd give anything for one seed that grows a plain, honest plant.",
			},
			choices = {
				{ text = "Where would you find one?", next = "where" },
				{ text = "[Ivy] Civic strains won't grow out here?", when = { { character = "ivy" } }, next = "ivy" },
				{ text = "Glowing food sounds fine to me.", next = "glowfood" },
				{ text = "Good luck with that." },
			},
		},
		ivy = {
			text = "Tried it. Smuggled a cutting out years ago. The wild lattice found it in a week and... rewrote it. Woke up to a planter full of violet.",
			next = "where",
		},
		glowfood = {
			text = "Spend a winter eating it. You start to hear the soil hum.",
			choices = {
				{ text = "Where would you find plain seeds?", next = "where" },
				{ text = "Noted." },
			},
		},
		where = {
			text = "Before the Bloom, Halvorsen kept a greenhouse northeast of here, out past the ridge. Rumor says there's a seed vault inside. Nothing pre-Bloom should still be alive out here... but if anything is, it's there.",
			choices = {
				{ text = "I'll take a look.", effects = { { startQuest = "seeds" } }, next = "luck" },
				{ text = "Not now." },
			},
		},
		luck = {
			text = "There's a Rooted sleeping by the greenhouse door. One of the few left around here. Walk soft. They sleep light.",
		},
		waiting = {
			text = "The greenhouse is northeast of here. Walk soft near the Rooted.",
		},
		surprise = {
			text = "Those seeds in your hand... are those plain? Not glowing? Where did you... never mind where. Would you give them to the garden?",
			effects = { { startQuest = "seeds" } },
			next = "deliver",
		},
		deliver = {
			text = "Are those... real seeds? Plain ones?",
			choices = {
				{ text = "They're yours.", effects = GENEROUS, next = "thanks" },
				{ text = "What are they worth to you?", next = "haggle" },
				{ text = "Ascent would pay more.", next = "threat" },
			},
		},
		haggle = {
			text = "Worth? Everything, and I've got almost nothing. Thirty credits and our thanks.",
			choices = {
				{
					text = "Fine. Thirty.",
					effects = give({ { credits = 30 }, { rep = "fringe", amount = 10 }, { trust = "bram", amount = 1 } }),
					next = "thanks_paid",
				},
				{ text = "Keep the credits. They're yours.", effects = GENEROUS, next = "thanks" },
			},
		},
		threat = {
			text = "...Then go and sell our future to Ascent. I'll remember your face, friend.",
			effects = { { trust = "bram", amount = -1 } },
		},
		thanks = {
			text = "Then Hollow Garden has a future that isn't glowing. Take what I can spare. And you're welcome at our fire, always.",
		},
		thanks_paid = {
			text = "A fair trade. We'll plant them at dawn.",
		},
		betrayed = {
			text = "Ascent's gene lab sends its thanks, I hear. Don't expect ours.",
		},
		after = {
			text = "Look. First shoot. Green. Not glowing, just green. You did that.",
		},
	},
}
