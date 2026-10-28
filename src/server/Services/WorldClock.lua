-- Advances the time of day. NPC schedules, shop hours and dialogue all read Lighting.ClockTime.
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared.Config)

local WorldClock = {}

function WorldClock.init()
	Lighting.ClockTime = Config.StartClockTime
	local hoursPerSecond = 24 / (Config.DayLengthMinutes * 60)
	RunService.Heartbeat:Connect(function(dt)
		Lighting.ClockTime = (Lighting.ClockTime + dt * hoursPerSecond) % 24
	end)
end

return WorldClock
