-- Per-region mood: fog, grading and bloom shift between the city's tiers and the Outlands.
-- Also drives the spore overlay and flickering lights.
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local ClientState = require(script.Parent.ClientState)

local AmbienceController = {}

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

local function preset(title, subtitle, ambient, outdoor, atmosphere, grade, bloom)
	return {
		title = title,
		subtitle = subtitle,
		ambient = ambient,
		outdoor = outdoor,
		atmosphere = atmosphere,
		grade = grade,
		bloom = bloom,
	}
end

local PRESETS = {
	rust = preset("THE RUST", "Veyra, street level", rgb(46, 30, 40), rgb(60, 40, 50),
		{ Density = 0.42, Color = rgb(140, 90, 110), Decay = rgb(90, 40, 60), Haze = 2.4, Glare = 0 },
		{ Saturation = 0.2, Contrast = 0.15, TintColor = rgb(255, 225, 225) },
		{ Intensity = 1.3, Threshold = 0.85 }),
	grid = preset("THE GRID", "Veyra, where ordinary people live", rgb(34, 30, 54), rgb(80, 70, 110),
		{ Density = 0.3, Color = rgb(170, 130, 210), Decay = rgb(80, 40, 120), Haze = 1.4, Glare = 0.3 },
		{ Saturation = 0.14, Contrast = 0.08, TintColor = rgb(240, 232, 255) },
		{ Intensity = 1, Threshold = 0.92 }),
	crown = preset("THE CROWN", "Where the city keeps its rich and its rulers", rgb(60, 54, 44), rgb(130, 120, 100),
		{ Density = 0.22, Color = rgb(240, 210, 170), Decay = rgb(140, 100, 70), Haze = 0.8, Glare = 0.6 },
		{ Saturation = 0.05, Contrast = 0.05, TintColor = rgb(255, 245, 225) },
		{ Intensity = 0.9, Threshold = 0.95 }),
	sewers = preset("THE STORM SEWERS", "Under the Rust", rgb(26, 34, 30), rgb(26, 34, 30),
		{ Density = 0.55, Color = rgb(90, 120, 100), Decay = rgb(30, 50, 40), Haze = 3, Glare = 0 },
		{ Saturation = -0.15, Contrast = 0.2, TintColor = rgb(220, 255, 235) },
		{ Intensity = 1.1, Threshold = 0.9 }),
	outlands = preset("THE OUTLANDS", "Outside the Wall", rgb(36, 44, 44), rgb(80, 100, 96),
		{ Density = 0.35, Color = rgb(160, 190, 180), Decay = rgb(60, 80, 80), Haze = 1.6, Glare = 0.3 },
		{ Saturation = 0.15, Contrast = 0.08, TintColor = rgb(235, 250, 245) },
		{ Intensity = 1, Threshold = 0.9 }),
	wilds = preset("THE SPOREWILDS", "Beyond the Wall", rgb(20, 44, 44), rgb(50, 100, 96),
		{ Density = 0.45, Color = rgb(110, 210, 190), Decay = rgb(20, 80, 90), Haze = 2.2, Glare = 0.1 },
		{ Saturation = 0.28, Contrast = 0.12, TintColor = rgb(215, 255, 240) },
		{ Intensity = 1.4, Threshold = 0.85 }),
	hollow = preset("HOLLOW GARDEN", "Fringe village", rgb(48, 36, 28), rgb(100, 80, 60),
		{ Density = 0.36, Color = rgb(220, 170, 120), Decay = rgb(110, 60, 30), Haze = 1.6, Glare = 0.2 },
		{ Saturation = 0.18, Contrast = 0.06, TintColor = rgb(255, 238, 220) },
		{ Intensity = 1.1, Threshold = 0.9 }),
	deadzone = preset("THE DEAD ZONE", "Halvorsen BioResearch Station", rgb(30, 34, 32), rgb(64, 70, 66),
		{ Density = 0.52, Color = rgb(150, 160, 150), Decay = rgb(50, 60, 55), Haze = 2.6, Glare = 0 },
		{ Saturation = -0.35, Contrast = 0.2, TintColor = rgb(225, 240, 230) },
		{ Intensity = 0.7, Threshold = 0.95 }),
	suburbs = preset("THE OVERGROWN SUBURBS", "What the old world left behind", rgb(40, 42, 36), rgb(96, 96, 80),
		{ Density = 0.38, Color = rgb(190, 190, 160), Decay = rgb(90, 90, 60), Haze = 1.8, Glare = 0.3 },
		{ Saturation = -0.05, Contrast = 0.1, TintColor = rgb(250, 245, 225) },
		{ Intensity = 0.9, Threshold = 0.92 }),
	railsend = preset("RAIL'S END", "Fringe village", rgb(50, 40, 30), rgb(110, 90, 70),
		{ Density = 0.34, Color = rgb(230, 180, 130), Decay = rgb(120, 70, 40), Haze = 1.5, Glare = 0.3 },
		{ Saturation = 0.12, Contrast = 0.08, TintColor = rgb(255, 238, 215) },
		{ Intensity = 1, Threshold = 0.9 }),
	marsh = preset("THE DROWNED MARSH", "South of the Wall", rgb(30, 40, 40), rgb(70, 90, 90),
		{ Density = 0.5, Color = rgb(150, 180, 175), Decay = rgb(50, 70, 70), Haze = 2.8, Glare = 0.1 },
		{ Saturation = 0, Contrast = 0.1, TintColor = rgb(225, 245, 240) },
		{ Intensity = 1, Threshold = 0.9 }),
	mirefall = preset("MIREFALL", "Fringe village", rgb(36, 46, 44), rgb(80, 100, 96),
		{ Density = 0.44, Color = rgb(170, 200, 190), Decay = rgb(60, 80, 70), Haze = 2.2, Glare = 0.2 },
		{ Saturation = 0.08, Contrast = 0.08, TintColor = rgb(235, 250, 245) },
		{ Intensity = 1.1, Threshold = 0.88 }),
}

local player = Players.LocalPlayer
local currentRegion

local function inside(part, position)
	local lp = part.CFrame:PointToObjectSpace(position)
	local half = part.Size / 2
	return math.abs(lp.X) <= half.X and math.abs(lp.Y) <= half.Y and math.abs(lp.Z) <= half.Z
end

local function apply(p)
	local info = TweenInfo.new(3, Enum.EasingStyle.Sine)
	TweenService:Create(Lighting, info, { Ambient = p.ambient, OutdoorAmbient = p.outdoor }):Play()
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		TweenService:Create(atmosphere, info, p.atmosphere):Play()
	end
	local grade = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	if grade then
		TweenService:Create(grade, info, p.grade):Play()
	end
	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if bloom then
		TweenService:Create(bloom, info, p.bloom):Play()
	end
end

local function sporeImmune()
	local s = ClientState.state
	return s and (s.character == "juno" or (s.inventory.filter_mask or 0) > 0)
end

function AmbienceController.init(ui)
	task.spawn(function()
		while true do
			task.wait(0.3)
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if root and ClientState.state and ClientState.state.character then
				local best, bestPriority = nil, -math.huge
				local inSpores = false
				for _, zone in ipairs(CollectionService:GetTagged("Zone")) do
					if inside(zone, root.Position) then
						local kind = zone:GetAttribute("ZoneType")
						if kind == "Region" and (zone:GetAttribute("Priority") or 0) > bestPriority then
							best, bestPriority = zone:GetAttribute("Region"), zone:GetAttribute("Priority") or 0
						elseif kind == "Spores" then
							inSpores = true
						end
					end
				end
				if best and best ~= currentRegion and PRESETS[best] then
					currentRegion = best
					apply(PRESETS[best])
					ui.Overlay.banner(PRESETS[best].title, PRESETS[best].subtitle)
					ui.Hud.setRegion(PRESETS[best].title)
				end
				ui.Overlay.setSpores(inSpores, sporeImmune())
			end
		end
	end)

	-- Failing lights in the Dead Zone.
	task.spawn(function()
		while true do
			task.wait(0.08 + math.random() * 0.25)
			for _, part in ipairs(CollectionService:GetTagged("Flicker")) do
				local light = part:FindFirstChildOfClass("PointLight")
				if light and math.random() < 0.3 then
					local on = math.random() > 0.35
					light.Enabled = on
					part.Transparency = if on then 0 else 0.6
				end
			end
		end
	end)
end

return AmbienceController
