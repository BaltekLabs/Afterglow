-- The Dead Zone: Halvorsen BioResearch Station, far north of Veyra, where the broadcast comes from.
local Build = require(script.Parent.Parent.Build)

local C, M, rgb = Build.Colors, Build.M, Build.rgb
local V = Vector3.new

local ORIGIN = V(700, 0, 2750) -- station floor center

-- Station-local coordinates: x across, z from 550 (yard gate) to 700 (back fence); 640 = center.
local function P(x, y, z)
	return ORIGIN + V(x, y, z - 640)
end

return function(root)
	local folder = Build.folder(root, "DeadZone")
	local zones = Build.folder(root, "Zones")
	local rng = Random.new(31)

	Build.part(folder, V(14, 0.2, 60), P(0, 0.1, 575), rgb(34, 34, 36), M.Asphalt, { Name = "Road" })
	for _ = 1, 30 do
		local p = ORIGIN + V(rng:NextNumber(-330, 330), 0, rng:NextNumber(-320, 320))
		local local_ = p - ORIGIN
		if not (math.abs(local_.X) < 100 and local_.Z > -100 and local_.Z < 70) then
			local s = V(rng:NextNumber(2, 7), rng:NextNumber(1, 4), rng:NextNumber(2, 7))
			Build.part(folder, s, CFrame.new(p + V(0, s.Y / 2, 0)) * CFrame.Angles(0, rng:NextNumber(0, 6), 0), rgb(60, 60, 58), M.Concrete)
		end
	end
	for _, p in ipairs({ P(-30, 0, 570), P(52, 0, 596), P(-58, 0, 640) }) do
		Build.part(folder, V(6, 3.2, 11), CFrame.new(p + V(0, 1.6, 0)) * CFrame.Angles(0, rng:NextNumber(0, 3), 0), rgb(70, 60, 50), M.CorrodedMetal, { Name = "Wreck" })
	end

	-- Perimeter fence with a gate gap on the south side.
	local fence = rgb(66, 66, 62)
	Build.wall(folder, P(0, 0, 550), "X", 180, 12, 1, { offset = 0, width = 20, height = 12 }, fence, M.CorrodedMetal)
	Build.wall(folder, P(0, 0, 700), "X", 180, 12, 1, nil, fence, M.CorrodedMetal)
	Build.wall(folder, P(-90, 0, 625), "Z", 150, 12, 1, nil, fence, M.CorrodedMetal)
	Build.wall(folder, P(90, 0, 625), "Z", 150, 12, 1, nil, fence, M.CorrodedMetal)
	Build.sign(folder, "HALVORSEN BIORESEARCH — AUTHORIZED STAFF ONLY", P(-30, 9, 549.4), V(0, 0, -1), V(36, 3, 0.3), C.danger)
	Build.waypoint("M_StationGate", P(0, 0, 548))
	Build.waypoint("CP_Station", P(0, 0, 535), P(0, 0, 600))
	Build.zone(zones, "CP_Station_Zone", P(0, 0, 535), V(50, 0, 24), { ZoneType = "Checkpoint", Checkpoint = "CP_Station" })

	-- Gatehouse with the keycard.
	local gatehouse = Build.room(folder, {
		name = "Gatehouse",
		center = P(55, 0, 575),
		size = V(14, 11, 12),
		color = rgb(80, 82, 80),
		material = M.Concrete,
		doors = { W = { offset = 0, width = 5, height = 8 } },
	})
	local locker = Build.part(gatehouse, V(2, 7, 2), P(60.5, 3.5, 578), rgb(70, 80, 90), M.Metal, { Name = "Locker" })
	Build.interactable(locker, "gatehouse_locker")
	Build.ceilingLight(gatehouse, P(55, 10.4, 575), rgb(200, 255, 230), 14, 0.5, { "Flicker" })

	-- One sleeper in the yard, by the gatehouse door. Rare, but it only takes one.
	Build.rooted(folder, P(42, 0, 570), V(1, 0, 0.5), "Rooted_Yard")
	for _ = 1, 6 do
		local a = P(rng:NextNumber(-80, 80), 0.15, rng:NextNumber(560, 600))
		Build.beam(folder, a, a + V(rng:NextNumber(-20, 20), 0, rng:NextNumber(-10, 10)), 0.4, 0.2, C.vesper, M.Neon, { CanCollide = false, Tags = { "Vesper" } })
	end

	-- Station building (footprint 100 x 70).
	local station = Build.room(folder, {
		name = "HalvorsenStation",
		center = P(0, 0, 640),
		size = V(100, 22, 70),
		color = rgb(150, 156, 150),
		material = M.Concrete,
		floorColor = rgb(70, 74, 72),
		floorMaterial = M.Concrete,
		roofColor = rgb(90, 94, 90),
		doors = { S = { offset = 0, width = 10, height = 12 } },
	})
	Build.sign(folder, "HALVORSEN BIORESEARCH STATION", P(0, 17, 604.4), V(0, 0, -1), V(44, 4, 0.4), C.vesper, rgb(20, 24, 22))
	Build.part(station, V(10, 12, 1), P(0, 6, 605.5), rgb(90, 96, 100), M.DiamondPlate, { Name = "StationDoor", Tags = { "StationDoor" } })
	Build.part(station, V(10, 0.5, 1.2), P(0, 9, 605.5), C.danger, M.Neon, { CanCollide = false, Tags = { "StationDoor" } })
	local panel = Build.part(folder, V(1.4, 2, 0.4), P(8, 3.6, 604.3), rgb(40, 44, 50), M.Metal, { Name = "DoorPanel" })
	Build.screen(panel, "INSERT\nKEYCARD", C.danger)
	Build.interactable(panel, "station_door_panel")
	Build.waypoint("M_StationDoor", P(0, 0, 600))
	local vent = Build.part(folder, V(4, 3, 0.6), P(-44, 2, 604.4), rgb(60, 64, 62), M.Metal, { Name = "Vent" })
	for i = -1, 1 do
		Build.part(folder, V(3.6, 0.2, 0.2), P(-44, 2 + i * 0.8, 604), rgb(40, 42, 40), M.Metal)
	end
	Build.interactable(vent, "station_vent")

	-- Interior partitions: lobby (south), Lab A / corridor / Lab B, relay room (north).
	local wallColor = rgb(176, 182, 176)
	Build.wall(station, P(0, 0, 630), "X", 98, 22, 1, {
		{ offset = -32, width = 6, height = 10 },
		{ offset = 0, width = 8, height = 10 },
		{ offset = 32, width = 6, height = 10 },
	}, wallColor, M.Plaster)
	Build.wall(station, P(-15, 0, 642.5), "Z", 24, 22, 1, nil, wallColor, M.Plaster)
	Build.wall(station, P(15, 0, 642.5), "Z", 24, 22, 1, nil, wallColor, M.Plaster)
	Build.wall(station, P(0, 0, 655), "X", 98, 22, 1, { offset = 0, width = 8, height = 10 }, wallColor, M.Plaster)
	Build.waypoint("Station_Lobby", P(0, 0, 614), P(0, 0, 630))

	-- Lobby.
	Build.part(station, V(14, 3.5, 3), P(-18, 1.75, 620), rgb(90, 90, 96), M.Metal, { Name = "Reception" })
	Build.terminal(station, "term_lobby", P(-26, 0.4, 621), V(0, 0, -1), "SECURITY\nINCIDENTS: 32")
	Build.ceilingLight(station, P(-20, 21.4, 617), rgb(200, 255, 230), 30, 0.6, { "Flicker" })
	Build.ceilingLight(station, P(20, 21.4, 617), rgb(200, 255, 230), 30, 0.4)

	-- Lab A (Renn's old station).
	for i = 0, 1 do
		Build.part(station, V(14, 3.2, 3), P(-33, 1.6, 637 + i * 9), rgb(200, 204, 210), M.SmoothPlastic, { Name = "Bench" })
	end
	Build.terminal(station, "term_lab_a", P(-44, 0.4, 652), V(0, 0, -1), "STAFF LOGIN\n> _")
	Build.ceilingLight(station, P(-32, 21.4, 642), rgb(180, 220, 255), 24, 0.5, { "Flicker" })

	-- Lab B (Project LANTERN, Kemi's locker, and the station's other sleeper).
	for i = 0, 3 do
		Build.part(station, V(2, 7, 2), P(47.8, 3.5, 634 + i * 2.4), rgb(70, 80, 90), M.Metal, { Name = "Locker" })
	end
	local kemiLocker = Build.part(station, V(2, 7, 2), P(47.8, 3.5, 643.6), rgb(90, 80, 70), M.Metal, { Name = "KemiLocker" })
	Build.light(kemiLocker, rgb(255, 230, 190), 6, 0.6)
	Build.interactable(kemiLocker, "station_letter")
	Build.terminal(station, "term_lab_b", P(24, 0.4, 652), V(0, 0, -1), "PROJECT LANTERN\nPHASE II")
	Build.part(station, V(8, 4, 8), P(30, 2, 640), rgb(60, 70, 66), M.Glass, { Transparency = 0.4, Name = "Chamber" })
	Build.ball(station, 3.2, P(30, 3, 640), C.vesper, M.Neon, { CanCollide = false, Transparency = 0.3, Tags = { "Vesper" } })
	Build.ceilingLight(station, P(32, 21.4, 642), rgb(180, 255, 220), 24, 0.5)
	Build.rooted(station, P(40, 0, 636), V(-1, 0, 0.2), "Rooted_LabB")

	-- Relay room.
	local relay = Build.folder(station, "Relay")
	Build.part(relay, V(10, 2, 8), P(0, 1, 667), rgb(60, 64, 70), M.DiamondPlate, { Name = "TransmitterBase" })
	Build.cylinder(relay, 14, 4, P(0, 9, 667), rgb(80, 84, 92), M.Metal, { Name = "Coil" })
	for y = 4, 15, 2.5 do
		Build.cylinder(relay, 0.4, 4.6, P(0, y, 667), C.vesper, M.Neon, { CanCollide = false, Tags = { "RelayRoots" } })
	end
	Build.cylinder(relay, 30, 1, P(0, 30, 667), C.metal, M.Metal, { Name = "Mast" })
	local beacon = Build.part(relay, V(1.6, 1.6, 1.6), P(0, 45.5, 667), C.danger, M.Neon, { CanCollide = false })
	beacon:SetAttribute("Blink", true)
	Build.light(beacon, C.danger, 40, 2)
	local console = Build.part(relay, V(6, 3.5, 2), P(0, 1.75, 661), rgb(50, 54, 60), M.Metal, { Name = "Console" })
	local screen = Build.part(relay, V(5, 2, 0.2), CFrame.lookAt(P(0, 4.6, 660.4), P(0, 4.6, 650)), rgb(5, 15, 12), M.SmoothPlastic)
	Build.screen(screen, "RELAY ACTIVE\nCALLING: W. HOLLIS", C.vesper)
	Build.interactable(console, "relay_transmitter")
	Build.waypoint("M_Transmitter", P(0, 0, 659))
	for i = 1, 14 do
		local a = i / 14 * math.pi * 2
		local from = P(0, 2, 667)
		local to = P(math.cos(a) * rng:NextNumber(14, 40), rng:NextNumber(0.2, 14), 667 + math.sin(a) * rng:NextNumber(4, 8))
		Build.beam(relay, from, to, 0.6, 0.6, C.vesper, M.Neon, { CanCollide = false, Tags = { "RelayRoots", "Vesper" } })
	end
	Build.part(relay, V(6, 3, 3), P(-22, 1.5, 664), rgb(90, 90, 96), M.Metal, { Name = "Desk" })
	Build.note(relay, "relay_note", P(-22, 3.05, 664))
	local glow = Build.part(relay, V(1, 1, 1), P(0, 10, 664), C.vesper, M.Neon, { CanCollide = false, Transparency = 1, Tags = { "RelayRoots" } })
	Build.light(glow, C.vesper, 40, 2.2)

	Build.zone(zones, "Region_DeadZone", ORIGIN, V(900, 0, 700), { ZoneType = "Region", Region = "deadzone", Priority = 2, Outside = true })
end
