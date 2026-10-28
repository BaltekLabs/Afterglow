-- Decides, per player, which interaction prompts are visible (used-up, conditional, hidden, unlocked).
local Workspace = game:GetService("Workspace")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Interactables = require(Shared.Data.Interactables)

local ClientState = require(script.Parent.ClientState)

local PromptController = {}

local prompts = {}

-- Must match Interaction.lua on the server.
local function usedFlag(id, def, part)
	if def.perInstance then
		return "used_" .. id .. "_" .. tostring(part:GetAttribute("Key"))
	end
	return "used_" .. id
end

local function evaluate(prompt)
	local s = ClientState.state
	local enabled = s ~= nil and s.character ~= nil
	local id = prompt:GetAttribute("InteractId")
	local part = prompt.Parent
	if enabled and id then
		local def = Interactables[id]
		if not def then
			enabled = false
		elseif def.door then
			enabled = not s.flags["unlocked_" .. tostring(part:GetAttribute("Key"))]
		elseif def.once and s.flags[usedFlag(id, def, part)] then
			enabled = false
		elseif def.showWhen and not ClientState.check(def.showWhen) then
			enabled = false
		elseif def.hidden and os.clock() > ClientState.revealedUntil then
			enabled = false
		end
	end
	prompt.Enabled = enabled
end

function PromptController.refresh()
	for prompt in pairs(prompts) do
		if prompt.Parent then
			evaluate(prompt)
		else
			prompts[prompt] = nil
		end
	end
end

local function track(inst)
	if inst:IsA("ProximityPrompt") then
		prompts[inst] = true
		evaluate(inst)
	end
end

-- Parts whose prompt is still usable (used by Insight to highlight things).
function PromptController.interactableParts()
	local parts = {}
	local s = ClientState.state
	for prompt in pairs(prompts) do
		local id = prompt:GetAttribute("InteractId")
		local def = id and Interactables[id]
		if prompt.Parent and def and s and not def.lift and not def.door then
			if not (def.once and s.flags[usedFlag(id, def, prompt.Parent)]) then
				table.insert(parts, { part = prompt.Parent, hidden = def.hidden == true })
			end
		end
	end
	return parts
end

function PromptController.init()
	for _, inst in ipairs(Workspace:GetDescendants()) do
		track(inst)
	end
	Workspace.DescendantAdded:Connect(track)
	ClientState.Changed:Connect(PromptController.refresh)
	task.spawn(function()
		while true do
			task.wait(1)
			PromptController.refresh()
		end
	end)
end

return PromptController
