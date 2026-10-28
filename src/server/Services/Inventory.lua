-- Consumable item use from the journal.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Net = require(Shared.Net)
local Items = require(Shared.Data.Items)

local PlayerData = require(script.Parent.PlayerData)
local Story = require(script.Parent.Story)

local Inventory = {}

function Inventory.init()
	Net.UseItem.OnServerEvent:Connect(function(player, itemId)
		local s = PlayerData.get(player)
		local item = type(itemId) == "string" and Items[itemId]
		if not s or not item or not item.use or (s.inventory[itemId] or 0) < 1 then
			return
		end
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return
		end
		local effects = { { takeItem = itemId } }
		if item.use.heal then
			table.insert(effects, { heal = item.use.heal })
		end
		Story.apply(player, effects)
	end)
end

return Inventory
