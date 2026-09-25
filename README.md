# RPG Auto Battler *(working title)*

A top-down, low-poly party RPG with auto-battles, inspired by **AFK Journey** and **Fellowship**.
Built in **Godot 4.3+** with GDScript. First playable iteration.

Walk the village of Oakhaven with your party trailing behind you, take on quests, recruit heroes at
the Sleepy Griffin Inn, gear up at Tilda's Wares, then clear **Glimmerdeep Cave**: three encounters
and a boss, fought in place by your heroes using the ability priorities you set.

## Running it
1. Install **Godot 4.3 or newer** (standard build, not .NET) from godotengine.org.
2. Open Godot → **Import** → select this folder's `project.godot`.
3. Press **F5** (Run Project). The first open takes a moment while Godot imports the font.

No external assets or plugins are needed: every model, icon and UI element is generated in code.

## Controls
| Action | Keys |
|---|---|
| Move | WASD / arrow keys, or click the ground |
| Interact | E / Space, or click an NPC or door |
| Party · Bag · Quests | P · I · J |
| Menu | Esc |
| Zoom | mouse wheel |
| Battle speed | Tab |

## What's in iteration 1
* Splash screen → animated title screen → threaded **loading screens** with tips
* **Oakhaven Village** with an enterable **Inn** (rest, recruit) and **Shop** (potions, weapons, armour)
* A **party of 5** that follows you (3 at the start, 2 recruitable)
* **Warrior, Priest, Hunter, Mage** — each with a basic attack and a 4-ability kit, unlocked with skill points
* **Auto-battler**: action bars under the health bars, cast bars, interrupts, taunts, shields, DoTs, stuns, a boss enrage
* Pre-battle screen to **reorder and toggle** each hero's abilities
* 8 NPCs, 3 quests with markers, a journal, a HUD tracker, toasts, tooltips
* Levelling, equipment, a shared bag and gold

## Documentation
* [`docs/DOMAIN_MODEL.md`](docs/DOMAIN_MODEL.md) — **every object in the game and its inheritance chain**
  (e.g. `WorldEntity → Character → NPC → FriendlyNPC → Vendor → Innkeeper`), plus class diagrams
* [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — layers, principles (SOLID, YAGNI, composition), patterns,
  runtime and battle flow, the AI decision system, how to extend
* [`docs/GAME_DESIGN.md`](docs/GAME_DESIGN.md) — core loop, class kits, encounters, quests, economy, art direction, roadmap

## Tests
```bash
godot --headless --path . res://tests/parse_all.tscn             # all scripts compile
godot --headless --script res://tests/battle_sim.gd --path .     # balance simulation
godot --path . res://tests/playthrough.tscn -- --shots=/tmp/shots  # scripted end-to-end run with screenshots
```

## Credits
* Font: **Fredoka** by the Fredoka Project Authors, SIL Open Font License (`assets/fonts/OFL.txt`).
* Engine: Godot Engine (MIT).
# AutoRPG
