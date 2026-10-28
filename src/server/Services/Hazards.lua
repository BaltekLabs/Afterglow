--[[
	World zones and threats, checked on the server:
	  Region      sets visited_<region> the first time you enter; Outside regions set left_city
	  Checkpoint  updates your respawn point
	  Spores      hurt over time unless you're Juno, carry a filter mask, or are Blooming
	  Restricted  warns, then escorts trespassers out with reputation consequences
	  Lethal      the Powerhouse perimeter: turrets open fire after a short warning
	And the Rooted: rare dormant zombies that wake when you move loudly nearby.
]]
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared.Config)
local Net = require(Shared.Net)

local PlayerData = require(script.Parent.PlayerData)
local Story = require(script.Parent.Story)
local AbilityService = require(script.Parent.AbilityService)
local CompanionService = require(script.Parent.CompanionService)

local Hazards = {}

local TICK = 0.2
local H = Config.Hazards

local tracking = {} -- player -> { region, restrictedSince, lethalSince, lastAlert }

local function inside(part, position)
	local lp = part.CFrame:PointToObjectSpace(position)
	local half = part.Size / 2
	return math.abs(lp.X) <= half.X and math.abs(lp.Y) <= half.Y and math.abs(lp.Z) <= half.Z
end

local function sporeImmune(player, s)
	return s.character == "juno" or (s.inventory.filter_mask or 0) > 0 or AbilityService.isBlooming(player)
end

-- Turrets ------------------------------------------------------------------------------

local turretReady = {}
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function tracer(from, to)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Material = Enum.Material.Neon
	p.Color = Color3.fromRGB(255, 70, 50)
	local length = (to - from).Magnitude
	p.Size = Vector3.new(0.25, 0.25, length)
	p.CFrame = CFrame.lookAt((from + to) / 2, to)
	p.Parent = Workspace
	task.delay(0.08, function()
		p:Destroy()
	end)
end

local function turretsFire(player, root, humanoid)
	local now = os.clock()
	for _, turret in ipairs(CollectionService:GetTagged("Turret")) do
		local muzzle = turret:FindFirstChild("Muzzle")
		if muzzle and not AbilityService.turretDisabled(turret) and (turretReady[turret] or 0) <= now then
			local from = muzzle.Position
			local to = root.Position
			if (to - from).Magnitude <= H.TurretRange then
				rayParams.FilterDescendantsInstances = { turret }
				local hit = Workspace:Raycast(from, to - from, rayParams)
				if hit and hit.Instance:IsDescendantOf(player.Character) then
					turretReady[turret] = now + H.TurretFireInterval
					-- Swing the head toward the target.
					local head = turret:FindFirstChild("Head")
					if head then
						head.CFrame = CFrame.lookAt(head.Position, to)
						muzzle.CFrame = head.CFrame * CFrame.new(0, 0, -2.2)
					end
					tracer(muzzle.Position, to)
					humanoid:TakeDamage(H.TurretDamage)
					Net.Hurt:FireClient(player, "turret")
				end
			end
		end
	end
end

-- Zones ------------------------------------------------------------------------------

local function checkZones(player, s, root, humanoid)
	local t = tracking[player]
	if not t then
		t = {}
		tracking[player] = t
	end

	local bestRegion, bestPriority, bestOutside = nil, -math.huge, false
	local inRestricted, inLethal = nil, nil
	for _, zone in ipairs(CollectionService:GetTagged("Zone")) do
		if inside(zone, root.Position) then
			local kind = zone:GetAttribute("ZoneType")
			if kind == "Region" then
				local priority = zone:GetAttribute("Priority") or 0
				if priority > bestPriority then
					bestRegion, bestPriority, bestOutside = zone:GetAttribute("Region"), priority, zone:GetAttribute("Outside") == true
				end
			elseif kind == "Checkpoint" then
				local name = zone:GetAttribute("Checkpoint")
				if name and s.checkpoint ~= name then
					s.checkpoint = name
					Story.notify(player, "Checkpoint reached", "info")
				end
			elseif kind == "Spores" then
				if not sporeImmune(player, s) and humanoid.Health > 0 then
					humanoid:TakeDamage(H.SporeDamagePerSecond * TICK)
				end
			elseif kind == "Restricted" then
				local required = zone:GetAttribute("Requires")
				if not (required and s.flags[required]) then
					inRestricted = zone
				end
			elseif kind == "Lethal" then
				inLethal = zone
			end
		end
	end

	if bestRegion and bestRegion ~= t.region then
		t.region = bestRegion
		local effects = {}
		if not s.flags["visited_" .. bestRegion] then
			table.insert(effects, { setFlag = "visited_" .. bestRegion })
		end
		if bestOutside and not s.flags.left_city then
			table.insert(effects, { setFlag = "left_city" })
		end
		if #effects > 0 then
			Story.apply(player, effects)
		end
	end

	if inRestricted then
		if not t.restrictedSince then
			t.restrictedSince = os.clock()
			Story.notify(player, "RESTRICTED: " .. (inRestricted:GetAttribute("Label") or "private property") .. ". Leave now.", "warn")
		elseif os.clock() - t.restrictedSince > H.RestrictedGraceSeconds then
			t.restrictedSince = nil
			Story.apply(player, {
				{ setFlag = inRestricted:GetAttribute("TrespassFlag") or "trespassed_ascent" },
				{ rep = inRestricted:GetAttribute("Faction") or "ascent", amount = -5 },
				{ notify = "Security marches you back out.", kind = "warn" },
				{ teleport = inRestricted:GetAttribute("Eject") },
			})
		end
	else
		t.restrictedSince = nil
	end

	if inLethal and not AbilityService.isCloaked(player) then
		if not t.lethalSince then
			t.lethalSince = os.clock()
			Story.notify(player, "WARNING: POWERHOUSE PERIMETER. LETHAL FORCE AUTHORIZED.", "warn")
		elseif os.clock() - t.lethalSince > H.TurretWarningSeconds and humanoid.Health > 0 then
			turretsFire(player, root, humanoid)
		end
	elseif not inLethal then
		t.lethalSince = nil
	end
end

-- Rooted ------------------------------------------------------------------------------

local rooted = {} -- model -> { home = CFrame, cooldown = number }

local function setRootedState(model, state)
	if model:GetAttribute("State") == state then
		return
	end
	model:SetAttribute("State", state)
	local eye = model:FindFirstChild("Eye")
	if eye then
		eye.Color = if state == "lunge"
			then Color3.fromRGB(255, 50, 40)
			elseif state == "alert" then Color3.fromRGB(255, 170, 40)
			else Color3.fromRGB(60, 160, 130)
	end
end

local function lunge(model, data, targetPosition)
	task.spawn(function()
		local home = data.home
		local flat = Vector3.new(targetPosition.X - home.Position.X, 0, targetPosition.Z - home.Position.Z)
		if flat.Magnitude < 0.1 then
			return
		end
		local strike = CFrame.lookAt(home.Position, home.Position + flat) + flat.Unit * math.min(4, flat.Magnitude - 1.5)
		for i = 1, 5 do
			model:PivotTo(home:Lerp(strike, i / 5))
			task.wait(0.02)
		end
		task.wait(0.4)
		for i = 1, 10 do
			model:PivotTo(strike:Lerp(home, i / 10))
			task.wait(0.04)
		end
		model:PivotTo(home)
	end)
end

local function hearingRadius(root)
	local v = root.AssemblyLinearVelocity
	local speed = Vector3.new(v.X, 0, v.Z).Magnitude
	if speed > H.LoudSpeed then
		return H.RootedHearSprint
	elseif speed > H.QuietSpeed then
		return H.RootedHearWalk
	end
	return H.RootedHearSneak
end

local function companionAlerts(player, distance)
	local perk, name = CompanionService.perk(player)
	if perk ~= "alert" or distance > Config.Companions.AlertRadius then
		return
	end
	local t = tracking[player]
	if t and os.clock() - (t.lastAlert or 0) > 25 then
		t.lastAlert = os.clock()
		Story.notify(player, "Your " .. name .. " goes rigid, staring into the dark. A Rooted is close.", "warn")
	end
end

local function updateRooted()
	local now = os.clock()
	for _, model in ipairs(CollectionService:GetTagged("Rooted")) do
		local data = rooted[model]
		if not data then
			data = { home = model:GetPivot(), cooldown = 0 }
			rooted[model] = data
		end

		local closest, closestDistance, closestRoot, closestRadius = nil, math.huge, nil, 0
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if root and humanoid and humanoid.Health > 0 then
				local d = (root.Position - data.home.Position).Magnitude
				if d < 80 then
					companionAlerts(player, d)
				end
				if d < closestDistance and not AbilityService.isCloaked(player) then
					closest, closestDistance, closestRoot, closestRadius = player, d, root, hearingRadius(root)
				end
			end
		end

		if closest and AbilityService.calmedAt(data.home.Position) then
			if now >= data.cooldown then
				setRootedState(model, "dormant")
			end
		elseif closest and closestDistance <= closestRadius then
			if now >= data.cooldown then
				data.cooldown = now + H.RootedCooldown
				setRootedState(model, "lunge")
				lunge(model, data, closestRoot.Position)
				closest.Character:FindFirstChildOfClass("Humanoid"):TakeDamage(H.RootedDamage)
				Net.Hurt:FireClient(closest, "rooted")
			end
		elseif closest and closestDistance <= math.max(closestRadius, H.RootedHearWalk) * H.RootedAlertMultiplier then
			if now >= data.cooldown then
				setRootedState(model, "alert")
			end
		elseif now >= data.cooldown then
			setRootedState(model, "dormant")
		end
	end
end

-- Forget region/trespass tracking (used when a save is wiped).
function Hazards.forget(player)
	tracking[player] = nil
end

function Hazards.init()
	Players.PlayerRemoving:Connect(Hazards.forget)

	task.spawn(function()
		while true do
			task.wait(TICK)
			for _, player in ipairs(Players:GetPlayers()) do
				local s = PlayerData.get(player)
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if s and s.character and root and humanoid then
					checkZones(player, s, root, humanoid)
				end
			end
			updateRooted()
		end
	end)
end

return Hazards
