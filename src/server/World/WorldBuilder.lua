--[[
	Builds the whole greybox world at server start. Replace it piece by piece with authored
	Studio builds later; gameplay only depends on tags, attributes, zones and waypoint names.

	Veyra (City/): Rust, Grid + sky roads + lifts, Crown, Powerhouse, landmarks, Wall, sewers.
	Outlands:      terrain, Sporewilds + Hollow Garden, Halvorsen (Dead Zone),
	               Overgrown Suburbs + Rail's End, Drowned Marsh + Mirefall.
]]
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Build = require(script.Parent.Build)
local City = script.Parent.City
local Outlands = script.Parent.Outlands

local WorldBuilder = {}

local CITY_NOTES = { "city_note_1", "city_note_2", "city_note_3", "city_note_4", "city_note_5", "city_note_6", "city_note_7", "city_note_8" }
local STASH_COUNT = 45

local function ensure(className, name)
	local inst = Lighting:FindFirstChild(name)
	if not inst then
		inst = Instance.new(className)
		inst.Name = name
		inst.Parent = Lighting
	end
	return inst
end

local function setupLighting()
	Lighting.Ambient = Color3.fromRGB(34, 28, 52)
	Lighting.OutdoorAmbient = Color3.fromRGB(70, 60, 100)
	Lighting.ExposureCompensation = 0.15
	Lighting.GeographicLatitude = 28

	local atmosphere = ensure("Atmosphere", "Atmosphere")
	atmosphere.Density = 0.3
	atmosphere.Offset = 0.1
	atmosphere.Color = Color3.fromRGB(170, 130, 210)
	atmosphere.Decay = Color3.fromRGB(80, 40, 120)
	atmosphere.Glare = 0.3
	atmosphere.Haze = 1.4

	local bloom = ensure("BloomEffect", "Bloom")
	bloom.Intensity = 1
	bloom.Size = 28
	bloom.Threshold = 0.92

	local cc = ensure("ColorCorrectionEffect", "Grade")
	cc.Saturation = 0.12
	cc.Contrast = 0.08
	cc.TintColor = Color3.fromRGB(240, 230, 255)

	local rays = ensure("SunRaysEffect", "SunRays")
	rays.Intensity = 0.04
	rays.Spread = 0.6

	local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky")
	sky.StarCount = 4000
	sky.Parent = Lighting
end

-- Scatters city notes and credit stashes into collected furniture spots.
local function scatter(root, spots)
	local rng = Random.new(1999)
	local folder = Build.folder(root, "Scattered")
	for i = #spots, 2, -1 do
		local j = rng:NextInteger(1, i)
		spots[i], spots[j] = spots[j], spots[i]
	end
	-- Notes: only in city buildings, one per spot.
	local noteIndex = 1
	for _, spot in ipairs(spots) do
		if noteIndex > #CITY_NOTES then
			break
		end
		if spot.tier == "rust" or spot.tier == "grid" or spot.tier == "crown" then
			local note = Build.part(folder, Vector3.new(1.2, 0.08, 0.9), spot.position + Vector3.new(0, 0.05, 0), Build.Colors.paper, Build.M.SmoothPlastic, {
				Name = "CityNote",
				Attributes = { Lore = CITY_NOTES[noteIndex] },
			})
			Build.interactable(note, "city_note")
			spot.used = true
			noteIndex += 1
		end
	end
	-- Stashes: locked buildings first (a reward for hackers and lockpickers), then anywhere.
	table.sort(spots, function(a, b)
		return (a.locked and 1 or 0) > (b.locked and 1 or 0)
	end)
	local placed = 0
	for _, spot in ipairs(spots) do
		if placed >= STASH_COUNT then
			break
		end
		if not spot.used and (spot.locked or rng:NextNumber() < 0.15) then
			local stash = Build.part(folder, Vector3.new(1.6, 0.9, 1.1), spot.position + Vector3.new(rng:NextNumber(-1, 1), 0.45, rng:NextNumber(-1, 1)), Build.rgb(70, 74, 84), Build.M.DiamondPlate, {
				Name = "Stash",
				Attributes = { Key = Build.key("stash") },
			})
			Build.part(folder, Vector3.new(1.62, 0.1, 0.2), stash.CFrame.Position + Vector3.new(0, 0.46, 0), Build.Colors.amber, Build.M.Neon, { CanCollide = false })
			Build.interactable(stash, "stash")
			placed += 1
		end
	end
end

function WorldBuilder.build()
	local existing = Workspace:FindFirstChild("World")
	if existing then
		existing:Destroy()
	end
	local root = Instance.new("Folder")
	root.Name = "World"
	root.Parent = Workspace
	local ctx = { spots = {} }

	setupLighting()
	require(Outlands.Terrain).build()

	require(City.Rust)(root, ctx)
	require(City.Grid)(root, ctx)
	require(City.Landmarks)(root)
	require(City.Powerhouse)(root)
	require(City.Crown)(root, ctx)
	require(City.Wall)(root)
	require(City.Sewers)(root, ctx)

	require(Outlands.Sporewilds)(root, ctx)
	require(Outlands.DeadZone)(root)
	require(Outlands.Suburbs)(root, ctx)
	require(Outlands.Marsh)(root, ctx)

	-- Anywhere outside the Wall counts as "outside" even between named regions.
	Build.zone(Build.folder(root, "Zones"), "Region_Outlands", Vector3.new(0, 0, 0), Vector3.new(6400, 0, 6400), {
		ZoneType = "Region",
		Region = "outlands",
		Priority = 0,
		Outside = true,
	})

	scatter(root, ctx.spots)

	local count = 0
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("BasePart") then
			count += 1
		end
	end
	print(string.format("[Afterglow] World built: %d parts, %d furniture spots.", count, #ctx.spots))
end

return WorldBuilder
