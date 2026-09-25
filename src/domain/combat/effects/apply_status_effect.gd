class_name ApplyStatusEffect
extends AbilityEffect
## Applies a copy of `status` (a StatusEffect template) to each target.
## Utility is delegated to the status itself (a shield knows when a shield is useful).

@export var status: StatusEffect


static func create(status_: StatusEffect) -> ApplyStatusEffect:
	var e := ApplyStatusEffect.new()
	e.status = status_
	return e


func evaluate(caster: BattleUnit, targets: Array[BattleUnit], battle: Battle) -> float:
	var total := 0.0
	for t in targets:
		total += status.evaluate_on(caster, t, battle)
	return total


func apply(caster: BattleUnit, target: BattleUnit, battle: Battle) -> void:
	target.add_status(status.instantiate_for(caster, target, battle), battle)
