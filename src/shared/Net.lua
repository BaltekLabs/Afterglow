-- Remote events shared by server and client. The server creates them; clients wait for them.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EVENTS = {
	"Ready", -- C->S  client finished loading, send me my state
	"State", -- S->C  full story state snapshot
	"Notify", -- S->C  toast (text, kind)
	"Narrate", -- S->C  cinematic lines
	"ShowLore", -- S->C  open the reader on a journal entry
	"Dialogue", -- S->C  dialogue node payload, or nil to close
	"DialogueChoice", -- C->S  chosen option index
	"Shop", -- S->C  open shop payload
	"ShopBuy", -- C->S  (shopId, index)
	"ShopClose", -- C->S
	"SelectCharacter", -- C->S  protagonist id
	"UseItem", -- C->S  item id
	"ResetSave", -- C->S  debug: wipe profile
	"ChapterComplete", -- S->C  final state for the summary card
	"Hurt", -- S->C  screen flash
	"Ability", -- C->S  server-side ability (hack, overload, bloom, cloak)
	"AbilityFx", -- S->C  (abilityId, duration) confirmed, play local effects
	"Companion", -- C->S  summon companion id, or nil to dismiss
}

local Net = {}

local isServer = RunService:IsServer()
local folder

if isServer then
	folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
	end
	for _, name in ipairs(EVENTS) do
		if not folder:FindFirstChild(name) then
			local remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = folder
		end
	end
	folder.Parent = ReplicatedStorage
else
	folder = ReplicatedStorage:WaitForChild("Remotes")
end

for _, name in ipairs(EVENTS) do
	Net[name] = if isServer then folder:FindFirstChild(name) else folder:WaitForChild(name)
end

return Net
