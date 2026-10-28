-- Root of the HUD and menus. Submodules receive this table in init() to avoid require cycles.
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local UI = {}

local player = Players.LocalPlayer

UI.gui = Instance.new("ScreenGui")
UI.gui.Name = "AfterglowUI"
UI.gui.ResetOnSpawn = false
UI.gui.IgnoreGuiInset = true
UI.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UI.gui.DisplayOrder = 5
UI.gui.Parent = player:WaitForChild("PlayerGui")

UI.Kit = require(script.Kit)
UI.Overlay = require(script.Overlay)
UI.Hud = require(script.Hud)
UI.Dialogue = require(script.DialogueUI)
UI.Journal = require(script.Journal)
UI.Shop = require(script.ShopUI)
UI.CharacterSelect = require(script.CharacterSelect)
UI.ChapterCard = require(script.ChapterCard)

local busy = {}

-- Panels that take the mouse and stop movement register themselves here.
function UI.setBusy(key, value)
	busy[key] = if value then true else nil
end

function UI.isBusy()
	return next(busy) ~= nil
end

function UI.init()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end)
	UI.Overlay.init(UI)
	UI.Hud.init(UI)
	UI.Dialogue.init(UI)
	UI.Journal.init(UI)
	UI.Shop.init(UI)
	UI.CharacterSelect.init(UI)
	UI.ChapterCard.init(UI)
end

return UI
