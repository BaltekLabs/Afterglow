--[[
	East of Veyra: the Overgrown Suburbs (ruined houses, scrap, the odd sleeper) and Rail's End,
	a village living in an old train yard. An abandoned railway runs from Rail's End back to a
	bricked-up rail gate in the city's east wall.
]]
local Build = require(script.Parent.Parent.Build)

local C, M, rgb = Build.Colors, Build.M, Build.rgb
local V = Vector3.new

local SUBURBS = V(1700, 0, 300)
local RAILS_END = V(2500, 0, -900)
local SOUTH_OUTFLOW = V(-192, 0, -805)

local PASTELS = { rgb(170, 150, 140), rgb(150, 160, 170), rgb(160, 170, 140), rgb(180, 160, 120), rgb(140, 140, 150) }

local function rails(parent, points)
	for i = 1, #points - 1 do
		local a, b = points[i], points[i + 1]
		local dir = (b - a).Unit
		local right = dir:Cross(V(0, 1, 0)).Unit
		local length = (b - a).Magnitude
		local pieces = math.ceil(length / 400)
		for k = 1, pieces do
			local p0, p1 = a:Lerp(b, (k - 1) / pieces), a:Lerp(b, k / pieces)
			for _, side in ipairs({ -2.2, 2.2 }) do
				Build.beam(parent, p0 + right * side + V(0, 0.4, 0), p1 + right * side + V(0, 0.4, 0), 0.4, 0.4, rgb(110, 80, 60), M.CorrodedMetal, { Name = "Rail" })
			end
		end
		for d = 0, length, 24 do
			local p = a + dir * d
			Build.part(parent, V(7, 0.3, 1.2), CFrame.lookAt(p + V(0, 0.15, 0), p + V(0, 0.15, 0) + right), rgb(70, 54, 40), M.Wood, { Name = "Sleeper" })
		end
	end
end

local function wagon(parent, position, facing, scrapId)
	local cf = CFrame.lookAt(position + V(0, 3.4, 0), position + V(0, 3.4, 0) + facing)
	local body = Build.part(parent, V(8, 5, 18), cf, rgb(110, 70, 50), M.CorrodedMetal, { Name = "Wagon" })
	for _, z in ipairs({ -6, 6 }) do
		for _, x in ipairs({ -3.6, 3.6 }) do
			Build.part(parent, V(1, 2.4, 2.4), cf * CFrame.new(x, -2.6, z), rgb(50, 46, 44), M.Metal, { Shape = Enum.PartType.Cylinder })
		end
	end
	Build.vines(parent, position, 6, Random.new(scrapId), 3)
	local coupler = Build.part(parent, V(1.6, 1.2, 1.6), cf * CFrame.new(0, -1.4, -9.6), rgb(140, 100, 60), M.CorrodedMetal, { Name = "Coupler" })
	Build.light(coupler, rgb(255, 200, 120), 6, 0.5)
	Build.interactable(coupler, "scrap_" .. scrapId)
	return body
end

local function suburbs(parent, zones, ctx, rng)
	local f = Build.folder(parent, "OvergrownSuburbs")
	Build.waypoint("M_Suburbs", SUBURBS)
	local n = 0
	for gx = -2, 2 do
		for gz = -3, 2 do
			local center = SUBURBS + V(gx * 75 + rng:NextNumber(-8, 8), 0, gz * 80 + rng:NextNumber(-8, 8))
			if rng:NextNumber() < 0.85 then
				n += 1
				local side = ({ "N", "S", "E", "W" })[rng:NextInteger(1, 4)]
				local _, spots = Build.building(f, {
					name = "House" .. n,
					center = center,
					size = V(rng:NextInteger(22, 30), 12, rng:NextInteger(20, 26)),
					side = side,
					kind = if rng:NextNumber() < 0.5 then "apartment" else "empty",
					neon = rgb(120, 110, 90),
					wallColor = PASTELS[rng:NextInteger(1, #PASTELS)],
					material = M.WoodPlanks,
					sign = "",
					light = false,
					rng = rng,
				})
				for _, spot in ipairs(spots) do
					table.insert(ctx.spots, { position = spot, locked = false, tier = "outlands" })
				end
				-- Overgrowth: wild trees bursting from yards, vines on the walls.
				if rng:NextNumber() < 0.55 then
					Build.glowTree(f, rng, center + V(rng:NextNumber(-18, 18), 0, if rng:NextNumber() < 0.5 then 18 else -18), rng:NextNumber(0.8, 1.3))
				else
					Build.deadTree(f, rng, center + V(rng:NextNumber(-18, 18), 0, 17))
				end
				Build.vines(f, center, 12, rng, 3)
				if n == 7 then
					Build.note(f, "suburbs_diary", center + V(0, 0.5, 0))
				end
				-- Fence stubs.
				for k = -2, 2 do
					Build.part(f, V(1, 3, 1), center + V(k * 6, 1.5, 20), rgb(150, 140, 120), M.Wood)
				end
			end
		end
	end
	-- A rusted rail spur through the suburbs with three wagons to strip.
	local spur = { RAILS_END + V(-300, 0, 500), SUBURBS + V(80, 0, -80), SUBURBS + V(120, 0, 250) }
	rails(f, spur)
	wagon(f, spur[1]:Lerp(spur[2], 0.4), (spur[2] - spur[1]).Unit, 1)
	wagon(f, spur[2], (spur[3] - spur[2]).Unit, 2)
	wagon(f, spur[2]:Lerp(spur[3], 0.7), (spur[3] - spur[2]).Unit, 3)
	-- The suburbs' sleeper, standing where its garden swallowed it.
	Build.rooted(f, SUBURBS + V(-70, 0, 120), V(1, 0, 0), "Rooted_Suburbs")
	Build.zone(zones, "Region_Suburbs", SUBURBS, V(520, 0, 620), { ZoneType = "Region", Region = "suburbs", Priority = 2, Outside = true })
end

local function railsEnd(parent, zones, rng)
	local f = Build.folder(parent, "RailsEnd")
	local c = RAILS_END
	-- Main line through the yard and on toward the city's east wall.
	rails(f, { c + V(200, 0, 0), c, c + V(-600, 0, 100), V(1200, 0, -400), V(680, 0, -220) })
	rails(f, { c + V(150, 0, 30), c + V(-150, 0, 30) })
	-- Station building.
	Build.building(f, {
		name = "Station",
		center = c + V(0, 0, -40),
		size = V(44, 16, 24),
		side = "N",
		kind = "cafe",
		neon = C.amber,
		wallColor = rgb(150, 100, 80),
		material = M.Brick,
		sign = "RAIL'S END",
		rng = rng,
	})
	local board = Build.part(f, V(10, 6, 0.4), CFrame.lookAt(c + V(16, 6, -27.6), c + V(16, 6, 0)), rgb(20, 22, 20), M.Slate, { Name = "DeparturesBoard" })
	Build.screen(board, "DEPARTURES\nVEYRA: CANCELLED\nANYWHERE: SOON", rgb(255, 230, 160))
	Build.interactable(board, "railsend_board")
	-- Carriages people live in.
	for k = 0, 5 do
		local center = c + V(-130 + k * 34, 0.3, 46)
		Build.building(f, {
			name = "Carriage" .. k,
			center = center,
			size = V(12, 10, 28),
			side = "W",
			kind = if k == 2 then "shop" else "apartment",
			neon = ({ C.amber, C.cyan, rgb(255, 120, 200) })[k % 3 + 1],
			wallColor = ({ rgb(120, 40, 40), rgb(40, 70, 110), rgb(60, 90, 60) })[k % 3 + 1],
			material = M.Metal,
			sign = if k == 2 then "ILSA'S" else "",
			rng = rng,
		})
		for _, z in ipairs({ -9, 9 }) do
			Build.part(f, V(13, 1.6, 1.6), center + V(0, -0.2, z), rgb(40, 40, 40), M.Metal, { Shape = Enum.PartType.Cylinder })
		end
	end
	Build.waypoint("Ilsa_Car", c + V(-62 - 1, 0.3, 46), c + V(-80, 0, 46))
	Build.waypoint("Dunmore_Car", c + V(-130, 0.3, 46))
	-- The locomotive Dunmore is rebuilding.
	local loco = c + V(80, 0, 0)
	Build.part(f, V(10, 4, 34), loco + V(0, 2.5, 0), rgb(30, 30, 34), M.Metal, { Name = "LocoFrame" })
	Build.part(f, V(8, 8, 22), CFrame.new(loco + V(0, 8.5, 4)) * CFrame.Angles(0, math.rad(90), 0), rgb(40, 50, 60), M.Metal, { Shape = Enum.PartType.Cylinder, Name = "Boiler" })
	Build.part(f, V(10, 10, 9), loco + V(0, 9.5, -12), rgb(120, 40, 30), M.Metal, { Name = "Cab" })
	Build.cylinder(f, 6, 2.4, loco + V(0, 15, 12), rgb(30, 30, 34), M.Metal)
	local lamp = Build.part(f, V(2, 2, 0.5), loco + V(0, 8.5, 17.4), rgb(255, 230, 160), M.Neon, { CanCollide = false })
	Build.light(lamp, rgb(255, 230, 160), 40, 1.5, true)
	Build.waypoint("Dunmore_Yard", loco + V(-9, 0, 0), loco)
	-- Water tower and a fire.
	Build.cylinder(f, 10, 12, c + V(-40, 22, -10), rgb(110, 80, 60), M.WoodPlanks)
	for _, p in ipairs({ V(-45, 0, -15), V(-35, 0, -15), V(-45, 0, -5), V(-35, 0, -5) }) do
		Build.cylinder(f, 17, 1, c + p + V(0, 8.5, 0), rgb(80, 60, 44), M.Wood)
	end
	local fire = Build.part(f, V(2, 2, 2), c + V(-10, 1.2, 10), rgb(255, 140, 50), M.Neon, { CanCollide = false })
	Build.light(fire, rgb(255, 150, 70), 40, 1.8, true)
	for k = 1, 4 do
		Build.planter(f, c + V(-100 + k * 30, 0.3, 75), rng, false)
	end
	Build.waypoint("CP_RailsEnd", c + V(-10, 0.3, 20), c)
	Build.waypoint("Res_Rails_1", c + V(-120, 0.3, 20))
	Build.waypoint("Res_Rails_2", c + V(40, 0.3, 20))
	Build.zone(zones, "Region_RailsEnd", c, V(420, 0, 300), { ZoneType = "Region", Region = "railsend", Priority = 3, Outside = true })
	Build.zone(zones, "CP_RailsEnd_Zone", c, V(200, 0, 160), { ZoneType = "Checkpoint", Checkpoint = "CP_RailsEnd" })
	-- Bricked-up rail gate where the line meets the city's east wall.
	Build.part(f, V(4, 40, 30), V(672, 20, -220), rgb(90, 60, 50), M.Brick, { Name = "BrickedRailGate" })
end

return function(root, ctx)
	local folder = Build.folder(root, "EastOutlands")
	local zones = Build.folder(root, "Zones")
	local rng = Random.new(303)
	Build.trail(folder, { SOUTH_OUTFLOW, V(600, 0, -1000), V(1500, 0, -950), RAILS_END + V(-160, 0, 0) }, 9)
	Build.trail(folder, { RAILS_END + V(-50, 0, 80), V(2000, 0, -300), SUBURBS + V(0, 0, -260) }, 8)
	-- Scattered dead farmland trees between.
	for _ = 1, 90 do
		local p = V(rng:NextNumber(800, 3000), 0, rng:NextNumber(-1500, 1300))
		if (p - SUBURBS).Magnitude > 330 and (p - RAILS_END).Magnitude > 260 then
			if rng:NextNumber() < 0.6 then
				Build.deadTree(folder, rng, p)
			else
				Build.glowTree(folder, rng, p, rng:NextNumber(0.8, 1.3))
			end
		end
	end
	suburbs(folder, zones, ctx, rng)
	railsEnd(folder, zones, rng)
end
