-- Hand-placed story locations inside Veyra. Positions come from Layout's special tiles.
local Build = require(script.Parent.Parent.Build)
local Layout = require(script.Parent.Layout)

local C, M, rgb = Build.Colors, Build.M, Build.rgb
local V = Vector3.new

local DECK = Layout.DECK_Y
local FLOOR = 0.3 -- Rust block top
local GFLOOR = DECK + 0.4 -- Grid sidewalk top

local function pad(parent, c, color, material)
	Build.part(parent, V(Layout.PAD, 0.3, Layout.PAD), c + V(0, 0.15, 0), color, material or M.Concrete, { Name = "Block" })
end

local function stall(parent, x, z, name, neon)
	Build.part(parent, V(12, 3.5, 2), V(x, FLOOR + 1.75, z), C.wood, M.WoodPlanks, { Name = "Counter" })
	Build.part(parent, V(14, 0.5, 9), V(x, 9, z - 4), rgb(24, 22, 30), M.Metal, { Name = "Canopy" })
	Build.part(parent, V(14, 0.4, 0.4), V(x, 8.7, z + 0.5), neon, M.Neon, { CanCollide = false })
	Build.part(parent, V(14, 8.6, 0.6), V(x, 4.6, z - 8.5), rgb(30, 28, 36), M.Metal)
	for _, dx in ipairs({ -6.6, 6.6 }) do
		Build.cylinder(parent, 9, 0.5, V(x + dx, 4.8, z + 0.3), C.metal, M.Metal)
	end
	Build.sign(parent, name, V(x, 10.4, z + 0.4), V(0, 0, 1), V(10, 1.8, 0.3), neon)
	local lamp = Build.part(parent, V(1, 0.3, 1), V(x, 8.5, z - 4), neon, M.Neon, { CanCollide = false })
	Build.light(lamp, neon, 18, 1.2)
end

local function stringLights(parent, from, to, count, rng)
	for k = 0, count do
		local p = from:Lerp(to, k / count) - V(0, math.sin(k / count * math.pi) * 2, 0)
		local colors = { C.magenta, C.amber, C.cyan, C.vesper }
		Build.ball(parent, 0.6, p, colors[rng:NextInteger(1, #colors)], M.Neon, { CanCollide = false })
	end
end

-- The Rust ---------------------------------------------------------------------------------

local function market(parent, rng)
	local c = Layout.tile(1, 6, 0)
	pad(parent, c, rgb(50, 44, 50))
	Build.sign(parent, "LANTERN ROW", V(c.X, 16, c.Z + 30), V(0, 0, 1), V(30, 4, 0.4), C.magenta)
	for _, dx in ipairs({ -16, 16 }) do
		Build.cylinder(parent, 16, 0.7, V(c.X + dx, 8, c.Z + 30), C.metal, M.Metal)
	end
	stall(parent, c.X - 30, c.Z, "PARTS & PIECES", C.cyan)
	stall(parent, c.X, c.Z, "VELA'S", C.magenta)
	stall(parent, c.X + 30, c.Z, "GLOWBOWL", C.amber)
	stringLights(parent, V(c.X - 45, 12, c.Z + 12), V(c.X + 45, 12, c.Z + 12), 18, rng)
	stringLights(parent, V(c.X - 45, 13, c.Z + 26), V(c.X + 45, 13, c.Z + 26), 18, rng)
	local crate = Build.part(parent, V(3, 3, 3), V(c.X + 5, FLOOR + 1.5, c.Z - 6), C.wood, M.WoodPlanks, { Name = "VelaCrate" })
	Build.interactable(crate, "vela_crate")
	Build.waypoint("Vela_Stall", V(c.X - 1, FLOOR, c.Z - 3), V(c.X - 1, FLOOR, c.Z + 20))

	Build.building(parent, {
		name = "VelaHome",
		center = V(c.X - 35, FLOOR, c.Z - 36),
		size = V(18, 12, 16),
		side = "N",
		kind = "apartment",
		neon = C.magenta,
		wallColor = rgb(74, 50, 50),
		material = M.Brick,
		sign = "",
		rng = rng,
	})
	Build.waypoint("Vela_Home", V(c.X - 35, FLOOR, c.Z - 36), V(c.X - 35, FLOOR, c.Z - 20))
	Build.building(parent, {
		name = "NoodleCorner",
		center = V(c.X + 34, FLOOR, c.Z - 34),
		size = V(26, 14, 22),
		side = "N",
		kind = "noodle",
		neon = C.amber,
		wallColor = rgb(84, 64, 48),
		material = M.CorrodedMetal,
		sign = "MAMA LIN'S",
		rng = rng,
	})
	Build.planter(parent, V(c.X - 40, FLOOR, c.Z + 40), rng, true)
	Build.planter(parent, V(c.X + 40, FLOOR, c.Z + 40), rng, true)
	Build.vines(parent, c, DECK - Layout.DECK_T, rng, 8)
	Build.waypoint("Pike_Market", V(c.X + 20, FLOOR, c.Z + 18), V(c.X, FLOOR, c.Z))
	Build.waypoint("CP_Rust", V(c.X, FLOOR, c.Z + 34), V(c.X, FLOOR, c.Z))
	Build.waypoint("Res_Rust_A1", V(c.X - 40, FLOOR, c.Z + 20))
	Build.waypoint("Res_Rust_A2", V(c.X + 40, FLOOR, c.Z + 20))
	Build.waypoint("Res_Rust_A3", V(c.X + 10, FLOOR, c.Z + 45))
	local zones = Build.folder(parent.Parent.Parent, "Zones")
	Build.zone(zones, "CP_Rust_Zone", V(c.X, 30, c.Z), V(110, 60, 110), { ZoneType = "Checkpoint", Checkpoint = "CP_Rust" })
end

local function drip(parent, rng)
	local c = Layout.tile(7, 6, 0)
	pad(parent, c, rgb(40, 36, 42))
	local dripCenter = V(c.X - 22, FLOOR, c.Z + 4)
	Build.building(parent, {
		name = "TheDrip",
		center = dripCenter,
		size = V(42, 16, 40),
		side = "W",
		kind = "bar",
		neon = rgb(180, 30, 50),
		wallColor = rgb(40, 34, 38),
		material = M.Brick,
		sign = "THE DRIP",
		rng = rng,
	})
	Build.part(parent, V(8, 3, 6), dripCenter + V(-10, 1.5, -12), rgb(60, 20, 30), M.Fabric, { Name = "VaneBooth" })
	Build.waypoint("Vane_Booth", dripCenter + V(-10, 0, -8), dripCenter + V(-10, 0, 10))
	Build.building(parent, {
		name = "GlitchDen",
		center = V(c.X + 28, FLOOR, c.Z - 22),
		size = V(30, 14, 30),
		side = "E",
		kind = "workshop",
		neon = C.cyan,
		wallColor = rgb(30, 30, 36),
		material = M.Metal,
		sign = "GLITCH",
		rng = rng,
	})
	for k = 0, 5 do
		local screen = Build.part(parent, V(3, 2, 0.2), CFrame.lookAt(V(c.X + 28 - 7 + k * 2.8, 5 + (k % 2) * 2.2, c.Z - 36), V(c.X + 28 - 7 + k * 2.8, 5 + (k % 2) * 2.2, c.Z)), rgb(5, 15, 20), M.SmoothPlastic, { CanCollide = false })
		Build.screen(screen, ({ "> ACCESS", "VEIL.SYS", "01101", "CROWN.KEY", "PH-HATCH", "> ROOT" })[k + 1], C.cyan)
	end
	Build.waypoint("Glitch_Den", V(c.X + 28, FLOOR, c.Z - 22), V(c.X + 40, FLOOR, c.Z - 22))
	Build.waypoint("Vane_Alley", V(c.X, FLOOR, c.Z + 42), V(c.X, FLOOR, c.Z))
	Build.waypoint("Res_Rust_B1", V(c.X - 45, FLOOR, c.Z - 40))
	Build.waypoint("Res_Rust_B2", V(c.X + 45, FLOOR, c.Z + 40))
	Build.waypoint("Res_Rust_B3", V(c.X - 45, FLOOR, c.Z + 45))
	Build.vines(parent, c, DECK - Layout.DECK_T, rng, 6)
end

local function botshop(parent, rng)
	local c = Layout.tile(2, 2, 0)
	pad(parent, c, rgb(44, 42, 46))
	local center = V(c.X, FLOOR, c.Z)
	Build.building(parent, {
		name = "KettlesBotShop",
		center = center,
		size = V(60, 18, 44),
		side = "N",
		kind = "workshop",
		neon = C.amber,
		wallColor = rgb(84, 64, 48),
		material = M.CorrodedMetal,
		sign = "KETTLE'S BOT SHOP",
		rng = rng,
	})
	-- Display bots: a robo-dog on a plinth and a shelf of drones.
	for k = -2, 2 do
		local base = center + V(k * 9, 0, 12)
		Build.part(parent, V(4, 1.6, 4), base + V(0, 0.8, 0), rgb(50, 50, 56), M.DiamondPlate)
		Build.part(parent, V(1.4, 1, 2.4), base + V(0, 2.8, 0), rgb(90, 96, 110), M.Metal)
		Build.part(parent, V(0.9, 0.9, 0.9), base + V(0, 3.4, -1.4), rgb(90, 96, 110), M.Metal)
		Build.part(parent, V(0.6, 0.15, 0.05), base + V(0, 3.5, -1.86), C.danger, M.Neon, { CanCollide = false })
	end
	Build.waypoint("Kettle_Shop", center + V(4, 0, 3), center + V(4, 0, 20))
	Build.waypoint("Kettle_Back", center + V(20, 0, -14), center + V(0, 0, -14))
	Build.planter(parent, c + V(-40, FLOOR, 40), rng, true)
end

local function gateSquare(parent, rng)
	local c = V(0, 0, 576)
	Build.part(parent, V(236, 0.3, Layout.PAD), c + V(0, 0.15, 0), rgb(52, 50, 54), M.Concrete, { Name = "GateSquare" })
	-- Enforcer post (locked) and Okafor's booth.
	Build.building(parent, {
		name = "EnforcerPost",
		center = V(-80, FLOOR, 590),
		size = V(40, 18, 30),
		side = "E",
		kind = "office",
		neon = C.danger,
		wallColor = rgb(40, 44, 58),
		material = M.Metal,
		sign = "ENFORCER POST",
		closed = { Mode = "locked", Hackable = true },
		rng = rng,
	})
	local booth = Build.room(parent, {
		name = "GateBooth",
		center = V(24, FLOOR, 628),
		size = V(10, 10, 10),
		color = rgb(52, 60, 78),
		material = M.Metal,
		doors = { W = { offset = 0, width = 4, height = 8 } },
	})
	Build.ceilingLight(booth, V(24, 9.6, 628), rgb(255, 220, 180), 12, 0.8)
	Build.waypoint("Okafor_Post", V(14, FLOOR, 630), V(14, FLOOR, 600))
	-- Barricades before the gate.
	for k = -3, 3 do
		Build.part(parent, V(8, 3, 2), V(k * 10, 1.8, 640), rgb(200, 170, 40), M.Concrete, { Name = "Barricade" })
	end
	local notice = Build.sign(parent, "NOTICE OF THE SEALED GATES", V(0, 4, 600), V(0, 0, -1), V(14, 3, 0.4), C.danger, rgb(30, 20, 20))
	Build.interactable(notice, "veil_notice")
	for _, x in ipairs({ -60, 60 }) do
		local flood = Build.part(parent, V(3, 1, 3), V(x, 30, 630), rgb(255, 250, 230), M.Neon, { CanCollide = false })
		Build.light(flood, rgb(255, 245, 220), 60, 1.6, true)
		Build.cylinder(parent, 30, 1, V(x, 15, 630), C.metal, M.Metal)
	end
	Build.waypoint("Enf_Gate_1", V(-40, FLOOR, 620))
	Build.waypoint("Enf_Gate_2", V(40, FLOOR, 620))
	Build.waypoint("Enf_Gate_3", V(0, FLOOR, 560))
end

-- The Grid ---------------------------------------------------------------------------------

local function staticTower(parent, rng)
	local c = Layout.tile(2, 6, GFLOOR)
	local base, top = GFLOOR, 310
	local function halfWidth(y)
		return 16 - (y - base) / (top - base) * 13
	end
	local corners = { V(-1, 0, -1), V(1, 0, -1), V(1, 0, 1), V(-1, 0, 1) }
	local steel = rgb(150, 40, 40)
	for _, k in ipairs(corners) do
		Build.beam(parent, c + k * halfWidth(base), V(c.X, top, c.Z) + k * halfWidth(top), 1.6, 1.6, steel, M.Metal, { Name = "TowerLeg" })
	end
	local sections = 10
	for s = 1, sections do
		local y0 = base + (s - 1) / sections * (top - base)
		local y1 = base + s / sections * (top - base)
		for n = 1, 4 do
			local a, b = corners[n], corners[n % 4 + 1]
			local a0, b0 = V(c.X, y0, c.Z) + a * halfWidth(y0), V(c.X, y0, c.Z) + b * halfWidth(y0)
			local a1, b1 = V(c.X, y1, c.Z) + a * halfWidth(y1), V(c.X, y1, c.Z) + b * halfWidth(y1)
			if s > 1 then
				Build.beam(parent, a0, b0, 0.8, 0.8, steel, M.Metal)
			end
			Build.beam(parent, a0, b1, 0.6, 0.6, steel, M.Metal)
			Build.beam(parent, b0, a1, 0.6, 0.6, steel, M.Metal)
		end
	end
	-- Dishes, antenna and blinking beacons.
	for k, y in ipairs({ 150, 200, 240 }) do
		local dir = corners[k]
		local p = V(c.X, y, c.Z) + dir * (halfWidth(y) + 3)
		Build.part(parent, V(0.6, 7, 7), CFrame.lookAt(p, p + dir) * CFrame.Angles(0, math.rad(90), 0), rgb(220, 220, 225), M.Metal, { Shape = Enum.PartType.Cylinder })
	end
	Build.cylinder(parent, 40, 1, V(c.X, top + 20, c.Z), C.metal, M.Metal)
	for _, y in ipairs({ 180, 260, top + 40 }) do
		local beacon = Build.part(parent, V(2, 2, 2), V(c.X, y, c.Z), C.danger, M.Neon, { CanCollide = false })
		beacon:SetAttribute("Blink", true)
		Build.light(beacon, C.danger, 40, 1.5)
	end
	Build.holo(parent, V(c.X, 120, c.Z - 22), V(0, 0, -1), V(30, 14, 0.2), C.amber, "STATIC & SONS\n14 YEARS ON AIR")

	-- Observation deck.
	local deckY = 270
	Build.part(parent, V(32, 1, 32), V(c.X, deckY - 0.5, c.Z), rgb(60, 62, 70), M.DiamondPlate, { Name = "ObservationDeck" })
	for _, dir in ipairs({ V(1, 0, 0), V(-1, 0, 0), V(0, 0, 1), V(0, 0, -1) }) do
		local p = V(c.X, deckY + 1.5, c.Z) + dir * 15.7
		Build.part(parent, V(32, 3, 0.4), CFrame.lookAt(p, p + dir), rgb(160, 200, 230), M.Glass, { Transparency = 0.5 })
	end
	Build.liftStop(parent, "tower", "Lift_Tower_Top", V(c.X, deckY, c.Z - 9), V(0, 0, -1))
	Build.liftStop(parent, "tower", "Lift_Tower_Base", V(c.X + 6, base, c.Z - 17), V(0, 0, -1))

	-- Broadcast horns at the foot of the tower.
	local cabinet = Build.part(parent, V(6, 4, 3), V(c.X, base + 2, c.Z - 20), rgb(40, 36, 32), M.Wood, { Name = "SpeakerCabinet" })
	Build.interactable(cabinet, "tower_speaker")
	for k = -1, 1 do
		local p = V(c.X + k * 5, base + 14, c.Z - 18)
		Build.part(parent, V(2.4, 3.6, 3.6), CFrame.lookAt(p, p + V(k * 0.4, -0.2, -1)) * CFrame.Angles(0, math.rad(90), 0), rgb(200, 190, 160), M.Metal, { Shape = Enum.PartType.Cylinder })
	end
	Build.cylinder(parent, 14, 0.6, V(c.X, base + 7, c.Z - 18), C.metal, M.Metal)
	Build.waypoint("M_TowerSpeaker", V(c.X, base, c.Z - 26))

	-- Static & Sons Radio (Tamsin's shop) and her flat.
	local shopCenter = V(c.X + 32, base, c.Z - 28)
	local shop = Build.room(parent, {
		name = "StaticAndSons",
		center = shopCenter,
		size = V(26, 14, 20),
		color = rgb(46, 40, 52),
		material = M.Brick,
		doors = { W = { offset = 0, width = 6, height = 9 } },
	})
	Build.part(shop, V(2, 3.5, 10), shopCenter + V(-5, 1.75, 0), C.wood, M.WoodPlanks, { Name = "Counter" })
	Build.part(shop, V(2, 9, 16), shopCenter + V(11.5, 4.5, 0), rgb(36, 30, 28), M.Wood, { Name = "Shelves" })
	for i = 1, 10 do
		local radio = Build.part(shop, V(1.2, 1, 1.2), shopCenter + V(10.2, 2 + (i % 3) * 2.8, -7 + i * 1.4), rgb(60, 50, 44), M.Wood)
		Build.part(shop, V(0.1, 0.3, 0.3), radio.CFrame.Position + V(-0.62, 0.1, 0), ({ C.amber, C.cyan, C.danger })[i % 3 + 1], M.Neon, { CanCollide = false })
	end
	local photo = Build.part(shop, V(0.2, 1, 1.3), CFrame.new(shopCenter + V(-5, 4, -3.5)) * CFrame.Angles(0, 0, math.rad(10)), rgb(80, 60, 40), M.Wood, { Name = "Photo" })
	Build.interactable(photo, "tamsin_photo")
	Build.ceilingLight(shop, shopCenter + V(0, 13.4, 0), rgb(255, 196, 140), 22, 1)
	Build.sign(parent, "STATIC & SONS RADIO", shopCenter + V(-13.4, 11, 0), V(-1, 0, 0), V(16, 2.6, 0.4), C.amber)
	Build.waypoint("Tamsin_Shop", shopCenter + V(-1, 0, 0), shopCenter + V(-12, 0, 0))
	Build.building(parent, {
		name = "TamsinFlat",
		center = V(c.X - 32, base, c.Z + 32),
		size = V(18, 12, 16),
		side = "S",
		kind = "apartment",
		neon = C.amber,
		wallColor = rgb(200, 190, 180),
		material = M.Plaster,
		sign = "",
		rng = rng,
	})
	Build.waypoint("Tamsin_Home", V(c.X - 32, base, c.Z + 32), V(c.X - 32, base, c.Z + 10))

	-- Generator (cell run job).
	local gen = Build.part(parent, V(7, 5, 4), V(c.X - 26, base + 2.5, c.Z - 22), rgb(52, 56, 64), M.DiamondPlate, { Name = "Generator" })
	for i = -1, 1 do
		Build.part(parent, V(0.6, 3, 0.2), V(c.X - 26 + i * 2, base + 2.6, c.Z - 24.05), rgb(30, 34, 36), M.SmoothPlastic, { CanCollide = false, Tags = { "GeneratorLight" } })
	end
	Build.interactable(gen, "tower_generator")
	Build.waypoint("M_Generator", V(c.X - 26, base, c.Z - 28))
	Build.planter(parent, V(c.X + 40, base, c.Z + 40), rng, true)
end

local function depot(parent, rng)
	local c = Layout.tile(7, 3, GFLOOR)
	local fence = rgb(40, 44, 54)
	Build.wall(parent, c + V(0, 0, -40), "X", 80, 10, 1, nil, fence, M.DiamondPlate)
	Build.wall(parent, c + V(0, 0, 40), "X", 80, 10, 1, nil, fence, M.DiamondPlate)
	Build.wall(parent, c + V(40, 0, 0), "Z", 80, 10, 1, nil, fence, M.DiamondPlate)
	Build.wall(parent, c + V(-40, 0, 0), "Z", 80, 10, 1, { offset = 0, width = 12, height = 10 }, fence, M.DiamondPlate)
	Build.part(parent, V(1.2, 0.5, 80), c + V(-40, 10.2, 0), C.ascent, M.Neon, { CanCollide = false })
	Build.sign(parent, "ASCENT BIOTECH · GRID DEPOT", c + V(-40.8, 13.5, 0), V(-1, 0, 0), V(24, 3, 0.4), C.ascent)
	Build.holo(parent, c + V(0, 40, 0), V(-1, 0, 0), V(40, 16, 0.2), C.ascent, "ASCENT BIOTECH\nGROWING TOMORROW")

	local officeCenter = c + V(22, 0, 22)
	local office = Build.room(parent, {
		name = "DepotOffice",
		center = officeCenter,
		size = V(20, 12, 14),
		color = rgb(210, 214, 224),
		material = M.SmoothPlastic,
		doors = { W = { offset = 0, width = 5, height = 9 } },
	})
	Build.part(office, V(6, 3, 3), officeCenter + V(4, 1.5, 0), rgb(60, 64, 76), M.Metal, { Name = "Desk" })
	local memo = Build.part(office, V(1.6, 1.1, 0.2), CFrame.lookAt(officeCenter + V(4, 3.6, 0), officeCenter + V(-6, 3.6, 0)), rgb(10, 20, 30), M.SmoothPlastic, { Name = "MemoTerminal" })
	Build.screen(memo, "ASCENT // CONFIDENTIAL", C.ascent)
	Build.interactable(memo, "ascent_memo")
	Build.ceilingLight(office, officeCenter + V(0, 11.4, 0), rgb(220, 235, 255), 18, 1)

	local crate = Build.part(parent, V(4, 3, 4), c + V(-10, 1.5, -15), rgb(60, 66, 80), M.Metal, { Name = "CellCrate" })
	for i = -1, 1 do
		Build.cylinder(parent, 1.6, 0.8, c + V(-10 + i * 1.1, 3.8, -15), C.vesper, M.Neon, { CanCollide = false, Tags = { "Vesper" } })
	end
	Build.interactable(crate, "cell_crate")
	Build.waypoint("M_CellCrate", c + V(-10, 0, -20))
	for i = 0, 3 do
		local rack = Build.part(parent, V(3, 6, 10), c + V(-26 + i * 8, 3, 18), rgb(36, 40, 50), M.Metal)
		Build.part(parent, V(3.2, 0.4, 10.2), rack.CFrame.Position + V(0, 1.5, 0), C.vesper, M.Neon, { CanCollide = false, Tags = { "Vesper" } })
	end

	Build.part(parent, V(2, 3.5, 6), c + V(-46, 1.75, 0), rgb(200, 205, 215), M.SmoothPlastic, { Name = "Kiosk" })
	Build.waypoint("Kessler_Desk", c + V(-43.5, 0, 0), c + V(-60, 0, 0))
	Build.waypoint("Depot_Eject", c + V(-52, 0, -8), c + V(-70, 0, -8))
	Build.waypoint("Warden_1", c + V(-30, 0, -30))
	Build.waypoint("Warden_2", c + V(30, 0, -30))
	Build.waypoint("Warden_3", c + V(30, 0, 8))
	Build.waypoint("Warden_4", c + V(-30, 0, 30))

	local zones = Build.folder(parent.Parent.Parent, "Zones")
	Build.zone(zones, "Depot_Restricted", c + V(0, 36, 0), V(76, 80, 76), {
		ZoneType = "Restricted",
		Requires = "ascent_access",
		Eject = "Depot_Eject",
		Label = "Ascent Biotech property",
		Faction = "ascent",
		TrespassFlag = "trespassed_ascent",
	})
end

local function wick(parent, rng)
	local c = Layout.tile(6, 2, GFLOOR)
	local barCenter = V(c.X - 24, GFLOOR, c.Z)
	Build.building(parent, {
		name = "TheWick",
		center = barCenter,
		size = V(36, 14, 30),
		side = "W",
		kind = "bar",
		neon = C.magenta,
		wallColor = rgb(60, 40, 50),
		material = M.Brick,
		sign = "THE WICK",
		rng = rng,
	})
	Build.waypoint("Kessler_Bar", barCenter + V(4, 0, 8), barCenter + V(4, 0, 14))
	Build.waypoint("Pell_Wick", barCenter + V(-4, 0, 8), barCenter + V(-4, 0, 14))
	Build.part(parent, V(36, 60, 30), barCenter + V(0, 14.6 + 30, 0), rgb(36, 34, 48), M.Glass, { Reflectance = 0.15 })

	-- Orrin Pell's apartment: brass lock (key), but a hacker or lockpick also works.
	local aptCenter = V(c.X + 26, GFLOOR, c.Z + 14)
	Build.building(parent, {
		name = "PellApartment",
		center = aptCenter,
		size = V(28, 14, 24),
		side = "N",
		kind = "apartment",
		neon = rgb(255, 224, 138),
		wallColor = rgb(220, 214, 200),
		material = M.Plaster,
		sign = "",
		closed = { Mode = "locked", Hackable = true, Pickable = true, KeyItem = "pell_key", Key = "pell_door" },
		rng = rng,
	})
	Build.part(parent, V(4, 2.8, 2.4), aptCenter + V(-6, 1.4, -6), C.wood, M.Wood, { Name = "PellDesk" })
	local ledger = Build.part(parent, V(1.4, 0.3, 1), aptCenter + V(-6, 2.95, -6), rgb(120, 40, 40), M.Fabric, { Name = "Ledger" })
	Build.light(ledger, rgb(255, 230, 190), 6, 0.6)
	Build.interactable(ledger, "pell_ledger")
	local mailbox = Build.part(parent, V(1.6, 2, 0.8), aptCenter + V(9, 4, 12.6), rgb(150, 120, 60), M.Metal, { Name = "PellMailbox" })
	Build.interactable(mailbox, "pell_mailbox")
	Build.waypoint("M_PellDoor", aptCenter + V(0, 0, 16))
	Build.waypoint("Pell_Street", aptCenter + V(0, 0, 26), aptCenter + V(0, 0, 40))
	Build.part(parent, V(28, 90, 24), aptCenter + V(0, 14.6 + 45, 0), rgb(40, 38, 52), M.Glass, { Reflectance = 0.15 })
	Build.greenWall(parent, aptCenter + V(0, 40, 12.6), V(0, 0, 1), 18, 40)
	Build.planter(parent, c + V(-40, 0, 40), rng, false)
	Build.planter(parent, c + V(40, 0, -40), rng, false)
end

local function lowmarsh(parent, rng)
	local c = Layout.tile(3, 2, GFLOOR)
	-- Lowmarsh Apartments, Unit 4B: the Adeyemi letters.
	local center = V(c.X - 20, GFLOOR, c.Z + 14)
	local apt = Build.room(parent, {
		name = "Lowmarsh4B",
		center = center,
		size = V(40, 14, 28),
		color = rgb(200, 196, 190),
		material = M.Plaster,
		floorMaterial = M.WoodPlanks,
		doors = { E = { offset = 0, width = 6, height = 10 } },
	})
	Build.wall(apt, center + V(-2, 0, 0), "Z", 26, 14, 1, { offset = 6, width = 5, height = 9 }, rgb(170, 160, 160), M.Plaster)
	Build.part(apt, V(6, 3, 4), center + V(10, 1.5, -4), C.wood, M.Wood, { Name = "Table" })
	Build.note(apt, "apt_letter_1", center + V(10, 3.05, -4))
	Build.part(apt, V(8, 2.5, 3), center + V(12, 1.25, 8), rgb(70, 50, 60), M.Fabric, { Name = "Couch" })
	Build.part(apt, V(8, 2, 5), center + V(-14, 1, 8), rgb(90, 80, 100), M.Fabric, { Name = "Bed" })
	Build.note(apt, "apt_letter_2", center + V(-14, 2.05, 8))
	Build.part(apt, V(4, 3, 3), center + V(-12, 1.5, -10), C.wood, M.Wood, { Name = "KidsDesk" })
	Build.note(apt, "apt_drawing", center + V(-12, 3.05, -10), rgb(255, 240, 160))
	Build.ceilingLight(apt, center + V(10, 13.4, 0), rgb(200, 210, 255), 20, 0.6)
	Build.ceilingLight(apt, center + V(-12, 13.4, 0), rgb(200, 210, 255), 18, 0.4)
	Build.sign(parent, "LOWMARSH APTS · UNIT 4B", center + V(20.4, 11.5, 0), V(1, 0, 0), V(14, 2, 0.4), C.cyan)
	Build.part(parent, V(40, 80, 28), center + V(0, 14.6 + 40, 0), rgb(46, 44, 56), M.Glass, { Reflectance = 0.15 })

	-- Marigold's Menagerie (pet shop).
	local petCenter = V(c.X + 26, GFLOOR, c.Z - 22)
	Build.building(parent, {
		name = "MarigoldsMenagerie",
		center = petCenter,
		size = V(34, 14, 30),
		side = "N",
		kind = "florist",
		neon = rgb(255, 210, 90),
		wallColor = rgb(240, 230, 200),
		material = M.Plaster,
		sign = "MARIGOLD'S MENAGERIE",
		rng = rng,
	})
	for k = -1, 1 do
		local cage = Build.part(parent, V(4, 4, 4), petCenter + V(k * 7, 2, -8), rgb(200, 190, 150), M.Glass, { Transparency = 0.5 })
		Build.part(parent, V(1.2, 1, 1.8), cage.CFrame.Position + V(0, -1.2, 0), ({ rgb(140, 100, 60), rgb(40, 36, 40), rgb(230, 120, 60) })[k + 2], M.Fabric, { CanCollide = false })
	end
	Build.holo(parent, petCenter + V(0, 30, 16), V(0, 0, 1), V(24, 10, 0.2), rgb(255, 210, 90), "MARIGOLD'S\nMENAGERIE")
	Build.waypoint("Marigold_Shop", petCenter + V(0, 0, 3), petCenter + V(0, 0, 15))
	Build.waypoint("Marigold_Home", V(c.X + 30, GFLOOR, c.Z + 38), V(c.X + 30, GFLOOR, c.Z + 20))
	Build.waypoint("Res_Grid_B1", c + V(-40, 0, -40))
	Build.waypoint("Res_Grid_B2", c + V(40, 0, 40))
	Build.waypoint("Res_Grid_B3", c + V(-45, 0, 45))
	Build.planter(parent, c + V(45, 0, 45), rng, false)
end

local function meridian(parent, rng)
	local c = Layout.tile(6, 6, GFLOOR)
	Build.cylinder(parent, 0.3, 96, c + V(0, 0.15, 0), rgb(170, 172, 180), M.Pavement, { Name = "MeridianPlaza" })
	-- The Bloom Accord: a giant civic tree on a marble plinth.
	Build.cylinder(parent, 3, 22, c + V(0, 1.5, 0), rgb(220, 216, 206), M.Marble)
	Build.cylinder(parent, 30, 4, c + V(0, 18, 0), rgb(80, 60, 44), M.Wood)
	for k = 1, 6 do
		local p = c + V(math.cos(k) * 9, 32 + (k % 3) * 4, math.sin(k) * 9)
		Build.ball(parent, 16 + (k % 2) * 4, p, C.civic:Lerp(rgb(60, 160, 90), k / 6), M.Grass, { CanCollide = false, Tags = { "CivicPlant", "PlazaNeon" } })
	end
	for k = 1, 10 do
		local bud = c + V(math.cos(k * 2.1) * 12, 30 + (k % 4) * 4, math.sin(k * 2.1) * 12)
		Build.part(parent, V(1, 1, 1), bud, rgb(150, 255, 170), M.Neon, { CanCollide = false, Shape = Enum.PartType.Ball, Tags = { "PlazaNeon" } })
	end
	local glow = Build.part(parent, V(1, 1, 1), c + V(0, 30, 0), rgb(150, 255, 170), M.Neon, { CanCollide = false, Transparency = 1, Tags = { "PlazaNeon" } })
	Build.light(glow, rgb(150, 255, 170), 50, 1.8)
	local plaque = Build.sign(parent, "THE BLOOM ACCORD", c + V(0, 2.4, -11.4), V(0, 0, -1), V(8, 2, 0.5), C.amber, rgb(60, 44, 28))
	Build.interactable(plaque, "accord_plaque")
	local sign = Build.sign(parent, "CIVIC STRAIN V-7 · THESE PLANTS ARE SAFE", c + V(30, 3, -30), V(-1, 0, -1).Unit, V(16, 3, 0.4), C.civic, rgb(20, 40, 24))
	Build.interactable(sign, "civic_plaque")
	for k = 0, 7 do
		local a = k / 8 * math.pi * 2
		Build.planter(parent, c + V(math.cos(a) * 38, 0, math.sin(a) * 38), rng, k % 2 == 0)
	end
	for _, p in ipairs({ V(-24, 0, 24), V(24, 0, 24) }) do
		Build.cylinder(parent, 1.2, 10, c + p + V(0, 0.6, 0), rgb(220, 220, 230), M.Marble)
		Build.cylinder(parent, 0.3, 8.6, c + p + V(0, 1.3, 0), rgb(140, 210, 255), M.Glass, { Transparency = 0.4, CanCollide = false })
	end
	Build.holo(parent, c + V(-40, 30, 40), V(1, 0, -1).Unit, V(26, 12, 0.2), C.cyan, "14 YEARS OF LIGHT")
	Build.waypoint("CP_Grid", c + V(0, 0, -30), c)
	Build.waypoint("Res_Grid_A1", c + V(40, 0, 40))
	Build.waypoint("Res_Grid_A2", c + V(-40, 0, 40))
	Build.waypoint("Res_Grid_A3", c + V(-40, 0, -40))
	Build.waypoint("Res_Grid_A4", c + V(40, 0, -40))
	local zones = Build.folder(parent.Parent.Parent, "Zones")
	Build.zone(zones, "CP_Grid_Zone", c + V(0, 20, 0), V(100, 40, 100), { ZoneType = "Checkpoint", Checkpoint = "CP_Grid" })
end

return function(root)
	local folder = Build.folder(root, "Landmarks")
	local rng = Random.new(4242)
	market(Build.folder(folder, "LanternRow"), rng)
	drip(Build.folder(folder, "TheDrip"), rng)
	botshop(Build.folder(folder, "BotShop"), rng)
	gateSquare(Build.folder(folder, "GateSquare"), rng)
	staticTower(Build.folder(folder, "StaticTower"), rng)
	depot(Build.folder(folder, "AscentDepot"), rng)
	wick(Build.folder(folder, "TheWick"), rng)
	lowmarsh(Build.folder(folder, "Lowmarsh"), rng)
	meridian(Build.folder(folder, "Meridian"), rng)
end
