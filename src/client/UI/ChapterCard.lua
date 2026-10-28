-- End-of-chapter summary: recaps the choices this playthrough made.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Net = require(Shared.Net)
local Config = require(Shared.Config)
local Characters = require(Shared.Data.Characters)

local ChapterCard = {}

local UI, Kit, C
local screen, list

local function recap(s)
	local f = s.flags
	local lines = {}
	local function add(text)
		table.insert(lines, text)
	end

	local char = Characters.list[s.character]
	add("You played as <b>" .. (char and char.name or "?") .. "</b>.")

	if f.took_sewers then
		add("You escaped a city that never lets anyone leave, through the storm sewers.")
	end
	if f.entered_powerhouse then
		add("You broke into the Powerhouse and saw the Mother Strain.")
	end

	if f.ending_silence then
		add("You <b>silenced</b> the Halvorsen relay. Half of Veyra's lights went dark.")
	elseif f.ending_listen then
		add("You <b>left the broadcast running</b>. Wren's voice still calls home.")
	elseif f.ending_core then
		add("You <b>took the relay core</b>. The broadcast broke into static.")
	elseif f.ending_answered then
		add("You <b>answered the broadcast</b>. Now it calls your name.")
	end

	if f.core_to_ascent then
		add("You sold the relay core to Ascent.")
	elseif f.core_to_fringe then
		add("You gave the relay core to Mother Lune to bury.")
	elseif f.ending_core then
		add("You still carry the relay core. Someone will want it.")
	end

	if f.told_truth then
		add("You told Tamsin the truth.")
	elseif f.told_lie then
		add("You told Tamsin a kind lie.")
	end

	if f.seeds_to_fringe then
		add("Hollow Garden planted the first plain seeds in fourteen years.")
	elseif f.seeds_to_ascent then
		add("Ascent's gene lab got the pre-Bloom seeds. Bram remembers.")
	end
	if f.gave_letters then
		add("Pike, once Tobi Adeyemi, finally read his parents' letters.")
	end
	if f.caught_stealing_vela then
		add("Vela caught you stealing.")
	elseif f.stole_from_vela then
		add("You stole from Vela's stall, and nobody saw.")
	end
	if f.trespassed_ascent then
		add("Ascent security has your face on file.")
	end
	if f.ledger_broadcast then
		add("You broadcast Pell's ledger to every radio in Veyra.")
	elseif f.ledger_to_vane then
		add("You sold Pell's ledger to Vane.")
	elseif f.ledger_to_pell then
		add("You gave Pell his ledger back, and he got you into the Crown.")
	end
	if f.parts_delivered then
		add("Rail's End's locomotive has its couplers.")
	end
	local pets = 0
	for _ in pairs(s.companions or {}) do
		pets += 1
	end
	if pets > 0 then
		add(string.format("Companions adopted: %d", pets))
	end

	local found = 0
	for _ in pairs(s.lore) do
		found += 1
	end
	add(string.format("Journal entries discovered: %d", found))
	return lines
end

local function close()
	screen.Visible = false
	UI.setBusy("chapter", false)
end

function ChapterCard.init(ui)
	UI = ui
	Kit = ui.Kit
	C = Kit.Colors

	screen = Kit.new("Frame", {
		Name = "ChapterCard",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.15,
		Visible = false,
		Parent = UI.gui,
		ZIndex = 50,
	})
	local column = Kit.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(640, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = screen,
	}, { Kit.list(10, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center) })
	Kit.label({
		Text = "CHAPTER ONE COMPLETE",
		Font = Kit.Fonts.bold,
		TextSize = 16,
		TextColor3 = C.accent,
		TextXAlignment = Enum.TextXAlignment.Center,
		LayoutOrder = 1,
		Parent = column,
	})
	Kit.label({
		Text = "THE SIGNAL",
		Font = Kit.Fonts.title,
		TextSize = 54,
		Size = UDim2.new(1, 0, 0, 60),
		TextXAlignment = Enum.TextXAlignment.Center,
		LayoutOrder = 2,
		Parent = column,
	})
	list = Kit.new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Parent = column,
	}, { Kit.list(6, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center) })
	Kit.label({
		Text = "The world keeps going. Explore, finish what you started, or begin again as someone else.",
		TextSize = 14,
		TextColor3 = C.dim,
		TextXAlignment = Enum.TextXAlignment.Center,
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 4,
		Parent = column,
	})
	local buttons = Kit.new("Frame", {
		Size = UDim2.fromOffset(440, 44),
		BackgroundTransparency = 1,
		LayoutOrder = 5,
		Parent = column,
	}, { Kit.list(16, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center) })
	Kit.button({ Text = "Keep exploring", Size = UDim2.fromOffset(200, 42), Parent = buttons }, close)
	if Config.Debug.AllowReset then
		Kit.button({ Text = "Start over", Size = UDim2.fromOffset(200, 42), Parent = buttons }, function()
			close()
			Net.ResetSave:FireServer()
		end)
	end

	Net.ChapterComplete.OnClientEvent:Connect(function(s)
		Kit.clear(list)
		for i, line in ipairs(recap(s)) do
			Kit.label({
				Text = line,
				TextSize = 17,
				TextXAlignment = Enum.TextXAlignment.Center,
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = i,
				Parent = list,
			})
		end
		screen.Visible = true
		UI.setBusy("chapter", true)
	end)
end

return ChapterCard
