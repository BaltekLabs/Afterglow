-- Title screen and protagonist choice (8 characters in two rows). Shown whenever the profile
-- has no character. Hover or select a card to read the full bio.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Net = require(Shared.Net)
local Config = require(Shared.Config)
local Characters = require(Shared.Data.Characters)

local ClientState = require(script.Parent.Parent.ClientState)

local CharacterSelect = {}

local UI, Kit, C
local screen, detailName, detailTitle, detailBio, detailPerks, detailStart, detailBar
local chosen = false

local START_LABEL = { CP_Grid = "Starts in The Grid", CP_Rust = "Starts in The Rust", CP_Crown = "Starts in The Crown" }

local function showDetail(def)
	local color = Color3.fromHex(def.color)
	detailName.Text = def.name
	detailTitle.Text = string.upper(def.title)
	detailTitle.TextColor3 = color
	detailBar.BackgroundColor3 = color
	detailBio.Text = def.bio
	detailPerks.Text = "•  " .. table.concat(def.perks, "\n•  ")
	detailStart.Text = START_LABEL[def.start] or ""
end

local function card(parent, def, order)
	local color = Color3.fromHex(def.color)
	local frame = Kit.button({
		Text = "",
		BackgroundColor3 = C.panel,
		LayoutOrder = order,
		Parent = parent,
	}, function()
		if chosen then
			return
		end
		chosen = true
		Net.SelectCharacter:FireServer(def.id)
	end)
	frame:FindFirstChildOfClass("UIStroke").Color = color
	Kit.new("Frame", { Size = UDim2.new(1, 0, 0, 4), BackgroundColor3 = color, BorderSizePixel = 0, Parent = frame }, { Kit.corner(2) })
	Kit.label({ Position = UDim2.fromOffset(14, 16), Size = UDim2.new(1, -28, 0, 16), Text = string.upper(def.title), Font = Kit.Fonts.bold, TextSize = 12, TextColor3 = color, Parent = frame })
	Kit.label({ Position = UDim2.fromOffset(14, 34), Size = UDim2.new(1, -28, 0, 26), Text = def.name, Font = Kit.Fonts.title, TextSize = 20, Parent = frame })
	Kit.label({
		Position = UDim2.fromOffset(14, 64),
		Size = UDim2.new(1, -28, 1, -100),
		Text = def.perks[1],
		RichText = false,
		TextSize = 13,
		TextColor3 = C.dim,
		Parent = frame,
	})
	Kit.label({
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 14, 1, -12),
		Size = UDim2.new(1, -28, 0, 18),
		Text = "Play as " .. def.short .. "  ›",
		Font = Kit.Fonts.bold,
		TextSize = 14,
		TextColor3 = color,
		Parent = frame,
	})
	frame.MouseEnter:Connect(function()
		showDetail(def)
	end)
	frame.SelectionGained:Connect(function()
		showDetail(def)
	end)
end

local function setVisible(visible)
	screen.Visible = visible
	UI.setBusy("select", visible)
	if visible then
		chosen = false
	end
end

function CharacterSelect.init(ui)
	UI = ui
	Kit = ui.Kit
	C = Kit.Colors

	screen = Kit.new("Frame", {
		Name = "CharacterSelect",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = C.bg,
		BackgroundTransparency = 0.05,
		Visible = false,
		Parent = UI.gui,
		ZIndex = 40,
	})
	Kit.new("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(30, 14, 40), Color3.fromRGB(6, 20, 22)),
		Rotation = 90,
		Parent = screen,
	})
	Kit.label({
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 28),
		Size = UDim2.fromOffset(800, 60),
		Text = Config.GameTitle,
		Font = Kit.Fonts.title,
		TextSize = 56,
		TextColor3 = C.accent,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = screen,
	})
	Kit.label({
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 90),
		Size = UDim2.fromOffset(900, 44),
		Text = Config.ChapterTitle .. "\n<font color=\"#968fb2\">The apocalypse is over, at least according to the people who rebuilt the world.</font>",
		Font = Kit.Fonts.medium,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = screen,
	})

	local body = Kit.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 150),
		Size = UDim2.new(0.94, 0, 1, -200),
		BackgroundTransparency = 1,
		Parent = screen,
	}, { Kit.new("UISizeConstraint", { MaxSize = Vector2.new(1300, 640) }) })

	local grid = Kit.new("Frame", {
		Size = UDim2.new(0.68, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = body,
	}, {
		Kit.new("UIGridLayout", {
			CellSize = UDim2.new(0.25, -12, 0.5, -10),
			CellPadding = UDim2.fromOffset(12, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	for i, id in ipairs(Characters.order) do
		card(grid, Characters.list[id], i)
	end

	local detail = Kit.panel({
		Position = UDim2.new(0.7, 0, 0, 0),
		Size = UDim2.new(0.3, 0, 1, -6),
		Parent = body,
	})
	detailBar = Kit.new("Frame", { Size = UDim2.new(1, 0, 0, 4), BorderSizePixel = 0, Parent = detail })
	local inner = Kit.new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = detail }, { Kit.pad(20, 22), Kit.list(10) })
	detailTitle = Kit.label({ Font = Kit.Fonts.bold, TextSize = 13, LayoutOrder = 1, Parent = inner })
	detailName = Kit.label({ Font = Kit.Fonts.title, TextSize = 26, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 2, Parent = inner })
	detailStart = Kit.label({ TextSize = 13, TextColor3 = C.accent, LayoutOrder = 3, Parent = inner })
	detailBio = Kit.label({ RichText = false, TextSize = 14, TextColor3 = C.dim, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 4, Parent = inner })
	detailPerks = Kit.label({ RichText = false, TextSize = 14, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 5, Parent = inner })
	showDetail(Characters.list[Characters.order[1]])

	Kit.label({
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -16),
		Size = UDim2.fromOffset(900, 20),
		Text = "Your character shapes how you see the world. Your choices decide who you become in it.",
		TextSize = 14,
		TextColor3 = C.dim,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = screen,
	})

	ClientState.Changed:Connect(function(s)
		setVisible(s ~= nil and s.character == nil)
	end)
end

return CharacterSelect
