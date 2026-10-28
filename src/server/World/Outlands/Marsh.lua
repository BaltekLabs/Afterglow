--[[
	South of Veyra: the Drowned Marsh and Mirefall, a fishing village on stilts. The south sewer
	outflow opens at the marsh's edge. The wild roots dislike standing water, so the Glow mostly
	leaves Mirefall alone. Mostly.
]]
local Build = require(script.Parent.Parent.Build)

local M, rgb = Build.M, Build.rgb
local V = Vector3.new

local MIREFALL = V(-900, 0, -2200)
local DECK_Y = 5

local function boardwalk(parent, from, to)
	local a, b = from + V(0, DECK_Y - 0.3, 0), to + V(0, DECK_Y - 0.3, 0)
	Build.beam(parent, a, b, 6, 0.6, rgb(90, 70, 50), M.WoodPlanks, { Name = "Boardwalk" })
	local length = (b - a).Magnitude
	for d = 0, length, 12 do
		local p = a:Lerp(b, d / length)
		Build.cylinder(parent, DECK_Y + 3, 0.6, V(p.X, (DECK_Y - 3) / 2, p.Z), rgb(70, 54, 40), M.Wood)
	end
end

local function hut(parent, center, side, rng, n)
	-- Platform on stilts, then the hut on top.
	Build.part(parent, V(22, 0.8, 20), center + V(0, DECK_Y - 0.4, 0), rgb(90, 70, 50), M.WoodPlanks, { Name = "Platform" })
	for _, x in ipairs({ -9, 9 }) do
		for _, z in ipairs({ -8, 8 }) do
			Build.cylinder(parent, DECK_Y + 3, 0.9, center + V(x, (DECK_Y - 3) / 2, z), rgb(70, 54, 40), M.Wood)
		end
	end
	Build.building(parent, {
		name = "Hut" .. n,
		center = center + V(0, DECK_Y, 0),
		size = V(16, 10, 14),
		side = side,
		kind = if n == 3 then "shop" else "apartment",
		neon = rgb(140, 220, 200),
		wallColor = rgb(110, 100, 80),
		material = M.WoodPlanks,
		sign = if n == 3 then "NETS & BAIT" else "",
		rng = rng,
	})
end

return function(root, ctx)
	local folder = Build.folder(root, "Marsh")
	local zones = Build.folder(root, "Zones")
	local rng = Random.new(808)

	Build.trail(folder, { V(-192, 0, -805), V(-400, 0, -1400), V(-760, 0, -1980), MIREFALL + V(0, 0, 140) }, 9)

	-- Mirefall: huts on stilts around a central platform.
	local village = Build.folder(folder, "Mirefall")
	Build.part(village, V(30, 0.8, 30), MIREFALL + V(0, DECK_Y - 0.4, 0), rgb(90, 70, 50), M.WoodPlanks, { Name = "Square" })
	for _, x in ipairs({ -12, 12 }) do
		for _, z in ipairs({ -12, 12 }) do
			Build.cylinder(village, DECK_Y + 3, 1, MIREFALL + V(x, (DECK_Y - 3) / 2, z), rgb(70, 54, 40), M.Wood)
		end
	end
	local lantern = Build.part(village, V(1.4, 1.4, 1.4), MIREFALL + V(0, DECK_Y + 6, 0), rgb(140, 220, 200), M.Neon, { CanCollide = false })
	Build.light(lantern, rgb(160, 230, 210), 50, 1.6, true)
	Build.cylinder(village, 6, 0.4, MIREFALL + V(0, DECK_Y + 3, 0), rgb(70, 54, 40), M.Wood)
	for k = 0, 7 do
		local a = k / 8 * math.pi * 2
		local center = MIREFALL + V(math.cos(a) * 55, 0, math.sin(a) * 55)
		local toSquare = MIREFALL - center
		local side = if math.abs(toSquare.X) > math.abs(toSquare.Z) then (if toSquare.X > 0 then "E" else "W") else (if toSquare.Z > 0 then "N" else "S")
		hut(village, center, side, rng, k)
		boardwalk(village, MIREFALL, center)
	end
	-- Ramp from the trail up onto the boardwalks, and a dock.
	Build.beam(village, MIREFALL + V(0, 0.2, 140), MIREFALL + V(0, DECK_Y - 0.3, 64), 6, 0.6, rgb(90, 70, 50), M.WoodPlanks, { Name = "Ramp" })
	boardwalk(village, MIREFALL + V(0, 0, 64), MIREFALL + V(0, 0, 15))
	boardwalk(village, MIREFALL + V(-15, 0, 0), MIREFALL + V(-110, 0, -40))
	Build.waypoint("Reed_Dock", MIREFALL + V(-105, DECK_Y, -38), MIREFALL + V(-160, DECK_Y, -60))
	Build.waypoint("CP_Mirefall", MIREFALL + V(0, DECK_Y, 8), MIREFALL)
	Build.waypoint("Res_Mire_1", MIREFALL + V(10, DECK_Y, -8))
	Build.waypoint("Res_Mire_2", MIREFALL + V(-8, DECK_Y, 10))
	Build.zone(zones, "Region_Mirefall", MIREFALL, V(260, 0, 260), { ZoneType = "Region", Region = "mirefall", Priority = 3, Outside = true })
	Build.zone(zones, "CP_Mirefall_Zone", MIREFALL, V(140, 0, 140), { ZoneType = "Checkpoint", Checkpoint = "CP_Mirefall" })
	table.insert(ctx.spots, { position = MIREFALL + V(55, DECK_Y + 0.5, 4), locked = false, tier = "outlands" })

	-- Reeds and drowned trees across the water.
	for _ = 1, 260 do
		local p = V(rng:NextNumber(-1600, -250), 0, rng:NextNumber(-2850, -1650))
		if (p - MIREFALL).Magnitude > 110 then
			local h = rng:NextNumber(3, 7)
			Build.part(folder, V(0.3, h, 0.3), CFrame.new(p + V(0, h / 2 - 1, 0)) * CFrame.Angles(rng:NextNumber(-0.2, 0.2), 0, rng:NextNumber(-0.2, 0.2)), rgb(90, 120, 70), M.Grass, { CanCollide = false })
		end
	end
	for _ = 1, 40 do
		local p = V(rng:NextNumber(-1600, -250), 0, rng:NextNumber(-2850, -1650))
		if (p - MIREFALL).Magnitude > 120 then
			Build.deadTree(folder, rng, p - V(0, 1, 0))
		end
	end
	-- Old Reed's sleeper, among the reeds.
	Build.rooted(folder, MIREFALL + V(200, -1.5, 150), V(-1, 0, 0), "Rooted_Marsh")

	Build.zone(zones, "Region_Marsh", V(-925, 0, -2250), V(1500, 0, 1300), { ZoneType = "Region", Region = "marsh", Priority = 2, Outside = true })
end
