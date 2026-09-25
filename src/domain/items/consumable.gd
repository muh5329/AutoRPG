class_name Consumable
extends Item
## Abstract: an item that is used up when used on a hero.


func is_stackable() -> bool:
	return true


func get_category() -> String:
	return "Consumable"


## Whether using the item on this hero would have any effect.
func can_use_on(_hero: Hero) -> bool:
	return false


## Apply the effect. Returns true if the item was consumed.
func use_on(_hero: Hero) -> bool:
	push_error("Consumable.use_on is abstract")
	return false
