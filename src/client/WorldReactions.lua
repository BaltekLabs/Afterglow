--[[
	Visible, per-player consequences of story state. These changes are local to your client,
	so each player's world reflects their own choices:
	  unlocked_<Key>   a locked building door you opened stays open (for you)
	  station_open     Halvorsen's doors open
	  cells_delivered  the plaza generator lights up
	  seeds_to_fringe  a green shoot appears in Hollow Garden
	  ending_silence   the plaza's lights go dark; the relay roots die
	  ending_answered  the plaza glow turns red
]]
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local ClientState = require(script.Parent.ClientState)

local WorldReactions = {}

local applied = {}
local originals = {} -- part -> saved properties, so a save reset can restore the world

local function remember(part)
	if originals[part] then
		return
	end
	local lights = {}
	for _, child in ipairs(part:GetChildren()) do
		if child:IsA("Light") then
			lights[child] = { Enabled = child.Enabled, Color = child.Color }
		end
	end
	originals[part] = {
		CFrame = part.CFrame,
		CanCollide = part.CanCollide,
		Color = part.Color,
		Material = part.Material,
		Transparency = part.Transparency,
		lights = lights,
	}
end

local function once(key, fn)
	if not applied[key] then
		applied[key] = true
		fn()
	end
end

local function slide(tag, offset)
	for _, part in ipairs(CollectionService:GetTagged(tag)) do
		remember(part)
		part.CanCollide = false
		TweenService:Create(part, TweenInfo.new(2.5, Enum.EasingStyle.Quad), { CFrame = part.CFrame + offset }):Play()
	end
end

local function recolor(tag, color, material, lightsOff)
	for _, part in ipairs(CollectionService:GetTagged(tag)) do
		if part:IsA("BasePart") then
			remember(part)
			TweenService:Create(part, TweenInfo.new(2), { Color = color }):Play()
			if material then
				part.Material = material
			end
			for _, child in ipairs(part:GetChildren()) do
				if child:IsA("Light") then
					if lightsOff then
						child.Enabled = false
					else
						child.Color = color
					end
				end
			end
		end
	end
end

local function update(s)
	if not s then
		return
	end
	local f = s.flags
	-- Locked doors this player has hacked, picked or keyed open.
	for _, door in ipairs(CollectionService:GetTagged("Door")) do
		if door:GetAttribute("Mode") == "locked" and f["unlocked_" .. tostring(door:GetAttribute("Key"))] and door.CanCollide then
			remember(door)
			door.CanCollide = false
			TweenService:Create(door, TweenInfo.new(0.6), { Transparency = 0.85 }):Play()
			local gui = door:FindFirstChildOfClass("SurfaceGui")
			if gui then
				gui.Enabled = false
			end
		end
	end
	if f.station_open then
		once("station", function()
			slide("StationDoor", Vector3.new(0, 11.5, 0))
		end)
	end
	if f.cells_delivered then
		once("generator", function()
			for _, part in ipairs(CollectionService:GetTagged("GeneratorLight")) do
				remember(part)
				part.Material = Enum.Material.Neon
				part.Color = Color3.fromRGB(90, 255, 190)
			end
		end)
	end
	if f.seeds_to_fringe then
		once("shoot", function()
			for _, part in ipairs(CollectionService:GetTagged("GreenShoot")) do
				remember(part)
				TweenService:Create(part, TweenInfo.new(3), { Transparency = 0 }):Play()
			end
		end)
	end
	if f.ending_silence then
		once("silence", function()
			recolor("PlazaNeon", Color3.fromRGB(40, 40, 46), Enum.Material.SmoothPlastic, true)
			recolor("RelayRoots", Color3.fromRGB(70, 56, 44), Enum.Material.Wood, true)
		end)
	end
	if f.ending_answered then
		once("answered", function()
			recolor("PlazaNeon", Color3.fromRGB(255, 50, 60))
			recolor("RelayRoots", Color3.fromRGB(255, 50, 60))
		end)
	end
end

-- Undo every local change (used when the save is wiped for a replay).
function WorldReactions.restore()
	for part, saved in pairs(originals) do
		if part.Parent then
			part.CFrame = saved.CFrame
			part.CanCollide = saved.CanCollide
			part.Color = saved.Color
			part.Material = saved.Material
			part.Transparency = saved.Transparency
			for light, props in pairs(saved.lights) do
				light.Enabled = props.Enabled
				light.Color = props.Color
			end
			local gui = part:FindFirstChildOfClass("SurfaceGui")
			if gui then
				gui.Enabled = true
			end
		end
	end
	table.clear(originals)
	table.clear(applied)
end

function WorldReactions.init()
	ClientState.Changed:Connect(function(s)
		if s and not s.character then
			WorldReactions.restore()
		end
		update(s)
	end)
end

return WorldReactions
