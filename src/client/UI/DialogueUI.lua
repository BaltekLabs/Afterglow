-- Conversation panel. The server sends nodes; we render them and send back the chosen index.
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Net = require(Shared.Net)

local DialogueUI = {}

local UI, Kit, C
local panel, speakerLabel, speakerBar, body, choiceList
local current
local showToken = 0
local typing = false
local skipTyping = false
local choiceButtons = {}

local NUMBER_KEYS = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
}

local function choose(index)
	if not current or typing or not current.choices[index] then
		return
	end
	current = nil
	for _, b in ipairs(choiceButtons) do
		b.Active = false
		b.AutoButtonColor = false
		b.TextTransparency = 0.6
	end
	Net.DialogueChoice:FireServer(index)
end

local function typeText(text, token)
	typing = true
	skipTyping = false
	body.Text = text
	body.MaxVisibleGraphemes = 0
	local total = utf8.len(text) or #text
	local shown = 0
	while shown < total and not skipTyping and token == showToken do
		shown = math.min(total, shown + 2)
		body.MaxVisibleGraphemes = shown
		task.wait(0.016)
	end
	if token == showToken then
		body.MaxVisibleGraphemes = -1
		typing = false
	end
end

local function show(payload)
	showToken += 1
	local token = showToken
	current = payload
	panel.Visible = true
	UI.setBusy("dialogue", true)
	speakerLabel.Text = string.upper(payload.speaker or "")
	speakerLabel.TextColor3 = payload.color or C.accent
	speakerBar.BackgroundColor3 = payload.color or C.accent

	Kit.clear(choiceList)
	table.clear(choiceButtons)
	choiceList.Visible = false
	typeText(Kit.escape(payload.text or ""), token)
	if token ~= showToken then
		return
	end

	for i, raw in ipairs(payload.choices) do
		local text = Kit.escape(raw)
		local tagged = string.match(text, "^%[(.-)%]")
		local display = string.format("<font color=\"#5affc8\">%d.</font>  %s", i, text)
		if tagged then
			display = string.format("<font color=\"#5affc8\">%d.</font>  <font color=\"#ffb048\">[%s]</font>%s", i, tagged, string.sub(text, #tagged + 3))
		end
		local button = Kit.button({
			Text = display,
			RichText = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 36),
			LayoutOrder = i,
			Parent = choiceList,
		}, function()
			choose(i)
		end)
		Kit.pad(14, 0).Parent = button
		table.insert(choiceButtons, button)
	end
	choiceList.Visible = true
	if UserInputService.GamepadEnabled and choiceButtons[1] then
		GuiService.SelectedObject = choiceButtons[1]
	end
end

local function close()
	showToken += 1
	typing = false
	current = nil
	skipTyping = true
	panel.Visible = false
	UI.setBusy("dialogue", false)
	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(panel) then
		GuiService.SelectedObject = nil
	end
end

function DialogueUI.init(ui)
	UI = ui
	Kit = ui.Kit
	C = Kit.Colors

	panel = Kit.panel({
		Name = "Dialogue",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -40),
		Size = UDim2.new(0, 780, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = UI.gui,
		ZIndex = 10,
	})
	Kit.new("UISizeConstraint", { MaxSize = Vector2.new(780, 600) }).Parent = panel
	local inner = Kit.new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = panel,
	}, { Kit.pad(22, 18), Kit.list(12) })

	local header = Kit.new("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = 1, Parent = inner })
	speakerBar = Kit.new("Frame", { Size = UDim2.fromOffset(4, 20), BorderSizePixel = 0, Parent = header })
	speakerLabel = Kit.label({ Position = UDim2.fromOffset(12, 1), Size = UDim2.new(1, -12, 1, 0), Font = Kit.Fonts.bold, TextSize = 16, Parent = header })

	body = Kit.label({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = Kit.Fonts.body,
		TextSize = 19,
		LineHeight = 1.15,
		LayoutOrder = 2,
		Parent = inner,
	})

	choiceList = Kit.new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Parent = inner,
	}, { Kit.list(6) })

	panel.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and typing then
			skipTyping = true
		end
	end)

	UserInputService.InputBegan:Connect(function(input)
		if not panel.Visible then
			return
		end
		if typing and (input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.ButtonA) then
			skipTyping = true
			return
		end
		local index = NUMBER_KEYS[input.KeyCode]
		if index then
			choose(index)
		elseif (input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Return) and current and #current.choices == 1 then
			choose(1)
		end
	end)

	Net.Dialogue.OnClientEvent:Connect(function(payload)
		if payload then
			task.spawn(show, payload)
		else
			close()
		end
	end)
end

return DialogueUI
