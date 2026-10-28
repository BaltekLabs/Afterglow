-- Client entry point.
local Client = script.Parent
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Net = require(Shared.Net)

local UI = require(Client.UI)
local CameraController = require(Client.CameraController)
local MovementController = require(Client.MovementController)
local AbilityController = require(Client.AbilityController)
local PromptController = require(Client.PromptController)
local MarkerController = require(Client.MarkerController)
local AmbienceController = require(Client.AmbienceController)
local WorldReactions = require(Client.WorldReactions)
local CityLife = require(Client.CityLife)

UI.init()
CameraController.init(UI.isBusy)
MovementController.init(UI.isBusy)
AbilityController.init(UI)
PromptController.init()
MarkerController.init(UI.isBusy)
AmbienceController.init(UI)
WorldReactions.init()
CityLife.init()

Net.Notify.OnClientEvent:Connect(function(text, kind)
	UI.Overlay.toast(text, kind)
end)

Net.Narrate.OnClientEvent:Connect(function(lines)
	task.spawn(UI.Overlay.narrate, lines)
end)

Net.Hurt.OnClientEvent:Connect(function()
	UI.Overlay.hurt()
end)

-- Ask for our state once every listener is connected.
Net.Ready:FireServer()
