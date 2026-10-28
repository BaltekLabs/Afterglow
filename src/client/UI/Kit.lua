-- Tiny UI construction helpers and the shared visual theme.
local TweenService = game:GetService("TweenService")

local Kit = {}

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

Kit.Colors = {
	bg = rgb(8, 7, 14),
	panel = rgb(14, 13, 24),
	panelLight = rgb(28, 26, 44),
	line = rgb(70, 64, 110),
	text = rgb(234, 230, 246),
	dim = rgb(150, 144, 178),
	accent = rgb(90, 255, 200),
	magenta = rgb(255, 80, 190),
	amber = rgb(255, 176, 72),
	violet = rgb(160, 130, 255),
	danger = rgb(255, 90, 80),
	ascent = rgb(120, 200, 255),
}

Kit.Fonts = {
	title = Enum.Font.GothamBlack,
	bold = Enum.Font.GothamBold,
	medium = Enum.Font.GothamMedium,
	body = Enum.Font.Gotham,
	mono = Enum.Font.Code,
}

function Kit.new(className, props, children)
	local inst = Instance.new(className)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then
			parent = v
		else
			inst[k] = v
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

function Kit.corner(radius)
	return Kit.new("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
end

function Kit.stroke(color, thickness, transparency)
	return Kit.new("UIStroke", {
		Color = color or Kit.Colors.line,
		Thickness = thickness or 1,
		Transparency = transparency or 0.3,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function Kit.pad(px, py)
	py = py or px
	return Kit.new("UIPadding", {
		PaddingLeft = UDim.new(0, px),
		PaddingRight = UDim.new(0, px),
		PaddingTop = UDim.new(0, py),
		PaddingBottom = UDim.new(0, py),
	})
end

function Kit.list(padding, direction, hAlign)
	return Kit.new("UIListLayout", {
		Padding = UDim.new(0, padding or 6),
		FillDirection = direction or Enum.FillDirection.Vertical,
		HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end

function Kit.label(props)
	local defaults = {
		BackgroundTransparency = 1,
		Font = Kit.Fonts.body,
		TextColor3 = Kit.Colors.text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		RichText = true,
		Size = UDim2.new(1, 0, 0, 20),
	}
	for k, v in pairs(props) do
		defaults[k] = v
	end
	return Kit.new("TextLabel", defaults)
end

function Kit.button(props, onClick)
	local base = props.BackgroundColor3 or Kit.Colors.panelLight
	local defaults = {
		BackgroundColor3 = base,
		AutoButtonColor = false,
		Font = Kit.Fonts.medium,
		TextColor3 = Kit.Colors.text,
		TextSize = 16,
		Size = UDim2.new(1, 0, 0, 38),
		Selectable = true,
	}
	for k, v in pairs(props) do
		defaults[k] = v
	end
	local button = Kit.new("TextButton", defaults, { Kit.corner(6), Kit.stroke(Kit.Colors.line, 1, 0.5) })
	local hover = base:Lerp(Kit.Colors.accent, 0.18)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), { BackgroundColor3 = hover }):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), { BackgroundColor3 = base }):Play()
	end)
	button.SelectionGained:Connect(function()
		button.BackgroundColor3 = hover
	end)
	button.SelectionLost:Connect(function()
		button.BackgroundColor3 = base
	end)
	if onClick then
		button.Activated:Connect(onClick)
	end
	return button
end

function Kit.panel(props)
	local defaults = {
		BackgroundColor3 = Kit.Colors.panel,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
	}
	for k, v in pairs(props) do
		defaults[k] = v
	end
	return Kit.new("Frame", defaults, { Kit.corner(10), Kit.stroke(Kit.Colors.line, 1, 0.35) })
end

function Kit.tween(inst, time, props, style)
	local t = TweenService:Create(inst, TweenInfo.new(time, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

-- Escape story text before inserting it into RichText labels (e.g. "Static & Sons").
function Kit.escape(text)
	return (string.gsub(string.gsub(string.gsub(text, "&", "&amp;"), "<", "&lt;"), ">", "&gt;"))
end

function Kit.clear(container)
	for _, child in ipairs(container:GetChildren()) do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") and not child:IsA("UIGridLayout") then
			child:Destroy()
		end
	end
end

return Kit
