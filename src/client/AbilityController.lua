--[[
	Character abilities on [Q] / gamepad Y:
	  insight  (Mara)   highlight interactables nearby and reveal hidden ones
	  dash     (Juno)   short burst of speed in the camera direction
	  analyze  (Renn)   highlight Rooted (red) and Vesper growth (teal) through walls
	  grapple  (Silas)  pull yourself to wherever the camera is aimed
	  hack / overload / bloom / cloak (Dex, Teo, Ivy, Sable) are resolved on the server
	  (AbilityService) and play their local effects when confirmed.
]]
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Characters = require(Shared.Data.Characters)
local Net = require(Shared.Net)

local ClientState = require(script.Parent.ClientState)
local PromptController = require(script.Parent.PromptController)
local CameraController = require(script.Parent.CameraController)

local AbilityController = {}

local MAX_HIGHLIGHTS = 28

local player = Players.LocalPlayer
local readyAt = 0
local ui

local function highlight(adornee, fill, outline, duration)
	local h = Instance.new("Highlight")
	h.Adornee = adornee
	h.FillColor = fill
	h.OutlineColor = outline
	h.FillTransparency = 0.65
	h.OutlineTransparency = 0
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.Parent = adornee
	task.delay(duration, function()
		h:Destroy()
	end)
end

local function nearest(list, origin, radius, limit)
	local scored = {}
	for _, item in ipairs(list) do
		local pos = if item.part:IsA("Model") then item.part:GetPivot().Position else item.part.Position
		local d = (pos - origin).Magnitude
		if d <= radius then
			table.insert(scored, { item = item, d = d })
		end
	end
	table.sort(scored, function(a, b)
		return a.d < b.d
	end)
	local out = {}
	for i = 1, math.min(limit, #scored) do
		out[i] = scored[i].item
	end
	return out
end

local function insight(ability, root)
	ClientState.revealedUntil = os.clock() + ability.duration
	PromptController.refresh()
	task.delay(ability.duration + 0.1, PromptController.refresh)
	local found = nearest(PromptController.interactableParts(), root.Position, ability.radius, MAX_HIGHLIGHTS)
	local hidden = 0
	for _, item in ipairs(found) do
		if item.hidden then
			hidden += 1
		end
		highlight(item.part, Color3.fromRGB(255, 176, 72), if item.hidden then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(255, 176, 72), ability.duration)
	end
	if hidden > 0 then
		ui.Overlay.toast("Insight: something hidden is nearby.", "lore")
	elseif #found > 0 then
		ui.Overlay.toast("Insight: " .. #found .. " point(s) of interest nearby.", "info")
	else
		ui.Overlay.toast("Insight: nothing out of place here.", "info")
	end
end

local function analyze(ability, root)
	local items = {}
	for _, model in ipairs(CollectionService:GetTagged("Rooted")) do
		table.insert(items, { part = model, rooted = true })
	end
	local rooted = nearest(items, root.Position, ability.radius, 12)
	for _, item in ipairs(rooted) do
		highlight(item.part, Color3.fromRGB(255, 60, 50), Color3.fromRGB(255, 120, 100), ability.duration)
	end
	local vesper = {}
	for _, part in ipairs(CollectionService:GetTagged("Vesper")) do
		if part:IsA("BasePart") then
			table.insert(vesper, { part = part })
		end
	end
	for _, item in ipairs(nearest(vesper, root.Position, ability.radius * 0.5, MAX_HIGHLIGHTS - #rooted)) do
		highlight(item.part, Color3.fromRGB(90, 255, 190), Color3.fromRGB(90, 255, 190), ability.duration)
	end
	if #rooted > 0 then
		ui.Overlay.toast("Analyze: " .. #rooted .. " Rooted within range. Move quietly.", "warn")
	else
		ui.Overlay.toast("Analyze: no Rooted nearby. The lattice hums.", "info")
	end
end

local function dash(ability, root)
	local attachment = Instance.new("Attachment")
	attachment.Parent = root
	local velocity = Instance.new("LinearVelocity")
	velocity.Attachment0 = attachment
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	velocity.PrimaryTangentAxis = Vector3.xAxis
	velocity.SecondaryTangentAxis = Vector3.zAxis
	local dir = CameraController.forward()
	velocity.PlaneVelocity = Vector2.new(dir.X, dir.Z) * ability.power
	velocity.MaxForce = math.huge
	velocity.Parent = root
	task.delay(0.18, function()
		velocity:Destroy()
		attachment:Destroy()
	end)
end

-- Silas: fire a line where the camera is looking and get pulled to it.
local function grapple(ability, root)
	local camera = Workspace.CurrentCamera
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }
	local hit = Workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * (ability.range + 20), params)
	if not hit or (hit.Position - root.Position).Magnitude > ability.range then
		ui.Overlay.toast("Grapple: nothing to hook within range.", "info")
		return false
	end
	local target = hit.Position + hit.Normal * 2.5 + Vector3.new(0, 2, 0)
	-- The line.
	local a0 = Instance.new("Attachment")
	a0.Parent = root
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(0.2, 0.2, 0.2)
	anchor.Position = hit.Position
	anchor.Parent = Workspace
	local a1 = Instance.new("Attachment")
	a1.Parent = anchor
	local line = Instance.new("Beam")
	line.Attachment0 = a0
	line.Attachment1 = a1
	line.Width0, line.Width1 = 0.15, 0.15
	line.Color = ColorSequence.new(Color3.fromRGB(255, 224, 138))
	line.LightEmission = 1
	line.FaceCamera = true
	line.Parent = anchor
	-- The pull.
	local velocity = Instance.new("LinearVelocity")
	velocity.Attachment0 = a0
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.MaxForce = math.huge
	velocity.Parent = root
	local started = os.clock()
	local maxTime = (target - root.Position).Magnitude / ability.speed + 0.4
	task.spawn(function()
		while os.clock() - started < maxTime do
			local offset = target - root.Position
			if offset.Magnitude < 4 then
				break
			end
			velocity.VectorVelocity = offset.Unit * ability.speed
			RunService.Heartbeat:Wait()
		end
		velocity:Destroy()
		root.AssemblyLinearVelocity = Vector3.new(0, 8, 0)
		anchor:Destroy()
		a0:Destroy()
	end)
	return true
end

-- Local feedback once the server confirms a server-side ability.
local function playFx(abilityId, duration)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	if abilityId == "bloom" then
		local aura = Instance.new("PointLight")
		aura.Color = Color3.fromRGB(150, 255, 170)
		aura.Range = 40
		aura.Brightness = 2
		aura.Parent = root
		local petals = Instance.new("ParticleEmitter")
		petals.Rate = 30
		petals.Lifetime = NumberRange.new(2, 3)
		petals.Speed = NumberRange.new(2, 5)
		petals.SpreadAngle = Vector2.new(180, 180)
		petals.Color = ColorSequence.new(Color3.fromRGB(150, 255, 170))
		petals.LightEmission = 1
		petals.Size = NumberSequence.new(0.4)
		petals.Parent = root
		task.delay(duration, function()
			aura:Destroy()
			petals:Destroy()
		end)
	elseif abilityId == "overload" or abilityId == "hack" then
		local pulse = Instance.new("Part")
		pulse.Shape = Enum.PartType.Ball
		pulse.Anchored = true
		pulse.CanCollide = false
		pulse.CanQuery = false
		pulse.Material = Enum.Material.ForceField
		pulse.Color = if abilityId == "hack" then Color3.fromRGB(60, 240, 255) else Color3.fromRGB(255, 140, 60)
		pulse.Size = Vector3.new(2, 2, 2)
		pulse.Position = root.Position
		pulse.Parent = Workspace
		local size = if abilityId == "hack" then 40 else 280
		TweenService:Create(pulse, TweenInfo.new(0.6), { Size = Vector3.new(size, size, size), Transparency = 1 }):Play()
		task.delay(0.7, function()
			pulse:Destroy()
		end)
	end
end

local SERVER_ABILITIES = { hack = true, overload = true, bloom = true, cloak = true }

local function activate()
	local s = ClientState.state
	local def = s and s.character and Characters.list[s.character]
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not def or not root or ui.isBusy() then
		return
	end
	if os.clock() < readyAt then
		return
	end
	local ability = def.ability
	if ability.id == "grapple" then
		if not grapple(ability, root) then
			return -- a miss doesn't cost the cooldown
		end
	elseif ability.id == "insight" then
		insight(ability, root)
	elseif ability.id == "analyze" then
		analyze(ability, root)
	elseif ability.id == "dash" then
		dash(ability, root)
	elseif SERVER_ABILITIES[ability.id] then
		Net.Ability:FireServer(ability.id)
	end
	readyAt = os.clock() + ability.cooldown
	ui.Hud.abilityUsed(ability.cooldown)
end

function AbilityController.init(uiModule)
	ui = uiModule
	Net.AbilityFx.OnClientEvent:Connect(playFx)
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.ButtonY then
			activate()
		end
	end)
end

return AbilityController
