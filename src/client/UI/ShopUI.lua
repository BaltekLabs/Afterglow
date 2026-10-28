-- Vendor window.
local UserInputService = game:GetService("UserInputService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Net = require(Shared.Net)

local ClientState = require(script.Parent.Parent.ClientState)

local ShopUI = {}

local UI, Kit, C
local window, title, list, wallet
local current

local function close()
	if not window.Visible then
		return
	end
	window.Visible = false
	current = nil
	UI.setBusy("shop", false)
	Net.ShopClose:FireServer()
end

local function render()
	if not current then
		return
	end
	local s = ClientState.state
	wallet.Text = string.format("◈ %d credits", s and s.credits or 0)
	Kit.clear(list)
	for i, entry in ipairs(current.stock) do
		local owned
		if entry.companion then
			owned = if s and s.companions and s.companions[entry.companion] then 1 else 0
		else
			owned = s and s.inventory[entry.item] or 0
		end
		local row = Kit.new("Frame", {
			Size = UDim2.new(1, 0, 0, 64),
			BackgroundColor3 = C.panelLight,
			BackgroundTransparency = 0.3,
			LayoutOrder = i,
			Parent = list,
		}, { Kit.corner(8) })
		Kit.label({
			Position = UDim2.fromOffset(14, 8),
			Size = UDim2.new(1, -140, 0, 20),
			Text = string.format("<b>%s</b>%s", entry.name, if owned > 0 then "  <font color=\"#968fb2\">(own " .. owned .. ")</font>" else ""),
			Parent = row,
		})
		Kit.label({
			Position = UDim2.fromOffset(14, 30),
			Size = UDim2.new(1, -140, 0, 30),
			Text = entry.description,
			RichText = false,
			TextSize = 13,
			TextColor3 = C.dim,
			Parent = row,
		})
		local affordable = s and (s.credits or 0) >= entry.price
		Kit.button({
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(110, 36),
			Text = "◈ " .. entry.price,
			TextColor3 = if affordable then C.amber else C.dim,
			Parent = row,
		}, function()
			Net.ShopBuy:FireServer(current.id, i)
		end)
	end
end

function ShopUI.init(ui)
	UI = ui
	Kit = ui.Kit
	C = Kit.Colors

	window = Kit.panel({
		Name = "Shop",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(520, 360),
		Visible = false,
		Parent = UI.gui,
		ZIndex = 12,
	})
	title = Kit.label({ Position = UDim2.fromOffset(22, 18), Size = UDim2.new(1, -80, 0, 28), Font = Kit.Fonts.title, TextSize = 22, Parent = window })
	wallet = Kit.label({ Position = UDim2.fromOffset(22, 48), Size = UDim2.new(1, -44, 0, 20), TextColor3 = C.amber, Parent = window })
	Kit.button({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 16),
		Size = UDim2.fromOffset(34, 34),
		Text = "✕",
		Parent = window,
	}, close)
	list = Kit.new("ScrollingFrame", {
		Position = UDim2.fromOffset(22, 80),
		Size = UDim2.new(1, -44, 1, -100),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Parent = window,
	}, { Kit.list(8) })

	Net.Shop.OnClientEvent:Connect(function(payload)
		current = payload
		title.Text = string.upper(payload.name)
		window.Visible = true
		UI.setBusy("shop", true)
		render()
	end)
	ClientState.Changed:Connect(render)

	UserInputService.InputBegan:Connect(function(input)
		if window.Visible and (input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.ButtonB) then
			close()
		end
	end)
end

return ShopUI
