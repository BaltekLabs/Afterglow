-- Spawns NPCs, walks them between scheduled locations as the clock turns, and handles barks.
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Conditions = require(Shared.Conditions)
local NPCs = require(Shared.Data.NPCs)
local DialogueData = require(Shared.Data.Dialogue)

local Dialogue = require(script.Parent.Dialogue)

local NPCService = {}

-- Roblox's stock R15 animations.
local WALK_ANIM = "rbxassetid://507777826"
local IDLE_ANIM = "rbxassetid://507766666"

local npcs = {}
local folder

local function waypoint(name)
	local wps = Workspace:FindFirstChild("Waypoints")
	return wps and wps:FindFirstChild(name)
end

local function flatDistance(a, b)
	return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
end

local function scheduleTarget(def, clock)
	for _, slot in ipairs(def.schedule or {}) do
		local inside
		if slot.from <= slot.to then
			inside = clock >= slot.from and clock < slot.to
		else
			inside = clock >= slot.from or clock < slot.to
		end
		if inside then
			return slot.at
		end
	end
	return def.schedule and def.schedule[1] and def.schedule[1].at
end

local function addAccent(model, def)
	local torso = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
	if not torso then
		return
	end
	local accent = Instance.new("Part")
	accent.Name = "Accent"
	accent.Size = Vector3.new(torso.Size.X + 0.15, 0.3, torso.Size.Z + 0.15)
	accent.CFrame = torso.CFrame * CFrame.new(0, torso.Size.Y / 2 - 0.15, 0)
	accent.Color = Color3.fromHex(def.accent or "#ffffff")
	accent.Material = Enum.Material.Neon
	accent.CanCollide = false
	accent.CanQuery = false
	accent.CanTouch = false
	accent.Massless = true
	accent.Parent = model
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = torso
	weld.Part1 = accent
	weld.Parent = accent
	local light = Instance.new("PointLight")
	light.Color = accent.Color
	light.Range = 7
	light.Brightness = 0.6
	light.Parent = accent
end

local function addBarkGui(model)
	local head = model:FindFirstChild("Head")
	if not head then
		return nil
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "Bark"
	gui.Size = UDim2.fromOffset(280, 64)
	gui.StudsOffset = Vector3.new(0, 3.2, 0)
	gui.MaxDistance = 70
	gui.Enabled = false
	gui.Parent = head
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(12, 10, 20)
	label.BackgroundTransparency = 0.25
	label.TextColor3 = Color3.fromRGB(235, 230, 250)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 15
	label.TextWrapped = true
	label.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = label
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = label
	return gui
end

-- Fallback if the engine can't build a rig (offline Studio etc.): an anchored mannequin.
local function buildStatue(def)
	local model = Instance.new("Model")
	local function part(name, size, offset, color)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.Color = color
		p.Anchored = true
		p.CFrame = CFrame.new(offset)
		p.Parent = model
		return p
	end
	local root = part("HumanoidRootPart", Vector3.new(2, 2, 1), Vector3.new(0, 3, 0), Color3.fromHex(def.torso))
	root.Transparency = 1
	root.CanCollide = false
	part("Torso", Vector3.new(2, 2, 1), Vector3.new(0, 3, 0), Color3.fromHex(def.torso))
	part("Head", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 4.6, 0), Color3.fromHex(def.skin))
	part("Legs", Vector3.new(2, 2, 1), Vector3.new(0, 1, 0), Color3.fromHex(def.legs))
	model.PrimaryPart = root
	return model
end

local function buildModel(def)
	local desc = Instance.new("HumanoidDescription")
	local skin, torso, legs = Color3.fromHex(def.skin), Color3.fromHex(def.torso), Color3.fromHex(def.legs)
	desc.HeadColor = skin
	desc.LeftArmColor = skin
	desc.RightArmColor = skin
	desc.TorsoColor = torso
	desc.LeftLegColor = legs
	desc.RightLegColor = legs
	desc.HeightScale = def.height or 1
	local ok, model = pcall(function()
		return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
	end)
	if ok and model then
		return model, false
	end
	warn("[Afterglow] Could not build rig for " .. def.name .. ", using a statue: " .. tostring(model))
	return buildStatue(def), true
end

local function playAnimations(npc)
	local animator = npc.humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = npc.humanoid
	end
	local function load(id)
		local anim = Instance.new("Animation")
		anim.AnimationId = id
		local ok, track = pcall(function()
			return animator:LoadAnimation(anim)
		end)
		return ok and track or nil
	end
	local walk, idle = load(WALK_ANIM), load(IDLE_ANIM)
	if idle then
		idle.Looped = true
		idle:Play()
	end
	npc.humanoid.Running:Connect(function(speed)
		if not walk then
			return
		end
		if speed > 0.5 then
			if not walk.IsPlaying then
				walk:Play(0.2)
			end
			walk:AdjustSpeed(speed / 12)
		elseif walk.IsPlaying then
			walk:Stop(0.25)
		end
	end)
end

local function waitMove(humanoid, timeout)
	local finished, reached = false, false
	local conn = humanoid.MoveToFinished:Connect(function(r)
		finished = true
		reached = r
	end)
	local started = os.clock()
	while not finished and os.clock() - started < timeout do
		task.wait(0.1)
	end
	conn:Disconnect()
	return reached
end

local function walkTo(npc, destination)
	local path = PathfindingService:CreatePath({ AgentRadius = 2, AgentHeight = 5.5, AgentCanJump = false, WaypointSpacing = 6 })
	local ok = pcall(function()
		path:ComputeAsync(npc.root.Position, destination)
	end)
	local points
	if ok and path.Status == Enum.PathStatus.Success then
		points = path:GetWaypoints()
	else
		points = { { Position = destination } }
	end
	for i, point in ipairs(points) do
		if i > 1 or #points == 1 then
			if Dialogue.isTalking(npc.dialogueId) or not npc.model.Parent then
				npc.humanoid:MoveTo(npc.root.Position)
				return
			end
			npc.humanoid:MoveTo(point.Position)
			if not waitMove(npc.humanoid, 6) then
				return
			end
		end
	end
end

local function faceWaypoint(npc, wp)
	local look = wp.CFrame.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	if flat.Magnitude > 0.1 then
		local pos = npc.root.Position
		npc.root.CFrame = CFrame.lookAt(pos, pos + flat)
	end
end

local function runBehaviour(npc)
	local def = npc.def
	local patrolIndex = 1
	while npc.model.Parent do
		if not Dialogue.isTalking(npc.dialogueId) then
			local targetName = if def.patrol then def.patrol[patrolIndex] else scheduleTarget(def, Lighting.ClockTime)
			local wp = targetName and waypoint(targetName)
			if wp then
				local distance = flatDistance(npc.root.Position, wp.Position)
				if distance > 3.5 then
					if npc.statue then
						npc.model:PivotTo(wp.CFrame + Vector3.new(0, 3, 0))
					else
						walkTo(npc, wp.Position)
					end
				elseif def.patrol then
					patrolIndex = patrolIndex % #def.patrol + 1
					task.wait(def.patrolPause or 3)
				elseif not npc.statue and not npc.faced then
					faceWaypoint(npc, wp)
					npc.faced = true
				end
				if distance > 3.5 then
					npc.faced = false
				end
			end
		end
		task.wait(0.8 + math.random() * 0.6)
	end
end

local function spawnNpc(id, def)
	local model, statue = buildModel(def)
	model.Name = id
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")
	if not root then
		model:Destroy()
		return
	end

	if humanoid then
		humanoid.DisplayName = def.name
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
		humanoid.NameDisplayDistance = 40
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		humanoid.BreakJointsOnDeath = false
		humanoid.WalkSpeed = 9
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	end
	addAccent(model, def)

	local start = def.patrol and def.patrol[1] or scheduleTarget(def, Lighting.ClockTime)
	local wp = start and waypoint(start)
	model:PivotTo((wp and wp.CFrame or CFrame.new(0, 0, 0)) + Vector3.new(0, 3.2, 0))
	model.Parent = folder
	pcall(function()
		root:SetNetworkOwner(nil)
	end)

	local npc = {
		id = id,
		def = def,
		model = model,
		root = root,
		humanoid = humanoid,
		statue = statue or not humanoid,
		dialogueId = if def.dialogue == false then nil else (def.dialogue or id),
		bark = addBarkGui(model),
		barkToken = 0,
	}
	npcs[id] = npc

	if npc.dialogueId and DialogueData[npc.dialogueId] then
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "TalkPrompt"
		prompt.ActionText = "Talk"
		prompt.ObjectText = def.name
		prompt.MaxActivationDistance = 10
		prompt.RequiresLineOfSight = false
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
		prompt:SetAttribute("NPC", id)
		prompt.Parent = root
		prompt.Triggered:Connect(function(player)
			NPCService.talk(player, id)
		end)
	end

	if not npc.statue then
		playAnimations(npc)
	end
	task.spawn(runBehaviour, npc)
end

function NPCService.talk(player, id)
	local npc = npcs[id]
	local proot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not npc or not proot or not npc.dialogueId then
		return
	end
	if Dialogue.start(player, npc.dialogueId, npc.root) and not npc.statue then
		npc.humanoid:MoveTo(npc.root.Position)
		local pos = npc.root.Position
		npc.root.CFrame = CFrame.lookAt(pos, Vector3.new(proot.Position.X, pos.Y, proot.Position.Z))
		npc.faced = false
	end
end

function NPCService.bark(id, text, duration)
	local npc = npcs[id]
	if not npc or not npc.bark then
		return
	end
	npc.barkToken += 1
	local token = npc.barkToken
	local label = npc.bark:FindFirstChild("Text")
	label.Text = text
	label.TextTransparency = 1
	label.BackgroundTransparency = 1
	npc.bark.Enabled = true
	TweenService:Create(label, TweenInfo.new(0.3), { TextTransparency = 0, BackgroundTransparency = 0.25 }):Play()
	task.delay(duration or 4.5, function()
		if npc.barkToken == token then
			local fade = TweenService:Create(label, TweenInfo.new(0.5), { TextTransparency = 1, BackgroundTransparency = 1 })
			fade:Play()
			fade.Completed:Wait()
			if npc.barkToken == token then
				npc.bark.Enabled = false
			end
		end
	end)
end

function NPCService.position(id)
	local npc = npcs[id]
	return npc and npc.root.Position
end

-- Returns the nearest NPC id within radius of a world position, if any.
function NPCService.findWitness(position, radius)
	local best, bestDistance = nil, radius
	for id, npc in pairs(npcs) do
		local d = (npc.root.Position - position).Magnitude
		if npc.def.witness ~= false and d <= bestDistance then
			best, bestDistance = id, d
		end
	end
	return best
end

local function ambientBarks()
	while true do
		task.wait(10 + math.random() * 12)
		local candidates = {}
		for id, npc in pairs(npcs) do
			if npc.def.barks and not Dialogue.isTalking(npc.dialogueId) then
				for _, player in ipairs(Players:GetPlayers()) do
					local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if root and (root.Position - npc.root.Position).Magnitude < 45 then
						table.insert(candidates, id)
						break
					end
				end
			end
		end
		if #candidates > 0 then
			local id = candidates[math.random(#candidates)]
			local lines = {}
			for _, bark in ipairs(npcs[id].def.barks) do
				if type(bark) == "string" then
					table.insert(lines, bark)
				elseif Conditions.check({ time = bark.time }, { flags = {} }, { clockTime = Lighting.ClockTime }) then
					table.insert(lines, bark.text)
				end
			end
			if #lines > 0 then
				NPCService.bark(id, lines[math.random(#lines)])
			end
		end
	end
end

function NPCService.init()
	folder = Instance.new("Folder")
	folder.Name = "NPCs"
	folder.Parent = Workspace
	for id, def in pairs(NPCs) do
		task.spawn(spawnNpc, id, def)
	end
	task.spawn(ambientBarks)
end

return NPCService
