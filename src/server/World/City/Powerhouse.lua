--[[
	The Powerhouse: an armored cylinder rising from the Rust through every tier, where the
	Council keeps the wild Mother Strain caged in light to power the city. Turrets cover the
	perimeter; Enforcers patrol the barricades. A maintenance hatch on the south face leads in.
]]
local Build = require(script.Parent.Parent.Build)
local Layout = require(script.Parent.Layout)

local C, M, rgb = Build.Colors, Build.M, Build.rgb
local V = Vector3.new

local R = Layout.PH_RADIUS
local TOP = Layout.PH_TOP
local SEGMENTS = 24

local function ring(parent, radius, y, height, thickness, color, material, props)
	for k = 0, SEGMENTS - 1 do
		local a = (k + 0.5) / SEGMENTS * math.pi * 2
		local radial = V(math.cos(a), 0, math.sin(a))
		local pos = radial * radius + V(0, y, 0)
		local width = 2 * math.pi * (radius + thickness / 2) / SEGMENTS + 0.6
		Build.part(parent, V(width, height, thickness), CFrame.lookAt(pos, pos + radial), color, material, props and table.clone(props))
	end
end

return function(root)
	local folder = Build.folder(root, "Powerhouse")
	local rng = Random.new(9)
	local hull = rgb(58, 62, 72)

	-- Hull: hollow, so the core chamber inside is real space.
	ring(folder, R, TOP / 2, TOP, 8, hull, M.DiamondPlate)
	for _, y in ipairs({ 40, 120, 200, 280 }) do
		ring(folder, R + 4.2, y, 2, 0.6, C.danger, M.Neon, { CanCollide = false })
	end
	for k = 0, 7 do
		local a = k / 8 * math.pi * 2
		local radial = V(math.cos(a), 0, math.sin(a))
		Build.part(folder, V(6, TOP, 6), CFrame.lookAt(radial * (R + 6), radial * (R + 7)) + V(0, TOP / 2, 0), rgb(40, 42, 50), M.Metal, { Name = "Rib" })
	end
	-- Roof cap and the glowing dome the Crown circles around.
	Build.cylinder(folder, 4, R * 2 + 10, V(0, TOP + 2, 0), hull, M.DiamondPlate)
	local dome = Build.ball(folder, R * 1.4, V(0, TOP + 4, 0), C.vesper, M.Neon, { Transparency = 0.45, CanCollide = false, Name = "Dome" })
	Build.light(dome, C.vesper, 60, 3)
	Build.cylinder(folder, 400, 6, V(0, TOP + 200, 0), C.vesper, M.ForceField, { CanCollide = false, Transparency = 0.6, Name = "LightColumn" })
	Build.sign(folder, "POWERHOUSE · AUTHORIZED PERSONNEL ONLY", V(0, 30, -(R + 4.6)), V(0, 0, -1), V(50, 5, 0.4), C.danger)

	-- Core chamber: the Mother Strain in a glass cage of light.
	local core = Build.folder(folder, "Core")
	Build.cylinder(core, 0.6, R * 2 - 8, V(0, 0.3, 0), rgb(30, 32, 38), M.DiamondPlate, { Name = "CoreFloor" })
	Build.cylinder(core, 320, 34, V(0, 160, 0), rgb(150, 255, 210), M.Glass, { Transparency = 0.7, Name = "Cage" })
	Build.cylinder(core, 300, 12, V(0, 150, 0), C.vesper, M.Neon, { Name = "MotherStrain", Tags = { "Vesper" } })
	for i = 1, 10 do
		local y = 30 + i * 26
		Build.ball(core, rng:NextNumber(16, 26), V(rng:NextNumber(-4, 4), y, rng:NextNumber(-4, 4)), C.vesper:Lerp(C.violet, rng:NextNumber()), M.Neon, {
			Transparency = 0.4,
			CanCollide = false,
			Tags = { "Vesper" },
		})
	end
	for i = 1, 18 do
		local a = i / 18 * math.pi * 2
		local to = V(math.cos(a) * rng:NextNumber(30, 80), 0.6, math.sin(a) * rng:NextNumber(30, 80))
		Build.beam(core, V(0, 1, 0), to, 1.4, 1, C.vesper, M.Neon, { CanCollide = false, Tags = { "Vesper" } })
	end
	for _, y in ipairs({ 30, 110, 190 }) do
		local lamp = Build.part(core, V(2, 2, 2), V(0, y, -40), C.vesper, M.Neon, { CanCollide = false, Transparency = 1 })
		Build.light(lamp, C.vesper, 60, 2)
	end
	Build.terminal(core, "powerhouse_log", V(-24, 0.6, -60), V(0, 0, -1), "CORE OUTPUT\n104%")
	Build.terminal(core, "powerhouse_order", V(24, 0.6, -60), V(0, 0, -1), "COUNCIL\nENCRYPTED")
	local exit = Build.part(core, V(4, 6, 1), V(0, 3.6, -(R - 4.6)), rgb(60, 64, 72), M.Metal, { Name = "HatchInside" })
	Build.interactable(exit, "powerhouse_exit")
	Build.waypoint("PH_Inside", V(0, 0.6, -(R - 12)), V(0, 0.6, 0))

	-- Maintenance hatch on the south face.
	local hatch = Build.part(folder, V(5, 7, 1), V(0, 3.5, -(R + 4.6)), rgb(80, 70, 50), M.DiamondPlate, { Name = "MaintenanceHatch" })
	Build.part(folder, V(5.4, 0.4, 1.2), V(0, 7.2, -(R + 4.6)), C.amber, M.Neon, { CanCollide = false })
	Build.interactable(hatch, "powerhouse_hatch")
	Build.waypoint("PH_Outside", V(0, 0.3, -(R + 12)), V(0, 0, -200))

	-- Rust-level compound: barricades with checkpoint gaps, floodlights, turrets.
	local compound = Build.folder(folder, "Compound")
	local B = 124
	for _, side in ipairs({ { V(0, 0, B), "X" }, { V(0, 0, -B), "X" }, { V(B, 0, 0), "Z" }, { V(-B, 0, 0), "Z" } }) do
		Build.wall(compound, side[1], side[2], B * 2, 10, 2, { offset = 0, width = 14, height = 10 }, rgb(70, 70, 66), M.Concrete)
		Build.part(compound, if side[2] == "X" then V(B * 2, 0.6, 2.2) else V(2.2, 0.6, B * 2), side[1] + V(0, 10.2, 0), rgb(255, 200, 40), M.Neon, { CanCollide = false })
	end
	for _, p in ipairs({ V(B, 0, B), V(-B, 0, B), V(B, 0, -B), V(-B, 0, -B) }) do
		Build.part(compound, V(10, 24, 10), p + V(0, 12, 0), rgb(50, 52, 58), M.Concrete, { Name = "GuardTower" })
		local flood = Build.part(compound, V(3, 1.5, 3), p + V(0, 25, 0), rgb(255, 250, 230), M.Neon, { CanCollide = false })
		Build.light(flood, rgb(255, 245, 220), 70, 2, true)
		Build.turret(compound, p + V(0, 24.5, 0), (V(0, 0, 0) - p).Unit)
	end
	Build.sign(compound, "STOP · POWERHOUSE PERIMETER · TURRETS ACTIVE", V(0, 13, -B - 1.2), V(0, 0, -1), V(36, 3, 0.3), C.danger)

	-- Turrets mounted on the hull at Rust level and at the Grid bridges.
	for k = 0, 3 do
		local a = (k + 0.5) / 4 * math.pi * 2
		local radial = V(math.cos(a), 0, math.sin(a))
		Build.turret(compound, radial * (R + 9) + V(0, 18, 0), radial)
		Build.turret(compound, radial * (R + 9) + V(0, Layout.DECK_Y + 10, 0), radial)
	end

	-- Security bridges from the Grid deck to sealed blast doors on the hull.
	for _, dir in ipairs({ V(1, 0, 0), V(-1, 0, 0), V(0, 0, 1), V(0, 0, -1) }) do
		local from = dir * (R + 4) + V(0, Layout.DECK_Y - 1, 0)
		local to = dir * 130 + V(0, Layout.DECK_Y - 1, 0)
		Build.beam(compound, from, to, 14, 2, rgb(60, 62, 70), M.DiamondPlate, { Name = "Bridge" })
		local door = dir * (R + 4.4) + V(0, Layout.DECK_Y + 7, 0)
		Build.part(compound, V(12, 14, 1), CFrame.lookAt(door, door + dir), rgb(90, 40, 40), M.DiamondPlate, { Name = "BlastDoor" })
		local barrier = dir * 124 + V(0, Layout.DECK_Y + 2, 0)
		Build.part(compound, V(14, 4, 1), CFrame.lookAt(barrier, barrier + dir), rgb(255, 200, 40), M.Metal, { Name = "Barrier" })
	end

	for i, p in ipairs({ V(-110, 0, -110), V(110, 0, -110), V(110, 0, 110), V(-110, 0, 110) }) do
		Build.waypoint("Enf_PH_" .. i, p + V(0, 0.3, 0) + (p.Unit * -0) + V(math.sign(p.X) * 22, 0, math.sign(p.Z) * 22))
	end

	local zones = Build.folder(root, "Zones")
	-- Lethal zone: inside the barricades at Rust level, and the pit around the hull up to the Crown.
	Build.zone(zones, "Powerhouse_Lethal", V(0, 100, 0), V(240, 210, 240), { ZoneType = "Lethal" })
end
