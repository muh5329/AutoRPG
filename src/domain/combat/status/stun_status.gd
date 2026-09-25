class_name StunStatus
extends StatusEffect
## The holder cannot act, and any cast in progress is broken.


func _on_instantiated(_caster: BattleUnit, _battle: Battle) -> void:
	is_harmful = true


func on_applied(battle: Battle) -> void:
	if holder.is_casting():
		holder.interrupt(true)
		battle.announce("%s's cast was broken!" % holder.get_name())


func prevents_action() -> bool:
	return true


func _utility(_caster: BattleUnit, target: BattleUnit, _battle: Battle) -> float:
	if target.combatant.is_control_immune():
		return 0.0
	return 3.0 if target.is_casting() else 0.4
