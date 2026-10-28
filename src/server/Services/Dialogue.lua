-- Server-authoritative dialogue: the server picks nodes, filters choices and applies effects.
-- The client only renders text and sends back the index of the chosen option.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Conditions = require(Shared.Conditions)
local Net = require(Shared.Net)
local DialogueData = require(Shared.Data.Dialogue)
local Lifts = require(Shared.Data.Lifts)
local Characters = require(Shared.Data.Characters)
local NPCs = require(Shared.Data.NPCs)

local PlayerData = require(script.Parent.PlayerData)
local Story = require(script.Parent.Story)

local Dialogue = {}

local MAX_DISTANCE = 18
local sessions = {}

local function format(text, s)
	local def = s.character and Characters.list[s.character]
	return (
		string.gsub(text, "{(%w+)}", function(token)
			if token == "player" then
				return def and def.name or "stranger"
			elseif token == "first" then
				return def and def.short or "stranger"
			elseif token == "credits" then
				return tostring(s.credits)
			end
			return "{" .. token .. "}"
		end)
	)
end

local function speakerColor(dialogueId)
	local npc = NPCs[dialogueId]
	return Color3.fromHex(npc and npc.accent or "#5affc8")
end

function Dialogue.close(player)
	if sessions[player] then
		sessions[player] = nil
		Net.Dialogue:FireClient(player, nil)
	end
end

local function showNode(player, nodeId)
	local session = sessions[player]
	if not session then
		return
	end
	local node = session.def.nodes[nodeId]
	if not node then
		warn("[Afterglow] Missing dialogue node " .. session.id .. "." .. tostring(nodeId))
		Dialogue.close(player)
		return
	end
	session.node = nodeId

	if node.effects then
		Story.apply(player, node.effects)
		if sessions[player] ~= session then
			return
		end
	end

	local s = PlayerData.get(player)
	local ctx = Story.ctx()
	local text = (node.textBy and s.character and node.textBy[s.character]) or node.text

	local options, map = {}, {}
	for _, choice in ipairs(node.choices or {}) do
		if Conditions.all(choice.when, s, ctx) then
			table.insert(options, format(choice.text, s))
			table.insert(map, choice)
		end
	end
	if #map == 0 then
		local fallback = { text = if node.next then "Continue" else "[Leave]", next = node.next }
		table.insert(options, fallback.text)
		table.insert(map, fallback)
	end
	session.map = map

	Net.Dialogue:FireClient(player, {
		speaker = node.speaker or session.def.name,
		color = speakerColor(session.id),
		text = format(text, s),
		choices = options,
	})
end

-- Starts any dialogue definition (from data, or built at runtime like lift menus).
function Dialogue.startDef(player, dialogueId, def, anchor)
	local s = PlayerData.get(player)
	if not def or not s or not s.character then
		return false
	end
	local ctx = Story.ctx()
	for _, entry in ipairs(def.entry) do
		if Conditions.all(entry.when, s, ctx) then
			sessions[player] = { id = dialogueId, def = def, anchor = anchor }
			if NPCs[dialogueId] and not s.flags["met_" .. dialogueId] then
				s.flags["met_" .. dialogueId] = true
				Story.push(player)
			end
			showNode(player, entry.node)
			return true
		end
	end
	return false
end

function Dialogue.start(player, dialogueId, anchor)
	return Dialogue.startDef(player, dialogueId, DialogueData[dialogueId], anchor)
end

-- Lift menu: one choice per other stop; restricted stops show as denied unless allowed.
function Dialogue.startLift(player, liftId, anchor)
	local lift = Lifts[liftId]
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local waypoints = Workspace:FindFirstChild("Waypoints")
	if not lift or not root or not waypoints then
		return false
	end
	local current, nearest = nil, math.huge
	for i, stop in ipairs(lift.stops) do
		local wp = waypoints:FindFirstChild(stop.waypoint)
		local d = wp and (wp.Position - root.Position).Magnitude or math.huge
		if d < nearest then
			current, nearest = i, d
		end
	end
	local choices = {}
	for i, stop in ipairs(lift.stops) do
		if i ~= current then
			local go = { { teleport = stop.waypoint } }
			if stop.requires then
				table.insert(choices, { text = "▲▼ " .. stop.label, when = stop.requires, effects = go })
				table.insert(choices, { text = "▲▼ " .. stop.label .. "  [RESTRICTED]", when = { { none = stop.requires } }, next = "denied_" .. i })
			else
				table.insert(choices, { text = "▲▼ " .. stop.label, effects = go })
			end
		end
	end
	table.insert(choices, { text = "Cancel" })
	local nodes = {
		menu = {
			text = "Current level: " .. (current and lift.stops[current].label or "?") .. ".\nSelect a destination.",
			choices = choices,
		},
	}
	for i, stop in ipairs(lift.stops) do
		if stop.requires then
			nodes["denied_" .. i] = { text = stop.denied or "Access denied." }
		end
	end
	return Dialogue.startDef(player, "lift_" .. liftId, { name = lift.name, entry = { { node = "menu" } }, nodes = nodes }, anchor)
end

function Dialogue.isTalking(dialogueId)
	for _, session in pairs(sessions) do
		if session.id == dialogueId then
			return true
		end
	end
	return false
end

function Dialogue.init()
	Net.DialogueChoice.OnServerEvent:Connect(function(player, index)
		local session = sessions[player]
		if not session or type(index) ~= "number" or not session.map then
			return
		end
		local choice = session.map[index]
		if not choice then
			return
		end
		session.map = nil -- ignore double clicks until the next node is shown

		if choice.when and not Story.check(player, choice.when) then
			showNode(player, session.node)
			return
		end
		if choice.effects then
			Story.apply(player, choice.effects)
		end
		if sessions[player] ~= session then
			return
		end
		if choice.next then
			showNode(player, choice.next)
		else
			Dialogue.close(player)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		sessions[player] = nil
	end)

	-- End conversations when the player walks away.
	task.spawn(function()
		while true do
			task.wait(0.5)
			for player, session in pairs(sessions) do
				local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				local anchor = session.anchor
				if not root or (anchor and anchor.Parent and (root.Position - anchor.Position).Magnitude > MAX_DISTANCE) then
					Dialogue.close(player)
				end
			end
		end
	end)
end

return Dialogue
