-- Small toolkit for building the greybox world from code.
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local Build = {}

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

Build.rgb = rgb
Build.Colors = {
	concrete = rgb(44, 44, 52),
	asphalt = rgb(22, 22, 28),
	plaza = rgb(58, 54, 70),
	building = rgb(30, 29, 40),
	brick = rgb(70, 48, 50),
	wall = rgb(58, 55, 66),
	metal = rgb(70, 72, 82),
	wood = rgb(74, 54, 40),
	trunk = rgb(34, 28, 36),
	paper = rgb(236, 230, 210),

	cyan = rgb(64, 240, 255),
	magenta = rgb(255, 64, 200),
	violet = rgb(150, 90, 255),
	amber = rgb(255, 170, 60),
	vesper = rgb(90, 255, 190),
	ascent = rgb(120, 200, 255),
	danger = rgb(255, 70, 60),
}

local M = Enum.Material
Build.M = M
local C = Build.Colors

function Build.folder(parent, name)
	local f = parent:FindFirstChild(name)
	if not f then
		f = Instance.new("Folder")
		f.Name = name
		f.Parent = parent
	end
	return f
end

local function toCFrame(cf)
	if typeof(cf) == "Vector3" then
		return CFrame.new(cf)
	end
	return cf
end

-- part(parent, size, cframe|position, color, material, props)
function Build.part(parent, size, cf, color, material, props)
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if props and props.Shape then
		p.Shape = props.Shape
	end
	p.Size = size
	p.CFrame = toCFrame(cf)
	p.Color = color or rgb(128, 128, 128)
	p.Material = material or M.SmoothPlastic
	if material == M.Neon then
		p.CastShadow = false
	end
	if props then
		for k, v in pairs(props) do
			if k == "Tags" then
				for _, tag in ipairs(v) do
					CollectionService:AddTag(p, tag)
				end
			elseif k == "Attributes" then
				for ak, av in pairs(v) do
					p:SetAttribute(ak, av)
				end
			elseif k ~= "Shape" then
				p[k] = v
			end
		end
	end
	p.Parent = parent
	return p
end

-- A box oriented from `from` toward `to`, its length running along Z.
function Build.beam(parent, from, to, width, height, color, material, props)
	local mid = (from + to) / 2
	local length = (to - from).Magnitude
	return Build.part(parent, Vector3.new(width, height, length), CFrame.lookAt(mid, to), color, material, props)
end

-- Vertical cylinder standing on its center position.
function Build.cylinder(parent, height, diameter, center, color, material, props)
	props = props or {}
	props.Shape = Enum.PartType.Cylinder
	return Build.part(parent, Vector3.new(height, diameter, diameter), CFrame.new(center) * CFrame.Angles(0, 0, math.rad(90)), color, material, props)
end

function Build.ball(parent, diameter, center, color, material, props)
	props = props or {}
	props.Shape = Enum.PartType.Ball
	return Build.part(parent, Vector3.new(diameter, diameter, diameter), center, color, material, props)
end

function Build.light(part, color, range, brightness, shadows)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = range or 16
	light.Brightness = brightness or 1
	light.Shadows = shadows or false
	light.Parent = part
	return light
end

-- A sign facing `facing` (a direction vector). Text renders on the part's front face.
function Build.sign(parent, text, position, facing, size, textColor, bgColor, props)
	local p = Build.part(parent, size, CFrame.lookAt(position, position + facing), bgColor or rgb(10, 10, 16), M.SmoothPlastic, props)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.LightInfluence = 0
	gui.Brightness = 2.5
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 30
	gui.Parent = p
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = textColor or Build.Colors.cyan
	label.Parent = gui
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0.04, 0)
	pad.PaddingRight = UDim.new(0.04, 0)
	pad.PaddingTop = UDim.new(0.1, 0)
	pad.PaddingBottom = UDim.new(0.1, 0)
	pad.Parent = label
	return p
end

-- Screen on a terminal or console.
function Build.screen(part, text, color)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.LightInfluence = 0
	gui.Brightness = 2
	gui.Parent = part
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = rgb(4, 14, 12)
	label.TextColor3 = color or Build.Colors.vesper
	label.Font = Enum.Font.Code
	label.TextScaled = true
	label.Text = text
	label.Parent = gui
end

--[[
	A straight wall with optional door openings.
	base: floor-level center; axis: "X" or "Z" (direction the wall runs);
	doors: { offset, width, height } or a list of them, offsets along the axis from center.
]]
function Build.wall(parent, base, axis, length, height, thickness, doors, color, material, props)
	local function segment(a, b, y0, y1)
		if b - a < 0.05 or y1 - y0 < 0.05 then
			return
		end
		local mid, len = (a + b) / 2, b - a
		local size, offset
		if axis == "X" then
			size = Vector3.new(len, y1 - y0, thickness)
			offset = Vector3.new(mid, (y0 + y1) / 2, 0)
		else
			size = Vector3.new(thickness, y1 - y0, len)
			offset = Vector3.new(0, (y0 + y1) / 2, mid)
		end
		Build.part(parent, size, base + offset, color, material, props and table.clone(props))
	end

	local half = length / 2
	if not doors then
		segment(-half, half, 0, height)
		return
	end
	local list = if doors.width then { doors } else table.clone(doors)
	table.sort(list, function(a, b)
		return (a.offset or 0) < (b.offset or 0)
	end)
	local cursor = -half
	for _, door in ipairs(list) do
		local o, w = door.offset or 0, door.width or 6
		segment(cursor, o - w / 2, 0, height)
		segment(o - w / 2, o + w / 2, math.min(door.height or 9, height), height)
		cursor = o + w / 2
	end
	segment(cursor, half, 0, height)
end

--[[
	A room: floor, four walls with door openings, optional roof.
	o = { name, center (floor-level), size (W,H,D), wall, color, material, transparency,
	      floorColor, floorMaterial, roof, roofColor, doors = { N = door, S = ..., E = ..., W = ... } }
	N = +Z, S = -Z, E = +X, W = -X.
]]
function Build.room(parent, o)
	local model = Instance.new("Model")
	model.Name = o.name or "Room"
	model.Parent = parent
	local c, s, t = o.center, o.size, o.wall or 1
	local doors = o.doors or {}
	local props = if o.transparency then { Transparency = o.transparency } else nil

	Build.part(model, Vector3.new(s.X, 0.4, s.Z), c + Vector3.new(0, 0.2, 0), o.floorColor or rgb(40, 38, 44), o.floorMaterial or M.WoodPlanks, { Name = "Floor" })
	Build.wall(model, c + Vector3.new(0, 0, s.Z / 2 - t / 2), "X", s.X, s.Y, t, doors.N, o.color, o.material, props)
	Build.wall(model, c + Vector3.new(0, 0, -s.Z / 2 + t / 2), "X", s.X, s.Y, t, doors.S, o.color, o.material, props)
	Build.wall(model, c + Vector3.new(s.X / 2 - t / 2, 0, 0), "Z", s.Z - 2 * t, s.Y, t, doors.E, o.color, o.material, props)
	Build.wall(model, c + Vector3.new(-s.X / 2 + t / 2, 0, 0), "Z", s.Z - 2 * t, s.Y, t, doors.W, o.color, o.material, props)
	if o.roof ~= false then
		Build.part(model, Vector3.new(s.X, 0.6, s.Z), c + Vector3.new(0, s.Y + 0.3, 0), o.roofColor or o.color, o.material, props and table.clone(props))
	end
	return model
end

-- Ceiling lamp inside a room.
function Build.ceilingLight(parent, position, color, range, brightness, tags)
	local lamp = Build.part(parent, Vector3.new(2.4, 0.3, 2.4), position, color, M.Neon, { CanCollide = false, Tags = tags })
	Build.light(lamp, color, range or 22, brightness or 1.2, true)
	return lamp
end

-- Invisible marker used by NPC schedules, quest markers, teleports and checkpoints.
function Build.waypoint(name, position, lookAt)
	local folder = Build.folder(Workspace, "Waypoints")
	local cf = if lookAt then CFrame.lookAt(position, Vector3.new(lookAt.X, position.Y, lookAt.Z)) else CFrame.new(position)
	return Build.part(folder, Vector3.new(1, 1, 1), cf, rgb(255, 0, 255), M.SmoothPlastic, {
		Name = name,
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
	})
end

-- Invisible volume checked by Hazards (server) and Ambience (client).
-- With size.Y == 0 the zone spans y -100..600; otherwise center/size are used as given.
-- Zones larger than Roblox's 2048-stud part limit are split into tiles with the same attributes.
local MAX_PART = 2048
function Build.zone(parent, name, center, size, attributes)
	local fullSize = if size.Y > 0 then size else Vector3.new(size.X, 700, size.Z)
	local fullCenter = if size.Y > 0 then center else Vector3.new(center.X, 250, center.Z)
	if fullSize.X > MAX_PART or fullSize.Z > MAX_PART then
		local nx, nz = math.ceil(fullSize.X / MAX_PART), math.ceil(fullSize.Z / MAX_PART)
		local tile = Vector3.new(fullSize.X / nx, fullSize.Y, fullSize.Z / nz)
		local first
		for ix = 0, nx - 1 do
			for iz = 0, nz - 1 do
				local offset = Vector3.new((ix + 0.5) * tile.X - fullSize.X / 2, 0, (iz + 0.5) * tile.Z - fullSize.Z / 2)
				local piece = Build.zone(parent, name, fullCenter + offset, tile, attributes)
				first = first or piece
			end
		end
		return first
	end
	return Build.part(parent, fullSize, fullCenter, rgb(255, 0, 0), M.SmoothPlastic, {
		Name = name,
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Tags = { "Zone" },
		Attributes = attributes,
	})
end

function Build.interactable(part, id)
	part:SetAttribute("InteractId", id)
	CollectionService:AddTag(part, "Interactable")
	return part
end

-- A small glowing paper/object to interact with.
function Build.note(parent, id, position, color)
	local p = Build.part(parent, Vector3.new(1.2, 0.08, 0.9), position, color or Build.Colors.paper, M.SmoothPlastic, { Name = "Note_" .. id })
	Build.light(p, rgb(255, 230, 190), 5, 0.6)
	return Build.interactable(p, id)
end

function Build.terminal(parent, id, position, facing, text)
	local base = Build.part(parent, Vector3.new(2.6, 3, 1.6), CFrame.lookAt(position + Vector3.new(0, 1.5, 0), position + Vector3.new(0, 1.5, 0) + facing), Build.Colors.metal, M.Metal)
	local screen = Build.part(
		parent,
		Vector3.new(2.2, 1.6, 0.2),
		CFrame.lookAt(position + Vector3.new(0, 3.6, 0), position + Vector3.new(0, 3.6, 0) + facing),
		rgb(10, 20, 18),
		M.SmoothPlastic,
		{ Name = "Terminal_" .. id }
	)
	Build.screen(screen, text or "> _", Build.Colors.vesper)
	Build.light(screen, Build.Colors.vesper, 8, 0.8)
	Build.interactable(screen, id)
	return base, screen
end

-- A dormant husk fused to the ground by roots.
function Build.rooted(parent, position, facing, name)
	local model = Instance.new("Model")
	model.Name = name or "Rooted"
	local root = CFrame.lookAt(position, position + Vector3.new(facing.X, 0, facing.Z))
	local skin = rgb(86, 98, 88)
	local cloth = rgb(48, 50, 52)

	local base = Build.part(model, Vector3.new(2.4, 1, 2.4), root * CFrame.new(0, 0.5, 0), rgb(40, 36, 34), M.Ground, { Name = "Base" })
	Build.part(model, Vector3.new(0.8, 2.4, 0.8), root * CFrame.new(-0.5, 1.7, 0) * CFrame.Angles(0, 0, math.rad(6)), cloth, M.Fabric)
	Build.part(model, Vector3.new(0.8, 2.4, 0.8), root * CFrame.new(0.5, 1.7, 0) * CFrame.Angles(0, 0, math.rad(-6)), cloth, M.Fabric)
	Build.part(model, Vector3.new(2, 2.4, 1.1), root * CFrame.new(0, 3.9, -0.3) * CFrame.Angles(math.rad(-22), 0, 0), cloth, M.Fabric)
	Build.part(model, Vector3.new(0.6, 2.4, 0.6), root * CFrame.new(-1.3, 3.4, -0.6) * CFrame.Angles(math.rad(-18), 0, 0), skin, M.Slate)
	Build.part(model, Vector3.new(0.6, 2.4, 0.6), root * CFrame.new(1.3, 3.4, -0.6) * CFrame.Angles(math.rad(-18), 0, 0), skin, M.Slate)
	local head = Build.part(model, Vector3.new(1.2, 1.3, 1.2), root * CFrame.new(0, 5.3, -1) * CFrame.Angles(math.rad(-30), 0, 0), skin, M.Slate, { Name = "Head" })
	Build.part(model, Vector3.new(0.9, 0.22, 0.1), head.CFrame * CFrame.new(0, 0.1, -0.62), rgb(60, 160, 130), M.Neon, { Name = "Eye", CanCollide = false })

	-- Roots spreading from the feet, and a few creeping up the body.
	for i = 1, 6 do
		local angle = (i / 6) * math.pi * 2
		local outward = Vector3.new(math.cos(angle), 0, math.sin(angle))
		local from = position + Vector3.new(0, 0.3, 0)
		local to = position + outward * (3 + (i % 3)) + Vector3.new(0, 0.1, 0)
		Build.beam(model, from, to, 0.35, 0.35, Build.Colors.vesper, M.Neon, { CanCollide = false, Transparency = 0.15, Tags = { "Vesper" } })
	end
	Build.beam(model, position + Vector3.new(0.4, 0.5, 0), position + Vector3.new(0.3, 4.5, -0.6), 0.25, 0.25, Build.Colors.vesper, M.Neon, { CanCollide = false })

	model.PrimaryPart = base
	model:SetAttribute("State", "dormant")
	CollectionService:AddTag(model, "Rooted")
	model.Parent = parent
	return model
end

-- Distance from point p to segment ab in the XZ plane.
function Build.distanceToSegment(p, a, b)
	local ab = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
	local ap = Vector3.new(p.X - a.X, 0, p.Z - a.Z)
	local t = if ab.Magnitude > 0 then math.clamp(ap:Dot(ab) / ab:Dot(ab), 0, 1) else 0
	return (ap - ab * t).Magnitude
end

function Build.distanceToPath(p, points)
	local best = math.huge
	for i = 1, #points - 1 do
		best = math.min(best, Build.distanceToSegment(p, points[i], points[i + 1]))
	end
	return best
end

-- Unique keys for per-instance doors and stashes.
local keyCounter = 0
function Build.key(prefix)
	keyCounter += 1
	return prefix .. keyCounter
end

-- Doors ---------------------------------------------------------------------------------

local SIDE_DIR = {
	N = Vector3.new(0, 0, 1),
	S = Vector3.new(0, 0, -1),
	E = Vector3.new(1, 0, 0),
	W = Vector3.new(-1, 0, 0),
}
Build.SIDE_DIR = SIDE_DIR

-- Door panel filling a room's doorway. attrs: Mode ("hours"|"locked"), OpenFrom/OpenTo,
-- Hackable, Pickable, KeyItem, Key. Locked doors get the "locked_door" prompt.
function Build.door(parent, roomCenter, roomSize, side, door, attrs)
	local dir = SIDE_DIR[side]
	local width, height = door.width or 6, math.min(door.height or 9, roomSize.Y)
	local along = if side == "N" or side == "S" then Vector3.new(1, 0, 0) else Vector3.new(0, 0, 1)
	local depth = if side == "N" or side == "S" then roomSize.Z else roomSize.X
	local pos = roomCenter + dir * (depth / 2 - 0.5) + along * (door.offset or 0) + Vector3.new(0, height / 2, 0)
	-- lookAt points the panel's local Z outward, so width always runs along local X.
	local size = Vector3.new(width, height, 0.6)
	attrs.Key = attrs.Key or Build.key("door")
	local color = if attrs.Mode == "locked" then rgb(60, 60, 70) else rgb(80, 74, 66)
	local panel = Build.part(parent, size, CFrame.lookAt(pos, pos + dir), color, M.DiamondPlate, {
		Name = "Door",
		Tags = { "Door" },
		Attributes = attrs,
	})
	-- Sign on the outside face ("CLOSED" for shops after hours, set by the Doors service).
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.LightInfluence = 0
	gui.Parent = panel
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 0.3)
	label.Position = UDim2.fromScale(0, 0.35)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = rgb(255, 90, 80)
	label.Text = if attrs.Mode == "locked" then "LOCKED" else ""
	label.Parent = gui
	if attrs.Mode == "locked" then
		Build.interactable(panel, "locked_door")
	end
	return panel
end

-- Interiors -----------------------------------------------------------------------------

Build.SIGN_NAMES = {
	bar = { "THE DRIP", "LAST CALL", "RUST & RYE", "NEON SAINT", "THE SUMP" },
	noodle = { "GLOWBOWL", "NOODLE 24H", "MAMA LIN'S", "STEAM HOUSE" },
	pawn = { "PAWN • CASH", "SECOND LIFE", "FENCE & SONS" },
	workshop = { "REPAIRS", "CHROME DOC", "VOLT WORKS", "BOLT BROS" },
	clinic = { "CLINIC", "MEDIBAY", "STREET DOC", "MEND + CO" },
	apartment = { "APARTMENTS", "HOUSING BLOCK", "FLATS", "ROOMS" },
	shop = { "MARKET", "CORNER STORE", "GOODS", "OPEN 24" },
	chapel = { "CHAPEL OF THE GREEN", "QUIET HOUSE" },
	arcade = { "ARCADE", "GAME DEN", "PIXEL PIT" },
	office = { "OFFICES", "ASCENT SERVICES", "CIVIC BUREAU" },
	florist = { "GREEN THUMB", "CIVIC FLORIST", "BLOOM & CO" },
	cafe = { "CAFE", "SYNTH BREW", "MORNING GRID" },
	empty = { "FOR LEASE", "", "CONDEMNED" },
	mansion = { "", "" },
}

local function prop(parent, size, pos, color, material, props)
	return Build.part(parent, size, pos, color, material or M.SmoothPlastic, props)
end

--[[
	Furnishes a room. center = floor-level center, size = room size, palette neon color.
	Returns a list of free floor spots where a stash or note can be placed.
]]
function Build.furnish(parent, kind, center, size, rng, neon)
	local w, d = size.X - 4, size.Z - 4
	local function spot(fx, fz, y)
		return center + Vector3.new(fx * w / 2, y or 0, fz * d / 2)
	end
	local wood, metal, dark = C.wood, C.metal, rgb(34, 32, 40)
	local spots = {}
	if kind == "bar" or kind == "noodle" or kind == "cafe" then
		prop(parent, Vector3.new(w * 0.6, 3.5, 2), spot(0, 0.55, 1.75), if kind == "bar" then dark else wood, M.Wood)
		prop(parent, Vector3.new(w * 0.6, 0.25, 0.25), spot(0, 0.48, 3.6), neon, M.Neon, { CanCollide = false })
		for i = -2, 2 do
			Build.cylinder(parent, 2.2, 1.2, spot(i * 0.2, 0.3, 1.1), metal, M.Metal)
		end
		for _, fx in ipairs({ -0.6, 0.6 }) do
			prop(parent, Vector3.new(3, 2.6, 3), spot(fx, -0.4, 1.3), wood, M.Wood)
		end
		table.insert(spots, spot(-0.8, 0.7, 0))
	elseif kind == "pawn" or kind == "shop" or kind == "florist" then
		prop(parent, Vector3.new(w * 0.5, 3.5, 2), spot(0, 0.5, 1.75), wood, M.WoodPlanks)
		for _, fx in ipairs({ -0.85, 0.85 }) do
			prop(parent, Vector3.new(2, 7, d * 0.6), spot(fx, 0, 3.5), dark, M.Metal)
			for i = -2, 2 do
				local item = if kind == "florist" then C.civic else neon
				prop(parent, Vector3.new(1.2, 1, 1.2), spot(fx * 0.92, i * 0.12, 2 + (i % 3) * 2), item, if kind == "florist" then M.Grass else M.Neon, { CanCollide = false })
			end
		end
		table.insert(spots, spot(0.3, 0.75, 0))
	elseif kind == "workshop" then
		prop(parent, Vector3.new(w * 0.5, 3.2, 3), spot(0, 0.5, 1.6), metal, M.DiamondPlate)
		prop(parent, Vector3.new(2, 4, 2), spot(-0.6, -0.4, 2), rgb(70, 76, 90), M.Metal)
		prop(parent, Vector3.new(1.2, 1.2, 1.2), spot(-0.6, -0.4, 4.6), neon, M.Neon, { CanCollide = false })
		prop(parent, Vector3.new(3, 1, 3), spot(0.6, -0.5, 0.5), rgb(60, 50, 40), M.CorrodedMetal)
		table.insert(spots, spot(0.8, 0.7, 0))
	elseif kind == "clinic" then
		for _, fx in ipairs({ -0.55, 0, 0.55 }) do
			prop(parent, Vector3.new(3, 1.8, 6), spot(fx, 0.4, 0.9), rgb(220, 226, 230), M.SmoothPlastic)
		end
		prop(parent, Vector3.new(4, 0.6, 0.3), spot(0, 0.95, 7), C.civic, M.Neon, { CanCollide = false })
		prop(parent, Vector3.new(0.6, 4, 0.3), spot(0, 0.95, 7), C.civic, M.Neon, { CanCollide = false })
		table.insert(spots, spot(-0.8, -0.6, 0))
	elseif kind == "chapel" then
		for i = -2, 1 do
			prop(parent, Vector3.new(w * 0.5, 1.6, 1.6), spot(0, i * 0.25, 0.8), wood, M.Wood)
		end
		prop(parent, Vector3.new(4, 3, 2), spot(0, 0.8, 1.5), rgb(200, 196, 180), M.Marble)
		Build.ball(parent, 2.2, spot(0, 0.8, 4.2), C.civic, M.Grass)
		table.insert(spots, spot(0.8, 0.8, 0))
	elseif kind == "arcade" then
		for i = -2, 2 do
			local cab = prop(parent, Vector3.new(2.4, 5, 2), spot(i * 0.35, 0.75, 2.5), dark, M.SmoothPlastic)
			prop(parent, Vector3.new(1.8, 1.4, 0.1), cab.CFrame.Position + Vector3.new(0, 0.8, -1.05), neon, M.Neon, { CanCollide = false })
		end
		table.insert(spots, spot(0.8, -0.7, 0))
	elseif kind == "office" then
		for _, fx in ipairs({ -0.5, 0.5 }) do
			for _, fz in ipairs({ -0.3, 0.4 }) do
				prop(parent, Vector3.new(5, 2.8, 2.6), spot(fx, fz, 1.4), rgb(200, 204, 210), M.SmoothPlastic)
				prop(parent, Vector3.new(1.6, 1, 0.1), spot(fx, fz, 3.3), C.ascent, M.Neon, { CanCollide = false })
			end
		end
		table.insert(spots, spot(-0.85, 0.85, 0))
	elseif kind == "mansion" then
		prop(parent, Vector3.new(w * 0.7, 0.1, d * 0.6), spot(0, 0, 0.45), rgb(120, 30, 40), M.Fabric, { CanCollide = false })
		prop(parent, Vector3.new(8, 2.6, 3), spot(0, 0.6, 1.3), rgb(240, 236, 226), M.Fabric)
		prop(parent, Vector3.new(4, 2.4, 4), spot(0, 0.1, 1.2), rgb(200, 170, 100), M.Marble)
		Build.ball(parent, 3, spot(-0.8, 0.8, 1.5), C.civic, M.Grass)
		Build.ball(parent, 3, spot(0.8, 0.8, 1.5), C.civic, M.Grass)
		prop(parent, Vector3.new(6, 4, 0.2), spot(0, 0.98, 6), rgb(255, 224, 138), M.Neon, { CanCollide = false, Transparency = 0.4 })
		table.insert(spots, spot(0.85, -0.6, 0))
	elseif kind == "apartment" then
		prop(parent, Vector3.new(5, 1.8, 7), spot(-0.6, 0.5, 0.9), rgb(90, 80, 100), M.Fabric)
		prop(parent, Vector3.new(4, 2.8, 3), spot(0.5, -0.2, 1.4), wood, M.Wood)
		prop(parent, Vector3.new(6, 2.4, 2.4), spot(0.4, 0.75, 1.2), rgb(70, 50, 60), M.Fabric)
		Build.ball(parent, 2, spot(-0.85, -0.85, 1.4), C.civic, M.Grass)
		table.insert(spots, spot(0.6, -0.2, 2.85))
	else -- empty / abandoned
		for _ = 1, 4 do
			local s = rng:NextNumber(1.5, 3.5)
			prop(parent, Vector3.new(s, s, s), spot(rng:NextNumber(-0.8, 0.8), rng:NextNumber(-0.8, 0.8), s / 2), wood, M.WoodPlanks)
		end
		table.insert(spots, spot(0, 0, 0))
	end
	return spots
end

-- An explorable building: room + roof sign + furniture + optional door lock.
-- o = { name, center, size, side ("N"|"S"|"E"|"W"), kind, neon, wallColor, material, closed = attrs|nil, sign = text|nil, light = bool, rng }
function Build.building(parent, o)
	local doorSpec = { offset = 0, width = 6, height = 9 }
	local room = Build.room(parent, {
		name = o.name or o.kind,
		center = o.center,
		size = o.size,
		color = o.wallColor,
		material = o.material or M.Concrete,
		floorMaterial = o.floorMaterial or M.WoodPlanks,
		floorColor = o.floorColor,
		doors = { [o.side] = doorSpec },
	})
	local dir = SIDE_DIR[o.side]
	local depth = if o.side == "N" or o.side == "S" then o.size.Z else o.size.X
	local signText = o.sign
	if signText == nil then
		local names = Build.SIGN_NAMES[o.kind] or { "" }
		signText = names[o.rng:NextInteger(1, #names)]
	end
	if signText ~= "" then
		local signPos = o.center + dir * (depth / 2 + 0.3) + Vector3.new(0, 11.5, 0)
		local signWidth = math.min(16, (if o.side == "N" or o.side == "S" then o.size.X else o.size.Z) - 4)
		Build.sign(room, signText, signPos, dir, Vector3.new(signWidth, 2.4, 0.3), o.neon)
	end
	-- Neon trim above the door.
	local trimPos = o.center + dir * (depth / 2 + 0.2) + Vector3.new(0, 9.4, 0)
	local trimSize = if o.side == "N" or o.side == "S" then Vector3.new(7, 0.3, 0.3) else Vector3.new(0.3, 0.3, 7)
	Build.part(room, trimSize, trimPos, o.neon, M.Neon, { CanCollide = false })
	if o.light ~= false then
		Build.ceilingLight(room, o.center + Vector3.new(0, o.size.Y - 0.4, 0), o.neon:Lerp(Color3.new(1, 1, 1), 0.6), 22, 0.8)
	end
	local spots = Build.furnish(room, o.kind, o.center, o.size, o.rng, o.neon)
	if o.closed then
		Build.door(room, o.center, o.size, o.side, doorSpec, o.closed)
	end
	return room, spots
end

-- Civic plants (safe, bioengineered, everywhere in the city) ---------------------------

C.civic = rgb(110, 220, 120)
C.civicGlow = rgb(150, 255, 170)

function Build.planter(parent, position, rng, big)
	local scale = if big then 1.6 else 1
	Build.part(parent, Vector3.new(4, 1.6, 4) * scale, position + Vector3.new(0, 0.8 * scale, 0), rgb(60, 62, 70), M.Concrete, { Tags = { "CivicPlant" } })
	local trunkH = rng:NextNumber(5, 9) * scale
	Build.cylinder(parent, trunkH, 0.6 * scale, position + Vector3.new(0, 1.6 * scale + trunkH / 2, 0), rgb(70, 54, 40), M.Wood)
	local top = position + Vector3.new(0, 1.6 * scale + trunkH, 0)
	Build.ball(parent, rng:NextNumber(5, 7) * scale, top, C.civic:Lerp(rgb(60, 160, 90), rng:NextNumber()), M.Grass, {
		CanCollide = false,
		Tags = { "CivicPlant" },
	})
	-- A few bioluminescent buds: the soft green glow of the civic strain.
	for _ = 1, 2 do
		local bud = top + Vector3.new(rng:NextNumber(-2.4, 2.4), rng:NextNumber(-1.5, 1.5), rng:NextNumber(-2.4, 2.4)) * scale
		Build.part(parent, Vector3.new(0.5, 0.5, 0.5), bud, C.civicGlow, M.Neon, { CanCollide = false, Shape = Enum.PartType.Ball })
	end
end

-- Vines hanging from an overhead surface at height `top`.
function Build.vines(parent, position, top, rng, count)
	for _ = 1, count do
		local len = rng:NextNumber(6, 28)
		local p = position + Vector3.new(rng:NextNumber(-6, 6), 0, rng:NextNumber(-6, 6))
		Build.part(parent, Vector3.new(0.35, len, 0.35), Vector3.new(p.X, top - len / 2, p.Z), C.civic, M.Grass, { CanCollide = false, CastShadow = false })
		if rng:NextNumber() < 0.5 then
			Build.part(parent, Vector3.new(0.5, 0.5, 0.5), Vector3.new(p.X, top - len, p.Z), C.civicGlow, M.Neon, { CanCollide = false })
		end
	end
end

-- Vertical garden panel on a facade.
function Build.greenWall(parent, position, facing, width, height)
	return Build.part(parent, Vector3.new(width, height, 0.8), CFrame.lookAt(position, position + facing), rgb(70, 150, 80), M.Grass, {
		CanCollide = false,
		Tags = { "CivicPlant" },
	})
end

-- Holographic advert: a translucent panel the client animates (HoloController).
function Build.holo(parent, position, facing, size, color, text)
	local panel = Build.part(parent, size, CFrame.lookAt(position, position + facing), color, M.Neon, {
		Name = "Holo",
		Transparency = 0.8,
		CanCollide = false,
		CanQuery = false,
		CastShadow = false,
		Tags = { "Holo" },
	})
	for _, face in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
		local gui = Instance.new("SurfaceGui")
		gui.Face = face
		gui.LightInfluence = 0
		gui.Brightness = 3
		gui.AlwaysOnTop = false
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 12
		gui.Parent = panel
		local label = Instance.new("TextLabel")
		label.Name = "Text"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.TextScaled = true
		label.Font = Enum.Font.GothamBlack
		label.TextColor3 = color
		label.Text = text or ""
		label.TextTransparency = 0.05
		label.Parent = gui
	end
	return panel
end

-- Wild growth (Sporewilds and beyond) -----------------------------------------------------

function Build.glowTree(parent, rng, position, scale)
	local h = rng:NextNumber(10, 22) * scale
	Build.cylinder(parent, h, 1.6 * scale, position + Vector3.new(0, h / 2, 0), C.trunk, M.Wood)
	local palette = { C.vesper, C.cyan, C.violet, C.magenta, C.vesper }
	local color = palette[rng:NextInteger(1, #palette)]
	for _ = 1, rng:NextInteger(2, 3) do
		local d = rng:NextNumber(6, 11) * scale
		local offset = Vector3.new(rng:NextNumber(-2.5, 2.5) * scale, h + rng:NextNumber(-1, 2), rng:NextNumber(-2.5, 2.5) * scale)
		Build.ball(parent, d, position + offset, color, M.Neon, { Transparency = 0.5, CanCollide = false, CastShadow = false, Tags = { "Vesper" } })
	end
	for _ = 1, 2 do
		local len = rng:NextNumber(3, 7)
		local top = position + Vector3.new(rng:NextNumber(-3, 3) * scale, h - 1, rng:NextNumber(-3, 3) * scale)
		Build.part(parent, Vector3.new(0.2, len, 0.2), top - Vector3.new(0, len / 2, 0), color, M.Neon, { CanCollide = false, Transparency = 0.2 })
	end
	if rng:NextNumber() < 0.15 then
		local core = Build.part(parent, Vector3.new(1, 1, 1), position + Vector3.new(0, h, 0), color, M.Neon, { CanCollide = false, Transparency = 1 })
		Build.light(core, color, 26 * scale, 1.2)
	end
end

function Build.deadTree(parent, rng, position)
	local h = rng:NextNumber(8, 18)
	Build.cylinder(parent, h, 1.2, position + Vector3.new(0, h / 2, 0), rgb(36, 30, 30), M.Wood)
	for _ = 1, 2 do
		local from = position + Vector3.new(0, h * rng:NextNumber(0.5, 0.9), 0)
		local to = from + Vector3.new(rng:NextNumber(-4, 4), rng:NextNumber(1, 3), rng:NextNumber(-4, 4))
		Build.beam(parent, from, to, 0.5, 0.5, rgb(36, 30, 30), M.Wood)
	end
end

function Build.mushroom(parent, rng, position, big)
	local h = if big then rng:NextNumber(6, 10) else rng:NextNumber(1.2, 3.5)
	local d = if big then rng:NextNumber(8, 12) else rng:NextNumber(2, 4.5)
	Build.cylinder(parent, h, d * 0.18, position + Vector3.new(0, h / 2, 0), rgb(200, 190, 210), M.SmoothPlastic, { CanCollide = big })
	local palette = { C.cyan, C.violet, C.magenta, C.vesper }
	local color = palette[rng:NextInteger(1, #palette)]
	local cap = Build.cylinder(parent, 0.7, d, position + Vector3.new(0, h, 0), color, M.Neon, { Transparency = 0.15, CanCollide = big, Tags = { "Vesper" } })
	if big then
		Build.light(cap, color, 24, 1)
	end
end

function Build.sporeCloud(parent, zones, name, center, size)
	Build.zone(zones, name, center, Vector3.new(size.X, 0, size.Z), { ZoneType = "Spores" })
	local emitterPart = Build.part(parent, Vector3.new(size.X, 8, size.Z), center + Vector3.new(0, 4, 0), rgb(0, 0, 0), M.SmoothPlastic, {
		Name = name .. "_Emitter",
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
	})
	local emitter = Instance.new("ParticleEmitter")
	emitter.Shape = Enum.ParticleEmitterShape.Box
	emitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	emitter.Rate = 45
	emitter.Lifetime = NumberRange.new(5, 9)
	emitter.Speed = NumberRange.new(0.3, 1.2)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.RotSpeed = NumberRange.new(-20, 20)
	emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 4) })
	emitter.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0.55), NumberSequenceKeypoint.new(1, 1) })
	emitter.Color = ColorSequence.new(rgb(170, 255, 120), rgb(90, 255, 190))
	emitter.LightEmission = 0.7
	emitter.Parent = emitterPart
	local glow = Build.part(parent, Vector3.new(1, 1, 1), center + Vector3.new(0, 3, 0), rgb(170, 255, 120), M.Neon, { CanCollide = false, Transparency = 1 })
	Build.light(glow, rgb(170, 255, 120), math.max(size.X, size.Z) * 0.7, 0.8)
end

-- A dirt trail over the terrain, split into segments short enough for part size limits.
function Build.trail(parent, points, width)
	for i = 1, #points - 1 do
		local a, b = points[i], points[i + 1]
		local length = (b - a).Magnitude
		local pieces = math.max(1, math.ceil(length / 400))
		for k = 1, pieces do
			local p0 = a:Lerp(b, (k - 1) / pieces) + Vector3.new(0, 0.12, 0)
			local p1 = a:Lerp(b, k / pieces) + Vector3.new(0, 0.12, 0)
			local dir = (p1 - p0).Unit
			Build.beam(parent, p0 - dir * 3, p1 + dir * 3, width or 9, 0.2, rgb(70, 58, 46), M.Ground, { Name = "Trail" })
		end
	end
end

-- Security ------------------------------------------------------------------------------

function Build.turret(parent, position, facing)
	local model = Instance.new("Model")
	model.Name = "Turret"
	Build.cylinder(model, 2, 3, position + Vector3.new(0, 1, 0), rgb(50, 54, 62), M.DiamondPlate, { Name = "Base" })
	local headCf = CFrame.lookAt(position + Vector3.new(0, 3, 0), position + Vector3.new(0, 3, 0) + facing)
	local head = Build.part(model, Vector3.new(2.4, 1.6, 3), headCf, rgb(70, 74, 84), M.Metal, { Name = "Head" })
	Build.part(model, Vector3.new(0.5, 0.5, 2), head.CFrame * CFrame.new(0, 0, -2.2), rgb(30, 30, 34), M.Metal, { Name = "Muzzle", CanCollide = false })
	local lens = Build.part(model, Vector3.new(0.6, 0.6, 0.1), head.CFrame * CFrame.new(0, 0.3, -1.55), rgb(255, 50, 40), M.Neon, { Name = "Lens", CanCollide = false })
	Build.light(lens, rgb(255, 50, 40), 10, 1)
	model.PrimaryPart = head
	CollectionService:AddTag(model, "Turret")
	model.Parent = parent
	return model
end

-- Lifts ---------------------------------------------------------------------------------

-- A call panel for `liftId` with a waypoint where arriving passengers appear.
function Build.liftStop(parent, liftId, waypointName, position, facing)
	local panelPos = position + Vector3.new(0, 3.2, 0)
	local panel = Build.part(parent, Vector3.new(1.6, 2.4, 0.4), CFrame.lookAt(panelPos, panelPos + facing), rgb(30, 34, 44), M.Metal, {
		Name = "LiftPanel",
		Tags = { "LiftPanel" },
		Attributes = { LiftId = liftId },
	})
	Build.screen(panel, "LIFT\n▲▼", C.cyan)
	Build.light(panel, C.cyan, 10, 0.8)
	Build.interactable(panel, "lift")
	Build.waypoint(waypointName, position + facing * 4, position + facing * 10)
	return panel
end

return Build
