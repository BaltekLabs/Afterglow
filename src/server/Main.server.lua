-- Server entry point: builds the world, starts services, and manages the player lifecycle.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

Players.CharacterAutoLoads = false

local Server = script.Parent
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared.Config)
local Net = require(Shared.Net)
local Characters = require(Shared.Data.Characters)

require(Server.World.WorldBuilder).build()

local Services = Server.Services
local PlayerData = require(Services.PlayerData)
local Story = require(Services.Story)
local Dialogue = require(Services.Dialogue)
local Interaction = require(Services.Interaction)
local NPCService = require(Services.NPCService)
local Hazards = require(Services.Hazards)
local Shop = require(Services.Shop)
local Inventory = require(Services.Inventory)
local WorldClock = require(Services.WorldClock)
local Doors = require(Services.Doors)
local AbilityService = require(Services.AbilityService)
local CompanionService = require(Services.CompanionService)

WorldClock.init()
Dialogue.init()
NPCService.init()
Interaction.init()
Doors.init()
AbilityService.init()
CompanionService.init()
Shop.init()
Inventory.init()
Hazards.init()

local function spawnCFrame(s)
	local waypoints = Workspace:FindFirstChild("Waypoints")
	local wp = waypoints and (waypoints:FindFirstChild(s.checkpoint) or waypoints:FindFirstChild("CP_Grid"))
	return wp and (wp.CFrame + Vector3.new(0, 3.5, 0))
end

-- Marks the avatar as the chosen protagonist: name tag plus a glowing accent.
local function applyRole(player, character)
	local s = PlayerData.get(player)
	local def = s and s.character and Characters.list[s.character]
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not def or not humanoid then
		return
	end
	humanoid.DisplayName = def.name
	character:SetAttribute("Role", def.id)

	local color = Color3.fromHex(def.color)
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if torso and not character:FindFirstChild("RoleAccent") then
		local accent = Instance.new("Part")
		accent.Name = "RoleAccent"
		accent.Size = Vector3.new(0.45, 0.45, 0.15)
		accent.Material = Enum.Material.Neon
		accent.Color = color
		accent.CanCollide = false
		accent.CanQuery = false
		accent.CanTouch = false
		accent.Massless = true
		accent.CFrame = torso.CFrame * CFrame.new(-0.45, 0.3, -torso.Size.Z / 2 - 0.08)
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = torso
		weld.Part1 = accent
		weld.Parent = accent
		local light = Instance.new("PointLight")
		light.Color = color
		light.Range = 8
		light.Brightness = 0.7
		light.Parent = accent
		accent.Parent = character
	end
end

local function onCharacterAdded(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	character:WaitForChild("HumanoidRootPart")
	local s = PlayerData.get(player)
	if s then
		local cf = spawnCFrame(s)
		if cf then
			character:PivotTo(cf)
		end
	end
	applyRole(player, character)
	CompanionService.onCharacterAdded(player)
	humanoid.Died:Connect(function()
		Dialogue.close(player)
		task.delay(Config.RespawnDelay, function()
			if player.Parent then
				player:LoadCharacter()
			end
		end)
	end)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
	PlayerData.load(player)
	if player.Parent then
		player:LoadCharacter()
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

Players.PlayerRemoving:Connect(function(player)
	Dialogue.close(player)
	PlayerData.release(player)
end)

game:BindToClose(function()
	for _, player in ipairs(PlayerData.all()) do
		PlayerData.save(player)
	end
end)

task.spawn(function()
	while true do
		task.wait(Config.AutosaveSeconds)
		for _, player in ipairs(PlayerData.all()) do
			task.spawn(PlayerData.save, player)
		end
	end
end)

-- Remotes -----------------------------------------------------------------------

Net.Ready.OnServerEvent:Connect(function(player)
	-- The profile may still be loading; wait briefly for it.
	for _ = 1, 50 do
		if PlayerData.get(player) then
			break
		end
		task.wait(0.1)
	end
	Story.push(player)
end)

Net.SelectCharacter.OnServerEvent:Connect(function(player, id)
	local s = PlayerData.get(player)
	local def = type(id) == "string" and Characters.list[id]
	if not s or s.character or not def then
		return
	end
	s.character = id
	s.credits = def.startCredits or 0
	s.checkpoint = def.start or "CP_Grid"
	for item, count in pairs(def.startItems or {}) do
		s.inventory[item] = count
	end
	Story.push(player)
	-- Respawn at the character's home tier.
	player:LoadCharacter()

	local lines = { "VEYRA", "Year 14 After the Bloom" }
	for _, line in ipairs(def.intro) do
		table.insert(lines, line)
	end
	Net.Narrate:FireClient(player, lines)
	-- No quest is forced on the player. A single rumor points at the main story; the rest is theirs.
	Story.notify(player, "Rumor: the old Static Tower in the Grid is calling a dead woman's name again.", "info")
end)

Net.ResetSave.OnServerEvent:Connect(function(player)
	if not Config.Debug.AllowReset then
		return
	end
	Dialogue.close(player)
	CompanionService.dismiss(player)
	Hazards.forget(player)
	PlayerData.reset(player)
	PlayerData.save(player)
	Story.push(player)
	player:LoadCharacter()
end)
