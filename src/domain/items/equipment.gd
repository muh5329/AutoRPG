class_name Equipment
extends Item
## Abstract: gear worn in one slot that adds a StatBlock to its wearer.

enum Slot { WEAPON, ARMOR }

const SLOT_NAMES := { Slot.WEAPON: "Weapon", Slot.ARMOR: "Armor" }

@export var stats: StatBlock = StatBlock.new()
@export var required_level: int = 1


## Concrete subclasses decide their slot.
func get_slot() -> Slot:
	push_error("Equipment.get_slot is abstract")
	return Slot.WEAPON


func get_category() -> String:
	return SLOT_NAMES[get_slot()]


## Base rule: level requirement. Subclasses add class restrictions.
func can_be_equipped_by(hero: Hero) -> bool:
	return hero.level >= required_level


func get_restriction_text(hero: Hero) -> String:
	if hero.level < required_level:
		return "Requires level %d" % required_level
	return ""


func get_tooltip() -> String:
	var text := "%s\n%s" % [description, stats.describe_bonus()]
	if required_level > 1:
		text += "\nRequires level %d" % required_level
	return text
