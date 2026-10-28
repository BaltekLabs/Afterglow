-- Global tuning values. Everything a designer might want to tweak without touching systems code.
local Config = {
	GameTitle = "AFTERGLOW",
	ChapterTitle = "Chapter One: The Signal",

	-- Real-time minutes for one full in-game day.
	DayLengthMinutes = 24,
	StartClockTime = 18.25,

	DataStoreName = "Afterglow_Profiles_v2",
	AutosaveSeconds = 90,
	RespawnDelay = 4,

	Camera = {
		ShoulderOffset = 2.2, -- studs to the side of the character
		Height = 2.4, -- focus height above the root part
		Distance = 11,
		MinDistance = 5,
		MaxDistance = 26,
		MouseSensitivity = 0.0045,
		GamepadSensitivity = 3.2,
	},

	Movement = {
		Walk = 16,
		Sprint = 28,
		Sneak = 7,
	},

	Hazards = {
		SporeDamagePerSecond = 7,
		-- Rooted (dormant zombies, now rare) notice you based on how loud you move.
		RootedHearSprint = 24,
		RootedHearWalk = 11,
		RootedHearSneak = 4.5,
		RootedAlertMultiplier = 1.7,
		RootedDamage = 24,
		RootedCooldown = 3,
		LoudSpeed = 19, -- horizontal speed above this counts as sprinting
		QuietSpeed = 8.5, -- at or below this counts as sneaking
		RestrictedGraceSeconds = 6,
		-- Powerhouse defenses.
		TurretRange = 260,
		TurretDamage = 12,
		TurretFireInterval = 0.7,
		TurretWarningSeconds = 2.5,
	},

	Companions = {
		FollowDistance = 5,
		TeleportDistance = 70,
		ScavengeIntervalSeconds = 90,
		AlertRadius = 45,
	},

	Debug = {
		-- Exposes "Start Over" in the journal so you can replay the story quickly.
		AllowReset = true,
	},
}

return Config
