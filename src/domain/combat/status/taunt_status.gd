class_name TauntStatus
extends StatusEffect
## Forces the holder to attack the taunter.


func _on_instantiated(_caster: BattleUnit, _battle: Battle) -> void:
	is_harmful = true


func get_forced_target() -> BattleUnit:
	return source if source and source.is_alive() else null


func evaluate_on(caster: BattleUnit, target: BattleUnit, _battle: Battle) -> float:
	# Worth it for every enemy that is currently hitting someone else.
	return 1.3 if target.focus != caster else 0.0
