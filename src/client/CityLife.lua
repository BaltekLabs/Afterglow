--[[
	Client-side city life, so it costs no server bandwidth:
	  - flying cars streaming along sky lanes between the towers
	  - holographic adverts that flicker, cycle text and shift color
	  - blinking aircraft beacons on rooftops and towers
]]
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local CityLife = {}

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

local ADS = {
	"ASCENT BIOTECH\nGROWING TOMORROW",
	"CIVIC STRAIN V-7\nSAFE • CLEAN • GREEN",
	"14 YEARS OF LIGHT",
	"THE VEIL\nKEEPS YOU SAFE",
	"HOVERCAB\nRIDE THE SKY",
	"REPORT WILD GROWTH",
	"GLOWBOWL 24/7",
	"NEURALINK\nFEEL MORE",
	"THE CROWN\nASPIRE HIGHER",
	"MARIGOLD'S\nMENAGERIE",
}
local CAR_COLORS = { rgb(220, 60, 80), rgb(40, 160, 255), rgb(250, 250, 250), rgb(30, 30, 36), rgb(255, 200, 40), rgb(140, 80, 255) }
local LIGHT_COLORS = { rgb(64, 240, 255), rgb(255, 64, 200), rgb(255, 170, 60) }

-- Lanes follow streets (tile edges) so cars never fly through towers.
-- Each lane is a closed rectangle: { x0, x1, z0, z1, y, speed, cars }
local LANES = {
	{ -384, 384, -384, 384, 118, 60, 10 },
	{ -512, 512, -512, 512, 135, 75, 12 },
	{ -384, 384, -384, 384, 205, -55, 8 },
	{ -512, 512, -128 - 256, 128 + 256, 250, 70, 8 },
	{ -632, 632, -632, 632, 300, -80, 10 }, -- just inside the Wall
	{ -128 - 256, 128 + 256, -512, 512, 380, 90, 8 },
}

local function buildCar(color, glow)
	local model = Instance.new("Model")
	local function part(size, offset, partColor, material, transparency)
		local p = Instance.new("Part")
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Size = size
		p.Color = partColor
		p.Material = material
		p.Transparency = transparency or 0
		p:SetAttribute("Offset", offset)
		p.Parent = model
		return p
	end
	local body = part(Vector3.new(4.5, 1.6, 9), CFrame.new(), color, Enum.Material.SmoothPlastic)
	part(Vector3.new(3.6, 1.2, 4), CFrame.new(0, 1.2, 0.3), rgb(20, 30, 40), Enum.Material.Glass, 0.3)
	part(Vector3.new(4.7, 0.25, 9.2), CFrame.new(0, -0.7, 0), glow, Enum.Material.Neon)
	part(Vector3.new(3.4, 0.4, 0.1), CFrame.new(0, 0.2, -4.55), rgb(255, 250, 230), Enum.Material.Neon)
	part(Vector3.new(3.4, 0.4, 0.1), CFrame.new(0, 0.2, 4.55), rgb(255, 40, 40), Enum.Material.Neon)
	model.PrimaryPart = body
	return model
end

local function lanePoint(lane, t)
	local x0, x1, z0, z1 = lane[1], lane[2], lane[3], lane[4]
	local w, d = x1 - x0, z1 - z0
	local perimeter = 2 * (w + d)
	local s = (t % 1) * perimeter
	if s < w then
		return Vector3.new(x0 + s, lane[5], z0)
	end
	s -= w
	if s < d then
		return Vector3.new(x1, lane[5], z0 + s)
	end
	s -= d
	if s < w then
		return Vector3.new(x1 - s, lane[5], z1)
	end
	s -= w
	return Vector3.new(x0, lane[5], z1 - s)
end

function CityLife.init()
	local folder = Instance.new("Folder")
	folder.Name = "Traffic"
	folder.Parent = Workspace
	local rng = Random.new()

	local cars = {}
	for _, lane in ipairs(LANES) do
		local perimeter = 2 * ((lane[2] - lane[1]) + (lane[4] - lane[3]))
		for k = 1, lane[7] do
			local model = buildCar(CAR_COLORS[rng:NextInteger(1, #CAR_COLORS)], LIGHT_COLORS[rng:NextInteger(1, #LIGHT_COLORS)])
			model.Parent = folder
			local parts = {}
			for _, p in ipairs(model:GetChildren()) do
				table.insert(parts, { part = p, offset = p:GetAttribute("Offset") })
			end
			table.insert(cars, {
				parts = parts,
				lane = lane,
				t = k / lane[7] + rng:NextNumber(0, 0.05),
				rate = lane[6] / perimeter,
				bob = rng:NextNumber(0, 6),
			})
		end
	end

	RunService.Heartbeat:Connect(function(dt)
		local now = os.clock()
		for _, car in ipairs(cars) do
			car.t += car.rate * dt
			local pos = lanePoint(car.lane, car.t) + Vector3.new(0, math.sin(now + car.bob) * 0.6, 0)
			local ahead = lanePoint(car.lane, car.t + 0.002 * math.sign(car.rate))
			local cf = CFrame.lookAt(pos, Vector3.new(ahead.X, pos.Y, ahead.Z) + Vector3.new(0.001, 0, 0))
			for _, entry in ipairs(car.parts) do
				entry.part.CFrame = cf * entry.offset
			end
		end
	end)

	-- Holograms and beacons.
	task.spawn(function()
		while true do
			task.wait(0.15)
			local now = os.clock()
			for _, holo in ipairs(CollectionService:GetTagged("Holo")) do
				local phase = (holo:GetAttribute("Phase") or rng:NextNumber(0, 10))
				holo:SetAttribute("Phase", phase)
				-- Flicker and a slow shimmer.
				local flicker = if rng:NextNumber() < 0.04 then 0.97 else 0.78 + math.sin(now * 2 + phase) * 0.04
				holo.Transparency = flicker
				local cycle = math.floor((now + phase * 3) / 6)
				if holo:GetAttribute("Cycle") ~= cycle then
					holo:SetAttribute("Cycle", cycle)
					local text = ADS[(cycle + math.floor(phase * 10)) % #ADS + 1]
					for _, gui in ipairs(holo:GetChildren()) do
						local label = gui:FindFirstChild("Text")
						if label and rng:NextNumber() < 0.5 then
							label.Text = text
						end
					end
				end
			end
			for _, part in ipairs(CollectionService:GetTagged("Blink")) do
				part.Transparency = if math.floor(now * 1.2) % 2 == 0 then 0 else 0.9
			end
		end
	end)

	-- Beacons are marked with an attribute; tag them locally for the loop above.
	for _, d in ipairs(Workspace:GetDescendants()) do
		if d:IsA("BasePart") and d:GetAttribute("Blink") then
			CollectionService:AddTag(d, "Blink")
		end
	end
end

return CityLife
