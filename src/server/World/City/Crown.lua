--[[
	The Crown: a ring-shaped platform at y = 330 encircling the glowing Powerhouse dome, where
	the rich and the Council live. Reached by the Crown Lift (east sky road). Mansions can be
	explored; some are locked. The Council Spire stands on the north side.
]]
local Build = require(script.Parent.Parent.Build)
local Layout = require(script.Parent.Layout)

local M, rgb = Build.M, Build.rgb
local V = Vector3.new

local Y = Layout.CROWN_Y
local GOLD = rgb(255, 224, 138)
local MID = (Layout.CROWN_INNER + Layout.CROWN_OUTER) / 2

local function polar(angleDeg, radius, y)
	local a = math.rad(angleDeg)
	return V(math.cos(a) * radius, y or Y, math.sin(a) * radius)
end

return function(root, ctx)
	local folder = Build.folder(root, "Crown")
	local rng = Random.new(777)

	-- The ring deck.
	local segments = 28
	local width = Layout.CROWN_OUTER - Layout.CROWN_INNER
	for k = 0, segments - 1 do
		local a = (k + 0.5) / segments * 360
		local pos = polar(a, MID, Y - 3)
		local radial = (pos * V(1, 0, 1)).Unit
		local arc = 2 * math.pi * Layout.CROWN_OUTER / segments + 2
		Build.part(folder, V(arc, 6, width), CFrame.lookAt(pos, pos + radial), rgb(232, 228, 216), M.Marble, { Name = "CrownDeck" })
		local edge = polar(a, Layout.CROWN_OUTER - 1, Y + 1.5)
		Build.part(folder, V(arc, 3, 0.6), CFrame.lookAt(edge, edge + radial), rgb(200, 220, 240), M.Glass, { Transparency = 0.5 })
		Build.part(folder, V(arc, 0.3, 0.4), CFrame.lookAt(edge + V(0, 1.7, 0), edge + V(0, 1.7, 0) + radial), GOLD, M.Neon, { CanCollide = false })
		local inner = polar(a, Layout.CROWN_INNER + 1, Y + 1.5)
		Build.part(folder, V(2 * math.pi * Layout.CROWN_INNER / segments + 2, 3, 0.6), CFrame.lookAt(inner, inner + radial), rgb(200, 220, 240), M.Glass, { Transparency = 0.5 })
	end
	-- Underside glow and pylons down to the Grid.
	for k = 0, 7 do
		local p = polar(k * 45 + 22.5, MID, 0)
		Build.cylinder(folder, Y - 6 - Layout.DECK_Y, 16, V(p.X, (Y - 6 + Layout.DECK_Y) / 2, p.Z), rgb(220, 210, 180), M.Marble, { Name = "CrownPylon" })
		local glow = Build.part(folder, V(4, 1, 4), V(p.X, Y - 6.5, p.Z), GOLD, M.Neon, { CanCollide = false })
		Build.light(glow, GOLD, 60, 1.5)
	end

	-- Crown Landing (east, at the lift).
	Build.waypoint("CP_Crown", polar(0, 225, Y + 0.3), V(0, Y, 0))
	Build.sign(folder, "WELCOME TO THE CROWN", polar(0, 200, Y + 10), V(1, 0, 0), V(26, 4, 0.4), GOLD, rgb(30, 26, 20))
	local zones = Build.folder(root, "Zones")
	Build.zone(zones, "CP_Crown_Zone", polar(0, 215, Y + 10), V(50, 40, 50), { ZoneType = "Checkpoint", Checkpoint = "CP_Crown" })

	-- Council Spire (north).
	local spirePos = polar(90, MID, Y)
	local spire = Build.room(folder, {
		name = "CouncilSpire",
		center = spirePos,
		size = V(46, 22, 46),
		color = rgb(240, 236, 226),
		material = M.Marble,
		floorMaterial = M.Marble,
		floorColor = rgb(200, 190, 170),
		doors = { S = { offset = 0, width = 10, height = 14 } },
	})
	Build.part(spire, V(20, 3, 6), spirePos + V(0, 1.5, 12), rgb(120, 90, 60), M.Wood, { Name = "CouncilTable" })
	Build.part(spire, V(14, 10, 0.3), spirePos + V(0, 10, 22.4), GOLD, M.Neon, { CanCollide = false, Transparency = 0.5 })
	Build.ceilingLight(spire, spirePos + V(0, 21.4, 0), rgb(255, 240, 210), 40, 1.2)
	Build.cylinder(folder, 180, 14, spirePos + V(0, 22 + 90, 0), rgb(240, 236, 226), M.Marble, { Name = "Spire" })
	local beacon = Build.ball(folder, 8, spirePos + V(0, 22 + 184, 0), GOLD, M.Neon, { CanCollide = false })
	Build.light(beacon, GOLD, 80, 2)
	Build.sign(folder, "COUNCIL OF VEYRA", spirePos + V(0, 18, -23.4), V(0, 0, -1), V(26, 3.5, 0.4), GOLD, rgb(30, 26, 20))
	Build.waypoint("Hale_Hall", spirePos + V(0, 0.4, 6), spirePos + V(0, 0, -20))

	-- Mansions around the ring.
	local mansionAngles = { 30, 60, 130, 165, 200, 240, 280, 320 }
	for n, angle in ipairs(mansionAngles) do
		local pos = polar(angle, MID + rng:NextNumber(-20, 20), Y)
		local toCenter = -(pos * V(1, 0, 1)).Unit
		local side
		if math.abs(toCenter.X) > math.abs(toCenter.Z) then
			side = if toCenter.X > 0 then "E" else "W"
		else
			side = if toCenter.Z > 0 then "N" else "S"
		end
		local locked = n % 3 == 0
		local _, spots = Build.building(folder, {
			name = "Mansion" .. n,
			center = pos,
			size = V(34, 18, 30),
			side = side,
			kind = "mansion",
			neon = GOLD,
			wallColor = rgb(246, 242, 232),
			material = M.Marble,
			floorMaterial = M.Marble,
			floorColor = rgb(210, 200, 180),
			sign = "",
			closed = if locked then { Mode = "locked", Hackable = true, Pickable = true } else nil,
			light = true,
			rng = rng,
		})
		for _, spot in ipairs(spots) do
			table.insert(ctx.spots, { position = spot, locked = locked, tier = "crown" })
		end
		if n == 2 then
			Build.note(folder, "crown_invite", pos + V(0, 2.65, 0), GOLD)
		end
		-- Gardens: hedges and civic trees.
		for _ = 1, 3 do
			Build.planter(folder, pos + V(rng:NextNumber(-30, 30), 0, rng:NextNumber(-30, 30)) * V(1, 0, 1) + V(0, Y - pos.Y, 0), rng, true)
		end
		Build.part(folder, V(20, 2.4, 2), pos + V(0, 1.2, 0) + toCenter * -22, rgb(60, 130, 70), M.Grass, { Name = "Hedge" })
	end

	-- Fountains and lamps along the promenade.
	for k = 0, 11 do
		local p = polar(k * 30 + 15, MID, Y)
		Build.cylinder(folder, 1.2, 10, p + V(0, 0.6, 0), rgb(220, 220, 230), M.Marble)
		Build.cylinder(folder, 0.3, 8.6, p + V(0, 1.3, 0), rgb(140, 210, 255), M.Glass, { Transparency = 0.4, CanCollide = false })
		local lamp = Build.part(folder, V(1, 0.6, 1), p + V(0, 9, 0), GOLD, M.Neon, { CanCollide = false })
		Build.cylinder(folder, 8.6, 0.4, p + V(0, 4.5, 0), GOLD, M.Metal)
		if k % 2 == 0 then
			Build.light(lamp, GOLD, 30, 1.2)
		end
	end
	Build.holo(folder, polar(180, MID, Y + 40), V(1, 0, 0), V(40, 18, 0.2), GOLD, "THE FOURTEENTH\nILLUMINATION")

	-- Patrol and resident routes.
	Build.waypoint("Enf_Crown_1", polar(10, 200, Y + 0.3))
	Build.waypoint("Enf_Crown_2", polar(80, 200, Y + 0.3))
	Build.waypoint("Res_Crown_1", polar(100, 160, Y + 0.3))
	Build.waypoint("Res_Crown_2", polar(150, 160, Y + 0.3))
	Build.waypoint("Res_Crown_3", polar(210, 160, Y + 0.3))

	Build.zone(zones, "Region_Crown", V(0, 400, 0), V(1320, 310, 1320), { ZoneType = "Region", Region = "crown", Priority = 4 })
end
