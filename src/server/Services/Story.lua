--[[
	Story is the single place where a player's narrative state changes.
	Everything (dialogue, interactables, zones) expresses consequences as effect lists:

	  { setFlag = "x", value = <optional> }   { clearFlag = "x" }
	  { startQuest = "id" }                   { quest = "id", setStage = "stage" }   { completeQuest = "id" }
	  { giveItem = "id", count = n }          { takeItem = "id", count = n }
	  { credits = +/-n }                      { randomCredits = { min, max } }
	  { rep = "faction", amount = n }         { trust = "npc", amount = n }
	  { lore = "id", read = true }            { checkpoint = "Waypoint" }
	  { heal = n }                            { teleport = "Waypoint" }
	  { notify = "text", kind = "info" }      { narrate = { "line", ... } }
	  { chapterComplete = true }
	  ...plus handlers registered by other services (e.g. openShop).

	Any effect can carry `when = { conditions }` to apply only if they pass.
]]
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Conditions = require(Shared.Conditions)
local Net = require(Shared.Net)
local Quests = require(Shared.Data.Quests)
local Items = require(Shared.Data.Items)
local Lore = require(Shared.Data.Lore)
local Factions = require(Shared.Data.Factions)
local NPCs = require(Shared.Data.NPCs)

local PlayerData = require(script.Parent.PlayerData)

local Story = {}
Story.handlers = {}

local KIND_LABEL = { main = "Main Quest", side = "Side Quest", job = "Job" }

function Story.ctx()
	return { clockTime = Lighting.ClockTime }
end

function Story.check(player, conditions)
	local s = PlayerData.get(player)
	if not s then
		return false
	end
	return Conditions.all(conditions, s, Story.ctx())
end

local pendingPush = {}
function Story.push(player)
	if pendingPush[player] then
		return
	end
	pendingPush[player] = true
	task.defer(function()
		pendingPush[player] = nil
		local s = PlayerData.get(player)
		if s and player.Parent then
			Net.State:FireClient(player, s)
		end
	end)
end

function Story.notify(player, text, kind)
	Net.Notify:FireClient(player, text, kind or "info")
end

local function pickTracked(s)
	local fallback
	for questId, q in pairs(s.quests) do
		if q.status == "active" then
			local def = Quests[questId]
			if def and def.kind == "main" then
				return questId
			end
			fallback = fallback or questId
		end
	end
	return fallback
end

function Story.startQuest(player, questId)
	local s = PlayerData.get(player)
	local def = Quests[questId]
	if not s or not def then
		warn("[Afterglow] Unknown quest: " .. tostring(questId))
		return
	end
	if s.quests[questId] then
		return
	end
	s.quests[questId] = { status = "active", stage = def.start }
	if not s.tracked or def.kind == "main" then
		s.tracked = questId
	end
	Story.notify(player, (KIND_LABEL[def.kind] or "Quest") .. ": " .. def.name, "quest")
	Story.notify(player, def.stages[def.start].objective, "objective")
end

function Story.setStage(player, questId, stageId)
	local s = PlayerData.get(player)
	local q = s and s.quests[questId]
	local def = Quests[questId]
	if not q or not def or not def.stages[stageId] then
		return
	end
	q.status = "active"
	q.stage = stageId
	Story.notify(player, def.stages[stageId].objective, "objective")
end

function Story.completeQuest(player, questId)
	local s = PlayerData.get(player)
	local def = Quests[questId]
	if not s or not def then
		return
	end
	s.quests[questId] = s.quests[questId] or {}
	s.quests[questId].status = "complete"
	if s.tracked == questId then
		s.tracked = pickTracked(s)
	end
	Story.notify(player, "Completed: " .. def.name, "quest")
end

function Story.unlockLore(player, id, read)
	local s = PlayerData.get(player)
	local entry = Lore.entries[id]
	if not s or not entry then
		warn("[Afterglow] Unknown lore entry: " .. tostring(id))
		return
	end
	if not s.lore[id] then
		s.lore[id] = true
		Story.notify(player, "Journal: " .. entry.title, "lore")
	end
	if read then
		Net.ShowLore:FireClient(player, id)
	end
end

function Story.teleport(player, waypointName)
	local folder = Workspace:FindFirstChild("Waypoints")
	local wp = folder and folder:FindFirstChild(waypointName)
	local character = player.Character
	if wp and character then
		character:PivotTo(wp.CFrame + Vector3.new(0, 3.5, 0))
	end
end

local function applyOne(player, s, e)
	if e.setFlag then
		s.flags[e.setFlag] = if e.value == nil then true else e.value
	end
	if e.clearFlag then
		s.flags[e.clearFlag] = nil
	end
	if e.startQuest then
		Story.startQuest(player, e.startQuest)
	end
	if e.setStage then
		Story.setStage(player, e.quest, e.setStage)
	end
	if e.completeQuest then
		Story.completeQuest(player, e.completeQuest)
	end
	if e.takeItem then
		local count = e.count or 1
		local left = (s.inventory[e.takeItem] or 0) - count
		s.inventory[e.takeItem] = if left > 0 then left else nil
		local item = Items[e.takeItem]
		Story.notify(player, "- " .. (item and item.name or e.takeItem) .. (if count > 1 then " x" .. count else ""), "item")
	end
	if e.giveItem then
		local count = e.count or 1
		s.inventory[e.giveItem] = (s.inventory[e.giveItem] or 0) + count
		local item = Items[e.giveItem]
		Story.notify(player, "+ " .. (item and item.name or e.giveItem) .. (if count > 1 then " x" .. count else ""), "item")
	end
	if e.credits then
		s.credits = math.max(0, (s.credits or 0) + e.credits)
		Story.notify(player, (if e.credits >= 0 then "+" else "") .. e.credits .. " credits", "item")
	end
	if e.randomCredits then
		local amount = math.random(e.randomCredits[1], e.randomCredits[2])
		s.credits = (s.credits or 0) + amount
		Story.notify(player, "Found " .. amount .. " credits", "item")
	end
	if e.rep then
		local amount = e.amount or 0
		s.rep[e.rep] = math.clamp((s.rep[e.rep] or 0) + amount, -100, 100)
		local faction = Factions.list[e.rep]
		local name = faction and faction.name or e.rep
		Story.notify(player, name .. (if amount >= 0 then " reputation ▲" else " reputation ▼"), "rep")
	end
	if e.trust then
		local amount = e.amount or 0
		s.trust[e.trust] = (s.trust[e.trust] or 0) + amount
		local npc = NPCs[e.trust]
		local name = npc and npc.name or e.trust
		Story.notify(player, if amount >= 0 then name .. " will remember that." else name .. " won't forget that.", "trust")
	end
	if e.lore then
		Story.unlockLore(player, e.lore, e.read)
	end
	if e.checkpoint then
		s.checkpoint = e.checkpoint
	end
	if e.heal then
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + e.heal)
		end
	end
	if e.teleport then
		Story.teleport(player, e.teleport)
	end
	if e.notify then
		Story.notify(player, e.notify, e.kind or "info")
	end
	if e.narrate then
		Net.Narrate:FireClient(player, e.narrate)
	end
	if e.chapterComplete then
		s.flags.chapter1_complete = true
		task.delay(2, function()
			local latest = PlayerData.get(player)
			if latest and player.Parent then
				Net.ChapterComplete:FireClient(player, latest)
			end
		end)
	end
	for key, handler in pairs(Story.handlers) do
		if e[key] ~= nil then
			handler(player, e[key], e)
		end
	end
end

-- Advances any quest stages whose completion conditions now pass.
function Story.evaluate(player)
	local s = PlayerData.get(player)
	if not s then
		return
	end
	for _ = 1, 16 do
		local advanced = false
		local ctx = Story.ctx()
		for questId, q in pairs(s.quests) do
			local def = Quests[questId]
			local stage = q.status == "active" and def and def.stages[q.stage]
			if stage and stage.completeWhen and Conditions.all(stage.completeWhen, s, ctx) then
				advanced = true
				if stage.next then
					q.stage = stage.next
					Story.notify(player, def.stages[stage.next].objective, "objective")
				else
					Story.completeQuest(player, questId)
				end
				if stage.onComplete then
					Story.apply(player, stage.onComplete, true)
				end
				break -- effects may have added quests; restart iteration
			end
		end
		if not advanced then
			break
		end
	end
	Story.push(player)
end

function Story.apply(player, effects, skipEvaluate)
	local s = PlayerData.get(player)
	if not s or not effects then
		return
	end
	for _, e in ipairs(effects) do
		if e.when == nil or Conditions.all(e.when, s, Story.ctx()) then
			applyOne(player, s, e)
		end
	end
	if skipEvaluate then
		Story.push(player)
	else
		Story.evaluate(player)
	end
end

return Story
