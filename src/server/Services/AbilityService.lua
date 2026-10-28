--[[
	Server-side abilities. Dash, Grapple, Insight and Analyze run on the client; these four
	change the world for gameplay, so the server owns them:

	  hack      (Dex)    unlock the nearest hackable door, spoof the Crown Lift, or blind a turret
	  overload  (Teo)    shut down every turret in a radius
	  bloom     (Ivy)    calm nearby Rooted and make her immune to spores
	  cloak     (Sable)  turrets and Rooted ignore her
]]
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Net = require(Shared.Net)
local Characters = require(Shared.Data.Characters)

local PlayerData = require(script.Parent.PlayerData)
local Story = require(script.Parent.Story)
local Doors = require(script.Parent.Doors)

local AbilityService = {}

local readyAt = {} -- player -> os.clock()
local cloakUntil = {}
local bloomUntil = {}
local turretOffUntil = {} -- turret model -> os.clock()

function AbilityService.isCloaked(player)
	return (cloakUntil[player] or 0) > os.clock()
end

function AbilityService.isBlooming(player)
	return (bloomUntil[player] or 0) > os.clock()
end

-- True if a blooming player is close enough to calm something at `position`.
function AbilityService.calmedAt(position)
	for player, untilTime in pairs(bloomUntil) do
		if untilTime > os.clock() then
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local s = PlayerData.get(player)
			local def = s and Characters.list[s.character]
			local radius = def and def.ability.radius or 45
			if root and (root.Position - position).Magnitude <= radius then
				return true
			end
		end
	end
	return false
end

function AbilityService.turretDisabled(turret)
	return (turretOffUntil[turret] or 0) > os.clock()
end

local function disableTurret(turret, seconds)
	turretOffUntil[turret] = os.clock() + seconds
	local lens = turret:FindFirstChild("Lens")
	if lens then
		lens.Color = Color3.fromRGB(60, 60, 70)
		task.delay(seconds, function()
			if not AbilityService.turretDisabled(turret) and lens.Parent then
				lens.Color = Color3.fromRGB(255, 50, 40)
			end
		end)
	end
end

local function turretsNear(position, radius)
	local list = {}
	for _, turret in ipairs(CollectionService:GetTagged("Turret")) do
		if (turret:GetPivot().Position - position).Magnitude <= radius then
			table.insert(list, turret)
		end
	end
	return list
end

local function hack(player, ability, root)
	local door = Doors.nearestHackable(player, root.Position, ability.radius)
	if door then
		Doors.unlock(player, door, "HACK: lock spliced. Door open.")
		return true
	end
	for _, panel in ipairs(CollectionService:GetTagged("LiftPanel")) do
		if panel:GetAttribute("LiftId") == "crown" and (panel.Position - root.Position).Magnitude <= ability.radius then
			Story.apply(player, {
				{ setFlag = "crown_hacked" },
				{ notify = "HACK: clearance spoofed. The Crown Lift thinks you live upstairs.", kind = "info" },
			})
			return true
		end
	end
	local turrets = turretsNear(root.Position, 70)
	if #turrets > 0 then
		for _, turret in ipairs(turrets) do
			disableTurret(turret, 20)
		end
		Story.notify(player, "HACK: " .. #turrets .. " turret feed(s) looped for 20 seconds.", "info")
		return true
	end
	Story.notify(player, "HACK: nothing hackable in range.", "info")
	return false
end

local function cloak(player, ability)
	cloakUntil[player] = os.clock() + ability.duration
	local character = player.Character
	local saved = {}
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			saved[part] = part.Transparency
			part.Transparency = math.max(part.Transparency, 0.85)
		end
	end
	task.delay(ability.duration, function()
		for part, transparency in pairs(saved) do
			if part.Parent then
				part.Transparency = transparency
			end
		end
	end)
	Story.notify(player, "Cloaked. Turrets and Rooted can't see you.", "info")
	return true
end

function AbilityService.init()
	Net.Ability.OnServerEvent:Connect(function(player, abilityId)
		local s = PlayerData.get(player)
		local def = s and s.character and Characters.list[s.character]
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not def or not root or def.ability.id ~= abilityId then
			return
		end
		local ability = def.ability
		-- Slight leniency so client and server clocks don't fight.
		if (readyAt[player] or 0) > os.clock() then
			return
		end
		readyAt[player] = os.clock() + ability.cooldown * 0.9

		local ok = false
		if abilityId == "hack" then
			ok = hack(player, ability, root)
		elseif abilityId == "overload" then
			local turrets = turretsNear(root.Position, ability.radius)
			for _, turret in ipairs(turrets) do
				disableTurret(turret, ability.duration)
			end
			Story.notify(player, "OVERLOAD: " .. #turrets .. " turret(s) down for " .. ability.duration .. " seconds.", "info")
			ok = true
		elseif abilityId == "bloom" then
			bloomUntil[player] = os.clock() + ability.duration
			Story.notify(player, "Bloom: the roots around you grow still.", "info")
			ok = true
		elseif abilityId == "cloak" then
			ok = cloak(player, ability)
		end
		if ok then
			Net.AbilityFx:FireClient(player, abilityId, ability.duration or 0)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		readyAt[player], cloakUntil[player], bloomUntil[player] = nil, nil, nil
	end)
end

return AbilityService
