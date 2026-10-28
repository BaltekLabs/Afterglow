-- Turns tagged world parts into ProximityPrompts driven by Data/Interactables.
local CollectionService = game:GetService("CollectionService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Interactables = require(Shared.Data.Interactables)

local PlayerData = require(script.Parent.PlayerData)
local Story = require(script.Parent.Story)
local Dialogue = require(script.Parent.Dialogue)
local NPCService = require(script.Parent.NPCService)
local Doors = require(script.Parent.Doors)

local Interaction = {}

-- Must match PromptController on the client.
local function usedFlag(id, def, part)
	if def.perInstance then
		return "used_" .. id .. "_" .. tostring(part:GetAttribute("Key"))
	end
	return "used_" .. id
end

local function steal(player, def, part)
	local witness = NPCService.findWitness(part.Position, def.steal.radius or 30)
	if witness then
		NPCService.bark(witness, def.steal.bark or "Hey!")
		Story.apply(player, def.steal.caught)
	else
		Story.apply(player, def.steal.success)
	end
end

function Interaction.trigger(player, id, part)
	local def = Interactables[id]
	local s = PlayerData.get(player)
	if not def or not s or not s.character then
		return
	end
	if def.door then
		Doors.tryOpen(player, part)
		return
	end
	if def.lift then
		Dialogue.startLift(player, part:GetAttribute("LiftId"), part)
		return
	end
	local flag = usedFlag(id, def, part)
	if def.once and s.flags[flag] then
		Story.notify(player, def.usedText or "There's nothing more here.", "info")
		return
	end
	if def.showWhen and not Story.check(player, def.showWhen) then
		return
	end
	if def.requires and not Story.check(player, def.requires) then
		Story.notify(player, def.failText or "You can't do that right now.", "warn")
		return
	end

	if def.once then
		s.flags[flag] = true
	end

	if def.steal then
		steal(player, def, part)
		return
	end

	local effects = {}
	for _, e in ipairs(def.effects or {}) do
		table.insert(effects, e)
	end
	local lore = def.lore or (def.loreAttribute and part:GetAttribute("Lore"))
	if lore then
		table.insert(effects, { lore = lore, read = true })
	end
	Story.apply(player, effects)

	if def.dialogue then
		Dialogue.start(player, def.dialogue, part)
	end
end

local function setup(part)
	if not part:IsA("BasePart") then
		return
	end
	local id = part:GetAttribute("InteractId")
	local def = Interactables[id]
	if not def then
		warn("[Afterglow] No interactable definition for '" .. tostring(id) .. "' on " .. part:GetFullName())
		return
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "InteractPrompt"
	prompt.ActionText = def.action or "Interact"
	prompt.ObjectText = part:GetAttribute("ObjectText") or def.object or ""
	prompt.HoldDuration = def.hold or 0
	prompt.MaxActivationDistance = def.distance or 9
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	-- Enabled on the server; each client hides prompts that don't apply to it (once-used,
	-- showWhen, hidden), and trigger() re-checks everything authoritatively.
	prompt:SetAttribute("InteractId", id)
	prompt.Parent = part
	prompt.Triggered:Connect(function(player)
		Interaction.trigger(player, id, part)
	end)
end

function Interaction.init()
	for _, part in ipairs(CollectionService:GetTagged("Interactable")) do
		setup(part)
	end
	CollectionService:GetInstanceAddedSignal("Interactable"):Connect(setup)
end

return Interaction
