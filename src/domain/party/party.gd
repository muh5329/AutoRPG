class_name Party
extends RefCounted
## The player's roster of recruited heroes (max 5 in this iteration).

signal changed

const MAX_SIZE := 5

var _members: Array[Hero] = []


func members() -> Array[Hero]:
	return _members.duplicate()


func size() -> int:
	return _members.size()


func is_full() -> bool:
	return _members.size() >= MAX_SIZE


func has_definition(def_id: StringName) -> bool:
	for h in _members:
		if h.definition.id == def_id:
			return true
	return false


func add(hero: Hero) -> bool:
	if is_full() or has_definition(hero.definition.id):
		return false
	_members.append(hero)
	hero.changed.connect(func() -> void: changed.emit())
	changed.emit()
	return true


func living() -> Array[Hero]:
	var out: Array[Hero] = []
	for h in _members:
		if h.is_alive():
			out.append(h)
	return out


func average_level() -> int:
	if _members.is_empty():
		return 1
	var total := 0
	for h in _members:
		total += h.level
	return roundi(float(total) / _members.size())


## Heals everyone to at least `ratio`, reviving the fallen.
func restore_all(ratio: float) -> void:
	for h in _members:
		h.restore_percent(ratio)
	changed.emit()


func needs_rest() -> bool:
	for h in _members:
		if h.current_hp < h.get_max_hp():
			return true
	return false


func total_skill_points() -> int:
	var n := 0
	for h in _members:
		n += h.skill_points
	return n
