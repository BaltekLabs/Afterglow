-- The Rust: street level under the Grid deck. Every building's ground floor can be entered
-- unless it's closed for the night or locked. Back alleys cross every block.
local Build = require(script.Parent.Parent.Build)
local Layout = require(script.Parent.Layout)

local C, M, rgb = Build.Colors, Build.M, Build.rgb
local V = Vector3.new

local WALLS = {
	{ rgb(74, 50, 50), M.Brick },
	{ rgb(62, 60, 68), M.Concrete },
	{ rgb(84, 64, 48), M.CorrodedMetal },
	{ rgb(52, 58, 62), M.Concrete },
	{ rgb(70, 66, 56), M.Brick },
}
local NEONS = { C.magenta, C.cyan, C.amber, C.danger, C.violet, Build.rgb(150, 255, 170) }
local KINDS = { "apartment", "apartment", "apartment", "bar", "noodle", "noodle", "pawn", "pawn", "workshop", "workshop", "clinic", "chapel", "arcade", "empty", "empty" }
local LATE = { bar = true, noodle = true, arcade = true }

local function pick(rng, list)
	return list[rng:NextInteger(1, #list)]
end

local function closedAttrs(rng, kind)
	local r = rng:NextNumber()
	if kind ~= "empty" and kind ~= "apartment" and r < 0.2 then
		if LATE[kind] then
			return { Mode = "hours", OpenFrom = 17, OpenTo = 5 }
		end
		return { Mode = "hours", OpenFrom = 8, OpenTo = 22 }
	elseif r < 0.36 then
		local hackable = rng:NextNumber() < 0.6
		return { Mode = "locked", Hackable = hackable, Pickable = not hackable or rng:NextNumber() < 0.5 }
	end
	return nil
end

local function lot(parent, ctx, c, sx, sz, rng)
	local qx, qz = c.X + sx * 30, c.Z + sz * 30
	if rng:NextNumber() < 0.2 then
		-- Empty lot: junk and a scrappy community garden of civic plants.
		for _ = 1, 3 do
			local s = rng:NextNumber(2, 5)
			Build.part(parent, V(s, s * 0.7, s), V(qx + rng:NextNumber(-15, 15), s * 0.35, qz + rng:NextNumber(-15, 15)), rgb(60, 52, 46), M.CorrodedMetal)
		end
		Build.planter(parent, V(qx, 0.3, qz), rng, true)
		return
	end
	local w, d = rng:NextInteger(30, 44), rng:NextInteger(30, 44)
	local h = rng:NextInteger(14, 28)
	local function along(size)
		local slack = Layout.LOT_MAX - Layout.LOT_MIN - size
		return Layout.LOT_MIN + size / 2 + rng:NextNumber() * math.max(0, slack)
	end
	local center = V(c.X + sx * along(w), 0.3, c.Z + sz * along(d))
	local side = if rng:NextNumber() < 0.5 then (if sx > 0 then "E" else "W") else (if sz > 0 then "N" else "S")
	local kind = pick(rng, KINDS)
	local wall = pick(rng, WALLS)
	local closed = closedAttrs(rng, kind)
	local _, spots = Build.building(parent, {
		center = center,
		size = V(w, h, d),
		side = side,
		kind = kind,
		neon = pick(rng, NEONS),
		wallColor = wall[1],
		material = wall[2],
		floorMaterial = M.Concrete,
		floorColor = rgb(44, 42, 46),
		closed = closed,
		light = rng:NextNumber() < 0.35,
		rng = rng,
	})
	for _, spot in ipairs(spots) do
		table.insert(ctx.spots, { position = spot, locked = closed ~= nil and closed.Mode == "locked", tier = "rust" })
	end
	-- Pipes and an AC unit on a side wall.
	if rng:NextNumber() < 0.5 then
		Build.cylinder(parent, h, 0.8, center + V(sx * (w / 2 + 0.5), h / 2, 0), rgb(80, 70, 60), M.CorrodedMetal)
	end
	if rng:NextNumber() < 0.4 then
		Build.part(parent, V(3, 2, 2), center + V(0, h - 3, sz * (d / 2 + 1)), rgb(110, 110, 104), M.Metal)
	end
end

local function manhole(parent, c, id)
	local pos = c + V(0, 0.32, 22)
	local cover = Build.cylinder(parent, 0.25, 4, pos, rgb(40, 40, 44), M.DiamondPlate, { Name = "Manhole" })
	Build.cylinder(parent, 0.2, 4.6, pos - V(0, 0.05, 0), rgb(90, 80, 70), M.CorrodedMetal, { CanCollide = false })
	Build.interactable(cover, "manhole_" .. id)
	-- Chalk arrow on the alley wall, the runners' mark.
	local chalk = Build.part(parent, V(3, 3, 0.1), CFrame.lookAt(c + V(0, 5, 34), c + V(0, 5, 0)), rgb(30, 30, 34), M.SmoothPlastic, { CanCollide = false })
	Build.screen(chalk, "↓ OUT", Color3.fromRGB(220, 220, 210))
	Build.waypoint("Manhole_" .. id, c + V(0, 0.3, 26), c + V(0, 0, 40))
	if id == 1 then
		-- Pike spends his days by this manhole, telling anyone who listens where it goes.
		Build.waypoint("Pike_Alley", c + V(3, 0.3, 30), c + V(0, 0.3, 22))
	end
end

return function(root, ctx)
	local folder = Build.folder(root, "Rust")
	local rng = Random.new(5150)

	local manholes = {}
	for _, m in ipairs(Layout.MANHOLES) do
		manholes[Layout.key(m.i, m.j)] = m.id
	end

	for i = 0, Layout.N - 1 do
		for j = 0, Layout.N - 1 do
			local key = Layout.key(i, j)
			local c = Layout.tile(i, j, 0)
			local tileFolder = Build.folder(folder, "Tile_" .. key)
			Build.part(tileFolder, V(Layout.TILE, 4, Layout.TILE), c - V(0, 2, 0), rgb(26, 25, 30), M.Asphalt, { Name = "Street" })
			if Layout.isRust(i, j) then
				Build.part(tileFolder, V(Layout.PAD, 0.3, Layout.PAD), c + V(0, 0.15, 0), rgb(46, 44, 50), M.Concrete, { Name = "Block" })
				for _, sx in ipairs({ -1, 1 }) do
					for _, sz in ipairs({ -1, 1 }) do
						lot(tileFolder, ctx, c, sx, sz, rng)
					end
				end
				-- Alley lamps and civic vines hanging from the Grid deck above.
				if rng:NextNumber() < 0.5 then
					local lamp = Build.part(tileFolder, V(1, 0.4, 1), c + V(0, 12, rng:NextNumber(-30, 30)), pick(rng, NEONS), M.Neon, { CanCollide = false })
					Build.light(lamp, lamp.Color, 22, 1)
				end
				if Layout.hasDeck(i, j) then
					Build.vines(tileFolder, c + V(rng:NextNumber(-20, 20), 0, rng:NextNumber(-20, 20)), Layout.DECK_Y - Layout.DECK_T, rng, 5)
				end
				local id = manholes[key]
				if id then
					manhole(tileFolder, c, id)
				end
			end
		end
	end

	-- Street lamps at every other intersection.
	for k = 1, Layout.N - 1 do
		for l = 1, Layout.N - 1 do
			if (k + l) % 2 == 0 and not (k >= 4 and k <= 6 and l >= 4 and l <= 6) then
				local p = Layout.corner(k, l, 0) + V(8, 0, 8)
				Build.cylinder(folder, 12, 0.5, p + V(0, 6, 0), C.metal, M.Metal)
				local head = Build.part(folder, V(1.4, 0.5, 1.4), p + V(0, 12.2, 0), rgb(255, 190, 120), M.Neon, { CanCollide = false })
				Build.light(head, rgb(255, 190, 130), 30, 1.2)
			end
		end
	end

	local zones = Build.folder(root, "Zones")
	Build.zone(zones, "Region_Rust", V(0, 35, 0), V(1320, 80, 1320), { ZoneType = "Region", Region = "rust", Priority = 3 })
end
