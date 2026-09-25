class_name Boss
extends Monster
## A monster with phases: becomes enraged once below its enrage threshold.

signal enraged

var is_enraged: bool = false


func is_control_immune() -> bool:
	return true


func on_battle_tick(unit: BattleUnit, battle: Battle) -> void:
	if is_enraged or definition.enrage_status == null:
		return
	if get_hp_ratio() <= definition.enrage_threshold:
		is_enraged = true
		unit.add_status(definition.enrage_status.instantiate_for(unit, unit, battle), battle)
		battle.announce("%s becomes ENRAGED!" % display_name)
		enraged.emit()
