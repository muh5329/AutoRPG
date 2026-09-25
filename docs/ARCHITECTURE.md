# Architecture & Engineering Principles

## Principles applied

| Principle | Where it shows |
|---|---|
| **Single Responsibility** | `Battle` does the maths, `BattleDirector` sequences the fight, `CombatUnitView` animates it and `BattleHud` displays it. `QuestLog` tracks quests; `QuestGiver` only talks. |
| **Open/Closed** | New abilities are data (TargetRule + Effects). New objectives subclass `QuestObjective.advance()`. New NPC roles subclass `FriendlyNPC` and override `_add_options()`. No switch statements need editing. |
| **Liskov** | Any `Combatant` works in a `Battle`; any `Equipment` can be equipped through the same `Hero.equip()`; any `UiWindow` goes through `UI.open_window()`. |
| **Interface Segregation** | The Interactable protocol is 5 small template methods on `WorldEntity`, used only by entities that opt in. |
| **Dependency Inversion** | Domain code never depends on nodes. Presentation subscribes to domain signals. Gameplay code asks `UI` (a facade) for screens instead of building widgets. |
| **Composition over inheritance** | Abilities (rule + effects), characters (entity + model), zones (walkable area + camera + party controller). Inheritance is kept for real *is-a* relationships (Vendor *is a* FriendlyNPC). |
| **YAGNI** | No save system, audio manager, item rolls, or data-driven dialogue graphs yet. Events, signals and methods that nothing used were deleted. Every class in the domain doc is exercised by the playable slice. |
| **DRY** | One `CharacterModel` renders heroes in the overworld, in battles, on the title screen and in portraits. One `LoadoutEditor` serves the Party screen and the pre-battle screen. |
| **Tell, don't ask** | `hero.equip(item)` validates and swaps. `potion.use_on(hero)` applies itself. `status.modify_incoming_damage()` owns its own rule. |

## Patterns used

* **Template Method** — `Zone._ready()` (environment → world → spawn), `WorldEntity` interaction protocol,
  `StatusEffect` hooks, `UiWindow._build()/refresh()`, `CharacterModel._build()`.
* **Strategy** — `TargetRule`, `AbilityEffect`, `BattleBrain` subclasses.
* **Factory** — `ModelFactory.build(appearance)`, `MonsterDefinition.spawn()`, `HeroClass.create_brain()`.
* **Prototype** — `StatusEffect.instantiate_for()` clones a template for each application.
* **Observer** — domain signals, `EventBus`, `GameEvent` → `QuestLog`.
* **Facade** — `UI`, `GameState`, `SceneRouter` autoloads.
* **Aggregate root** — `GameSession` (everything a future save file needs).
* **Utility AI** — see *Battle AI* below.

## Runtime flow

```
splash.tscn ─► SceneRouter.go_to_title() ─► title.tscn
   New Game ─► GameState.new_game() ─► SceneRouter.go_to_zone(&"town")
      ├─ LoadingScreen.show_card()            (fade in, tip)
      ├─ ResourceLoader.load_threaded_request (progress bar)
      ├─ change_scene_to_packed(TownZone)
      │     Zone._ready(): _build_environment → _build_world → _spawn_player
      │                    → GameState.reset_mode(EXPLORE) → UI.enter_zone()
      └─ LoadingScreen.hide_card()
```

### Input modes
`GameState` keeps a mode **stack**: `EXPLORE` at the bottom, and `DIALOGUE`, `WINDOW` or `BATTLE`
pushed on top. The player only moves in `EXPLORE`. Windows that belong to a battle (pre-battle,
results) set `pauses_exploration = false` so they don't disturb the battle mode.

### Battle sequence

```
Encounter._physics_process: player enters radius
  └─ Zone.start_encounter(encounter)          (BossEncounter first shows its intro dialogue)
       └─ BattleDirector.begin()
            ├─ push BATTLE mode, camera frames the arena
            └─ UI.open_pre_battle(director)   → PreBattleWindow (reorder/toggle abilities)
                  ├─ Retreat → player is pushed out of the radius, encounter disarmed
                  └─ Fight   → director.start_fight()
                       ├─ Battle.new(living heroes, spawned monsters, inventory)
                       ├─ followers hidden, CombatUnitViews spawned where the followers stood
                       ├─ ENTERING: heroes walk into formation (front row: tanks/melee, back row: ranged/healers)
                       ├─ FIGHTING: battle.tick(delta × speed) every frame
                       └─ Battle.ended(victory)
                            ├─ victory → GameState.grant_encounter_rewards → BattleResultWindow
                            │            → followers restored, encounter removed, EXPLORE mode
                            └─ defeat  → party restored at the inn (SceneRouter → inn)
```

### Battle AI (the "decision tree")
Every unit runs this loop when its action bar is full:

1. `get_usable_abilities()` — enabled, unlocked, off-cooldown, in the player's order, plus the basic attack.
2. For each ability: `targets = ability.target_rule.select()`. No targets means it's skipped.
3. `utility = Σ effect.evaluate(targets)`. Heals are only worth something when allies are hurt,
   interrupts only when an enemy is casting, taunts only when enemies are hitting someone else,
   shields only when nobody is already shielded, and so on.
4. `score = utility × brain.bias_for(ability.tags) × preference(order index)`.
5. The best score wins. Casts start a cast bar; everything else lands after its delivery delay.

Changing the order in the pre-battle screen adds up to +35% preference to the top ability, so the
player steers priorities without breaking role logic. Unticking an ability removes it entirely.

### Combat rules
* **Damage** = power × multiplier × (0.9–1.1) × 1.5 on a crit × `100 / (100 + armor)`, then status modifiers
  (shields absorb, Shield Wall halves).
* **Action bar** — after any action the unit waits `ability.recovery / (1 + haste)` seconds. It is shown
  as the thin bar under every health bar.
* **Casts** can be interrupted (Shield Slam, Counter Shot, Counterspell) or broken by stuns (Frost Nova),
  unless the cast is flagged uninterruptible. Bosses ignore stuns.
* **Potions** — any hero under 30% HP drinks one from the shared bag (6 s party-wide cooldown).
* **After a won fight** — fallen heroes get up at 25% HP; damage otherwise carries over. Resting at the inn heals everyone fully.

## Project layout

```
project.godot            Godot 4.3+, Forward+
assets/fonts/            Fredoka (SIL OFL)
scenes/screens/          splash.tscn, title.tscn
scenes/zones/            town.tscn, inn.tscn, shop.tscn, cave.tscn (a root node + zone script each)
src/autoload/            services (see DOMAIN_MODEL §7)
src/core/                Controls (input bindings)
src/domain/              pure game rules & data
src/content/             catalogs that author classes, heroes, items, monsters, encounters, quests
src/world/               entities, NPCs, zones, camera, low-poly art kit
src/battle/              battle presentation
src/ui/                  theme kit, widgets, HUDs, windows, screens
tests/                   headless balance sim, parse check, automated playthrough
```

## How to extend

| To add… | Do this |
|---|---|
| **An ability** | Add a `K.ability(...)` entry to a kit in `ClassCatalog` (or a monster in `MonsterCatalog`), combining existing rules and effects. |
| **A new effect type** (knockback, lifesteal…) | Subclass `AbilityEffect`; implement `evaluate()` and `apply()`. |
| **A status** (silence, haste…) | Subclass `StatusEffect` and override the hooks you need. |
| **A class** | Add a `HeroClass` in `ClassCatalog` with a role; its brain is chosen automatically. Add a `HeroDefinition` in `HeroCatalog` and place a `RecruitableHero`. |
| **An NPC role** (blacksmith, trainer) | Subclass `FriendlyNPC` (or `Vendor`) and override `_add_options()`. |
| **A quest objective** | Subclass `QuestObjective`, override `_matches()` or `advance()`, and publish the matching `GameEvent`. |
| **A zone** | Subclass `Zone` (or `InteriorZone`), implement `_build_world()`, add a one-node `.tscn`, and register it in `SceneRouter.ZONES`. |
| **An enemy look** | Add an `Appearance.Body` value and a `CharacterModel` subclass, then map it in `ModelFactory`. |

Content catalogs build plain `Resource`s, so moving content into `.tres` files for designers to edit
in the inspector is a mechanical change that doesn't touch any code that uses the content.

## Tests

| Command | What it checks |
|---|---|
| `godot --headless --path . res://tests/parse_all.tscn` | every script compiles |
| `godot --headless --script res://tests/battle_sim.gd --path .` | win rates / durations for every encounter at party sizes 3 and 5, a full campaign run with HP carried over, and an ability-usage trace for the boss |
| `godot --path . res://tests/playthrough.tscn -- --shots=/tmp/shots` | end-to-end: splash → title → quests → recruit → shop → all 4 cave fights → turn-ins, saving 40 screenshots along the way |
