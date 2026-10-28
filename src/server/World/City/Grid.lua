-- The Grid: the middle tier. Deck platforms at y = 80 carrying towers, plazas and planters;
-- sky roads at y = 170; public lifts tying the Rust, the Grid and the sky roads together.
local Build = require(script.Parent.Parent.Build)
local Layout = require(script.Parent.Layout)

local C, M, rgb = Build.Colors, Build.M, Build.rgb
local V = Vector3.new

local DECK = Layout.DECK_Y
local SKY = Layout.SKY_Y

local NEONS = { C.cyan, C.magenta, C.amber, C.violet, rgb(120, 200, 255), rgb(150, 255, 170) }
local KINDS = { "shop", "cafe", "apartment", "apartment", "office", "clinic", "florist", "noodle", "arcade" }
local ADS = {
	"ASCENT BIOTECH\nGROWING TOMORROW",
	"CIVIC STRAIN V-7\nSAFE • CLEAN • GREEN",
	"14 YEARS OF LIGHT",
	"GLOWBOWL\n24/7",
	"THE VEIL\nKEEPS YOU SAFE",
	"VISIT THE CROWN\n(RESIDENTS ONLY)",
	"MARIGOLD'S\nMENAGERIE",
	"HOVERCAB\nRIDE THE SKY",
	"REPORT WILD GROWTH",
	"NEURALINK\nFEEL MORE",
}
local TOWER_COLORS = { rgb(28, 30, 42), rgb(36, 34, 48), rgb(24, 32, 40), rgb(44, 42, 52) }

local function pick(rng, list)
	return list[rng:NextInteger(1, #list)]
end

local function tower(parent, ctx, c, sx, sz, rng)
	local w, d = rng:NextInteger(30, 42), rng:NextInteger(30, 42)
	local function along(size)
		return Layout.LOT_MIN + size / 2 + rng:NextNumber() * math.max(0, Layout.LOT_MAX - Layout.LOT_MIN - size)
	end
	local center = V(c.X + sx * along(w), DECK + 0.4, c.Z + sz * along(d))
	local side = if rng:NextNumber() < 0.5 then (if sx > 0 then "E" else "W") else (if sz > 0 then "N" else "S")
	local kind = pick(rng, KINDS)
	local neon = pick(rng, NEONS)
	local groundH = 14
	local closed = nil
	local r = rng:NextNumber()
	if kind ~= "apartment" and r < 0.22 then
		closed = { Mode = "hours", OpenFrom = 8, OpenTo = 21 }
	elseif r < 0.32 then
		closed = { Mode = "locked", Hackable = true, Pickable = rng:NextNumber() < 0.4 }
	end
	local _, spots = Build.building(parent, {
		center = center,
		size = V(w, groundH, d),
		side = side,
		kind = kind,
		neon = neon,
		wallColor = rgb(200, 204, 214),
		material = M.SmoothPlastic,
		closed = closed,
		light = rng:NextNumber() < 0.3,
		rng = rng,
	})
	for _, spot in ipairs(spots) do
		table.insert(ctx.spots, { position = spot, locked = closed ~= nil and closed.Mode == "locked", tier = "grid" })
	end

	-- The tower above the explorable ground floor.
	local h = rng:NextInteger(40, 210)
	local base = center + V(0, groundH + 0.6, 0)
	local towerColor = pick(rng, TOWER_COLORS)
	Build.part(parent, V(w, h, d), base + V(0, h / 2, 0), towerColor, M.Glass, { Name = "Tower", Reflectance = 0.15, Transparency = 0 })
	-- Neon edges and floor bands.
	for _, ex in ipairs({ -1, 1 }) do
		Build.part(parent, V(0.6, h, 0.6), base + V(ex * w / 2, h / 2, sz * d / 2), neon, M.Neon, { CanCollide = false })
	end
	for y = 16, h - 8, rng:NextInteger(18, 30) do
		Build.part(parent, V(w + 0.4, 0.5, d + 0.4), base + V(0, y, 0), neon, M.Neon, { CanCollide = false, Transparency = 0.35 })
	end
	Build.part(parent, V(w + 1, 1, d + 1), base + V(0, h + 0.5, 0), neon, M.Neon, { CanCollide = false })

	local dir = Build.SIDE_DIR[side]
	local faceDepth = if side == "N" or side == "S" then d / 2 else w / 2
	local faceWidth = if side == "N" or side == "S" then w else d
	-- Vertical gardens: the civic strain climbs half the city's towers.
	if rng:NextNumber() < 0.45 then
		local gh = math.min(h - 10, rng:NextInteger(20, 60))
		Build.greenWall(parent, base + dir * (faceDepth + 0.5) + V(0, 6 + gh / 2, 0), dir, faceWidth * 0.6, gh)
	end
	-- Holographic advert floating off the facade.
	if rng:NextNumber() < 0.5 and h > 40 then
		local y = rng:NextNumber(20, math.min(h - 10, 120))
		Build.holo(parent, base + dir * (faceDepth + 4) + V(0, y, 0), dir, V(faceWidth * 0.8, faceWidth * 0.45, 0.2), neon, pick(rng, ADS))
	end
	-- Roof garden or antenna.
	if rng:NextNumber() < 0.35 then
		Build.planter(parent, base + V(0, h + 1, 0), rng, true)
	else
		Build.cylinder(parent, 14, 0.5, base + V(w / 4, h + 7, d / 4), C.metal, M.Metal)
		local blink = Build.part(parent, V(0.8, 0.8, 0.8), base + V(w / 4, h + 14.4, d / 4), C.danger, M.Neon, { CanCollide = false })
		blink:SetAttribute("Blink", true)
	end
end

local function skyRoad(parent, from, to, rng)
	local length = (to - from).Magnitude
	local pieces = math.ceil(length / 128)
	for k = 1, pieces do
		local a = from:Lerp(to, (k - 1) / pieces)
		local b = from:Lerp(to, k / pieces)
		local mid = (a + b) / 2
		local cf = CFrame.lookAt(mid, b)
		Build.part(parent, V(24, 3, (b - a).Magnitude), cf - V(0, 1.5, 0), rgb(40, 40, 50), M.Asphalt, { Name = "SkyRoad" })
		for _, x in ipairs({ -11.6, 11.6 }) do
			Build.part(parent, V(0.6, 3.2, (b - a).Magnitude), cf * CFrame.new(x, 1.6, 0), rgb(120, 130, 150), M.Glass, { Transparency = 0.5 })
			Build.part(parent, V(0.3, 0.3, (b - a).Magnitude), cf * CFrame.new(x, 3.3, 0), C.cyan, M.Neon, { CanCollide = false })
		end
		if k % 2 == 0 then
			Build.planter(parent, (cf * CFrame.new(rng:NextNumber(-7, 7), 0, 0)).Position, rng, false)
		end
	end
end

local function pylon(parent, position, topY, diameter)
	Build.cylinder(parent, topY, diameter, V(position.X, topY / 2, position.Z), rgb(70, 72, 82), M.Concrete)
end

-- A glass lift shaft with call panels at each stop.
local function liftShaft(parent, id, position, stops)
	local top = stops[#stops].y + 4
	Build.cylinder(parent, top, 10, V(position.X, top / 2, position.Z), rgb(140, 200, 230), M.Glass, { Transparency = 0.6, Name = "LiftShaft" })
	Build.cylinder(parent, top, 1, V(position.X, top / 2, position.Z), C.cyan, M.Neon, { CanCollide = false })
	for _, stop in ipairs(stops) do
		local p = V(position.X, stop.y, position.Z) + stop.out * 6.5
		Build.liftStop(parent, id, stop.waypoint, p, stop.out)
	end
end

return function(root, ctx)
	local folder = Build.folder(root, "Grid")
	local rng = Random.new(8080)

	-- Deck tiles, plazas and towers.
	for i = 0, Layout.N - 1 do
		for j = 0, Layout.N - 1 do
			if Layout.hasDeck(i, j) then
				local key = Layout.key(i, j)
				local c = Layout.tile(i, j, DECK)
				local tileFolder = Build.folder(folder, "Tile_" .. key)
				Build.part(tileFolder, V(Layout.TILE, Layout.DECK_T, Layout.TILE), c - V(0, Layout.DECK_T / 2, 0), rgb(40, 40, 48), M.Concrete, { Name = "Deck" })
				Build.part(tileFolder, V(Layout.PAD, 0.4, Layout.PAD), c + V(0, 0.2, 0), rgb(150, 152, 160), M.Pavement, { Name = "Sidewalk" })
				-- Underside lights so the Rust gets something.
				local under = Build.part(tileFolder, V(2, 0.3, 2), c - V(0, Layout.DECK_T + 0.2, 0), rgb(255, 200, 150), M.Neon, { CanCollide = false })
				if rng:NextNumber() < 0.35 then
					Build.light(under, rgb(255, 200, 150), 34, 0.9)
				end
				if not Layout.GRID_SPECIAL[key] then
					local built = 0
					for _, sx in ipairs({ -1, 1 }) do
						for _, sz in ipairs({ -1, 1 }) do
							if rng:NextNumber() < 0.55 or (built == 0 and sx == 1 and sz == 1) then
								tower(tileFolder, ctx, c, sx, sz, rng)
								built += 1
							else
								Build.planter(tileFolder, c + V(sx * 30, 0.4, sz * 30), rng, true)
							end
						end
					end
					-- Street trees along the block edge.
					for _, off in ipairs({ V(-48, 0.4, 0), V(48, 0.4, 0), V(0, 0.4, -48), V(0, 0.4, 48) }) do
						Build.planter(tileFolder, c + off, rng, false)
					end
				end
			end
		end
	end

	-- Deck pillars at intersections (not inside the Powerhouse pit or where lifts stand).
	local liftCorners = {}
	for _, l in pairs(Layout.LIFTS) do
		liftCorners[l.k .. "," .. l.l] = true
	end
	for k = 0, Layout.N do
		for l = 0, Layout.N do
			local inPit = k >= 4 and k <= 6 and l >= 4 and l <= 6
			if not inPit and not liftCorners[k .. "," .. l] then
				pylon(folder, Layout.corner(k, l, 0), DECK - Layout.DECK_T, 8)
			end
		end
	end
	-- Grid street lamps.
	for k = 1, Layout.N - 1 do
		for l = 1, Layout.N - 1 do
			if (k + l) % 2 == 1 and not (k >= 4 and k <= 6 and l >= 4 and l <= 6) then
				local p = Layout.corner(k, l, DECK) + V(-8, 0, -8)
				Build.cylinder(folder, 10, 0.4, p + V(0, 5, 0), C.metal, M.Metal)
				local head = Build.part(folder, V(1.2, 0.4, 1.2), p + V(0, 10.2, 0), C.cyan, M.Neon, { CanCollide = false })
				Build.light(head, rgb(170, 230, 255), 28, 1.1)
			end
		end
	end

	-- Sky roads --------------------------------------------------------------------
	local sky = Build.folder(folder, "SkyRoads")
	for _, x in ipairs(Layout.SKY_LINES) do
		skyRoad(sky, V(x, SKY, -600), V(x, SKY, 600), rng)
		skyRoad(sky, V(-600, SKY + 0.05, x), V(600, SKY + 0.05, x), rng)
		for z = -512, 512, 128 do
			local onLift = math.abs(z) == 256 or (x == 256 and z == 0)
			if not onLift then
				pylon(sky, V(x, 0, z), SKY - 3, 6)
				pylon(sky, V(z, 0, x), SKY - 3, 6)
			end
		end
	end

	-- Public lifts at the four sky road crossings.
	for id, l in pairs(Layout.LIFTS) do
		local p = Layout.corner(l.k, l.l, 0)
		local out = V(-math.sign(p.X), 0, -math.sign(p.Z)).Unit -- toward the city center
		liftShaft(folder, id, p, {
			{ y = 0.3, waypoint = "Lift_" .. id .. "_Rust", out = out },
			{ y = DECK + 0.4, waypoint = "Lift_" .. id .. "_Grid", out = out },
			{ y = SKY, waypoint = "Lift_" .. id .. "_Sky", out = V(0, 0, -math.sign(p.Z)) },
		})
	end

	-- Crown Lift: from the east sky road up to the Crown ring.
	local cl = Layout.CROWN_LIFT
	liftShaft(folder, "crown", cl, {
		{ y = SKY, waypoint = "Lift_Crown_Sky", out = V(0, 0, -1) },
	})
	Build.cylinder(folder, Layout.CROWN_Y - SKY, 10, V(cl.X, (Layout.CROWN_Y + SKY) / 2, cl.Z), rgb(255, 224, 138), M.Glass, { Transparency = 0.5 })
	Build.liftStop(folder, "crown", "Lift_Crown_Top", V(cl.X - 14, Layout.CROWN_Y, cl.Z), V(-1, 0, 0))
	Build.sign(folder, "CROWN LIFT · RESIDENTS & GUESTS", V(cl.X, SKY + 12, cl.Z - 5.2), V(0, 0, -1), V(18, 2.6, 0.3), rgb(255, 224, 138))

	local zones = Build.folder(root, "Zones")
	Build.zone(zones, "Region_Grid", V(0, 160, 0), V(1320, 170, 1320), { ZoneType = "Region", Region = "grid", Priority = 3 })
end
