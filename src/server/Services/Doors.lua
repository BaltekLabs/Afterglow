--[[
	Building doors. Every building can be entered unless its door says otherwise:

	  Mode = "hours"   opens and closes with the clock (OpenFrom / OpenTo, in-game hours).
	                   Shared by everyone, toggled on the server.
	  Mode = "locked"  closed for everyone until a player unlocks it for themselves.
	                   Unlocking sets the flag unlocked_<Key>; that player's client opens it locally.

	Who can unlock a locked door (part attributes):
	  Hackable = true   Dex (by trying it, or with HACK)
	  Pickable = true   Sable, with her lockpicks
	  KeyItem  = "id"   anyone holding that item
]]
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")

local PlayerData = require(script.Parent.PlayerData)
local Story = require(script.Parent.Story)

local Doors = {}

local function inHours(from, to, clock)
	if from <= to then
		return clock >= from and clock < to
	end
	return clock >= from or clock < to
end

local function setSign(door, text, color)
	local gui = door:FindFirstChildOfClass("SurfaceGui")
	local label = gui and gui:FindFirstChildOfClass("TextLabel")
	if label then
		label.Text = text
		label.TextColor3 = color
	end
end

function Doors.isUnlocked(s, door)
	return s.flags["unlocked_" .. tostring(door:GetAttribute("Key"))] == true
end

function Doors.unlock(player, door, message)
	local s = PlayerData.get(player)
	if not s then
		return
	end
	Story.apply(player, {
		{ setFlag = "unlocked_" .. tostring(door:GetAttribute("Key")) },
		{ notify = message, kind = "info" },
	})
end

-- Called when a player uses the "locked_door" prompt.
function Doors.tryOpen(player, door)
	local s = PlayerData.get(player)
	if not s or Doors.isUnlocked(s, door) then
		return
	end
	local keyItem = door:GetAttribute("KeyItem")
	if keyItem and (s.inventory[keyItem] or 0) > 0 then
		Doors.unlock(player, door, "The key turns. The door swings open.")
	elseif door:GetAttribute("Hackable") and s.character == "dex" then
		Doors.unlock(player, door, "You splice into the lock. Three seconds. Click.")
	elseif door:GetAttribute("Pickable") and s.character == "sable" then
		Doors.unlock(player, door, "A twist, a lift, a click. Vane taught you well.")
	else
		local hints = {}
		if door:GetAttribute("Hackable") then
			table.insert(hints, "a hacker could open it")
		end
		if door:GetAttribute("Pickable") then
			table.insert(hints, "the lock looks pickable")
		end
		if keyItem then
			table.insert(hints, "it takes a key")
		end
		local hint = if #hints > 0 then " (" .. table.concat(hints, "; ") .. ")" else ""
		Story.notify(player, "Locked." .. hint, "warn")
	end
end

-- Nearest locked, hackable door the player hasn't opened yet (used by HACK).
function Doors.nearestHackable(player, position, radius)
	local s = PlayerData.get(player)
	local best, bestDistance = nil, radius
	for _, door in ipairs(CollectionService:GetTagged("Door")) do
		if door:GetAttribute("Mode") == "locked" and door:GetAttribute("Hackable") and not Doors.isUnlocked(s, door) then
			local d = (door.Position - position).Magnitude
			if d <= bestDistance then
				best, bestDistance = door, d
			end
		end
	end
	return best
end

function Doors.init()
	task.spawn(function()
		while true do
			local clock = Lighting.ClockTime
			for _, door in ipairs(CollectionService:GetTagged("Door")) do
				if door:GetAttribute("Mode") == "hours" then
					local open = inHours(door:GetAttribute("OpenFrom") or 8, door:GetAttribute("OpenTo") or 20, clock)
					if door:GetAttribute("IsOpen") ~= open then
						door:SetAttribute("IsOpen", open)
						door.CanCollide = not open
						door.Transparency = if open then 1 else 0
						setSign(door, if open then "" else "CLOSED", Color3.fromRGB(255, 90, 80))
					end
				end
			end
			task.wait(2)
		end
	end)
end

return Doors
