# AFTERGLOW — Roblox prototype

A playable open-world slice of **AFTERGLOW**: a third-person, story-driven RPG set in a vertical neon
city rebuilt on the plant that caused the apocalypse — a city that will not let anyone leave. This
prototype exists to dial in story and gameplay before moving to a PC/console engine. See
[`docs/DESIGN.md`](docs/DESIGN.md) for the world, story, characters and roadmap.

**What's in it:** a ~6,400-stud map. **Veyra** in the middle, in three tiers (The Rust, The Grid,
The Crown) around the armored Powerhouse, with sky roads, flying cars, holo ads, plants everywhere and
explorable buildings. The **Outlands** outside the Wall: the Sporewilds, Halvorsen Station and three
far-flung villages (Hollow Garden, Rail's End, Mirefall). **8 playable characters**, **8 companions**
(animal or robot), a main story with 4 endings, 4 side stories, 35 journal entries, 28 NPCs on daily
routines. Nothing is forced: you find the story by exploring.

## Run it

Requirements: [Roblox Studio](https://create.roblox.com/) and [Rojo](https://rojo.space) 7.7
(pinned in `aftman.toml`; run `aftman install`).

**Quickest:** build the place file and open it.

```powershell
rojo build default.project.json -o build/Afterglow.rbxlx
```

Open `build/Afterglow.rbxlx` in Studio and press **Play** (F5). The world is generated when the
server starts (a couple of seconds; the output window prints the part count).

**While editing:** `rojo serve`, open a new Baseplate in Studio, **delete the Baseplate part**,
connect with the Rojo plugin, then Play. Edits under `src/` sync live.

**Saving** uses DataStores. In Studio, enable *Game Settings → Security → Enable Studio Access to API
Services* (the place must be published). Without it the game runs fine and doesn't save.

## Controls

| Action | Keyboard / mouse | Gamepad |
| --- | --- | --- |
| Look | Mouse (always on) | Right stick |
| Move | WASD | Left stick |
| Sprint (loud) | Hold Shift | L3 (toggle) |
| Sneak (quiet) | C (toggle) | B |
| Interact (talk, read, lifts, doors) | E | X |
| Character ability | Q | Y |
| Swap shoulder | V | R3 |
| Zoom | Mouse wheel | — |
| Journal (quests, lore, people, items, companions) | J | Select |
| Dialogue choice | 1–6 or click | D-pad + A |
| Skip text | Space / click | A |

## Project layout

```
src/
  shared/                  ReplicatedStorage.Shared: used by server and client
    Config.lua             tuning: speeds, hazards, turrets, companions, camera
    Conditions.lua         the condition language used by all story data
    Data/                  ← THE STORY. Pure data, no engine types.
      Characters.lua       the 8 protagonists
      Companions.lua       animal and robot companions
      Quests.lua  Lore.lua  Items.lua  Factions.lua  Shops.lua  Lifts.lua
      Dialogue/*.lua       one file per speaker
      Interactables.lua    letters, terminals, manholes, lifts, locked doors, stashes...
      NPCs.lua             cast, schedules, patrols, ambient lines
  server/
    Main.server.lua        entry point, player lifecycle
    Services/              Story (state + effects), Dialogue (+ lift menus), NPCService,
                           Interaction, Doors, AbilityService, CompanionService,
                           Hazards (zones, spores, turrets, Rooted), Shop, Inventory, PlayerData
    World/
      Build.lua            building blocks: rooms, interiors, doors, plants, holo ads, turrets, lifts
      City/                Layout (tile grid + tiers), Rust, Grid (+ sky roads, lifts), Crown,
                           Powerhouse, Landmarks, Wall (+ Veil), Sewers
      Outlands/            Terrain, Sporewilds (+ Hollow Garden), DeadZone (Halvorsen),
                           Suburbs (+ Rail's End), Marsh (+ Mirefall)
  client/
    CameraController  MovementController  AbilityController  PromptController
    MarkerController  AmbienceController  WorldReactions  CityLife (flying cars, holo ads)
    UI/                    HUD, dialogue, journal, shop, character select, chapter card
tools/
  validate_story.luau      checks every story cross-reference
```

## Editing the story

Everything narrative lives in `src/shared/Data` as plain tables of **conditions** and **effects**
(documented at the top of `Conditions.lua`, `server/Services/Story.lua` and
`Data/Dialogue/init.lua`). After editing, run the validator. It catches broken dialogue links,
unknown items, quests or companions, flags that are checked but never set, and unreachable nodes:

```powershell
luau tools/validate_story.luau
```

(`luau.exe` comes from the [Luau releases](https://github.com/luau-lang/luau/releases). If you add a
dialogue file, add its name to `DIALOGUE_FILES` at the top of the validator.)

To place story things in the world, edit the builders in `src/server/World`. Gameplay only cares
about **waypoint names** (NPC posts, quest markers, teleports), **InteractId** attributes, and **zone**
volumes, so you can also replace any region with a hand-built Studio model that keeps those.

For fast replays, open the journal (J) → **System** → *Start over*, which wipes the save and returns
to character select. Disable it for release with `Config.Debug.AllowReset = false`.
