-- Loads, holds and saves each player's story profile.
-- If DataStores are unavailable (e.g. Studio without API access), play continues without saving.
local DataStoreService = game:GetService("DataStoreService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared.Config)

local PlayerData = {}

local PROFILE_VERSION = 1
local sessions = {}

local store
do
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(Config.DataStoreName)
	end)
	if ok then
		store = result
	else
		warn("[Afterglow] DataStore unavailable: " .. tostring(result))
	end
end

function PlayerData.newProfile()
	return {
		version = PROFILE_VERSION,
		character = nil,
		credits = 0,
		inventory = {},
		flags = {},
		quests = {},
		rep = { grid = 0, rust = 0, council = 0, ascent = 0, fringe = 0 },
		trust = {},
		lore = {},
		checkpoint = "CP_Grid",
		tracked = nil,
		companions = {}, -- owned companion ids
		companion = nil, -- the one currently following
	}
end

local function reconcile(data)
	local defaults = PlayerData.newProfile()
	for key, value in pairs(defaults) do
		if data[key] == nil then
			data[key] = value
		end
	end
	for faction, value in pairs(defaults.rep) do
		if data.rep[faction] == nil then
			data.rep[faction] = value
		end
	end
	data.version = PROFILE_VERSION
	return data
end

local function key(player)
	return "p_" .. player.UserId
end

function PlayerData.load(player)
	local profile
	local canSave = false
	if store then
		local ok, data = pcall(function()
			return store:GetAsync(key(player))
		end)
		if ok then
			canSave = true
			if type(data) == "table" then
				profile = reconcile(data)
			end
		else
			warn("[Afterglow] Could not load profile; progress will not be saved this session. " .. tostring(data))
		end
	end
	sessions[player] = {
		data = profile or PlayerData.newProfile(),
		canSave = canSave,
	}
	return sessions[player].data
end

function PlayerData.get(player)
	local session = sessions[player]
	return session and session.data
end

function PlayerData.save(player)
	local session = sessions[player]
	if not session or not session.canSave or not store then
		return
	end
	local ok, err = pcall(function()
		store:SetAsync(key(player), session.data)
	end)
	if not ok then
		warn("[Afterglow] Save failed for " .. player.Name .. ": " .. tostring(err))
	end
end

function PlayerData.reset(player)
	local session = sessions[player]
	if session then
		session.data = PlayerData.newProfile()
	end
end

function PlayerData.release(player)
	PlayerData.save(player)
	sessions[player] = nil
end

function PlayerData.all()
	local list = {}
	for player in pairs(sessions) do
		table.insert(list, player)
	end
	return list
end

return PlayerData
