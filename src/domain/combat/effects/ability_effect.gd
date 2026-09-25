class_name AbilityEffect
extends Resource
## Abstract strategy: one atomic thing an ability does to a target.
## Each effect also scores itself so AI utility emerges from composition.


## AI utility of applying this effect to `targets` right now. 0 = useless.
func evaluate(_caster: BattleUnit, _targets: Array[BattleUnit], _battle: Battle) -> float:
	return 0.0


func apply(_caster: BattleUnit, _target: BattleUnit, _battle: Battle) -> void:
	push_error("AbilityEffect.apply is abstract")
