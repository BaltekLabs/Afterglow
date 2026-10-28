-- Fills the Outlands with terrain (everything outside the city's Wall), with distinct ground
-- for the Dead Zone and the marsh, and some hills near the world edge for a horizon.
local Workspace = game:GetService("Workspace")

local Terrain = {}

local EDGE = 3200
local CITY = 660
local CHUNK = 512

local Material = Enum.Material

local function fillChunked(x0, x1, z0, z1, y, height, material)
	local x = x0
	while x < x1 do
		local xe = math.min(x + CHUNK, x1)
		local z = z0
		while z < z1 do
			local ze = math.min(z + CHUNK, z1)
			Workspace.Terrain:FillBlock(CFrame.new((x + xe) / 2, y, (z + ze) / 2), Vector3.new(xe - x, height, ze - z), material)
			z = ze
		end
		x = xe
	end
end

-- Fill a rectangle, skipping the city square (which has its own part ground).
local function fillOutside(x0, x1, z0, z1, y, height, material)
	if x1 <= -CITY or x0 >= CITY or z1 <= -CITY or z0 >= CITY then
		fillChunked(x0, x1, z0, z1, y, height, material)
		return
	end
	if x0 < -CITY then
		fillChunked(x0, -CITY, z0, z1, y, height, material)
	end
	if x1 > CITY then
		fillChunked(CITY, x1, z0, z1, y, height, material)
	end
	local mx0, mx1 = math.max(x0, -CITY), math.min(x1, CITY)
	if z0 < -CITY then
		fillChunked(mx0, mx1, z0, -CITY, y, height, material)
	end
	if z1 > CITY then
		fillChunked(mx0, mx1, CITY, z1, y, height, material)
	end
end

Terrain.fillOutside = fillOutside

function Terrain.build()
	local t = Workspace.Terrain
	t:Clear()
	t:SetMaterialColor(Material.LeafyGrass, Color3.fromRGB(38, 66, 58))
	t:SetMaterialColor(Material.Grass, Color3.fromRGB(46, 74, 52))
	t:SetMaterialColor(Material.Ground, Color3.fromRGB(66, 56, 46))
	t:SetMaterialColor(Material.Mud, Color3.fromRGB(52, 46, 38))
	t:SetMaterialColor(Material.Slate, Color3.fromRGB(62, 64, 62))
	t.WaterColor = Color3.fromRGB(40, 70, 64)
	t.WaterTransparency = 0.5
	t.WaterWaveSize = 0.05

	-- Base ground: top surface at y = 0.
	fillOutside(-EDGE, EDGE, -EDGE, EDGE, -4, 8, Material.LeafyGrass)
	-- Farmland-gone-wild east and south of the city.
	fillOutside(700, EDGE, -1400, 1200, -4, 8, Material.Grass)
	-- Dead Zone around Halvorsen Station.
	fillOutside(250, 1150, 2400, 3100, -4, 8, Material.Slate)
	-- Rail's End yard.
	fillOutside(2250, 2750, -1150, -650, -4, 8, Material.Ground)
	-- The Drowned Marsh: mud with a shallow sheet of water.
	fillOutside(-1700, -150, -2950, -1550, -4, 8, Material.Mud)
	fillOutside(-1600, -250, -2850, -1650, -1, 2, Material.Water)

	-- Hills along the far edges for a horizon.
	local rng = Random.new(12)
	local keep = { Vector3.new(700, 0, 2750), Vector3.new(-2000, 0, 1500), Vector3.new(2500, 0, -900), Vector3.new(-900, 0, -2200) }
	for k = 0, 35 do
		local a = k / 36 * math.pi * 2
		local r = rng:NextNumber(2850, 3100)
		local p = Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
		local clear = true
		for _, spot in ipairs(keep) do
			if (spot - p).Magnitude < 650 then
				clear = false
			end
		end
		if clear then
			local radius = rng:NextNumber(160, 300)
			t:FillBall(p - Vector3.new(0, radius * 0.55, 0), radius, Material.Grass)
		end
	end
end

return Terrain
