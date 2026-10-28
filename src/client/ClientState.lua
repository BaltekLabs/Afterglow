-- The client's copy of the player's story state, plus local-only view state.
local Lighting = game:GetService("Lighting")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Conditions = require(Shared.Conditions)
local Net = require(Shared.Net)

local ClientState = {
	state = nil,
	revealedUntil = 0, -- Insight reveals hidden interactables until this os.clock()
	trackedOverride = nil, -- quest the player chose to track in the journal
}

local changed = Instance.new("BindableEvent")
ClientState.Changed = changed.Event

Net.State.OnClientEvent:Connect(function(s)
	ClientState.state = s
	changed:Fire(s)
end)

function ClientState.ctx()
	return { clockTime = Lighting.ClockTime }
end

function ClientState.check(conditions)
	local s = ClientState.state
	return s ~= nil and Conditions.all(conditions, s, ClientState.ctx())
end

function ClientState.tracked()
	local s = ClientState.state
	if not s then
		return nil
	end
	local override = ClientState.trackedOverride
	if override == "none" then
		return nil -- the player chose to track nothing; no objective, no marker
	end
	if override and s.quests[override] and s.quests[override].status == "active" then
		return override
	end
	return s.tracked
end

return ClientState
