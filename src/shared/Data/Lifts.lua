--[[
	Lifts move you between the city's tiers. Each stop is a waypoint the world builder creates.
	A stop with `requires` shows as restricted unless the conditions pass.
]]
local function publicLift(name, prefix)
	return {
		name = name,
		stops = {
			{ label = "The Rust", waypoint = prefix .. "_Rust" },
			{ label = "The Grid", waypoint = prefix .. "_Grid" },
			{ label = "Sky Road", waypoint = prefix .. "_Sky" },
		},
	}
end

return {
	NE = publicLift("Public Lift NE", "Lift_NE"),
	NW = publicLift("Public Lift NW", "Lift_NW"),
	SE = publicLift("Public Lift SE", "Lift_SE"),
	SW = publicLift("Public Lift SW", "Lift_SW"),

	crown = {
		name = "Crown Lift",
		stops = {
			{ label = "Sky Road", waypoint = "Lift_Crown_Sky" },
			{
				label = "The Crown",
				waypoint = "Lift_Crown_Top",
				requires = { { any = { { character = "silas" }, { item = "crown_pass" }, { flag = "crown_hacked" } } } },
				denied = "CLEARANCE REQUIRED. The Crown is reserved for residents and their invited guests.",
			},
		},
	},

	tower = {
		name = "Static Tower Lift",
		stops = {
			{ label = "Street level", waypoint = "Lift_Tower_Base" },
			{ label = "Observation deck", waypoint = "Lift_Tower_Top" },
		},
	},
}
