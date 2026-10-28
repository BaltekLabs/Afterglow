-- Floating marker for the tracked quest's current objective.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Quests = require(Shared.Data.Quests)

local ClientState = require(script.Parent.ClientState)

local MarkerController = {}

local STUDS_PER_METER = 3.5
local player = Players.LocalPlayer

local function resolve(marker)
	if not marker then
		return nil
	end
	local npcId = string.match(marker, "^NPC:(.+)$")
	if npcId then
		local folder = Workspace:FindFirstChild("NPCs")
		local model = folder and folder:FindFirstChild(npcId)
		return model and (model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart)
	end
	local waypoints = Workspace:FindFirstChild("Waypoints")
	return waypoints and waypoints:FindFirstChild(marker)
end

function MarkerController.currentMarker()
	local s = ClientState.state
	local questId = ClientState.tracked()
	local q = questId and s and s.quests[questId]
	local def = questId and Quests[questId]
	local stage = q and q.status == "active" and def and def.stages[q.stage]
	return stage and stage.marker
end

function MarkerController.init(isBusy)
	local gui = Instance.new("BillboardGui")
	gui.Name = "ObjectiveMarker"
	gui.Size = UDim2.fromOffset(120, 46)
	gui.StudsOffset = Vector3.new(0, 5, 0)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.Enabled = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local diamond = Instance.new("TextLabel")
	diamond.Size = UDim2.new(1, 0, 0, 24)
	diamond.BackgroundTransparency = 1
	diamond.Text = "◆"
	diamond.TextColor3 = Color3.fromRGB(90, 255, 200)
	diamond.TextStrokeTransparency = 0.4
	diamond.TextSize = 22
	diamond.Font = Enum.Font.GothamBlack
	diamond.Parent = gui

	local distanceLabel = Instance.new("TextLabel")
	distanceLabel.Position = UDim2.fromOffset(0, 24)
	distanceLabel.Size = UDim2.new(1, 0, 0, 18)
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.TextColor3 = Color3.fromRGB(235, 235, 245)
	distanceLabel.TextStrokeTransparency = 0.4
	distanceLabel.TextSize = 14
	distanceLabel.Font = Enum.Font.GothamBold
	distanceLabel.Parent = gui

	RunService.RenderStepped:Connect(function()
		local target = resolve(MarkerController.currentMarker())
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not target or not root or isBusy() then
			gui.Enabled = false
			return
		end
		local d = (target.Position - root.Position).Magnitude
		gui.Adornee = target
		gui.Enabled = d > 10
		distanceLabel.Text = string.format("%dm", math.floor(d / STUDS_PER_METER + 0.5))
		diamond.TextTransparency = 0.15 + 0.15 * math.sin(os.clock() * 4)
	end)
end

return MarkerController
