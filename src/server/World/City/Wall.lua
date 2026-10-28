--[[
	The Wall around Veyra and the Veil above it. The government does not let anyone out:
	the North Gate is welded shut and the Veil (a shimmering field) caps every wall, so there
	is no climbing or grappling over. The only way out is under: the storm sewers.
]]
local Build = require(script.Parent.Parent.Build)
local Layout = require(script.Parent.Layout)

local C, M, rgb = Build.Colors, Build.M, Build.rgb
local V = Vector3.new

local W = Layout.WALL
local H = Layout.WALL_H
local VEIL_TOP = 1000

return function(root)
	local folder = Build.folder(root, "Wall")
	local wallColor = rgb(58, 55, 66)
	local length = W * 2 + 20

	for _, side in ipairs({ { V(0, 0, W), "X" }, { V(0, 0, -W), "X" }, { V(W, 0, 0), "Z" }, { V(-W, 0, 0), "Z" } }) do
		local center, axis = side[1], side[2]
		local size = if axis == "X" then V(length, H, 20) else V(20, H, length)
		Build.part(folder, size, center + V(0, H / 2, 0), wallColor, M.Concrete, { Name = "Wall" })
		local band = if axis == "X" then V(length, 1.5, 20.6) else V(20.6, 1.5, length)
		Build.part(folder, band, center + V(0, H - 6, 0), C.magenta, M.Neon, { CanCollide = false })
		Build.part(folder, band, center + V(0, 60, 0), C.danger, M.Neon, { CanCollide = false, Transparency = 0.3 })
		-- The Veil: a faint shimmering field from the wall top to the sky.
		local veil = if axis == "X" then V(length, VEIL_TOP - H, 1) else V(1, VEIL_TOP - H, length)
		Build.part(folder, veil, center + V(0, H + (VEIL_TOP - H) / 2, 0), rgb(150, 120, 255), M.ForceField, {
			Name = "Veil",
			Transparency = 0.82,
			CastShadow = false,
		})
	end
	-- A lid over the city's Veil so nothing goes over the top either.
	Build.part(folder, V(length, 2, length), V(0, VEIL_TOP, 0), rgb(150, 120, 255), M.ForceField, { Name = "VeilCap", Transparency = 1 })

	-- The sealed North Gate, seen from Gate Square.
	local gateZ = W - 10.6
	Build.part(folder, V(52, 74, 2), V(0, 37, gateZ), rgb(60, 62, 70), M.DiamondPlate, { Name = "NorthGate" })
	Build.part(folder, V(0.6, 74, 2.2), V(0, 37, gateZ), C.amber, M.Neon, { CanCollide = false })
	for _, y in ipairs({ 20, 40, 60 }) do
		Build.part(folder, V(52, 1, 2.4), V(0, y, gateZ), rgb(120, 60, 40), M.CorrodedMetal, { Name = "Weld" })
	end
	Build.sign(folder, "SEALED BY ORDER OF THE COUNCIL", V(0, 80, gateZ - 1.4), V(0, 0, -1), V(50, 5, 0.4), C.danger)
	for _, x in ipairs({ -34, 34 }) do
		Build.part(folder, V(14, 96, 14), V(x, 48, gateZ + 2), rgb(48, 46, 56), M.Concrete, { Name = "GateTower" })
		local beacon = Build.part(folder, V(3, 3, 3), V(x, 98, gateZ + 2), C.danger, M.Neon, { CanCollide = false })
		beacon:SetAttribute("Blink", true)
		Build.light(beacon, C.danger, 50, 2)
	end
	Build.sign(folder, "VEYRA", V(0, 150, -W + 10.4), V(0, 0, 1), V(80, 20, 0.4), C.cyan)
	Build.sign(folder, "THE VEIL KEEPS YOU SAFE", V(-300, 120, W - 10.4), V(0, 0, -1), V(90, 10, 0.4), C.violet)

	-- Storm outflows outside the Wall (north to the Sporewilds, south to the marsh).
	local outflows = {
		{ pos = V(-448, 0, 785), dir = V(0, 0, 1), enter = "outflow_north_enter", wp = "Outflow_N", cp = "CP_Outflow_N" },
		{ pos = V(-192, 0, -785), dir = V(0, 0, -1), enter = "outflow_south_enter", wp = "Outflow_S", cp = "CP_Outflow_S" },
	}
	local zones = Build.folder(root, "Zones")
	for _, o in ipairs(outflows) do
		Build.part(folder, V(22, 9, 6), CFrame.lookAt(o.pos + V(0, 4.5, 0), o.pos + V(0, 4.5, 0) + o.dir), rgb(90, 90, 86), M.Concrete, { Name = "Headwall" })
		local pipe = Build.part(folder, V(1, 7, 7), CFrame.lookAt(o.pos + V(0, 3.6, 0) + o.dir * 3.1, o.pos + V(0, 3.6, 0) + o.dir * 4) * CFrame.Angles(0, math.rad(90), 0), rgb(10, 12, 12), M.SmoothPlastic, {
			Name = "PipeMouth",
			Shape = Enum.PartType.Cylinder,
		})
		Build.interactable(pipe, o.enter)
		Build.part(folder, V(4, 0.2, 14), CFrame.lookAt(o.pos + o.dir * 10 + V(0, 0.15, 0), o.pos + o.dir * 20), rgb(60, 110, 100), M.Glass, { Transparency = 0.4, CanCollide = false })
		Build.waypoint(o.wp, o.pos + o.dir * 16 + V(0, 0.5, 0), o.pos + o.dir * 60)
		Build.waypoint(o.cp, o.pos + o.dir * 16 + V(0, 0.5, 0), o.pos + o.dir * 60)
		Build.zone(zones, o.cp .. "_Zone", o.pos + o.dir * 20, V(40, 0, 30), { ZoneType = "Checkpoint", Checkpoint = o.cp })
	end

	-- Outer world boundary.
	local edge = 3200
	for _, s in ipairs({ { V(edge, 300, 0), V(4, 900, edge * 2) }, { V(-edge, 300, 0), V(4, 900, edge * 2) }, { V(0, 300, edge), V(edge * 2, 900, 4) }, { V(0, 300, -edge), V(edge * 2, 900, 4) } }) do
		for k = -2, 1 do
			-- Split into pieces under the 2048-stud part limit.
			local piece = s[2]
			local along = if piece.X > piece.Z then V(1, 0, 0) else V(0, 0, 1)
			local len = math.max(piece.X, piece.Z) / 4
			local size = if piece.X > piece.Z then V(len, piece.Y, piece.Z) else V(piece.X, piece.Y, len)
			Build.part(folder, size, s[1] + along * (k + 0.5) * len, nil, nil, { Transparency = 1, CanQuery = false, Name = "WorldEdge" })
		end
	end
end
