class_name DamageOverTimeStatus
extends StatusEffect
## Poison/burn: deals total_multiplier * power over the duration, once per second.

@export var total_multiplier: float = 1.5
@export var school: CombatTypes.School = CombatTypes.School.MAGIC

var _per_tick: float = 0.0
var _accum: float = 0.0


func _on_instantiated(caster: BattleUnit, battle: Battle) -> void:
	is_harmful = true
	_per_tick = battle.roll(caster, total_multiplier).amount / maxf(duration, 1.0)


func _on_tick(delta: float, _battle: Battle) -> void:
	_accum += delta
	while _accum >= 1.0 and holder.is_alive():
		_accum -= 1.0
		holder.take_damage(_per_tick, school, source, false, true)


func _utility(_caster: BattleUnit, target: BattleUnit, _battle: Battle) -> float:
	return total_multiplier * (1.0 if target.get_hp_ratio() > 0.3 else 0.3)
