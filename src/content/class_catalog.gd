class_name ClassCatalog
extends RefCounted
## The four launch classes and their 4-ability kits.
## Kit order = default priority. Index 0 is free; others cost a skill point.

const K = preload("res://src/content/content_kit.gd")
const T := CombatTypes.Tag
const D := CombatTypes.Delivery


static func build() -> Array[HeroClass]:
	var out: Array[HeroClass] = [_warrior(), _priest(), _hunter(), _mage()]
	return out


static func _make(id: StringName, name: String, desc: String, role: CombatTypes.Role, color: Color,
		base: StatBlock, growth: StatBlock, basic: Ability, kit: Array,
		weapons: Array, armors: Array) -> HeroClass:
	var c := HeroClass.new()
	c.id = id
	c.display_name = name
	c.description = desc
	c.role = role
	c.color = color
	c.base_stats = base
	c.growth = growth
	c.basic_attack = basic
	c.abilities.assign(kit)
	c.weapon_types.assign(weapons)
	c.armor_types.assign(armors)
	return c


static func _warrior() -> HeroClass:
	var basic := K.ability(&"strike", "Strike", "A solid sword blow.", [T.DAMAGE], K.focus(), [K.dmg(1.0)],
		{ "recovery": 1.6, "color": Color("dfe6ee") })
	var kit := [
		K.ability(&"taunting_roar", "Taunting Roar", "Roars a challenge, forcing every enemy to attack the Warrior for 5s.",
			[T.TANK], K.all_enemies(), [K.status(K.taunt(5.0))],
			{ "cooldown": 10.0, "recovery": 1.1, "delivery": D.SELF, "color": Color("ff7a45") }),
		K.ability(&"shield_slam", "Shield Slam", "Bashes a foe, interrupting any spell being cast.",
			[T.DAMAGE, T.INTERRUPT], K.casting_enemy(true), [K.dmg(1.3), K.interrupt()],
			{ "cooldown": 8.0, "recovery": 1.5, "color": Color("9fc3ff") }),
		K.ability(&"shield_wall", "Shield Wall", "Braces behind the shield: -50% damage taken for 6s.",
			[T.DEFENSIVE], K.self_only(),
			[K.status(K.modifier(&"shield_wall", "Shield Wall", 6.0, Color("7fb2ff"),
				{ "intent": StatModifierStatus.Intent.DEFENSIVE, "taken": 0.5 }))],
			{ "cooldown": 18.0, "recovery": 0.8, "delivery": D.SELF, "unlock": 2, "color": Color("7fb2ff") }),
		K.ability(&"cleave", "Cleave", "A wide swing that hits every enemy.",
			[T.DAMAGE, T.AOE], K.all_enemies(), [K.dmg(0.75)],
			{ "cooldown": 6.0, "recovery": 1.8, "unlock": 3, "color": Color("ffd27a") }),
	]
	return _make(&"warrior", "Warrior",
		"Plate-clad protector. Taunts enemies, soaks damage and interrupts casters.",
		CombatTypes.Role.TANK, Color("d9534f"),
		StatBlock.make(460, 20, 70, 0.0, 0.05), StatBlock.make(55, 2.5, 6, 0.0, 0.0),
		basic, kit, [Weapon.WeaponType.SWORD, Weapon.WeaponType.MACE], [Armor.ArmorType.PLATE])


static func _priest() -> HeroClass:
	var basic := K.ability(&"smite", "Smite", "A bolt of holy light.", [T.DAMAGE], K.focus(), [K.dmg(1.0, true)],
		{ "recovery": 1.6, "delivery": D.PROJECTILE, "color": Color("fff2a8") })
	var kit := [
		K.ability(&"flash_heal", "Flash Heal", "Quickly mends the most wounded ally.",
			[T.HEAL], K.lowest_ally(), [K.heal(2.2)],
			{ "cooldown": 2.5, "recovery": 1.5, "delivery": D.INSTANT, "color": Color("9cf29a") }),
		K.ability(&"holy_ward", "Holy Ward", "Shields the ally under the most pressure, absorbing damage for 8s.",
			[T.DEFENSIVE, T.HEAL], K.threatened_ally(), [K.status(K.shield(&"holy_ward", "Holy Ward", 2.2, 8.0))],
			{ "cooldown": 7.0, "recovery": 1.2, "delivery": D.INSTANT, "color": Color("ffe38a") }),
		K.ability(&"renewing_light", "Renewing Light", "Heals the target gradually over 8s.",
			[T.HEAL], K.lowest_ally(), [K.status(K.hot(&"renewing_light", "Renewing Light", 2.4, 8.0))],
			{ "cooldown": 3.0, "recovery": 1.2, "delivery": D.INSTANT, "unlock": 2, "color": Color("b8ffb0") }),
		K.ability(&"sanctuary", "Sanctuary", "Channels light that heals the whole party.",
			[T.HEAL, T.AOE], K.all_allies(), [K.heal(1.1, 0.12)],
			{ "cooldown": 12.0, "recovery": 1.6, "cast": 1.2, "delivery": D.INSTANT, "unlock": 3, "color": Color("fff7c2") }),
	]
	return _make(&"priest", "Priest",
		"Devoted healer. Keeps the party alive with heals, shields and restorative light.",
		CombatTypes.Role.HEALER, Color("f0c75e"),
		StatBlock.make(280, 24, 25, 0.0, 0.05), StatBlock.make(30, 3.0, 2, 0.0, 0.0),
		basic, kit, [Weapon.WeaponType.MACE, Weapon.WeaponType.STAFF], [Armor.ArmorType.CLOTH])


static func _hunter() -> HeroClass:
	var basic := K.ability(&"quick_shot", "Quick Shot", "A fast arrow.", [T.DAMAGE], K.focus(), [K.dmg(1.0)],
		{ "recovery": 1.4, "delivery": D.PROJECTILE, "color": Color("e8d7b0") })
	var kit := [
		K.ability(&"aimed_shot", "Aimed Shot", "Takes careful aim for a devastating arrow.",
			[T.DAMAGE], K.focus(), [K.dmg(2.4)],
			{ "cooldown": 6.0, "recovery": 1.4, "cast": 0.8, "delivery": D.PROJECTILE, "color": Color("fff0a0") }),
		K.ability(&"serpent_sting", "Serpent Sting", "A venomed arrow that poisons for 8s.",
			[T.DAMAGE, T.DOT], K.focus(), [K.dmg(0.3), K.status(K.dot(&"serpent_sting", "Serpent Sting", 2.0, 8.0, Color("7ddc4a")))],
			{ "cooldown": 5.0, "recovery": 1.3, "delivery": D.PROJECTILE, "color": Color("7ddc4a") }),
		K.ability(&"counter_shot", "Counter Shot", "A snap shot that interrupts a spellcaster.",
			[T.INTERRUPT], K.casting_enemy(false), [K.dmg(0.5), K.interrupt()],
			{ "cooldown": 9.0, "recovery": 0.8, "delivery": D.PROJECTILE, "unlock": 2, "color": Color("9fe8ff") }),
		K.ability(&"multi_shot", "Multi-Shot", "Looses a volley at every enemy.",
			[T.DAMAGE, T.AOE], K.all_enemies(), [K.dmg(0.7)],
			{ "cooldown": 7.0, "recovery": 1.6, "delivery": D.PROJECTILE, "unlock": 3, "color": Color("ffd08a") }),
	]
	return _make(&"hunter", "Hunter",
		"Ranged marksman. Stays in the back line, poisons foes and snipes enemy casters.",
		CombatTypes.Role.RANGED_DPS, Color("5cb85c"),
		StatBlock.make(300, 28, 30, 0.0, 0.10), StatBlock.make(32, 3.5, 2.5, 0.0, 0.0),
		basic, kit, [Weapon.WeaponType.BOW], [Armor.ArmorType.LEATHER])


static func _mage() -> HeroClass:
	var basic := K.ability(&"arcane_bolt", "Arcane Bolt", "A crackling bolt of arcane force.", [T.DAMAGE], K.focus(),
		[K.dmg(1.0, true)], { "recovery": 1.5, "delivery": D.PROJECTILE, "color": Color("c89bff") })
	var kit := [
		K.ability(&"fireball", "Fireball", "Hurls a massive ball of fire.",
			[T.DAMAGE], K.focus(), [K.dmg(2.6, true)],
			{ "cooldown": 4.0, "recovery": 1.4, "cast": 1.2, "delivery": D.PROJECTILE, "color": Color("ff8a3d") }),
		K.ability(&"frost_nova", "Frost Nova", "Blasts all enemies with frost, freezing them for 2s.",
			[T.CONTROL, T.AOE], K.all_enemies(), [K.dmg(0.5, true), K.status(K.stun(&"frozen", "Frozen", 2.0))],
			{ "cooldown": 14.0, "recovery": 1.3, "delivery": D.INSTANT, "color": Color("8fd3ff") }),
		K.ability(&"counterspell", "Counterspell", "Unravels an enemy's spell mid-cast.",
			[T.INTERRUPT], K.casting_enemy(false), [K.dmg(0.4, true), K.interrupt()],
			{ "cooldown": 10.0, "recovery": 0.8, "delivery": D.INSTANT, "unlock": 2, "color": Color("d6a8ff") }),
		K.ability(&"flamestrike", "Flamestrike", "Calls down a pillar of flame on every enemy.",
			[T.DAMAGE, T.AOE], K.all_enemies(), [K.dmg(1.1, true)],
			{ "cooldown": 10.0, "recovery": 1.6, "cast": 1.5, "delivery": D.INSTANT, "unlock": 3, "color": Color("ffb03d") }),
	]
	return _make(&"mage", "Mage",
		"Fragile spellcaster with enormous damage, crowd control and counterspells.",
		CombatTypes.Role.RANGED_DPS, Color("8e6bd6"),
		StatBlock.make(260, 31, 18, 0.0, 0.08), StatBlock.make(28, 4.0, 2, 0.0, 0.0),
		basic, kit, [Weapon.WeaponType.STAFF, Weapon.WeaponType.WAND], [Armor.ArmorType.CLOTH])
