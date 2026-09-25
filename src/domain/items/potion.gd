class_name Potion
extends Consumable
## Restores health. Usable from the bag, and auto-quaffed by heroes in battle
## when they drop below Battle.AUTO_POTION_THRESHOLD.

@export var heal_flat: float = 0.0
@export_range(0.0, 1.0) var heal_percent: float = 0.0


func get_category() -> String:
	return "Potion"


func heal_amount_for(hero_max_hp: float) -> float:
	return heal_flat + hero_max_hp * heal_percent


func can_use_on(hero: Hero) -> bool:
	return hero.is_alive() and hero.current_hp < hero.get_max_hp()


func use_on(hero: Hero) -> bool:
	if not can_use_on(hero):
		return false
	hero.apply_heal(heal_amount_for(hero.get_max_hp()))
	return true


func get_tooltip() -> String:
	var parts: PackedStringArray = []
	if heal_flat > 0.0: parts.append("%d" % roundi(heal_flat))
	if heal_percent > 0.0: parts.append("%d%% of max HP" % roundi(heal_percent * 100.0))
	return "%s\nRestores %s." % [description, " + ".join(parts)]
