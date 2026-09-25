class_name HealEffect
extends AbilityEffect
## Heals caster.power * multiplier. Only valuable when targets are actually hurt.

@export var multiplier: float = 1.0
## Below this missing-health ratio a target is not worth healing.
@export var min_missing: float = 0.18


static func create(multiplier_: float, min_missing_ := 0.18) -> HealEffect:
	var e := HealEffect.new()
	e.multiplier = multiplier_
	e.min_missing = min_missing_
	return e


func evaluate(_caster: BattleUnit, targets: Array[BattleUnit], _battle: Battle) -> float:
	var total := 0.0
	for t in targets:
		var missing := 1.0 - t.get_hp_ratio()
		if missing >= min_missing:
			total += missing * multiplier * 4.0
	return total


func apply(caster: BattleUnit, target: BattleUnit, battle: Battle) -> void:
	var roll := battle.roll(caster, multiplier)
	target.receive_heal(roll.amount, caster, roll.crit)
