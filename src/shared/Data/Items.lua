-- Item definitions. `use` makes an item consumable from the journal's Items tab.
return {
	receiver = {
		name = "Tamsin's Receiver",
		kind = "Key",
		description = "A hand-built radio receiver. It pulls the Halvorsen broadcast out of the noise and points toward it.",
	},
	vesper_cell = {
		name = "Vesper Cell",
		kind = "Material",
		description = "A glass cylinder of living Vesper culture. It is warm, and it hums when held.",
	},
	filter_mask = {
		name = "Filter Mask",
		kind = "Gear",
		description = "Scrubs spores from the air. While carried, spore clouds can't hurt you.",
	},
	mend_patch = {
		name = "Mend Patch",
		kind = "Consumable",
		description = "Civic-strain gel dressing. Restores 45 health.",
		use = { heal = 45 },
	},
	glowbowl = {
		name = "Glowbowl",
		kind = "Consumable",
		description = "Noodles in luminous broth from Vela's stall. Restores 15 health. Tastes faintly of copper.",
		use = { heal = 15 },
	},
	seed_packet = {
		name = "Pre-Bloom Seeds",
		kind = "Quest",
		description = "Seeds from a sunflower that should not exist. Plain, ordinary, impossible.",
	},
	station_keycard = {
		name = "Halvorsen Keycard",
		kind = "Key",
		description = "Security keycard for Halvorsen BioResearch Station. The photo has been scratched out.",
	},
	relay_core = {
		name = "Relay Core",
		kind = "Quest",
		description = "The heart of the Halvorsen transmitter, threaded with fine roots. It is still warm. It is still faintly speaking.",
	},
	crown_pass = {
		name = "Crown Pass",
		kind = "Key",
		description = "Guest clearance for the Crown Lift. Whether it's real depends on who you got it from.",
	},
	powerhouse_keycard = {
		name = "Powerhouse Keycard",
		kind = "Key",
		description = "A maintenance keycard for the Powerhouse hatch. Forged, probably. Hopefully good enough.",
	},
	pell_key = {
		name = "Pell's Key",
		kind = "Key",
		description = "An old-fashioned brass key on a Council lanyard. Orrin Pell doesn't trust smart locks.",
	},
	pell_ledger = {
		name = "Pell's Ledger",
		kind = "Quest",
		description = "A paper ledger of payments between Ascent Biotech and the Council. Paper, so it can't be hacked. Or so Pell thought.",
	},
	rail_part = {
		name = "Coupler Part",
		kind = "Material",
		description = "A heavy rail coupler pried from the Overgrown Suburbs. Rail's End needs these.",
	},
	old_badge = { name = "Civic Security Badge", kind = "Keepsake", description = "Badge 4471. Officially revoked. Unofficially, still useful." },
	runner_gloves = { name = "Runner's Gloves", kind = "Keepsake", description = "Patched, spore-stained, lucky." },
	halvorsen_badge = { name = "Halvorsen ID", kind = "Keepsake", description = "I. RENN, ASSISTANT BOTANIST. You have never been able to throw it away." },
	pruning_shears = { name = "Pruning Shears", kind = "Keepsake", description = "Civic Greenkeeping issue. The handles are worn to the shape of Ivy's hand." },
	lockpicks = { name = "Lockpicks", kind = "Keepsake", description = "A gift from Vane. 'Doors are just walls that haven't met you yet.'" },
	cyberdeck = { name = "Cyberdeck", kind = "Keepsake", description = "Scratch-built, overclocked, held together with tape and spite." },
	signet_ring = { name = "Crane Signet Ring", kind = "Keepsake", description = "Opens doors in the Crown. Closes them everywhere else." },
	powerhouse_badge = { name = "Powerhouse Badge", kind = "Keepsake", description = "T. MARSH, MAINTENANCE. Deactivated. Teo remembers the codes anyway." },
}
