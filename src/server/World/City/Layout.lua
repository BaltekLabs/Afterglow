--[[
	Veyra's layout. The city is a 10 x 10 grid of 128-stud tiles (x, z from -640 to 640),
	stacked in three tiers:

	  The Rust   y = 0     street level, under the Grid deck. Poor, dark, dangerous.
	  The Grid   y = 80    a deck of platforms where ordinary people live. Sky roads at y = 170.
	  The Crown  y = 330   a ring of mansions and the Council Spire around the Powerhouse top.

	The Powerhouse fills the four center tiles and rises through every tier.
	Tile (i, j) has its center at (-576 + 128 i, -576 + 128 j). Streets run along tile edges.
]]
local Layout = {}

Layout.TILE = 128
Layout.N = 10
Layout.HALF = 640
Layout.STREET = 20
Layout.PAD = Layout.TILE - Layout.STREET -- 108: buildable block inside each tile
Layout.LOT_MIN = 6 -- buildings keep at least this far from the tile center (alleys)
Layout.LOT_MAX = 50 -- ...and no further out than this (keeps sky roads clear)

Layout.DECK_Y = 80
Layout.DECK_T = 4
Layout.SKY_Y = 170
Layout.CROWN_Y = 330
Layout.CROWN_INNER = 110
Layout.CROWN_OUTER = 250
Layout.WALL = 660
Layout.WALL_H = 180

Layout.PH_RADIUS = 90
Layout.PH_TOP = 360

function Layout.tile(i, j, y)
	return Vector3.new(-Layout.HALF + Layout.TILE * (i + 0.5), y or 0, -Layout.HALF + Layout.TILE * (j + 0.5))
end

-- Street intersection k, l in 0..10.
function Layout.corner(k, l, y)
	return Vector3.new(-Layout.HALF + Layout.TILE * k, y or 0, -Layout.HALF + Layout.TILE * l)
end

function Layout.key(i, j)
	return i .. "," .. j
end

local function set(list)
	local s = {}
	for _, k in ipairs(list) do
		s[k] = true
	end
	return s
end

Layout.CENTER = set({ "4,4", "4,5", "5,4", "5,5" })

-- Tiles with no Grid deck above, so daylight reaches the Rust.
Layout.LIGHT_WELLS = set({ "0,0", "9,9", "1,4", "8,5", "3,8", "6,1", "0,8", "9,2" })

Layout.RUST_SPECIAL = {
	["1,6"] = "market", -- Lantern Row night market (Vela)
	["7,6"] = "drip", -- The Drip (Vane) and Glitch's den
	["2,2"] = "botshop", -- Kettle's Bot Shop
	["4,9"] = "gate", -- Gate Square and the sealed North Gate
	["5,9"] = "gate",
}

Layout.GRID_SPECIAL = {
	["2,6"] = "tower", -- the Static Tower and Static & Sons (Tamsin)
	["7,3"] = "depot", -- Ascent Grid Depot (Kessler)
	["6,2"] = "wick", -- The Wick bar and Orrin Pell's apartment
	["3,2"] = "lowmarsh", -- Lowmarsh Apartments (Adeyemi) and Marigold's Menagerie
	["6,6"] = "meridian", -- Meridian Plaza, the Bloom Accord
}

-- Manholes in Rust back alleys, leading into the storm sewers.
Layout.MANHOLES = {
	{ i = 1, j = 7, id = 1 },
	{ i = 8, j = 7, id = 2 },
	{ i = 3, j = 1, id = 3 },
}

-- Public lifts at street intersections (Rust / Grid / Sky Road).
Layout.LIFTS = {
	NE = { k = 7, l = 7 },
	NW = { k = 3, l = 7 },
	SE = { k = 7, l = 3 },
	SW = { k = 3, l = 3 },
}

-- Sky roads run along these x and z lines.
Layout.SKY_LINES = { -256, 256 }

-- The Crown Lift rises from the east sky road to the Crown ring.
Layout.CROWN_LIFT = Vector3.new(256, 0, 0)

function Layout.isRust(i, j)
	return not Layout.CENTER[Layout.key(i, j)] and not Layout.RUST_SPECIAL[Layout.key(i, j)]
end

function Layout.hasDeck(i, j)
	local k = Layout.key(i, j)
	return not Layout.CENTER[k] and not Layout.LIGHT_WELLS[k]
end

return Layout
