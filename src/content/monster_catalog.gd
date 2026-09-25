class_name MonsterCatalog
extends RefCounted
## Enemies of Glimmerdeep Cave and the encounters built from them.

const K = preload("res://src/content/content_kit.gd")
const T := CombatTypes.Tag
const D := CombatTypes.Delivery
const O := Appearance.Outfit
const H := Appearance.Headgear
const P := Appearance.Prop


static func build_monsters() -> Array[MonsterDefinition]:
	var bite := K.ability(&"bite", "Bite", "Sharp teeth.", [T.DAMAGE], K.focus(), [K.dmg(1.0)], { "recovery": 1.5 })
	var out: Array[MonsterDefinition] = [
		_monster(&"cave_rat", "Cave Rat", CombatTypes.Role.MELEE_DPS, StatBlock.make(300, 58, 10), bite,
			[K.ability(&"frenzied_gnaw", "Frenzied Gnaw", "", [T.DAMAGE], K.focus(), [K.dmg(1.8)], { "cooldown": 7.0 })],
			Appearance.creature(Appearance.Body.RAT, Color("8c7a6b"), Color("f0b6b0"), 0.9), 45, 4),
		_monster(&"giant_rat", "Giant Rat", CombatTypes.Role.MELEE_DPS, StatBlock.make(620, 78, 20), bite,
			[K.ability(&"plague_bite", "Plague Bite", "", [T.DAMAGE, T.DOT], K.focus(),
				[K.dmg(0.6), K.status(K.dot(&"plague", "Plague", 1.8, 6.0, Color("a7c957")))], { "cooldown": 8.0 })],
			Appearance.creature(Appearance.Body.RAT, Color("5e5048"), Color("e89a94"), 1.45), 70, 8),
		_monster(&"goblin_grunt", "Goblin Grunt", CombatTypes.Role.MELEE_DPS, StatBlock.make(560, 74, 35),
			K.ability(&"stab", "Stab", "", [T.DAMAGE], K.focus(), [K.dmg(1.0)], { "recovery": 1.6 }),
			[K.ability(&"dirty_kick", "Dirty Kick", "", [T.DAMAGE, T.CONTROL], K.focus(),
				[K.dmg(0.8), K.status(K.stun(&"dazed", "Dazed", 1.2, Color("ffe066")))], { "cooldown": 10.0 })],
			_goblin(O.GOBLIN, H.BALD, P.SPEAR, Color("7a5a3a")), 70, 10),
		_monster(&"goblin_shaman", "Goblin Shaman", CombatTypes.Role.HEALER, StatBlock.make(420, 66, 15),
			K.ability(&"hex_bolt", "Hex Bolt", "", [T.DAMAGE], K.focus(), [K.dmg(1.0, true)],
				{ "recovery": 1.7, "delivery": D.PROJECTILE, "color": Color("b6ff6a") }),
			[K.ability(&"mending_chant", "Mending Chant", "", [T.HEAL], K.lowest_ally(), [K.heal(3.0, 0.15)],
				{ "cooldown": 6.0, "cast": 2.0, "delivery": D.INSTANT, "color": Color("b6ff6a") })],
			_goblin(O.SHAMAN, H.HORNS, P.TOTEM, Color("6a3d8f")), 90, 14),
		_monster(&"spiderling", "Spiderling", CombatTypes.Role.MELEE_DPS, StatBlock.make(260, 52, 10), bite, [],
			Appearance.creature(Appearance.Body.SPIDER, Color("4b3b5c"), Color("c86bff"), 0.7), 40, 3),
		_monster(&"broodmother", "Broodmother", CombatTypes.Role.MELEE_DPS, StatBlock.make(1700, 96, 35), bite,
			[
				K.ability(&"venom_spit", "Venom Spit", "", [T.DAMAGE, T.DOT], K.focus(),
					[K.status(K.dot(&"venom", "Venom", 2.2, 6.0, Color("9dff6a")))],
					{ "cooldown": 7.0, "delivery": D.PROJECTILE, "color": Color("9dff6a") }),
				K.ability(&"web_wrap", "Web Wrap", "", [T.CONTROL], K.focus(),
					[K.dmg(0.5), K.status(K.stun(&"webbed", "Webbed", 2.5, Color("f2f2f2")))],
					{ "cooldown": 12.0, "cast": 1.6, "delivery": D.PROJECTILE, "color": Color("f2f2f2") }),
			],
			Appearance.creature(Appearance.Body.SPIDER, Color("3a2d4a"), Color("ff5fa2"), 1.5), 200, 30),
		_boss(),
	]
	return out


static func build_encounters(monsters: Dictionary, items: Dictionary) -> Array[EncounterDefinition]:
	var out: Array[EncounterDefinition] = [
		_encounter(&"cave_rats", "Rat-Infested Tunnels", [monsters[&"cave_rat"], monsters[&"giant_rat"], monsters[&"cave_rat"]], 10, [items[&"potion_health"]]),
		_encounter(&"cave_goblins", "Goblin Raiders", [monsters[&"goblin_grunt"], monsters[&"goblin_shaman"], monsters[&"goblin_grunt"]], 20, [items[&"potion_health"]]),
		_encounter(&"cave_spiders", "The Spider Nest", [monsters[&"spiderling"], monsters[&"broodmother"], monsters[&"spiderling"], monsters[&"spiderling"]], 30, [items[&"ranger_leathers"]]),
		_encounter(&"cave_boss", "Gorrak the Stonehide", [monsters[&"gorrak"]], 80, [items[&"stonehide_cleaver"], items[&"potion_greater"]], true,
			"WHO DARES WAKE GORRAK?! Your bones will line my throne!"),
	]
	return out


static func _boss() -> MonsterDefinition:
	var m := _monster(&"gorrak", "Gorrak the Stonehide", CombatTypes.Role.TANK, StatBlock.make(6000, 122, 60),
		K.ability(&"smash", "Smash", "", [T.DAMAGE], K.focus(), [K.dmg(1.0)], { "recovery": 1.8 }),
		[
			K.ability(&"crushing_blow", "Crushing Blow", "", [T.DAMAGE], K.focus(), [K.dmg(2.3)], { "cooldown": 7.0, "recovery": 2.0 }),
			K.ability(&"earthshatter", "Earthshatter", "", [T.DAMAGE, T.AOE], K.all_enemies(), [K.dmg(1.2)],
				{ "cooldown": 13.0, "cast": 2.4, "interruptible": false, "delivery": D.INSTANT, "recovery": 2.0, "color": Color("c9a36b") }),
			K.ability(&"rallying_roar", "Rallying Roar", "", [T.BUFF], K.self_only(),
				[K.status(K.modifier(&"rallying_roar", "Rallying Roar", 15.0, Color("ff5a3d"), { "power": 1.4 }))],
				{ "cooldown": 16.0, "cast": 2.0, "delivery": D.SELF, "color": Color("ff5a3d") }),
		],
		Appearance.humanoid(O.OGRE, H.HORNS, P.GREAT_CLUB, Color("6b5a4a"), Color("a08a70"), Color("8d9aa3"), Color("3a3a3a"), 1.9),
		600, 150)
	m.is_boss = true
	m.enrage_threshold = 0.3
	m.enrage_status = K.modifier(&"enrage", "Enraged", 999.0, Color("ff2d2d"), { "power": 1.5, "haste": 0.3 })
	return m


static func _goblin(outfit: Appearance.Outfit, head: Appearance.Headgear, prop: Appearance.Prop, cloth: Color) -> Appearance:
	var a := Appearance.humanoid(outfit, head, prop, cloth, Color("c9a36b"), Color("7fb04a"), Color("2d2d2d"), 0.8)
	a.pointy_ears = true
	return a


static func _monster(id: StringName, name: String, role: CombatTypes.Role, stats: StatBlock, basic: Ability,
		abilities: Array, appearance: Appearance, xp: int, gold: int) -> MonsterDefinition:
	var m := MonsterDefinition.new()
	m.id = id
	m.display_name = name
	m.role = role
	m.stats = stats
	m.basic_attack = basic
	m.abilities.assign(abilities)
	m.appearance = appearance
	m.xp_reward = xp
	m.gold_reward = gold
	return m


static func _encounter(id: StringName, name: String, monsters: Array, gold: int, loot: Array,
		boss := false, intro := "") -> EncounterDefinition:
	var e := EncounterDefinition.new()
	e.id = id
	e.display_name = name
	e.monsters.assign(monsters)
	e.bonus_gold = gold
	e.loot.assign(loot)
	e.is_boss = boss
	e.intro_line = intro
	return e
