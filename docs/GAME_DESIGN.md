# Game Design — RPG Auto Battler (working title) · Iteration 1

## Pitch
A cosy low-poly party RPG in the spirit of **AFK Journey** and **Fellowship**. You are the Wayfarer,
wandering with a party of up to five heroes who trail behind you. Talk to villagers, take on quests,
recruit heroes at the tavern, gear them up, then walk into danger: battles happen **in place, on
the map**, and your heroes fight on their own using the ability priorities you set.

## Core loop
1. **Explore** — walk around the town and dungeons with your party in tow.
2. **Talk & take quests** — NPCs with a golden **!** have work for you; **?** means come back to them.
3. **Prepare** — recruit heroes, buy potions and gear, spend skill points, order abilities.
4. **Fight** — walking into an enemy group opens the pre-battle screen; press **Fight!** and watch the auto battle.
5. **Reap** — XP (shared by the party), gold, loot, level-ups → skill points → stronger kits.

## Iteration 1 scope

| Brief item | Delivered as |
|---|---|
| Town with enterable buildings | **Oakhaven Village**: plaza and fountain, market stalls, well, 8 cottages; the **Sleepy Griffin Inn** and **Tilda's Wares** are enterable |
| Party of 5 that follows you | Breadcrumb-trail followers; start with 3, recruit 2 at the inn |
| Cave zone: 3 encounters + a boss | **Glimmerdeep Cave**: Rat-Infested Tunnels → Goblin Raiders → The Spider Nest → **Gorrak the Stonehide** |
| A few NPCs | Elder Maren, Captain Aldric, Pip, Farmer Hobb, Old Nell, Bram, Tilda, plus the recruitable Ignatius and Lyra |
| Vendor selling potions and weapons | Tilda (potions, 4 weapons, 3 armours); Bram also sells potions |
| Tavern / Inn | Rest (10 gold, full heal), recruit heroes, buy potions |
| The 4 classes | Warrior, Priest, Hunter, Mage — each with a basic attack and 4 choosable abilities |
| NPC that gives quests | Elder Maren (main story), Captain Aldric (2-quest chain) |
| Quest menu | Journal window (J) plus an always-on HUD tracker |
| Smart UI | Contextual interaction prompts, click-to-interact, quest markers, skill-point badge, toasts, tooltips everywhere, battle unit plates with action and cast bars |
| Loading & splash screens | Splash → title (animated campfire diorama) → loading screen with tips and a real threaded-loading progress bar |
| Low-poly AFK-style art | Everything is procedural low-poly geometry: chibi proportions, faceted shading, saturated pastel palette, soft shadows, glowing crystals |

## Classes & kits
Each class has a basic attack plus four abilities. The first is free; the others are unlocked with
skill points (1 per level) at levels 1 / 2 / 3. Heroes can toggle and reorder their abilities.

### Warrior — Tank (melee · Sword/Mace · Plate)
| Ability | Effect | CD |
|---|---|---|
| Strike *(basic)* | 1.0× physical | — |
| **Taunting Roar** | Taunts **all** enemies for 5 s | 10 s |
| Shield Slam | 1.3× and **interrupts** (falls back to a normal hit) | 8 s |
| Shield Wall | −50% damage taken for 6 s | 18 s |
| Cleave | 0.75× to every enemy | 6 s |

### Priest — Healer (ranged · Mace/Staff · Cloth)
| Ability | Effect | CD |
|---|---|---|
| Smite *(basic)* | 1.0× holy bolt | — |
| **Flash Heal** | 2.2× heal on the lowest-HP ally | 2.5 s |
| Holy Ward | shield absorbing 2.2× power on the most-attacked ally | 7 s |
| Renewing Light | 2.4× heal over 8 s | 3 s |
| Sanctuary | 1.1× group heal (1.2 s cast) | 12 s |

### Hunter — Ranged DPS (Bow · Leather)
| Ability | Effect | CD |
|---|---|---|
| Quick Shot *(basic)* | 1.0× arrow | — |
| **Aimed Shot** | 2.4× (0.8 s cast) | 6 s |
| Serpent Sting | 0.3× plus 2.0× poison over 8 s | 5 s |
| Counter Shot | **interrupt** plus 0.5× | 9 s |
| Multi-Shot | 0.7× to every enemy | 7 s |

### Mage — Ranged DPS (Staff/Wand · Cloth)
| Ability | Effect | CD |
|---|---|---|
| Arcane Bolt *(basic)* | 1.0× magic | — |
| **Fireball** | 2.6× (1.2 s cast) | 4 s |
| Frost Nova | 0.5× to every enemy and **freezes** them for 2 s (breaks casts) | 14 s |
| Counterspell | **interrupt** plus 0.4× | 10 s |
| Flamestrike | 1.1× to every enemy (1.5 s cast) | 10 s |

### Role biases (auto-battle personality)
* **Tanks** taunt first, pop defensives when focused, interrupt, and peel enemies off allies.
* **Healers** heal and shield first; they only attack when everyone is healthy.
* **DPS** focus the party's kill target, jump on interrupts, and use AoE against packs.
* **Ranged** stay in the back row and snipe enemy healers first.

## Heroes
| Hero | Class | Where |
|---|---|---|
| Garrick Stoneheart — *Shield of Oakhaven* | Warrior | starting party |
| Seraphine Dawnlight — *Acolyte of the Dawn* | Priest | starting party |
| Wren Swiftarrow — *Warden of the Wilds* | Hunter | starting party |
| Ignatius Emberwick — *Pyromancer (Expelled)* | Mage | Sleepy Griffin Inn |
| Lyra Moonwhisper — *Silver Sharpshooter* | Hunter | Sleepy Griffin Inn |

Recruits join at the party's average level.

## Glimmerdeep encounters
| # | Encounter | Enemies | What it teaches |
|---|---|---|---|
| 1 | Rat-Infested Tunnels | Cave Rat ×2, Giant Rat (Plague Bite DoT) | basics, taunts |
| 2 | Goblin Raiders | Goblin Grunt ×2 (Dirty Kick stun), **Goblin Shaman** (2 s *Mending Chant* heal cast) | **interrupts**, killing healers first |
| 3 | The Spider Nest | Broodmother (Venom Spit, *Web Wrap* 2.5 s stun cast), Spiderling ×3 | AoE, cleansing through healing |
| 4 | **Gorrak the Stonehide** (boss) | Crushing Blow, **Earthshatter** (uninterruptible party-wide AoE), **Rallying Roar** (interruptible +40% power), **Enrage** under 30% HP, stun immune | everything together |

**Balance** (checked by `tests/battle_sim.gd`): a party of 5 carrying damage through the whole cave
without resting clears it over 90% of the time (97% in the latest run), usually losing a hero or two to the boss. A party of 3 cannot
beat the boss, which pushes the player to recruit.

## Quests
| Quest | Giver | Objectives | Reward |
|---|---|---|---|
| **Darkness in Glimmerdeep** (main) | Elder Maren | clear the 3 encounters, defeat Gorrak | 250 g, 300 XP, *Glimmerdeep Crystal Staff* (epic) |
| Strength in Numbers | Captain Aldric | have 5 heroes in the party | 60 g, 60 XP |
| Prepared for the Worst *(needs the previous one)* | Captain Aldric | buy a Health Potion; ask Bram about resting | 40 g, 40 XP, Greater Health Potion |

## Economy
Start with 120 gold and 2 Health Potions. Potions cost 25 / 60, uncommon gear 100–140, resting 10.
Encounters pay 26–230 gold. Anything sells back at half price.

## Controls
| Action | Keys |
|---|---|
| Move | WASD / arrow keys, or left-click the ground |
| Interact | E / Space / Enter, or click an NPC or door |
| Party / Bag / Quests | P / I / J |
| Menu / close | Esc |
| Zoom | mouse wheel |
| Battle speed ×1 / ×2 / ×3 | Tab |

## Art direction
* Chibi proportions (big heads, short bodies), simple dot eyes with highlights and blush.
* Faceted low-poly meshes with per-face brightness jitter and soft rim light.
* Bright, warm daylight in town; a blue-violet cave lit by glowing crystals, torches and the Wayfarer's lantern.
* UI: parchment panels, gold buttons, navy ribbons, rounded font (Fredoka), vector icons drawn in code.

## Roadmap (next iterations)
* Save/load (`GameSession` is already the aggregate to serialise).
* Hand-authored 3D assets and animation rigs to replace the procedural placeholders; audio and music.
* More classes and a hero roster larger than the active party; formation editing.
* Item rarities with random rolls; hero-specific signature abilities.
* A second dungeon and a world map.
