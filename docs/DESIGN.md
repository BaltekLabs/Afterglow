# AFTERGLOW: design notes for the prototype

This document records the decisions the Roblox slice makes, the Chapter One story, and what to learn
from playtests before moving to a PC/console engine. Names (Vesper, Veyra, the cast, the tiers) are
working names. Change them freely.

## Pillars

1. **A world rebuilt on something dangerous.** The plant that caused the outbreak powers the city. The
   wild Mother Strain is caged in the Powerhouse; tame, bioengineered *civic* strains grow everywhere.
2. **A city that won't let you leave.** The Council keeps the gates sealed and the Veil up. Officially
   it's protection. Lore reveals the city's population *is* the battery.
3. **Open world first.** Nothing is forced. Quests start when you stumble into them, any order works,
   and the HUD stays empty unless you choose to track something.
4. **Your character shapes how you see; your choices decide who you become.** Eight protagonists with
   different abilities, starting tiers, dialogue and reachable secrets. None lock out the main story.
5. **No morality meter.** Reputation per community (Grid, Rust, Council, Ascent, Fringe) and trust per
   person. The world responds to what you did.
6. **Zombies are rare.** Seven Rooted on the whole map. Each one is a moment.

## The world (about 6,400 × 6,400 studs)

### Veyra: a vertical city (1,280 studs across, walled)

| Tier | Height | Who lives there | What's there |
| --- | --- | --- | --- |
| **The Crown** | y 330 | the rich, politicians | A ring of mansions and gardens circling the Powerhouse dome; the Council Spire (Councillor Hale). Reached only by the restricted **Crown Lift**. |
| **Sky roads** | y 170 | everyone | Walkable roads in the sky along four lines, with flying-car traffic above and below. |
| **The Grid** | y 80 | ordinary people | Deck platforms of towers with explorable ground floors, holo ads, vertical gardens, planters everywhere. The **Static Tower** (Tamsin), Meridian Plaza, Ascent depot, Marigold's pet shop, The Wick. |
| **The Rust** | y 0 | the poor, hackers, fixers, hitmen | Dark streets under the deck, back alleys through every block, neon, civic vines hanging from above. Lantern Row night market, The Drip (Vane), Glitch's den, Kettle's Bot Shop, Gate Square. **Manholes** in back alleys lead to the sewers. |
| **The Powerhouse** | y 0–360 | nobody (officially) | The armored heart of the city: turrets, Enforcers, barricades. Inside, the wild **Mother Strain** in a cage of light. A maintenance hatch on the south face. |

- **Every building can be entered** unless its door says otherwise: shops close by the clock, and
  about one in five buildings is **locked** (hackable by Dex, pickable by Sable, or needs a key). Locked
  buildings usually hide a credit stash.
- **Lifts** at four sky road crossings connect the Rust, the Grid and the sky roads.
- **Plants everywhere**: civic-strain planters, street trees, vertical gardens, hanging vines and roof
  gardens. Safe, sterile, bioengineered. The violet wild growth only exists outside the Wall (and caged
  in the Powerhouse).

### Getting out

The government will not let anyone leave. The North Gate is welded shut; the **Veil** caps the Wall up
to the sky (no climbing, no grappling over). The way out is the **storm sewers**: three manholes in Rust
back alleys drop into walkable tunnels. The north pipe comes out in the Sporewilds; the south pipe
comes out in the marsh. One Rooted sleeps at the bend.

### The Outlands

| Place | Where | What |
| --- | --- | --- |
| **The Sporewilds** | north | Glowing forest, spore clouds, Wren's satchel, the Adeyemi camp. |
| **Hollow Garden** | far west (≈2,000 studs out) | Fringe farming village: ten shacks, a palisade, fire, garden plots, Mother Lune's shrine. Bram's seed quest. |
| **Greenhouse 3** | beyond Hollow Garden | The impossible sunflower. |
| **Halvorsen Station** | far north (≈2,800 studs out) | The Dead Zone. The source of the broadcast. |
| **The Overgrown Suburbs** | east | Ruined, explorable houses swallowed by wild growth; rusted rail wagons. |
| **Rail's End** | far east | A village living in an old train yard; Dunmore's locomotive; Ilsa's trade car. |
| **Mirefall** | far south, in the Drowned Marsh | Fishing village on stilts; Old Reed. |

## Characters (4 men, 4 women)

| | Ability [Q] | Starts in | Exclusive routes |
| --- | --- | --- | --- |
| **Mara Quell** (Investigator) | Insight: reveal clues and hidden objects | Grid | Ascent memo, station vent, Pell's mailbox at once |
| **Juno Ash** (Runner) | Dash; immune to spores | Rust | Fringe-born: unique village greetings |
| **Ivy Sol** (Greenkeeper) | Bloom: calm Rooted, clear spores | Grid | Plant-reading dialogue with Bram, Lune, Tamsin |
| **Sable Quinn** (Fixer) | Cloak: invisible to turrets and Rooted | Rust | Lockpicking; Vane's former apprentice |
| **Dr. Ilya Renn** (Researcher) | Analyze: see Rooted and Vesper through walls | Grid | Halvorsen access log; can *answer* the relay |
| **Dex Varga** (Hacker) | Hack: doors, the Crown Lift, turrets | Rust | Opens hackable locks just by trying; Powerhouse hatch |
| **Silas Crane** (Heir) | Grapple to where you aim | Crown | Crown clearance; confronts Hale about Directive 9 |
| **Teo Marsh** (Technician) | Overload: EMP shuts down turrets | Grid | Powerhouse hatch codes; hears the Mother Strain |

## Companions

Bought from **Marigold's Menagerie** (Grid, animals) or **Kettle's Bot Shop** (Rust, robots). One follows
you at a time; manage them in the journal.

| Animal | Robot | Perk |
| --- | --- | --- |
| Stray Mutt, Rust Crow | K9 Unit, Scrap Spider | **Alert**: warns you when a Rooted is near |
| Glow Fox | Hover Drone | **Light**: carries a light (great in the Rust and sewers) |
| Alley Cat | Clockwork Cat | **Scavenge**: brings you credits now and then |

## Chapter One: "The Signal"

The Static Tower relays a fourteen-year loop from Halvorsen Station: *"Calling Wren Hollis... the
garden is still growing. Come home."* It's Wren's own voice.

1. **The broadcast.** Heard at the foot of the Static Tower (or told to you by Tamsin, or discovered
   at the station itself; the story starts wherever you find it).
2. **Old Tamsin**: Wren was her wife. She gives you a receiver and tells you the one thing nobody says
   out loud: people in the Rust talk about the old sewers.
3. **Escape** through the sewers (rumors from Pike, Vela and a wink from Okafor point the way).
4. **The Sporewilds** → **Halvorsen Station** → the relay room.
5. **The choice**: silence it (half of Veyra's lights die; Kessler and Hale notice), leave it, take
   the core (sell to Ascent or bury with the Fringe), or, as Renn, *answer it*.
6. **Return to Tamsin.** Truth or kind lie. The chapter card recaps your run.

### Side stories
- **Loose Ends** (Vane): steal Councillor's aide Pell's paper ledger. Give it to Vane, give it back to
  Pell (he gets you a real Crown pass), or have Tamsin broadcast it to every radio in the city.
- **Seeds for Hollow Garden** (Bram), **Spare Parts** (Dunmore), **Cell Run** (Kessler's job).
- **The Adeyemi letters**: five letters across the Grid, the forest and the station. Pike recognizes
  his parents' handwriting.
- **The Powerhouse**: break in (Teo, Dex or a forged keycard; Sable/Teo help with the turrets) to find
  Council Directive 9: *"Lattice output correlates directly with resident population... The gates
  remain sealed."*

## Things to learn from playtests

- With nothing forced, do players find the Static Tower broadcast on their own? How long does it take?
- Do players discover the sewers through rumor, or wander into a manhole?
- Is the city legible? Can players tell the tiers apart and find the lifts?
- Do players try the Powerhouse? Are the turrets a fun challenge or a wall?
- Which companions do players buy first, and do the perks matter?
- Is the walk to Halvorsen too long? (It's deliberately far. Vehicles may be needed next.)
- Do the eight characters feel different enough in play, not just in dialogue?

## Moving to PC/console fidelity

- **Story data is engine-agnostic.** `src/shared/Data` is plain tables (strings, numbers, hex
  colors). It converts mechanically to JSON, then to Unreal DataTables, Unity ScriptableObjects, or a
  dialogue tool (articy:draft, Yarn Spinner, ink).
- **Conditions and effects are a small, documented language.** Reimplementing them in C++/C# is a few
  hundred lines; the validator rules carry over.
- **The world is greybox by design.** Gameplay depends only on named waypoints, tags and zone volumes,
  so each region can be replaced with real art without touching story logic.

Suggested target: Unreal Engine 5. Port in this order: conditions/effects → dialogue/quest runtime →
traversal camera, stealth and abilities → one district at full art (the Rust), then the rest.

## Known prototype limitations

- Characters use Roblox rigs and the player's own avatar, tagged with the protagonist's name and color.
- No audio yet. The broadcast especially deserves a voice and a radio-static bed.
- No vehicles; the Outlands are a long walk on purpose, but this needs testing.
- Story state is per player; in a shared server each player sees their own consequences.
- Desktop and gamepad are supported; touch controls for the custom camera are not.
- About 23,500 parts and 570 lights are built at server start, with streaming off. Fine on PC; mobile
  would need StreamingEnabled and persistent models for zones and waypoints.
