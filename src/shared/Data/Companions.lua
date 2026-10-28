--[[
	Animal companions you can buy: real animals from Marigold's pet shop in the Grid, robots
	from Kettle's workshop in the Rust. One follows you at a time (journal → Companions).

	perk:
	  alert     warns you when a Rooted is nearby
	  light     carries a light, useful in the Rust and the sewers
	  scavenge  now and then brings you a few credits it found
	look: body shape and colors for the procedural model.
]]
return {
	order = { "mutt", "alley_cat", "crow", "glow_fox", "k9", "drone", "clockcat", "scrap_spider" },

	list = {
		mutt = {
			name = "Stray Mutt",
			kind = "Animal",
			perk = "alert",
			description = "Scruffy, loyal and suspicious of anything that smells like roots. Growls when a Rooted is near.",
			look = { shape = "dog", size = 1, color = "#8a6a4a", accent = "#3a2a20" },
		},
		alley_cat = {
			name = "Alley Cat",
			kind = "Animal",
			perk = "scavenge",
			description = "Comes and goes as she pleases. Occasionally comes back with something shiny.",
			look = { shape = "cat", size = 1, color = "#2e2a30", accent = "#d8c070" },
		},
		crow = {
			name = "Rust Crow",
			kind = "Animal",
			perk = "alert",
			description = "Clever, loud, and always watching from above. Caws at things that shouldn't move.",
			look = { shape = "bird", size = 1, color = "#1c1a22", accent = "#5a5a70" },
		},
		glow_fox = {
			name = "Glow Fox",
			kind = "Animal",
			perk = "light",
			description = "A civic-strain fox bred in Ascent's labs. Its fur glows softly, which is either adorable or worrying.",
			look = { shape = "dog", size = 0.85, color = "#e07a3a", accent = "#9affd0", glow = true },
		},
		k9 = {
			name = "K9 Unit",
			kind = "Robot",
			perk = "alert",
			description = "Decommissioned Enforcer patrol dog, reflashed by Kettle. Its sensors still pick up Rooted heat.",
			look = { shape = "dog", size = 1.2, color = "#5a6070", accent = "#ff4040", robot = true },
		},
		drone = {
			name = "Hover Drone",
			kind = "Robot",
			perk = "light",
			description = "A palm-sized courier drone with a floodlight. Hums a little tune when idle.",
			look = { shape = "drone", size = 1, color = "#d0d4dc", accent = "#3cf0ff", robot = true },
		},
		clockcat = {
			name = "Clockwork Cat",
			kind = "Robot",
			perk = "scavenge",
			description = "Brass gears, glass eyes, and a scavenging subroutine Kettle swears she didn't write.",
			look = { shape = "cat", size = 1, color = "#b08840", accent = "#ffb048", robot = true },
		},
		scrap_spider = {
			name = "Scrap Spider",
			kind = "Robot",
			perk = "alert",
			description = "Eight legs of salvaged servo. Deeply unsettling. Excellent at noticing movement.",
			look = { shape = "spider", size = 1, color = "#4a4440", accent = "#9aff6a", robot = true },
		},
	},
}
