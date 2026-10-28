--[[
	The Sporewilds: the glowing forest north and west of Veyra. The north sewer outflow opens
	here. Trails lead north to Halvorsen Station and far west to Hollow Garden, a Fringe
	village, with Greenhouse 3 on the ridge beyond it.
]]
local Build = require(script.Parent.Parent.Build)

local C, M, rgb = Build.Colors, Build.M, Build.rgb
local V = Vector3.new

local OUTFLOW = V(-448, 0, 800)
local TRAIL_NORTH = { OUTFLOW, V(-300, 0, 1100), V(0, 0, 1600), V(400, 0, 2200), V(700, 0, 2640) }
local TRAIL_HOLLOW = { V(-300, 0, 1100), V(-1000, 0, 1300), V(-1600, 0, 1450), V(-1960, 0, 1500) }
local TRAIL_GREENHOUSE = { V(-1600, 0, 1450), V(-1650, 0, 1710) }
local TRAILS = { TRAIL_NORTH, TRAIL_HOLLOW, TRAIL_GREENHOUSE }

local HOLLOW = V(-2000, 0, 1500)
local GREENHOUSE = V(-1650, 0, 1750)
local CAMP = V(100, 0, 1650)
local STATION = V(700, 0, 2750)

local function nearTrail(p, margin)
	for _, path in ipairs(TRAILS) do
		if Build.distanceToPath(p, path) < margin then
			return true
		end
	end
	return false
end

local function shack(parent, name, center, side, rng)
	local room = Build.room(parent, {
		name = name,
		center = center,
		size = V(12, 9, 11),
		color = rgb(76, 60, 46),
		material = M.WoodPlanks,
		floorMaterial = M.Ground,
		doors = { [side] = { offset = 0, width = 4, height = 7 } },
	})
	Build.ceilingLight(room, center + V(0, 8.4, 0), C.amber, 14, 0.6)
	Build.furnish(room, "apartment", center, V(12, 9, 11), rng, C.amber)
end

local function hollowGarden(parent, zones, rng)
	local f = Build.folder(parent, "HollowGarden")
	-- A ring of shacks around the fire, a palisade, garden plots and the shrine.
	for k = 0, 9 do
		local a = k / 10 * math.pi * 2
		local p = HOLLOW + V(math.cos(a) * 62, 0, math.sin(a) * 62)
		local toFire = HOLLOW - p
		local side = if math.abs(toFire.X) > math.abs(toFire.Z) then (if toFire.X > 0 then "E" else "W") else (if toFire.Z > 0 then "N" else "S")
		shack(f, "Shack" .. k, p, side, rng)
	end
	for k = 0, 35 do
		local a = k / 36 * math.pi * 2
		if k % 9 ~= 0 then -- gaps for paths
			local p = HOLLOW + V(math.cos(a) * 95, 0, math.sin(a) * 95)
			Build.part(f, V(1.4, 7, 17), CFrame.lookAt(p + V(0, 3.5, 0), HOLLOW + V(0, 3.5, 0)), rgb(70, 54, 40), M.Wood, { Name = "Palisade" })
		end
	end
	Build.cylinder(f, 0.8, 8, HOLLOW + V(0, 0.4, 0), rgb(50, 46, 44), M.Slate)
	local fire = Build.part(f, V(2.4, 2.4, 2.4), HOLLOW + V(0, 1.6, 0), rgb(255, 140, 50), M.Neon, { CanCollide = false })
	Build.light(fire, rgb(255, 150, 70), 45, 2, true)
	for i, z in ipairs({ -30, -20, -10 }) do
		Build.part(f, V(18, 0.6, 7), HOLLOW + V(28, 0.3, z), rgb(60, 42, 30), M.Ground, { Name = "Plot" .. i })
		for j = -3, 3 do
			Build.part(f, V(0.3, 1.4, 0.3), HOLLOW + V(28 + j * 2.4, 1.2, z + (j % 2 - 0.5)), C.vesper, M.Neon, { CanCollide = false })
		end
	end
	-- Appears (client-side) once you give Bram the seeds.
	Build.part(f, V(0.5, 2.2, 0.5), HOLLOW + V(36, 1.7, -30), rgb(90, 200, 70), M.Grass, { Name = "GreenShoot", Transparency = 1, CanCollide = false, Tags = { "GreenShoot" } })
	Build.part(f, V(1.8, 0.2, 1), HOLLOW + V(36, 2.6, -30), rgb(90, 200, 70), M.Grass, { Transparency = 1, CanCollide = false, Tags = { "GreenShoot" } })

	local shrine = HOLLOW + V(-30, 0, 40)
	Build.glowTree(f, rng, shrine, 2.6)
	for i = 1, 5 do
		local a = i / 5 * math.pi * 2
		Build.part(f, V(1.6, 2.4, 1.2), shrine + V(math.cos(a) * 8, 1.2, math.sin(a) * 8), rgb(110, 110, 120), M.Slate)
	end
	local stones = Build.part(f, V(3, 2.2, 0.8), CFrame.lookAt(shrine + V(4, 1.1, -10), HOLLOW + V(0, 1.1, 0)), rgb(120, 120, 130), M.Slate, { Name = "ShrineStones" })
	Build.interactable(stones, "lune_shrine")

	Build.waypoint("Bram_Garden", HOLLOW + V(28, 0, -2), HOLLOW + V(28, 0, -20))
	Build.waypoint("Bram_Fire", HOLLOW + V(6, 0, -4), HOLLOW)
	Build.waypoint("Lune_Shrine", shrine + V(6, 0, -12), HOLLOW)
	Build.waypoint("CP_Hollow", HOLLOW + V(0, 0, -20), HOLLOW)
	Build.waypoint("Res_Hollow_1", HOLLOW + V(-20, 0, -30))
	Build.waypoint("Res_Hollow_2", HOLLOW + V(30, 0, 20))
	Build.waypoint("Res_Hollow_3", HOLLOW + V(-35, 0, 10))
	Build.zone(zones, "Region_Hollow", HOLLOW, V(220, 0, 220), { ZoneType = "Region", Region = "hollow", Priority = 2, Outside = true })
	Build.zone(zones, "CP_Hollow_Zone", HOLLOW, V(120, 0, 120), { ZoneType = "Checkpoint", Checkpoint = "CP_Hollow" })
end

local function greenhouse(parent)
	local gh = Build.room(parent, {
		name = "Greenhouse3",
		center = GREENHOUSE,
		size = V(34, 16, 26),
		color = rgb(150, 220, 210),
		material = M.Glass,
		transparency = 0.6,
		floorColor = rgb(50, 46, 40),
		floorMaterial = M.Slate,
		doors = { S = { offset = 0, width = 8, height = 11 } },
	})
	for i = -1, 1 do
		Build.part(gh, V(3, 2.4, 16), GREENHOUSE + V(i * 9, 1.2, 2), rgb(60, 56, 50), M.Wood, { Name = "Planter" })
		for j = -3, 3 do
			Build.part(gh, V(0.3, 1.8, 0.3), GREENHOUSE + V(i * 9, 3.2, 2 + j * 2), C.vesper, M.Neon, { CanCollide = false, Transparency = 0.3 })
		end
	end
	Build.note(gh, "greenhouse_note", GREENHOUSE + V(9, 2.45, -4))
	Build.terminal(gh, "greenhouse_terminal", GREENHOUSE + V(-14, 0.4, 8), V(1, 0, 0), "GREENHOUSE 3\nSEALED")
	Build.part(gh, V(6, 7, 6), GREENHOUSE + V(12, 3.5, 8), rgb(80, 84, 90), M.Metal, { Name = "SeedVault" })
	Build.part(gh, V(2.4, 1.4, 2.4), GREENHOUSE + V(0, 0.7, 10), rgb(110, 70, 50), M.Slate, { Name = "Pot" })
	Build.part(gh, V(0.3, 5, 0.3), GREENHOUSE + V(0, 3.9, 10), rgb(70, 140, 50), M.Grass)
	-- Cylinders run along X; rotate so the face looks south toward the door.
	local face = CFrame.new(GREENHOUSE + V(0, 6.6, 10)) * CFrame.Angles(0, math.rad(90), 0)
	local flower = Build.part(gh, V(0.4, 2.4, 2.4), face, rgb(255, 200, 40), M.SmoothPlastic, { Name = "Sunflower", Shape = Enum.PartType.Cylinder })
	Build.part(gh, V(0.5, 1, 1), face * CFrame.new(0.2, 0, 0), rgb(80, 50, 20), M.SmoothPlastic, { Shape = Enum.PartType.Cylinder })
	local sun = Build.part(gh, V(1, 1, 1), GREENHOUSE + V(0, 9, 8), rgb(255, 230, 160), M.Neon, { CanCollide = false, Transparency = 1 })
	Build.light(sun, rgb(255, 235, 180), 14, 1.2, true)
	Build.interactable(flower, "greenhouse_sunflower")
	Build.waypoint("M_Sunflower", GREENHOUSE + V(4.5, 0, 11))
	Build.rooted(gh, GREENHOUSE + V(4, 0, -7), V(0, 0, -1), "Rooted_Greenhouse")
end

return function(root, ctx)
	local folder = Build.folder(root, "Sporewilds")
	local zones = Build.folder(root, "Zones")
	local rng = Random.new(2027)

	for _, path in ipairs(TRAILS) do
		Build.trail(folder, path, 9)
	end

	-- Forest across the north band, thinning toward the Dead Zone.
	local forest = Build.folder(folder, "Forest")
	for _ = 1, 520 do
		local p = V(rng:NextNumber(-3100, 3100), 0, rng:NextNumber(700, 3100))
		local blocked = nearTrail(p, 10)
			or (p - HOLLOW).Magnitude < 110
			or (p - GREENHOUSE).Magnitude < 35
			or (p - CAMP).Magnitude < 14
			or (p - STATION).Magnitude < 330
			or (p - OUTFLOW).Magnitude < 40
			or (math.abs(p.X) < 700 and p.Z < 720)
		if not blocked then
			if rng:NextNumber() < 0.15 then
				Build.deadTree(forest, rng, p)
			else
				Build.glowTree(forest, rng, p, rng:NextNumber(0.9, 1.8))
			end
		end
	end
	for _ = 1, 160 do
		local p = V(rng:NextNumber(-3100, 3100), 0, rng:NextNumber(700, 3100))
		if not nearTrail(p, 5) and (p - HOLLOW).Magnitude > 100 and (p - STATION).Magnitude > 330 and not (math.abs(p.X) < 700 and p.Z < 720) then
			Build.mushroom(forest, rng, p, rng:NextNumber() < 0.08)
		end
	end
	for _ = 1, 60 do
		local a = V(rng:NextNumber(-3000, 3000), 0.15, rng:NextNumber(760, 3000))
		local b = a + V(rng:NextNumber(-40, 40), 0, rng:NextNumber(-40, 40))
		Build.beam(forest, a, b, 0.4, 0.2, C.vesper, M.Neon, { CanCollide = false, Transparency = 0.25, Tags = { "Vesper" } })
	end

	Build.sporeCloud(folder, zones, "Spores_1", V(-360, 0, 980), V(50, 0, 40))
	Build.sporeCloud(folder, zones, "Spores_2", V(-150, 0, 1360), V(60, 0, 44))
	Build.sporeCloud(folder, zones, "Spores_3", V(200, 0, 1900), V(60, 0, 50))
	Build.sporeCloud(folder, zones, "Spores_4", V(-1300, 0, 1375), V(56, 0, 44))
	Build.sporeCloud(folder, zones, "Spores_5", V(-1630, 0, 1600), V(40, 0, 40))
	Build.sporeCloud(folder, zones, "Spores_6", V(560, 0, 2420), V(70, 0, 50))

	-- Wren's satchel by the trail.
	local satchel = Build.part(folder, V(1.6, 1, 1.2), V(-284, 0.5, 1120), rgb(90, 70, 50), M.Fabric, { Name = "Satchel" })
	Build.light(satchel, rgb(255, 230, 190), 6, 0.7)
	Build.interactable(satchel, "wren_satchel")

	-- The Adeyemi camp, off the trail.
	local camp = Build.folder(folder, "AdeyemiCamp")
	Build.part(camp, V(6, 0.4, 6), CAMP + V(0, 0.2, 0), rgb(70, 64, 56), M.Fabric)
	Build.part(camp, V(6, 3.5, 0.3), CFrame.new(CAMP + V(0, 1.6, -1.5)) * CFrame.Angles(math.rad(-50), 0, 0), rgb(90, 80, 60), M.Fabric)
	Build.part(camp, V(6, 3.5, 0.3), CFrame.new(CAMP + V(0, 1.2, 1.8)) * CFrame.Angles(math.rad(70), 0, 0), rgb(90, 80, 60), M.Fabric)
	local tin = Build.part(camp, V(1, 0.6, 0.8), CAMP + V(-3, 0.3, 3), rgb(120, 120, 130), M.Metal, { Name = "TinBox" })
	Build.light(tin, rgb(255, 230, 190), 6, 0.6)
	Build.interactable(tin, "camp_letter")

	-- A rare Rooted, off the north trail.
	Build.rooted(folder, V(330, 0, 2150), V(1, 0, 0), "Rooted_Wilds")

	hollowGarden(folder, zones, rng)
	greenhouse(folder)
	table.insert(ctx.spots, { position = HOLLOW + V(-62, 0.4, 4), locked = false, tier = "outlands" })

	Build.zone(zones, "Region_Wilds", V(0, 0, 1930), V(6400, 0, 2540), { ZoneType = "Region", Region = "wilds", Priority = 1, Outside = true })
end
