--[[
	Story data validator. Run from the project root after editing anything in src/shared/Data:

	    luau tools/validate_story.luau

	(luau.exe comes from https://github.com/luau-lang/luau/releases)

	Checks every cross-reference between dialogue, quests, items, lore, NPCs, factions, shops
	and interactables, and warns about flags that are checked somewhere but never set.
]]

local DATA = "../src/shared/Data/"
local Items = require(DATA .. "Items")
local Lore = require(DATA .. "Lore")
local Quests = require(DATA .. "Quests")
local NPCs = require(DATA .. "NPCs")
local Shops = require(DATA .. "Shops")
local Factions = require(DATA .. "Factions")
local Characters = require(DATA .. "Characters")
local Interactables = require(DATA .. "Interactables")
local Companions = require(DATA .. "Companions")
local Lifts = require(DATA .. "Lifts")

-- Keep in sync with the files in Data/Dialogue (the Luau CLI can't list directories).
local DIALOGUE_FILES = {
	"tamsin", "okafor", "kessler", "vela", "pike", "bram", "lune", "transmitter", "tower_speaker",
	"glitch", "kettle", "marigold", "vane", "pell", "hale", "dunmore", "ilsa", "reed",
}
local Dialogue = {}
for _, name in DIALOGUE_FILES do
	Dialogue[name] = require(DATA .. "Dialogue/" .. name)
end

-- Flags set by systems code rather than data (see Hazards.lua, Story.lua, Dialogue.lua, Interaction.lua).
local CODE_FLAGS = { trespassed_ascent = true, chapter1_complete = true, left_city = true, crown_hacked = true }
local CODE_FLAG_PREFIXES = { "visited_", "used_", "met_", "unlocked_" }

local errors, warnings = {}, {}
local flagsSet, flagsChecked = {}, {}

local function err(where, msg)
	table.insert(errors, where .. ": " .. msg)
end

local function warn(where, msg)
	table.insert(warnings, where .. ": " .. msg)
end

local CONDITION_KEYS = {
	any = true, none = true, flag = true, value = true, notFlag = true, character = true, notCharacter = true,
	item = true, count = true, noItem = true, credits = true, quest = true, stage = true, status = true,
	notStatus = true, rep = true, trust = true, min = true, max = true, lore = true, loreCategory = true, time = true,
}

local EFFECT_KEYS = {
	setFlag = true, value = true, clearFlag = true, startQuest = true, quest = true, setStage = true,
	completeQuest = true, giveItem = true, takeItem = true, count = true, credits = true, rep = true,
	amount = true, trust = true, lore = true, read = true, checkpoint = true, heal = true, teleport = true,
	notify = true, kind = true, narrate = true, chapterComplete = true, when = true, openShop = true,
	randomCredits = true,
}

local function hasCategory(id)
	for _, c in Lore.categories do
		if c.id == id then
			return true
		end
	end
	return false
end

local checkConditions

local function checkCondition(where, c)
	for key in c do
		if not CONDITION_KEYS[key] then
			err(where, "unknown condition key '" .. tostring(key) .. "'")
		end
	end
	if c.any then
		checkConditions(where .. ".any", c.any)
	end
	if c.none then
		checkConditions(where .. ".none", c.none)
	end
	if c.flag then
		flagsChecked[c.flag] = flagsChecked[c.flag] or where
	end
	if c.notFlag then
		flagsChecked[c.notFlag] = flagsChecked[c.notFlag] or where
	end
	for _, key in { "item", "noItem" } do
		if c[key] and not Items[c[key]] then
			err(where, "unknown item '" .. c[key] .. "'")
		end
	end
	for _, key in { "character", "notCharacter" } do
		if c[key] and not Characters.list[c[key]] then
			err(where, "unknown character '" .. c[key] .. "'")
		end
	end
	if c.quest then
		local q = Quests[c.quest]
		if not q then
			err(where, "unknown quest '" .. c.quest .. "'")
		elseif c.stage and not q.stages[c.stage] then
			err(where, "quest '" .. c.quest .. "' has no stage '" .. c.stage .. "'")
		end
	end
	if c.rep and not Factions.list[c.rep] then
		err(where, "unknown faction '" .. c.rep .. "'")
	end
	if c.trust and not NPCs[c.trust] then
		err(where, "unknown NPC '" .. c.trust .. "'")
	end
	if c.lore and not Lore.entries[c.lore] then
		err(where, "unknown lore '" .. c.lore .. "'")
	end
	if c.loreCategory and not hasCategory(c.loreCategory) then
		err(where, "unknown lore category '" .. c.loreCategory .. "'")
	end
	if c.time and c.time ~= "day" and c.time ~= "night" then
		err(where, "time must be 'day' or 'night'")
	end
end

function checkConditions(where, list)
	if list == nil then
		return
	end
	for i, c in list do
		checkCondition(where .. "[" .. i .. "]", c)
	end
end

local function checkEffects(where, list)
	if list == nil then
		return
	end
	for i, e in list do
		local w = where .. "[" .. i .. "]"
		for key in e do
			if not EFFECT_KEYS[key] then
				err(w, "unknown effect key '" .. tostring(key) .. "'")
			end
		end
		checkConditions(w .. ".when", e.when)
		if e.setFlag then
			flagsSet[e.setFlag] = true
		end
		for _, key in { "giveItem", "takeItem" } do
			if e[key] and not Items[e[key]] then
				err(w, "unknown item '" .. e[key] .. "'")
			end
		end
		for _, key in { "startQuest", "completeQuest", "quest" } do
			if e[key] and not Quests[e[key]] then
				err(w, "unknown quest '" .. e[key] .. "'")
			end
		end
		if e.setStage and not (e.quest and Quests[e.quest] and Quests[e.quest].stages[e.setStage]) then
			err(w, "setStage needs a valid quest + stage")
		end
		if e.rep and not Factions.list[e.rep] then
			err(w, "unknown faction '" .. e.rep .. "'")
		end
		if e.trust and not NPCs[e.trust] then
			err(w, "unknown NPC '" .. e.trust .. "'")
		end
		if e.lore and not Lore.entries[e.lore] then
			err(w, "unknown lore '" .. e.lore .. "'")
		end
		if e.openShop and not Shops[e.openShop] then
			err(w, "unknown shop '" .. e.openShop .. "'")
		end
	end
end

-- Dialogue ---------------------------------------------------------------------
for id, def in Dialogue do
	if not def.entry or #def.entry == 0 then
		err("dialogue." .. id, "has no entry list")
	end
	local reachable = {}
	for i, entry in def.entry do
		local w = "dialogue." .. id .. ".entry[" .. i .. "]"
		checkConditions(w, entry.when)
		if not def.nodes[entry.node] then
			err(w, "points at missing node '" .. tostring(entry.node) .. "'")
		end
		reachable[entry.node] = true
	end
	for nodeId, node in def.nodes do
		local w = "dialogue." .. id .. "." .. nodeId
		if type(node.text) ~= "string" then
			err(w, "has no text")
		end
		checkEffects(w .. ".effects", node.effects)
		if node.next then
			reachable[node.next] = true
			if not def.nodes[node.next] then
				err(w, "next -> missing node '" .. node.next .. "'")
			end
		end
		for i, choice in node.choices or {} do
			local cw = w .. ".choices[" .. i .. "]"
			checkConditions(cw .. ".when", choice.when)
			checkEffects(cw .. ".effects", choice.effects)
			if choice.next then
				reachable[choice.next] = true
				if not def.nodes[choice.next] then
					err(cw, "next -> missing node '" .. choice.next .. "'")
				end
			end
		end
		if node.textBy then
			for char in node.textBy do
				if not Characters.list[char] then
					err(w, "textBy unknown character '" .. char .. "'")
				end
			end
		end
	end
	for nodeId in def.nodes do
		if not reachable[nodeId] then
			warn("dialogue." .. id .. "." .. nodeId, "node is never reached")
		end
	end
end

for id, npc in NPCs do
	local dialogueId = if npc.dialogue == false then nil else (npc.dialogue or id)
	if dialogueId and not Dialogue[dialogueId] then
		err("npc." .. id, "has no dialogue file '" .. dialogueId .. "'")
	end
	if npc.faction and not Factions.list[npc.faction] then
		err("npc." .. id, "unknown faction '" .. npc.faction .. "'")
	end
end

-- Quests -----------------------------------------------------------------------
for id, quest in Quests do
	if not quest.stages[quest.start] then
		err("quest." .. id, "start stage '" .. tostring(quest.start) .. "' missing")
	end
	for stageId, stage in quest.stages do
		local w = "quest." .. id .. "." .. stageId
		checkConditions(w .. ".completeWhen", stage.completeWhen)
		checkEffects(w .. ".onComplete", stage.onComplete)
		if stage.next and not quest.stages[stage.next] then
			err(w, "next -> missing stage '" .. stage.next .. "'")
		end
		if not stage.objective then
			err(w, "has no objective text")
		end
	end
end

-- Interactables ----------------------------------------------------------------
for id, def in Interactables do
	local w = "interactable." .. id
	checkConditions(w .. ".requires", def.requires)
	checkConditions(w .. ".showWhen", def.showWhen)
	checkEffects(w .. ".effects", def.effects)
	if def.lore and not Lore.entries[def.lore] then
		err(w, "unknown lore '" .. def.lore .. "'")
	end
	if def.dialogue and not Dialogue[def.dialogue] then
		err(w, "unknown dialogue '" .. def.dialogue .. "'")
	end
	if def.steal then
		checkEffects(w .. ".steal.success", def.steal.success)
		checkEffects(w .. ".steal.caught", def.steal.caught)
	end
end

-- Shops, lore, characters -------------------------------------------------------
for id, shop in Shops do
	if shop.npc and not NPCs[shop.npc] then
		err("shop." .. id, "unknown NPC '" .. shop.npc .. "'")
	end
	for i, entry in shop.stock do
		local w = "shop." .. id .. ".stock[" .. i .. "]"
		if entry.companion then
			if not Companions.list[entry.companion] then
				err(w, "unknown companion '" .. entry.companion .. "'")
			end
		elseif not Items[entry.item] then
			err(w, "unknown item '" .. tostring(entry.item) .. "'")
		end
	end
end
for id, entry in Lore.entries do
	if not hasCategory(entry.category) then
		err("lore." .. id, "unknown category '" .. tostring(entry.category) .. "'")
	end
end
for id, char in Characters.list do
	for item in char.startItems or {} do
		if not Items[item] then
			err("character." .. id, "unknown start item '" .. item .. "'")
		end
	end
end

for id, lift in Lifts do
	for i, stop in lift.stops do
		checkConditions("lift." .. id .. ".stops[" .. i .. "].requires", stop.requires)
	end
end
for _, id in Companions.order do
	if not Companions.list[id] then
		err("companions.order", "lists unknown companion '" .. id .. "'")
	end
end
for id, char in Characters.list do
	if not char.ability or not char.ability.id then
		err("character." .. id, "has no ability")
	end
end

-- Flags ------------------------------------------------------------------------
local function setByCode(flag)
	if CODE_FLAGS[flag] then
		return true
	end
	for _, prefix in CODE_FLAG_PREFIXES do
		if string.sub(flag, 1, #prefix) == prefix then
			return true
		end
	end
	return false
end

for flag, where in flagsChecked do
	if not flagsSet[flag] and not setByCode(flag) then
		warn(where, "checks flag '" .. flag .. "' but nothing sets it")
	end
end

-- Report -----------------------------------------------------------------------
table.sort(errors)
table.sort(warnings)
for _, w in warnings do
	print("WARN  " .. w)
end
for _, e in errors do
	print("ERROR " .. e)
end

local nodeCount = 0
for _, def in Dialogue do
	for _ in def.nodes do
		nodeCount += 1
	end
end
local loreCount = 0
for _ in Lore.entries do
	loreCount += 1
end
print(string.format("\n%d dialogue files, %d nodes, %d lore entries. %d errors, %d warnings.", #DIALOGUE_FILES, nodeCount, loreCount, #errors, #warnings))
if #errors > 0 then
	error("story validation failed", 0)
end
