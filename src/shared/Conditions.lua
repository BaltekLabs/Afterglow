--[[
	Conditions are plain data, shared by the server (authoritative) and the client
	(prompt visibility, UI hints). A list passes when every entry passes.
	Each entry checks one thing:

	  { flag = "x" }                        flag is set (or equals `value` when given)
	  { notFlag = "x" }                     flag is unset
	  { character = "mara" }                chosen protagonist
	  { notCharacter = "mara" }
	  { item = "id", count = 2 }            holds at least `count` (default 1)
	  { noItem = "id" }
	  { credits = 40 }                      has at least 40 credits
	  { quest = "id", stage = "s" }         quest is active at that stage
	  { quest = "id", status = "none" | "active" | "complete" }
	  { quest = "id", notStatus = "complete" }
	  { rep = "fringe", min = 10, max = 50 }
	  { trust = "tamsin", min = 1 }
	  { lore = "id" }                       journal entry discovered
	  { loreCategory = "adeyemi", count = 5 }
	  { time = "day" | "night" }
	  { any = { ...conditions } }           at least one sub-condition passes
	  { none = { ...conditions } }          no sub-condition passes
]]

local Lore = require(script.Parent.Data.Lore)

local Conditions = {}

function Conditions.isNight(clockTime)
	return clockTime >= 19 or clockTime < 6
end

local function inRange(value, c)
	if c.min ~= nil and value < c.min then
		return false
	end
	if c.max ~= nil and value > c.max then
		return false
	end
	return true
end

function Conditions.check(c, s, ctx)
	ctx = ctx or {}

	if c.any ~= nil then
		local passed = false
		for _, sub in ipairs(c.any) do
			if Conditions.check(sub, s, ctx) then
				passed = true
				break
			end
		end
		if not passed then
			return false
		end
	end
	if c.none ~= nil then
		for _, sub in ipairs(c.none) do
			if Conditions.check(sub, s, ctx) then
				return false
			end
		end
	end

	if c.flag ~= nil then
		local v = s.flags[c.flag]
		if c.value ~= nil then
			if v ~= c.value then
				return false
			end
		elseif not v then
			return false
		end
	end
	if c.notFlag ~= nil and s.flags[c.notFlag] then
		return false
	end

	if c.character ~= nil and s.character ~= c.character then
		return false
	end
	if c.notCharacter ~= nil and s.character == c.notCharacter then
		return false
	end

	if c.item ~= nil and (s.inventory[c.item] or 0) < (c.count or 1) then
		return false
	end
	if c.noItem ~= nil and (s.inventory[c.noItem] or 0) > 0 then
		return false
	end
	if c.credits ~= nil and (s.credits or 0) < c.credits then
		return false
	end

	if c.quest ~= nil then
		local q = s.quests[c.quest]
		local status = if q then q.status else "none"
		if c.stage ~= nil and (status ~= "active" or q.stage ~= c.stage) then
			return false
		end
		if c.status ~= nil and status ~= c.status then
			return false
		end
		if c.notStatus ~= nil and status == c.notStatus then
			return false
		end
	end

	if c.rep ~= nil and not inRange(s.rep[c.rep] or 0, c) then
		return false
	end
	if c.trust ~= nil and not inRange(s.trust[c.trust] or 0, c) then
		return false
	end

	if c.lore ~= nil and not s.lore[c.lore] then
		return false
	end
	if c.loreCategory ~= nil then
		local found = 0
		for id in pairs(s.lore) do
			local entry = Lore.entries[id]
			if entry and entry.category == c.loreCategory then
				found += 1
			end
		end
		if found < (c.count or 1) then
			return false
		end
	end

	if c.time ~= nil then
		local night = Conditions.isNight(ctx.clockTime or 12)
		if (c.time == "night") ~= night then
			return false
		end
	end

	return true
end

function Conditions.all(list, s, ctx)
	if list == nil then
		return true
	end
	for _, c in ipairs(list) do
		if not Conditions.check(c, s, ctx) then
			return false
		end
	end
	return true
end

return Conditions
