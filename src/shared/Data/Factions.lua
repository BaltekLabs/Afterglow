-- Communities that track your reputation separately. There is no global morality meter.
local Factions = {
	order = { "grid", "rust", "council", "ascent", "fringe" },
	list = {
		grid = {
			name = "The Grid",
			description = "Veyra's middle tier, where ordinary people live, work and try not to look down.",
			color = "#ffb048",
		},
		rust = {
			name = "The Rust",
			description = "The city's underside: the poor, the hidden, and the hackers, fixers and killers who serve them.",
			color = "#ff5a5a",
		},
		council = {
			name = "The Council",
			description = "The government in the Crown. It runs the Enforcers, the Powerhouse and the Veil.",
			color = "#ffe08a",
		},
		ascent = {
			name = "Ascent Biotech",
			description = "The corporation that grows Veyra's plants and the Council's official 'civic partner'.",
			color = "#78c8ff",
		},
		fringe = {
			name = "Fringe Settlements",
			description = "The villages scattered across the Outlands that live without the Council, and without its permission.",
			color = "#78e68c",
		},
	},
}

function Factions.standing(value)
	if value <= -20 then
		return "Hostile"
	elseif value < 0 then
		return "Wary"
	elseif value < 15 then
		return "Neutral"
	elseif value < 40 then
		return "Trusted"
	end
	return "Revered"
end

return Factions
