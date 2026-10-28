-- Builds companion models from Data/Companions and keeps the active one at the player's heel.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared.Config)
local Net = require(Shared.Net)
local Companions = require(Shared.Data.Companions)

local PlayerData = require(script.Parent.PlayerData)
local Story = require(script.Parent.Story)

local CompanionService = {}

local cfg = Config.Companions
local active = {} -- player -> { id, def, model, root, height, flying, lastScavenge }
local folder

-- Model building ---------------------------------------------------------------------

local function newPart(model, name, size, offset, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = material
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p:SetAttribute("Offset", offset)
	p.Parent = model
	return p
end

-- Returns model, root, height of root above ground, flying.
local function build(def)
	local look = def.look
	local s = look.size or 1
	local body = Color3.fromHex(look.color)
	local accent = Color3.fromHex(look.accent)
	local material = if look.robot then Enum.Material.Metal else Enum.Material.SmoothPlastic
	local eyeMaterial = if look.robot or look.glow then Enum.Material.Neon else Enum.Material.SmoothPlastic
	local model = Instance.new("Model")
	model.Name = def.name

	local parts = {}
	local function add(name, size, offset, color, mat)
		local p = newPart(model, name, size * s, offset * s, color, mat or material)
		table.insert(parts, p)
		return p
	end

	local root, height, flying
	if look.shape == "dog" or look.shape == "cat" then
		local cat = look.shape == "cat"
		local legH = if cat then 0.7 else 1
		local bodySize = if cat then Vector3.new(0.9, 0.8, 2) else Vector3.new(1.4, 1, 2.6)
		root = add("Body", bodySize, Vector3.zero, body)
		local headZ = -(bodySize.Z / 2 + 0.3)
		add("Head", Vector3.new(0.9, 0.9, 0.9), Vector3.new(0, 0.6, headZ), body)
		if not cat then
			add("Snout", Vector3.new(0.5, 0.4, 0.5), Vector3.new(0, 0.45, headZ - 0.6), accent)
		end
		add("EarL", Vector3.new(0.22, 0.4, 0.15), Vector3.new(-0.3, 1.2, headZ), accent)
		add("EarR", Vector3.new(0.22, 0.4, 0.15), Vector3.new(0.3, 1.2, headZ), accent)
		add("EyeL", Vector3.new(0.14, 0.14, 0.05), Vector3.new(-0.2, 0.7, headZ - 0.46), accent, eyeMaterial)
		add("EyeR", Vector3.new(0.14, 0.14, 0.05), Vector3.new(0.2, 0.7, headZ - 0.46), accent, eyeMaterial)
		for _, x in ipairs({ -1, 1 }) do
			for _, z in ipairs({ -1, 1 }) do
				add("Leg", Vector3.new(0.3, legH, 0.3), Vector3.new(x * (bodySize.X / 2 - 0.15), -(bodySize.Y + legH) / 2, z * (bodySize.Z / 2 - 0.3)), body)
			end
		end
		local tailLen = if cat then 1.6 else 1
		add("Tail", Vector3.new(0.18, 0.18, tailLen), Vector3.new(0, 0.35, bodySize.Z / 2 + tailLen / 2 - 0.1), accent)
		height = (bodySize.Y / 2 + legH) * s
		flying = false
	elseif look.shape == "bird" then
		root = add("Body", Vector3.new(0.6, 0.6, 1), Vector3.zero, body)
		add("Head", Vector3.new(0.45, 0.45, 0.45), Vector3.new(0, 0.35, -0.55), body)
		add("Beak", Vector3.new(0.15, 0.12, 0.35), Vector3.new(0, 0.3, -0.9), Color3.fromRGB(220, 180, 60))
		add("WingL", Vector3.new(0.9, 0.08, 0.6), Vector3.new(-0.7, 0.1, 0), accent)
		add("WingR", Vector3.new(0.9, 0.08, 0.6), Vector3.new(0.7, 0.1, 0), accent)
		add("Eye", Vector3.new(0.5, 0.08, 0.08), Vector3.new(0, 0.42, -0.75), Color3.fromRGB(255, 220, 80), eyeMaterial)
		height, flying = 6.5, true
	elseif look.shape == "drone" then
		root = add("Body", Vector3.new(1.4, 0.45, 1.4), Vector3.zero, body)
		add("Lens", Vector3.new(0.5, 0.3, 0.1), Vector3.new(0, -0.05, -0.72), accent, Enum.Material.Neon)
		for _, x in ipairs({ -1, 1 }) do
			for _, z in ipairs({ -1, 1 }) do
				add("Rotor", Vector3.new(0.8, 0.06, 0.8), Vector3.new(x * 0.9, 0.3, z * 0.9), accent, Enum.Material.Neon)
			end
		end
		height, flying = 7, true
	else -- spider
		root = add("Body", Vector3.new(1.2, 0.7, 1.4), Vector3.zero, body)
		add("Eyes", Vector3.new(0.7, 0.18, 0.08), Vector3.new(0, 0.1, -0.72), accent, Enum.Material.Neon)
		for i = 0, 3 do
			for _, x in ipairs({ -1, 1 }) do
				local z = -0.55 + i * 0.37
				local leg = add("Leg", Vector3.new(1.3, 0.12, 0.12), Vector3.new(x * 1.1, 0.1, z), body)
				leg:SetAttribute("Tilt", x * 25)
			end
		end
		height, flying = 0.7 * s, false
	end

	root.Anchored = true
	for _, p in ipairs(parts) do
		if p ~= root then
			local tilt = p:GetAttribute("Tilt") or 0
			p.CFrame = root.CFrame * CFrame.new(p:GetAttribute("Offset")) * CFrame.Angles(0, 0, math.rad(tilt))
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = root
			weld.Part1 = p
			weld.Parent = p
		end
	end
	model.PrimaryPart = root

	if def.perk == "light" or look.glow then
		local light = Instance.new("PointLight")
		light.Color = accent
		light.Range = if def.perk == "light" then 28 else 10
		light.Brightness = if def.perk == "light" then 1.6 else 0.8
		light.Shadows = def.perk == "light"
		light.Parent = root
	end
	return model, root, height, flying
end

-- Lifecycle ----------------------------------------------------------------------------

function CompanionService.dismiss(player)
	local entry = active[player]
	if entry then
		entry.model:Destroy()
		active[player] = nil
	end
end

function CompanionService.summon(player, id)
	local s = PlayerData.get(player)
	local def = Companions.list[id]
	local proot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not s or not def or not s.companions[id] then
		return
	end
	CompanionService.dismiss(player)
	s.companion = id
	Story.push(player)
	if not proot then
		return
	end
	local model, root, height, flying = build(def)
	model.Name = player.Name .. "_" .. def.name
	model:PivotTo(CFrame.new(proot.Position + Vector3.new(3, height, 3)))
	model.Parent = folder
	active[player] = { id = id, def = def, model = model, root = root, height = height, flying = flying, lastScavenge = os.clock() }
end

-- Called by Shop when a companion is bought.
function CompanionService.grant(player, id)
	local s = PlayerData.get(player)
	if not s then
		return
	end
	s.companions[id] = true
	CompanionService.summon(player, id)
	Story.notify(player, Companions.list[id].name .. " is now following you. Manage companions in the journal.", "item")
end

function CompanionService.perk(player)
	local entry = active[player]
	return entry and entry.def.perk, entry and entry.def.name
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function groundY(position)
	local exclude = { folder }
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			table.insert(exclude, p.Character)
		end
	end
	local npcs = Workspace:FindFirstChild("NPCs")
	if npcs then
		table.insert(exclude, npcs)
	end
	rayParams.FilterDescendantsInstances = exclude
	local hit = Workspace:Raycast(position + Vector3.new(0, 6, 0), Vector3.new(0, -40, 0), rayParams)
	return hit and hit.Position.Y
end

local function step(dt)
	local now = os.clock()
	for player, entry in pairs(active) do
		local proot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not proot or not entry.model.Parent then
			continue
		end
		local behind = proot.Position - proot.CFrame.LookVector * cfg.FollowDistance + proot.CFrame.RightVector * 2.5
		local current = entry.root.Position
		local target
		if entry.flying then
			target = behind + Vector3.new(0, entry.height - 3 + math.sin(now * 2) * 0.4, 0)
		else
			local y = groundY(behind) or (proot.Position.Y - 3)
			target = Vector3.new(behind.X, y + entry.height, behind.Z)
		end
		local position
		if (target - current).Magnitude > cfg.TeleportDistance then
			position = target
		else
			position = current:Lerp(target, math.min(1, dt * 5))
		end
		local flat = Vector3.new(position.X - current.X, 0, position.Z - current.Z)
		local facing
		if flat.Magnitude > 0.05 then
			facing = flat.Unit
		else
			local toPlayer = Vector3.new(proot.Position.X - position.X, 0, proot.Position.Z - position.Z)
			facing = if toPlayer.Magnitude > 0.1 then toPlayer.Unit else Vector3.new(0, 0, -1)
		end
		-- Little trot bob while moving.
		local bob = if not entry.flying and flat.Magnitude > 0.05 then math.abs(math.sin(now * 12)) * 0.15 else 0
		entry.root.CFrame = CFrame.lookAt(position + Vector3.new(0, bob, 0), position + Vector3.new(0, bob, 0) + facing)

		if entry.def.perk == "scavenge" and now - entry.lastScavenge > cfg.ScavengeIntervalSeconds then
			entry.lastScavenge = now
			if math.random() < 0.5 then
				local amount = math.random(3, 15)
				local s = PlayerData.get(player)
				if s then
					Story.apply(player, { { credits = amount }, { notify = "Your " .. entry.def.name .. " brought you something shiny.", kind = "info" } })
				end
			end
		end
	end
end

function CompanionService.init()
	folder = Instance.new("Folder")
	folder.Name = "Companions"
	folder.Parent = Workspace

	Net.Companion.OnServerEvent:Connect(function(player, id)
		local s = PlayerData.get(player)
		if not s then
			return
		end
		if id == nil then
			CompanionService.dismiss(player)
			s.companion = nil
			Story.push(player)
		elseif type(id) == "string" then
			CompanionService.summon(player, id)
		end
	end)

	Players.PlayerRemoving:Connect(CompanionService.dismiss)
	RunService.Heartbeat:Connect(step)
end

-- Re-summon after respawn.
function CompanionService.onCharacterAdded(player)
	local s = PlayerData.get(player)
	CompanionService.dismiss(player)
	if s and s.companion and s.companions[s.companion] then
		task.delay(0.5, function()
			CompanionService.summon(player, s.companion)
		end)
	end
end

return CompanionService
