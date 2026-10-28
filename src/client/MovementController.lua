-- Walk / sprint / sneak. Speed matters: the Rooted hear sprinting from far away.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared.Config)
local Characters = require(Shared.Data.Characters)

local ClientState = require(script.Parent.ClientState)

local MovementController = {}

local player = Players.LocalPlayer
local sprinting = false
local sneaking = false
local stanceChanged = Instance.new("BindableEvent")
MovementController.StanceChanged = stanceChanged.Event

local function stance()
	if sneaking then
		return "sneak"
	elseif sprinting then
		return "sprint"
	end
	return "walk"
end
MovementController.stance = stance

function MovementController.init(isBusy)
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed or isBusy() then
			return
		end
		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL3 then
			sprinting = if input.KeyCode == Enum.KeyCode.ButtonL3 then not sprinting else true
			if sprinting then
				sneaking = false
			end
			stanceChanged:Fire(stance())
		elseif input.KeyCode == Enum.KeyCode.C or input.KeyCode == Enum.KeyCode.ButtonB then
			sneaking = not sneaking
			if sneaking then
				sprinting = false
			end
			stanceChanged:Fire(stance())
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftShift and sprinting then
			sprinting = false
			stanceChanged:Fire(stance())
		end
	end)

	RunService.Heartbeat:Connect(function()
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end
		local s = ClientState.state
		local def = s and s.character and Characters.list[s.character]
		if not def or isBusy() then
			humanoid.WalkSpeed = 0
			humanoid.JumpHeight = 0
			return
		end
		local base = if sneaking then Config.Movement.Sneak elseif sprinting then Config.Movement.Sprint else Config.Movement.Walk
		humanoid.WalkSpeed = base * (def.speedMultiplier or 1)
		humanoid.JumpHeight = if sneaking then 0 else 7.2
	end)
end

return MovementController
