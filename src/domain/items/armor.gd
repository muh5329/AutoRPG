class_name Armor
extends Equipment
## Armor slot equipment. Classes declare which ArmorTypes they can wear.

enum ArmorType { CLOTH, LEATHER, PLATE }

const TYPE_NAMES := { ArmorType.CLOTH: "Cloth", ArmorType.LEATHER: "Leather", ArmorType.PLATE: "Plate" }

@export var armor_type: ArmorType = ArmorType.CLOTH


func get_slot() -> Slot:
	return Slot.ARMOR


func get_category() -> String:
	return "%s Armor" % TYPE_NAMES[armor_type]


func can_be_equipped_by(hero: Hero) -> bool:
	return super(hero) and hero.get_hero_class().armor_types.has(armor_type)


func get_restriction_text(hero: Hero) -> String:
	if not hero.get_hero_class().armor_types.has(armor_type):
		return "%s cannot wear %s" % [hero.get_hero_class().display_name, TYPE_NAMES[armor_type]]
	return super(hero)
