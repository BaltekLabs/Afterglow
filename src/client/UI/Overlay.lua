-- Toasts, region banners, cinematic narration, damage flash and the spore vignette.
local UserInputService = game:GetService("UserInputService")

local Overlay = {}

local UI, Kit, C
local toastStack, banner, bannerTitle, bannerSub, flash, spores, sporeLabel
local narration, narrationText, barTop, barBottom
local narrating = false
local skipLine = false
local bannerToken = 0

local KIND_COLORS

function Overlay.init(ui)
	UI = ui
	Kit = ui.Kit
	C = Kit.Colors
	KIND_COLORS = {
		quest = C.accent,
		objective = C.accent,
		item = C.amber,
		lore = C.violet,
		rep = C.ascent,
		trust = C.magenta,
		warn = C.danger,
		info = C.dim,
	}

	local root = Kit.new("Frame", { Name = "Overlay", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = UI.gui, ZIndex = 20 })

	toastStack = Kit.new("Frame", {
		Name = "Toasts",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -24, 0, 150),
		Size = UDim2.fromOffset(380, 400),
		BackgroundTransparency = 1,
		Parent = root,
	}, { Kit.list(6, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right) })

	banner = Kit.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.16, 0),
		Size = UDim2.fromOffset(700, 90),
		BackgroundTransparency = 1,
		Parent = root,
	})
	bannerTitle = Kit.label({
		Size = UDim2.new(1, 0, 0, 52),
		Font = Kit.Fonts.title,
		TextSize = 44,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTransparency = 1,
		TextStrokeTransparency = 1,
		Parent = banner,
	})
	bannerSub = Kit.label({
		Position = UDim2.fromOffset(0, 54),
		Size = UDim2.new(1, 0, 0, 24),
		Font = Kit.Fonts.medium,
		TextSize = 18,
		TextColor3 = C.accent,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTransparency = 1,
		Parent = banner,
	})

	flash = Kit.new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = C.danger,
		BackgroundTransparency = 1,
		Parent = root,
		ZIndex = 19,
	})

	spores = Kit.new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(140, 255, 120),
		BackgroundTransparency = 1,
		Parent = root,
		ZIndex = 18,
	})
	sporeLabel = Kit.label({
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -130),
		Size = UDim2.fromOffset(500, 24),
		Font = Kit.Fonts.bold,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(190, 255, 160),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTransparency = 1,
		Parent = root,
	})

	narration = Kit.new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = root, ZIndex = 30 })
	barTop = Kit.new("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Parent = narration, ZIndex = 30 })
	barBottom = Kit.new("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Parent = narration,
		ZIndex = 30,
	})
	Kit.new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Parent = narration, ZIndex = 29 })
	narrationText = Kit.label({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0.6, 0, 0, 140),
		Font = Kit.Fonts.medium,
		TextSize = 26,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTransparency = 1,
		Parent = narration,
		ZIndex = 31,
	})

	UserInputService.InputBegan:Connect(function(input)
		if narrating and (input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.ButtonA or input.UserInputType == Enum.UserInputType.MouseButton1) then
			skipLine = true
		end
	end)
end

function Overlay.toast(text, kind)
	if narrating then
		-- Hold notifications until the cinematic finishes.
		task.spawn(function()
			while narrating do
				task.wait(0.2)
			end
			Overlay.toast(text, kind)
		end)
		return
	end
	local color = KIND_COLORS[kind] or C.dim
	local isObjective = kind == "objective"
	local frame = Kit.panel({
		Size = UDim2.fromOffset(360, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0.15,
		Parent = toastStack,
	})
	Kit.pad(12, 9).Parent = frame
	Kit.new("Frame", {
		Size = UDim2.new(0, 3, 1, 0),
		Position = UDim2.fromOffset(-12, 0),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = frame,
	})
	local safe = Kit.escape(text)
	local label = Kit.label({
		Text = if isObjective then "<font color=\"#5affc8\"><b>OBJECTIVE</b></font>  " .. safe else safe,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		TextSize = 15,
		TextColor3 = if kind == "info" then C.text else color:Lerp(C.text, 0.45),
		Parent = frame,
	})
	frame.BackgroundTransparency = 1
	label.TextTransparency = 1
	Kit.tween(frame, 0.25, { BackgroundTransparency = 0.15 })
	Kit.tween(label, 0.25, { TextTransparency = 0 })
	task.delay(if isObjective then 6 else 4.5, function()
		Kit.tween(frame, 0.4, { BackgroundTransparency = 1 })
		Kit.tween(label, 0.4, { TextTransparency = 1 })
		task.wait(0.45)
		frame:Destroy()
	end)
end

function Overlay.banner(title, subtitle)
	bannerToken += 1
	local token = bannerToken
	bannerTitle.Text = title
	bannerSub.Text = subtitle or ""
	Kit.tween(bannerTitle, 0.8, { TextTransparency = 0, TextStrokeTransparency = 0.7 })
	Kit.tween(bannerSub, 0.8, { TextTransparency = 0 })
	task.delay(3.5, function()
		if token == bannerToken then
			Kit.tween(bannerTitle, 1.2, { TextTransparency = 1, TextStrokeTransparency = 1 })
			Kit.tween(bannerSub, 1.2, { TextTransparency = 1 })
		end
	end)
end

function Overlay.hurt()
	flash.BackgroundTransparency = 0.55
	Kit.tween(flash, 0.6, { BackgroundTransparency = 1 })
end

local sporeState
function Overlay.setSpores(inside, immune)
	local state = if not inside then "none" elseif immune then "immune" else "hurt"
	if state == sporeState then
		return
	end
	sporeState = state
	if state == "none" then
		Kit.tween(spores, 0.8, { BackgroundTransparency = 1 })
		Kit.tween(sporeLabel, 0.8, { TextTransparency = 1 })
	else
		Kit.tween(spores, 0.8, { BackgroundTransparency = if state == "hurt" then 0.82 else 0.93 })
		sporeLabel.Text = if state == "hurt" then "SPORE CLOUD — every breath burns. Get out, or find a filter mask." else "Spore cloud — you breathe easy."
		Kit.tween(sporeLabel, 0.8, { TextTransparency = 0 })
	end
end

-- Plays lines one by one in letterbox. Yields until finished.
function Overlay.narrate(lines)
	while narrating do
		task.wait(0.2)
	end
	narrating = true
	UI.setBusy("narration", true)
	narration.Visible = true
	Kit.tween(barTop, 0.6, { Size = UDim2.new(1, 0, 0.12, 0) })
	Kit.tween(barBottom, 0.6, { Size = UDim2.new(1, 0, 0.12, 0) })
	task.wait(0.6)
	for i, line in ipairs(lines) do
		skipLine = false
		narrationText.Text = line
		narrationText.Font = if i <= 2 then Kit.Fonts.title else Kit.Fonts.medium
		narrationText.TextSize = if i == 1 then 40 elseif i == 2 then 20 else 26
		narrationText.TextColor3 = if i == 2 then C.accent else C.text
		Kit.tween(narrationText, 0.6, { TextTransparency = 0 })
		local hold = 1.6 + #line * 0.035
		local started = os.clock()
		task.wait(0.3)
		skipLine = false
		while os.clock() - started < hold and not skipLine do
			task.wait(0.05)
		end
		Kit.tween(narrationText, 0.4, { TextTransparency = 1 })
		task.wait(0.45)
	end
	Kit.tween(barTop, 0.6, { Size = UDim2.new(1, 0, 0, 0) })
	Kit.tween(barBottom, 0.6, { Size = UDim2.new(1, 0, 0, 0) })
	task.wait(0.6)
	narration.Visible = false
	UI.setBusy("narration", false)
	narrating = false
end

return Overlay
