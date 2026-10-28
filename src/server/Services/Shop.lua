-- Vendor purchases. Opened from dialogue with the { openShop = "id" } effect.
-- Stock entries sell an item, or a companion (handed to CompanionService).
local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Net = require(Shared.Net)
local Shops = require(Shared.Data.Shops)
local Items = require(Shared.Data.Items)
local Companions = require(Shared.Data.Companions)

local PlayerData = require(script.Parent.PlayerData)
local Story = require(script.Parent.Story)
local NPCService = require(script.Parent.NPCService)
local CompanionService = require(script.Parent.CompanionService)

local Shop = {}

local MAX_DISTANCE = 24
local open = {}

local function nearVendor(player, shop)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local vendor = shop.npc and NPCService.position(shop.npc)
	return root and (not vendor or (root.Position - vendor).Magnitude <= MAX_DISTANCE)
end

local function describe(entry)
	if entry.companion then
		local c = Companions.list[entry.companion]
		local perk = ({ alert = "Warns you of Rooted.", light = "Carries a light.", scavenge = "Finds credits." })[c.perk] or ""
		return c.name, c.kind .. " companion. " .. c.description .. " " .. perk
	end
	local item = Items[entry.item]
	return item and item.name or entry.item, item and item.description or ""
end

function Shop.init()
	Story.handlers.openShop = function(player, shopId)
		local shop = Shops[shopId]
		if not shop then
			return
		end
		open[player] = shopId
		local stock = {}
		for i, entry in ipairs(shop.stock) do
			local name, description = describe(entry)
			stock[i] = {
				item = entry.item,
				companion = entry.companion,
				name = name,
				description = description,
				price = entry.price,
			}
		end
		Net.Shop:FireClient(player, { id = shopId, name = shop.name, stock = stock })
	end

	Net.ShopBuy.OnServerEvent:Connect(function(player, shopId, index)
		local shop = Shops[shopId]
		local s = PlayerData.get(player)
		if open[player] ~= shopId or not shop or not s or type(index) ~= "number" then
			return
		end
		local entry = shop.stock[index]
		if not entry then
			return
		end
		if not nearVendor(player, shop) then
			open[player] = nil
			Story.notify(player, "You're too far from the counter.", "warn")
			return
		end
		if entry.companion and s.companions[entry.companion] then
			Story.notify(player, "You already have one. They'd get jealous.", "info")
			return
		end
		if (s.credits or 0) < entry.price then
			Story.notify(player, "Not enough credits.", "warn")
			return
		end
		if entry.companion then
			Story.apply(player, { { credits = -entry.price } })
			CompanionService.grant(player, entry.companion)
		else
			Story.apply(player, { { credits = -entry.price }, { giveItem = entry.item } })
		end
	end)

	Net.ShopClose.OnServerEvent:Connect(function(player)
		open[player] = nil
	end)

	Players.PlayerRemoving:Connect(function(player)
		open[player] = nil
	end)
end

return Shop
