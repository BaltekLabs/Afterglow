-- Journal [J]: quests, discovered lore (with a reader), people & reputation, items, system.
local UserInputService = game:GetService("UserInputService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Net = require(Shared.Net)
local Config = require(Shared.Config)
local Quests = require(Shared.Data.Quests)
local Lore = require(Shared.Data.Lore)
local Items = require(Shared.Data.Items)
local NPCs = require(Shared.Data.NPCs)
local Factions = require(Shared.Data.Factions)
local Characters = require(Shared.Data.Characters)
local Companions = require(Shared.Data.Companions)

local ClientState = require(script.Parent.Parent.ClientState)

local Journal = {}

local UI, Kit, C
local window, content, tabButtons, reader, readerTitle, readerCategory, readerBody
local activeTab = "quests"
local TABS = {
	{ id = "quests", name = "Quests" },
	{ id = "journal", name = "Journal" },
	{ id = "people", name = "People" },
	{ id = "items", name = "Items" },
	{ id = "companions", name = "Companions" },
	{ id = "system", name = "System" },
}
local KIND_LABEL = { main = "MAIN", side = "SIDE", job = "JOB" }

local function sectionTitle(text, order)
	return Kit.label({ Text = text, Font = Kit.Fonts.bold, TextSize = 13, TextColor3 = C.accent, LayoutOrder = order, Parent = content })
end

local function card(order)
	local frame = Kit.new("Frame", {
		Size = UDim2.new(1, -8, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = C.panelLight,
		BackgroundTransparency = 0.3,
		LayoutOrder = order,
		Parent = content,
	}, { Kit.corner(8), Kit.pad(14, 12), Kit.list(6) })
	return frame
end

local function renderQuests(s)
	local order = 0
	local function add(status)
		local list = {}
		for id, q in pairs(s.quests) do
			if q.status == status and Quests[id] then
				table.insert(list, id)
			end
		end
		table.sort(list, function(a, b)
			return (Quests[a].kind == "main" and 0 or 1) < (Quests[b].kind == "main" and 0 or 1)
		end)
		return list
	end
	local active, complete = add("active"), add("complete")
	order += 1
	sectionTitle("ACTIVE", order)
	if #active == 0 then
		order += 1
		Kit.label({ Text = "Nothing active. The city is yours: talk to people, listen to rumors, go exploring.", TextColor3 = C.dim, LayoutOrder = order, Parent = content })
	end
	local tracked = ClientState.tracked()
	for _, id in ipairs(active) do
		local def, q = Quests[id], s.quests[id]
		local stage = def.stages[q.stage]
		order += 1
		local c = card(order)
		Kit.label({
			Text = string.format("<font color=\"#ffb048\">%s</font>   <b>%s</b>%s", KIND_LABEL[def.kind] or "", def.name, if id == tracked then "   <font color=\"#5affc8\">◆ tracked</font>" else ""),
			TextSize = 17,
			LayoutOrder = 1,
			Parent = c,
		})
		Kit.label({ Text = def.description, RichText = false, TextColor3 = C.dim, TextSize = 14, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = c })
		if stage then
			Kit.label({ Text = "→ " .. stage.objective, RichText = false, TextSize = 15, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3, Parent = c })
			if stage.hint then
				Kit.label({ Text = stage.hint, RichText = false, TextSize = 13, TextColor3 = C.violet, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 4, Parent = c })
			end
		end
		Kit.button({ Text = if id == tracked then "Untrack" else "Track", Size = UDim2.fromOffset(100, 30), TextSize = 14, LayoutOrder = 5, Parent = c }, function()
			ClientState.trackedOverride = if id == tracked then "none" else id
			UI.Hud.refresh()
			Journal.render()
		end)
	end
	if #complete > 0 then
		order += 1
		sectionTitle("COMPLETED", order)
		for _, id in ipairs(complete) do
			order += 1
			Kit.label({ Text = "✓  " .. Quests[id].name, TextColor3 = C.dim, LayoutOrder = order, Parent = content })
		end
	end
end

local function renderJournal(s)
	local order = 0
	for _, category in ipairs(Lore.categories) do
		local entries = {}
		for id, entry in pairs(Lore.entries) do
			if entry.category == category.id then
				table.insert(entries, { id = id, entry = entry })
			end
		end
		table.sort(entries, function(a, b)
			return a.entry.order < b.entry.order
		end)
		local found = 0
		for _, e in ipairs(entries) do
			if s.lore[e.id] then
				found += 1
			end
		end
		order += 1
		sectionTitle(string.format("%s   <font color=\"#968fb2\">%d / %d</font>", string.upper(category.name), found, #entries), order)
		for _, e in ipairs(entries) do
			order += 1
			if s.lore[e.id] then
				Kit.button({
					Text = e.entry.title,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -8, 0, 34),
					LayoutOrder = order,
					Parent = content,
				}, function()
					Journal.openReader(e.id)
				end).TextSize = 15
			else
				Kit.label({ Text = "   ? ? ?", TextColor3 = C.line, LayoutOrder = order, Parent = content })
			end
		end
	end
end

local function trustLabel(v)
	if v <= -3 then
		return "Resentful", C.danger
	elseif v < 0 then
		return "Wary", C.amber
	elseif v == 0 then
		return "Acquainted", C.dim
	elseif v < 4 then
		return "Friendly", C.accent
	end
	return "Trusts you", C.accent
end

local function renderPeople(s)
	local order = 1
	sectionTitle("REPUTATION", order)
	for _, id in ipairs(Factions.order) do
		local faction = Factions.list[id]
		local value = s.rep[id] or 0
		order += 1
		local c = card(order)
		Kit.label({
			Text = string.format("<b>%s</b>   <font color=\"#968fb2\">%s</font>", faction.name, Factions.standing(value)),
			LayoutOrder = 1,
			Parent = c,
		})
		local bar = Kit.new("Frame", { Size = UDim2.new(1, 0, 0, 6), BackgroundColor3 = C.panel, BorderSizePixel = 0, LayoutOrder = 2, Parent = c }, { Kit.corner(3) })
		local fill = math.clamp((value + 100) / 200, 0, 1)
		Kit.new("Frame", { Size = UDim2.fromScale(fill, 1), BackgroundColor3 = Color3.fromHex(faction.color), BorderSizePixel = 0, Parent = bar }, { Kit.corner(3) })
		Kit.label({ Text = faction.description, RichText = false, TextSize = 13, TextColor3 = C.dim, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3, Parent = c })
	end
	order += 1
	sectionTitle("PEOPLE YOU'VE MET", order)
	local met = {}
	for id, npc in pairs(NPCs) do
		if s.flags["met_" .. id] then
			table.insert(met, { id = id, npc = npc })
		end
	end
	table.sort(met, function(a, b)
		return a.npc.name < b.npc.name
	end)
	if #met == 0 then
		order += 1
		Kit.label({ Text = "No one yet.", TextColor3 = C.dim, LayoutOrder = order, Parent = content })
	end
	for _, m in ipairs(met) do
		local label, color = trustLabel(s.trust[m.id] or 0)
		order += 1
		Kit.label({
			Text = string.format("<b>%s</b>  <font color=\"#968fb2\">%s</font>   <font color=\"#%s\">%s</font>", m.npc.name, Kit.escape(m.npc.role or ""), color:ToHex(), label),
			TextSize = 15,
			LayoutOrder = order,
			Parent = content,
		})
	end
end

local function renderItems(s)
	local order = 1
	sectionTitle(string.format("INVENTORY   <font color=\"#ffb048\">◈ %d credits</font>", s.credits or 0), order)
	local ids = {}
	for id in pairs(s.inventory) do
		table.insert(ids, id)
	end
	table.sort(ids)
	if #ids == 0 then
		order += 1
		Kit.label({ Text = "Empty pockets.", TextColor3 = C.dim, LayoutOrder = order, Parent = content })
	end
	for _, id in ipairs(ids) do
		local item = Items[id]
		if item then
			order += 1
			local c = card(order)
			local count = s.inventory[id]
			Kit.label({
				Text = string.format("<b>%s</b>%s   <font color=\"#968fb2\">%s</font>", item.name, if count > 1 then " ×" .. count else "", string.upper(item.kind)),
				LayoutOrder = 1,
				Parent = c,
			})
			Kit.label({ Text = item.description, RichText = false, TextSize = 14, TextColor3 = C.dim, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = c })
			if item.use then
				Kit.button({ Text = "Use", Size = UDim2.fromOffset(90, 30), TextSize = 14, LayoutOrder = 3, Parent = c }, function()
					Net.UseItem:FireServer(id)
				end)
			end
		end
	end
end

local function renderCompanions(s)
	local order = 1
	sectionTitle("COMPANIONS", order)
	local owned = {}
	for _, id in ipairs(Companions.order) do
		if s.companions and s.companions[id] then
			table.insert(owned, id)
		end
	end
	if #owned == 0 then
		order += 1
		Kit.label({
			Text = "No companions yet. Marigold's Menagerie in the Grid sells animals; Kettle's Bot Shop in the Rust sells robots.",
			RichText = false,
			TextColor3 = C.dim,
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = order,
			Parent = content,
		})
	end
	local perkText = { alert = "Warns you of Rooted", light = "Carries a light", scavenge = "Finds credits" }
	for _, id in ipairs(owned) do
		local def = Companions.list[id]
		order += 1
		local c = card(order)
		local following = s.companion == id
		Kit.label({
			Text = string.format("<b>%s</b>   <font color=\"#968fb2\">%s · %s</font>%s", def.name, string.upper(def.kind), perkText[def.perk] or "", if following then "   <font color=\"#5affc8\">◆ following</font>" else ""),
			LayoutOrder = 1,
			Parent = c,
		})
		Kit.label({ Text = def.description, RichText = false, TextSize = 14, TextColor3 = C.dim, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = c })
		Kit.button({ Text = if following then "Send home" else "Summon", Size = UDim2.fromOffset(120, 30), TextSize = 14, LayoutOrder = 3, Parent = c }, function()
			Net.Companion:FireServer(if following then nil else id)
		end)
	end
end

local function renderSystem(s)
	local char = Characters.list[s.character]
	local order = 1
	sectionTitle("PLAYING AS", order)
	order += 1
	Kit.label({
		Text = string.format("<b>%s</b> — %s", char and char.name or "?", char and char.title or ""),
		LayoutOrder = order,
		Parent = content,
	})
	order += 1
	sectionTitle("CONTROLS", order)
	local lines = {
		"Mouse / right stick — look   ·   WASD / left stick — move",
		"Shift / L3 — sprint (loud)   ·   C / B — sneak (quiet)",
		"E / X — interact   ·   Q / Y — ability   ·   V / R3 — swap shoulder",
		"J / Select — journal   ·   1-6 or click — dialogue choices   ·   Space — skip text",
		"Lifts connect the Rust, the Grid and the sky roads. The Crown Lift needs clearance.",
	}
	for _, line in ipairs(lines) do
		order += 1
		Kit.label({ Text = line, TextSize = 14, TextColor3 = C.dim, LayoutOrder = order, Parent = content })
	end
	if Config.Debug.AllowReset then
		order += 1
		sectionTitle("PROTOTYPE", order)
		order += 1
		local confirm = false
		local button
		button = Kit.button({
			Text = "Start over (wipe this save)",
			Size = UDim2.fromOffset(260, 36),
			BackgroundColor3 = Color3.fromRGB(70, 24, 30),
			LayoutOrder = order,
			Parent = content,
		}, function()
			if not confirm then
				confirm = true
				button.Text = "Click again to confirm"
				return
			end
			Journal.close()
			Net.ResetSave:FireServer()
		end)
	end
end

function Journal.render()
	local s = ClientState.state
	if not window.Visible or not s then
		return
	end
	for id, button in pairs(tabButtons) do
		button.TextColor3 = if id == activeTab then C.accent else C.dim
	end
	Kit.clear(content)
	if activeTab == "quests" then
		renderQuests(s)
	elseif activeTab == "journal" then
		renderJournal(s)
	elseif activeTab == "people" then
		renderPeople(s)
	elseif activeTab == "items" then
		renderItems(s)
	elseif activeTab == "companions" then
		renderCompanions(s)
	else
		renderSystem(s)
	end
end

function Journal.open(tab)
	local s = ClientState.state
	if not s or not s.character then
		return
	end
	activeTab = tab or activeTab
	window.Visible = true
	UI.setBusy("journal", true)
	Journal.render()
end

function Journal.close()
	window.Visible = false
	reader.Visible = false
	UI.setBusy("journal", false)
	UI.setBusy("reader", false)
end

function Journal.openReader(id)
	local entry = Lore.entries[id]
	if not entry then
		return
	end
	local category = ""
	for _, c in ipairs(Lore.categories) do
		if c.id == entry.category then
			category = string.upper(c.name)
		end
	end
	readerCategory.Text = category
	readerTitle.Text = entry.title
	readerBody.Text = entry.text
	reader.Visible = true
	UI.setBusy("reader", true)
end

function Journal.init(ui)
	UI = ui
	Kit = ui.Kit
	C = Kit.Colors

	window = Kit.panel({
		Name = "Journal",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0.8, 0, 0.78, 0),
		Visible = false,
		Parent = UI.gui,
		ZIndex = 12,
	})
	Kit.new("UISizeConstraint", { MaxSize = Vector2.new(900, 620) }).Parent = window

	Kit.label({
		Position = UDim2.fromOffset(24, 18),
		Size = UDim2.new(1, -48, 0, 28),
		Text = "JOURNAL",
		Font = Kit.Fonts.title,
		TextSize = 24,
		Parent = window,
	})
	Kit.button({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 16),
		Size = UDim2.fromOffset(34, 34),
		Text = "✕",
		Parent = window,
	}, Journal.close)

	local tabs = Kit.new("Frame", {
		Position = UDim2.fromOffset(24, 58),
		Size = UDim2.new(1, -48, 0, 32),
		BackgroundTransparency = 1,
		Parent = window,
	}, { Kit.list(8, Enum.FillDirection.Horizontal) })
	tabButtons = {}
	for i, tab in ipairs(TABS) do
		tabButtons[tab.id] = Kit.button({
			Text = tab.name,
			Size = UDim2.fromOffset(104, 32),
			TextSize = 15,
			LayoutOrder = i,
			Parent = tabs,
		}, function()
			activeTab = tab.id
			Journal.render()
		end)
	end

	content = Kit.new("ScrollingFrame", {
		Position = UDim2.fromOffset(24, 104),
		Size = UDim2.new(1, -48, 1, -124),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = C.line,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Parent = window,
	}, { Kit.list(8) })

	-- Reader for letters and logs, opened from the journal or when you read something in the world.
	reader = Kit.panel({
		Name = "Reader",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0.5, 0, 0.7, 0),
		BackgroundColor3 = Color3.fromRGB(20, 18, 26),
		BackgroundTransparency = 0.02,
		Visible = false,
		Parent = UI.gui,
		ZIndex = 14,
	})
	Kit.new("UISizeConstraint", { MinSize = Vector2.new(420, 320), MaxSize = Vector2.new(620, 640) }).Parent = reader
	readerCategory = Kit.label({ Position = UDim2.fromOffset(28, 22), Size = UDim2.new(1, -56, 0, 16), Font = Kit.Fonts.bold, TextSize = 12, TextColor3 = C.violet, Parent = reader })
	readerTitle = Kit.label({ Position = UDim2.fromOffset(28, 42), Size = UDim2.new(1, -90, 0, 30), Font = Kit.Fonts.title, TextSize = 22, Parent = reader })
	local scroll = Kit.new("ScrollingFrame", {
		Position = UDim2.fromOffset(28, 84),
		Size = UDim2.new(1, -56, 1, -136),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Parent = reader,
	})
	readerBody = Kit.label({
		Size = UDim2.new(1, -10, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = Kit.Fonts.mono,
		TextSize = 16,
		LineHeight = 1.2,
		RichText = false,
		Parent = scroll,
	})
	Kit.button({
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -14),
		Size = UDim2.fromOffset(140, 34),
		Text = "Close",
		Parent = reader,
	}, function()
		reader.Visible = false
		UI.setBusy("reader", false)
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.J or input.KeyCode == Enum.KeyCode.ButtonSelect then
			if window.Visible then
				Journal.close()
			elseif not UI.isBusy() then
				Journal.open()
			end
		elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.ButtonB then
			if reader.Visible then
				reader.Visible = false
				UI.setBusy("reader", false)
			elseif window.Visible then
				Journal.close()
			end
		end
	end)

	Net.ShowLore.OnClientEvent:Connect(Journal.openReader)
	ClientState.Changed:Connect(Journal.render)
end

return Journal
