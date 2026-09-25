class_name AbilityLoadout
extends RefCounted
## The player's per-hero battle plan: which abilities are enabled and in what
## priority order. The HeroBrain adds a preference bonus to earlier abilities.

signal changed

class Slot:
	extends RefCounted
	var ability: Ability
	var enabled: bool = true

	func _init(ability_: Ability) -> void:
		ability = ability_


var _slots: Array[Slot] = []


func _init(abilities: Array[Ability]) -> void:
	for a in abilities:
		_slots.append(Slot.new(a))


func slots() -> Array[Slot]:
	return _slots.duplicate()


func index_of(ability: Ability) -> int:
	for i in _slots.size():
		if _slots[i].ability == ability:
			return i
	return -1


func set_enabled(ability: Ability, value: bool) -> void:
	var i := index_of(ability)
	if i >= 0 and _slots[i].enabled != value:
		_slots[i].enabled = value
		changed.emit()


## Move an ability up (-1) or down (+1) in priority.
func move(ability: Ability, delta: int) -> void:
	var i := index_of(ability)
	var j := i + delta
	if i < 0 or j < 0 or j >= _slots.size():
		return
	var tmp := _slots[i]
	_slots[i] = _slots[j]
	_slots[j] = tmp
	changed.emit()
