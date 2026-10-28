--[[
	The storm sewers: walkable tunnels 60 studs under the Rust. Three manholes in Rust back
	alleys drop into an east-west trunk; a north branch runs under the Wall to an outflow in
	the Sporewilds, a south branch to an outflow in the marsh. One Rooted sleeps at the bend.
]]
local Build = require(script.Parent.Parent.Build)

local C, M, rgb = Build.Colors, Build.M, Build.rgb
local V = Vector3.new

local FLOOR = -60
local HEIGHT = 14
local WIDTH = 18
local wallColor = rgb(56, 60, 54)

-- A straight tunnel along `axis` ("X" or "Z") at fixed cross coordinate `at`, from a to b.
-- gapsA / gapsB are door openings in the low-side / high-side walls (offsets along the axis).
local function tunnel(parent, axis, at, a, b, gapsLow, gapsHigh, rng)
	local mid, length = (a + b) / 2, math.abs(b - a)
	local function pos(along, cross, y)
		if axis == "X" then
			return V(along, y, at + cross)
		end
		return V(at + cross, y, along)
	end
	local function size(len, h, thick)
		if axis == "X" then
			return V(len, h, thick)
		end
		return V(thick, h, len)
	end
	local function relative(gaps)
		if not gaps then
			return nil
		end
		local out = {}
		for _, g in ipairs(gaps) do
			table.insert(out, { offset = g - mid, width = WIDTH, height = HEIGHT })
		end
		return out
	end
	Build.part(parent, size(length, 1, WIDTH), pos(mid, 0, FLOOR - 0.5), rgb(50, 52, 48), M.Concrete, { Name = "SewerFloor" })
	Build.part(parent, size(length, 1, WIDTH), pos(mid, 0, FLOOR + HEIGHT + 0.5), wallColor, M.Concrete, { Name = "SewerCeiling" })
	Build.part(parent, size(length, 0.2, 6), pos(mid, 0, FLOOR + 0.15), rgb(60, 130, 110), M.Glass, { Transparency = 0.35, CanCollide = false, Name = "Water" })
	Build.wall(parent, pos(mid, -WIDTH / 2 - 0.5, FLOOR), axis, length, HEIGHT, 1, relative(gapsLow), wallColor, M.Concrete)
	Build.wall(parent, pos(mid, WIDTH / 2 + 0.5, FLOOR), axis, length, HEIGHT, 1, relative(gapsHigh), wallColor, M.Concrete)
	-- Pipes along one wall, lamps along the ceiling.
	Build.part(parent, size(length, 1.2, 1.2), pos(mid, WIDTH / 2 - 1, FLOOR + HEIGHT - 2), rgb(90, 70, 50), M.CorrodedMetal, { CanCollide = false })
	for d = 0, length, 60 do
		local along = math.min(a, b) + d
		local lamp = Build.part(parent, size(3, 0.3, 1), pos(along, 0, FLOOR + HEIGHT - 0.2), rgb(200, 255, 220), M.Neon, { CanCollide = false })
		if d % 120 == 0 then
			Build.light(lamp, rgb(170, 255, 210), 40, 0.9)
		end
		if rng:NextNumber() < 0.3 then
			Build.part(parent, V(0.3, rng:NextNumber(3, 8), 0.3), pos(along + 10, rng:NextNumber(-6, 6), FLOOR + HEIGHT - 3), C.civic, M.Grass, { CanCollide = false })
		end
	end
end

local function cap(parent, position, axis)
	local size = if axis == "X" then V(1, HEIGHT, WIDTH + 2) else V(WIDTH + 2, HEIGHT, 1)
	Build.part(parent, size, position + V(0, FLOOR + HEIGHT / 2, 0), wallColor, M.Concrete, { Name = "Cap" })
end

local function ladder(parent, id, position, facing)
	local base = position + V(0, FLOOR, 0)
	for k = 0, 6 do
		Build.part(parent, V(2.4, 0.25, 0.25), CFrame.lookAt(base + V(0, 1 + k * 2, 0), base + V(0, 1 + k * 2, 0) + facing), rgb(120, 110, 90), M.Metal, { CanCollide = false })
	end
	local rail = Build.part(parent, V(2.8, HEIGHT, 0.3), CFrame.lookAt(base + V(0, HEIGHT / 2, 0) - facing * 0.2, base + V(0, HEIGHT / 2, 0) + facing), rgb(70, 66, 56), M.Metal, { Name = "Ladder" })
	Build.interactable(rail, "ladder_" .. id)
	Build.waypoint("Sewer_M" .. id, base + facing * 5 + V(0, 0.5, 0), base + facing * 20)
end

local function grate(parent, interactId, position, facing)
	local g = Build.part(parent, V(14, 10, 0.6), CFrame.lookAt(position + V(0, FLOOR + 5, 0), position + V(0, FLOOR + 5, 0) + facing), rgb(110, 80, 60), M.CorrodedMetal, { Name = "Grate", CanCollide = false })
	for k = -3, 3 do
		Build.part(parent, V(0.4, 10, 0.4), CFrame.lookAt(position + V(k * 2, FLOOR + 5, 0) - facing * 0.4, position + V(k * 2, FLOOR + 5, 0) + facing), rgb(90, 70, 50), M.CorrodedMetal)
	end
	local daylight = Build.part(parent, V(1, 1, 1), position + V(0, FLOOR + 6, 0) + facing * 2, rgb(200, 255, 230), M.Neon, { Transparency = 1, CanCollide = false })
	Build.light(daylight, rgb(200, 255, 230), 30, 1.5)
	Build.interactable(g, interactId)
end

return function(root, ctx)
	local folder = Build.folder(root, "Sewers")
	local rng = Random.new(66)

	-- Trunk along z = 320, x -470..470. North branch leaves at x = -448, south branch at x = -192.
	tunnel(folder, "X", 320, -470, 470, { -192 }, { -448 }, rng)
	cap(folder, V(-470.5, 0, 320), "X")
	cap(folder, V(470.5, 0, 320), "X")
	-- North branch along x = -448 from the trunk to past the Wall.
	tunnel(folder, "Z", -448, 329, 760, nil, nil, rng)
	-- South branch along x = -192 from the trunk to past the Wall.
	tunnel(folder, "Z", -192, -760, 311, nil, nil, rng)

	ladder(folder, 1, V(-448, 0, 338), V(0, 0, 1))
	ladder(folder, 2, V(460, 0, 320), V(-1, 0, 0))
	ladder(folder, 3, V(-192, 0, -440), V(0, 0, 1))

	cap(folder, V(-448, 0, 761), "Z")
	cap(folder, V(-192, 0, -761), "Z")
	grate(folder, "outflow_north_exit", V(-448, 0, 759), V(0, 0, 1))
	grate(folder, "outflow_south_exit", V(-192, 0, -759), V(0, 0, -1))
	Build.waypoint("Sewer_North_End", V(-448, FLOOR + 0.5, 745), V(-448, FLOOR, 600))
	Build.waypoint("Sewer_South_End", V(-192, FLOOR + 0.5, -745), V(-192, FLOOR, -600))

	-- Runners' chalk map at the junction, and their camp in the south branch.
	local chalk = Build.part(folder, V(0.2, 6, 8), V(-456.8, FLOOR + 5, 380), rgb(40, 42, 40), M.Slate, { Name = "ChalkMap" })
	Build.interactable(chalk, "sewer_chalk")
	local camp = V(-192, FLOOR, -120)
	Build.part(folder, V(4, 0.4, 7), camp + V(-5, 0.2, 0), rgb(110, 60, 50), M.Fabric)
	Build.part(folder, V(2, 1.5, 2), camp + V(5, 0.75, 3), C.wood, M.WoodPlanks)
	local candle = Build.part(folder, V(0.4, 0.8, 0.4), camp + V(5, 1.9, 3), C.amber, M.Neon, { CanCollide = false })
	Build.light(candle, C.amber, 16, 1)
	table.insert(ctx.spots, { position = camp + V(5, 1.5, -2), locked = true, tier = "sewer" })

	-- The sleeper at the bend. Sneak past along the wall.
	Build.rooted(folder, V(-448, FLOOR, 560), V(0, 0, -1), "Rooted_Sewer")

	local zones = Build.folder(root, "Zones")
	Build.zone(zones, "Region_Sewers", V(0, -60, 0), V(1100, 60, 1700), { ZoneType = "Region", Region = "sewers", Priority = 5 })
end
