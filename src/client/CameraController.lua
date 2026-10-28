--[[
	Over-the-shoulder third-person camera. The mouse always steers the camera (no right-click
	dragging), and the character turns to face the way it walks. Gamepad uses the right stick.
	V swaps shoulders; the mouse wheel zooms. While a UI panel is open the cursor is released.
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared.Config)

local CameraController = {}

local player = Players.LocalPlayer
local cfg = Config.Camera

local yaw, pitch = math.rad(180), math.rad(-12)
local distance = cfg.Distance
local targetDistance = cfg.Distance
local side, sideTarget = 1, 1
local stick = Vector2.zero
local smoothedFocus

local isBusy = function()
	return false
end

function CameraController.init(busyCheck)
	isBusy = busyCheck or isBusy

	UserInputService.InputChanged:Connect(function(input, processed)
		if input.UserInputType == Enum.UserInputType.MouseWheel and not processed and not isBusy() then
			targetDistance = math.clamp(targetDistance - input.Position.Z * 1.5, cfg.MinDistance, cfg.MaxDistance)
		elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
			stick = Vector2.new(input.Position.X, input.Position.Y)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.V or input.KeyCode == Enum.KeyCode.ButtonR3 then
			sideTarget = -sideTarget
		end
	end)

	-- Face the way the character spawned.
	player.CharacterAdded:Connect(function(character)
		local root = character:WaitForChild("HumanoidRootPart")
		task.wait(0.3) -- let the server move us to our checkpoint first
		local look = root.CFrame.LookVector
		yaw = math.atan2(-look.X, -look.Z)
		smoothedFocus = nil
	end)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude

	RunService:BindToRenderStep("AfterglowCamera", Enum.RenderPriority.Camera.Value + 1, function(dt)
		local camera = Workspace.CurrentCamera
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end
		camera.CameraType = Enum.CameraType.Scriptable

		local busy = isBusy()
		UserInputService.MouseBehavior = if busy then Enum.MouseBehavior.Default else Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = busy

		if not busy then
			local delta = UserInputService:GetMouseDelta()
			yaw -= delta.X * cfg.MouseSensitivity
			pitch -= delta.Y * cfg.MouseSensitivity
			if stick.Magnitude > 0.15 then
				yaw -= stick.X * cfg.GamepadSensitivity * dt
				pitch += stick.Y * cfg.GamepadSensitivity * 0.6 * dt
			end
		end
		pitch = math.clamp(pitch, math.rad(-65), math.rad(45))

		distance += (targetDistance - distance) * math.min(1, dt * 10)
		side += (sideTarget - side) * math.min(1, dt * 8)

		local focus = root.Position + Vector3.new(0, cfg.Height, 0)
		smoothedFocus = if smoothedFocus then smoothedFocus:Lerp(focus, math.min(1, dt * 18)) else focus

		local rotation = CFrame.fromEulerAnglesYXZ(pitch, yaw, 0)
		local shoulder = rotation.RightVector * cfg.ShoulderOffset * side
		local pivot = smoothedFocus + shoulder
		local desired = pivot - rotation.LookVector * distance

		-- Keep the camera from clipping through walls.
		params.FilterDescendantsInstances = { character }
		local fromFocus = Workspace:Raycast(smoothedFocus, shoulder, params)
		if fromFocus then
			pivot = smoothedFocus + shoulder.Unit * math.max(0, fromFocus.Distance - 0.6)
			desired = pivot - rotation.LookVector * distance
		end
		local hit = Workspace:Raycast(pivot, desired - pivot, params)
		local position = if hit then hit.Position + hit.Normal * 0.6 else desired

		camera.CFrame = CFrame.lookAt(position, position + rotation.LookVector)
		camera.Focus = CFrame.new(smoothedFocus)
	end)
end

-- Flat forward direction of the camera, for abilities like Dash.
function CameraController.forward()
	local look = CFrame.fromEulerAnglesYXZ(0, yaw, 0).LookVector
	return Vector3.new(look.X, 0, look.Z).Unit
end

return CameraController
