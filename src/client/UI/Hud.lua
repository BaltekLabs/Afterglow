-- Always-on HUD: objective tracker, credits / clock / region, controls and ability cooldown.
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Quests = require(Shared.Data.Quests)
local Characters = require(Shared.Data.Characters)

local ClientState = require(script.Parent.Parent.ClientState)
local MovementController = require(script.Parent.Parent.MovementController)

local Hud = {}

local UI, Kit, C
local root, questName, objective, hint, credits, clock, region, controls, abilityName, abilityBar, stance
local cooldownStart, cooldownLength = 0, 0

local function phase(t)
	if t >= 5 and t < 7 then
		return "Dawn"
	elseif t >= 7 and t < 17 then
		return "Day"
	elseif t >= 17 and t < 19.5 then
		return "Dusk"
	end
	return "Night"
end

local function refresh(s)
	root.Visible = s ~= nil and s.character ~= nil
	if not root.Visible then
		return
	end
	credits.Text = "◈ " .. tostring(s.credits or 0) .. " credits"

	local questId = ClientState.tracked()
	local q = questId and s.quests[questId]
	local def = questId and Quests[questId]
	local stage = q and q.status == "active" and def and def.stages[q.stage]
	if stage then
		questName.Text = string.upper(def.name)
		objective.Text = stage.objective
		hint.Text = stage.hint or ""
	else
		-- Nothing tracked: no nagging. The journal [J] has everything when you want it.
		questName.Text = ""
		objective.Text = ""
		hint.Text = ""
	end

	local char = Characters.list[s.character]
	if char then
		abilityName.Text = "[Q]  " .. string.upper(char.ability.name)
		controls.Text = "WASD move   ·   Shift sprint   ·   C sneak   ·   Q " .. char.ability.name .. "   ·   E interact   ·   J journal   ·   V shoulder"
	end
end

function Hud.setRegion(name)
	region.Text = name
end

function Hud.abilityUsed(cooldown)
	cooldownStart, cooldownLength = os.clock(), cooldown
end

function Hud.init(ui)
	UI = ui
	Kit = ui.Kit
	C = Kit.Colors

	root = Kit.new("Frame", { Name = "Hud", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = UI.gui })

	-- Objective tracker (top-left, below the Roblox menu buttons).
	local tracker = Kit.new("Frame", {
		Position = UDim2.fromOffset(24, 70),
		Size = UDim2.fromOffset(380, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = root,
	}, { Kit.list(4) })
	questName = Kit.label({ Font = Kit.Fonts.bold, TextSize = 14, TextColor3 = C.accent, LayoutOrder = 1, Parent = tracker })
	objective = Kit.label({
		Font = Kit.Fonts.medium,
		TextSize = 18,
		AutomaticSize = Enum.AutomaticSize.Y,
		TextStrokeTransparency = 0.6,
		RichText = false,
		LayoutOrder = 2,
		Parent = tracker,
	})
	hint = Kit.label({
		TextSize = 14,
		TextColor3 = C.dim,
		AutomaticSize = Enum.AutomaticSize.Y,
		TextStrokeTransparency = 0.8,
		RichText = false,
		LayoutOrder = 3,
		Parent = tracker,
	})

	-- Status (top-right).
	local status = Kit.new("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -24, 0, 70),
		Size = UDim2.fromOffset(260, 70),
		BackgroundTransparency = 1,
		Parent = root,
	}, { Kit.new("UIListLayout", { HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }) })
	region = Kit.label({ Text = "", Font = Kit.Fonts.bold, TextSize = 14, TextColor3 = C.accent, TextXAlignment = Enum.TextXAlignment.Right, LayoutOrder = 1, Parent = status })
	clock = Kit.label({ Font = Kit.Fonts.medium, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Right, TextStrokeTransparency = 0.7, LayoutOrder = 2, Parent = status })
	credits = Kit.label({ Font = Kit.Fonts.medium, TextSize = 16, TextColor3 = C.amber, TextXAlignment = Enum.TextXAlignment.Right, LayoutOrder = 3, Parent = status })

	-- Controls hint (bottom).
	controls = Kit.label({
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -12),
		Size = UDim2.new(1, -48, 0, 18),
		TextSize = 13,
		TextColor3 = C.dim,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextStrokeTransparency = 0.8,
		Parent = root,
	})

	-- Ability + stance (bottom-left).
	local abilityFrame = Kit.panel({
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 24, 1, -40),
		Size = UDim2.fromOffset(200, 46),
		BackgroundTransparency = 0.25,
		Parent = root,
	})
	abilityName = Kit.label({ Position = UDim2.fromOffset(12, 7), Size = UDim2.new(1, -24, 0, 18), Font = Kit.Fonts.bold, TextSize = 14, Parent = abilityFrame })
	local track = Kit.new("Frame", {
		Position = UDim2.new(0, 12, 0, 30),
		Size = UDim2.new(1, -24, 0, 6),
		BackgroundColor3 = C.panelLight,
		BorderSizePixel = 0,
		Parent = abilityFrame,
	}, { Kit.corner(3) })
	abilityBar = Kit.new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.accent, BorderSizePixel = 0, Parent = track }, { Kit.corner(3) })
	stance = Kit.label({
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 236, 1, -52),
		Size = UDim2.fromOffset(200, 22),
		Font = Kit.Fonts.bold,
		TextSize = 15,
		Text = "",
		TextStrokeTransparency = 0.6,
		Parent = root,
	})

	MovementController.StanceChanged:Connect(function(current)
		if current == "sneak" then
			stance.Text = "◐ SNEAKING"
			stance.TextColor3 = C.violet
		elseif current == "sprint" then
			stance.Text = "▶▶ SPRINTING (loud)"
			stance.TextColor3 = C.amber
		else
			stance.Text = ""
		end
	end)

	ClientState.Changed:Connect(refresh)

	RunService.RenderStepped:Connect(function()
		if not root.Visible then
			return
		end
		local t = Lighting.ClockTime
		local hours = math.floor(t)
		local minutes = math.floor((t - hours) * 60 / 10) * 10
		clock.Text = string.format("%02d:%02d · %s", hours, minutes, phase(t))
		local progress = if cooldownLength > 0 then math.clamp((os.clock() - cooldownStart) / cooldownLength, 0, 1) else 1
		abilityBar.Size = UDim2.fromScale(progress, 1)
		abilityBar.BackgroundColor3 = if progress >= 1 then C.accent else C.dim
	end)
end

-- Lets the journal re-render the tracker after the player changes the tracked quest.
function Hud.refresh()
	refresh(ClientState.state)
end

return Hud
