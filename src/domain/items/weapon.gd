class_name Weapon
extends Equipment
## Weapon slot equipment. Classes declare which WeaponTypes they can wield.

enum WeaponType { SWORD, MACE, STAFF, BOW, WAND }

const TYPE_NAMES := {
	WeaponType.SWORD: "Sword", WeaponType.MACE: "Mace", WeaponType.STAFF: "Staff",
	WeaponType.BOW: "Bow", WeaponType.WAND: "Wand",
}

@export var weapon_type: WeaponType = WeaponType.SWORD


func get_slot() -> Slot:
	return Slot.WEAPON


func get_category() -> String:
	return TYPE_NAMES[weapon_type]


func can_be_equipped_by(hero: Hero) -> bool:
	return super(hero) and hero.get_hero_class().weapon_types.has(weapon_type)


func get_restriction_text(hero: Hero) -> String:
	if not hero.get_hero_class().weapon_types.has(weapon_type):
		return "%s cannot use %ss" % [hero.get_hero_class().display_name, TYPE_NAMES[weapon_type]]
	return super(hero)
