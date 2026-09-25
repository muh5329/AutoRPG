class_name HealOverTimeStatus
extends StatusEffect
## Renew-style heal: total_multiplier * power over the duration, once per second.

@export var total_multiplier: float = 1.5

var _per_tick: float = 0.0
var _accum: float = 0.0


func _on_instantiated(caster: BattleUnit, battle: Battle) -> void:
	_per_tick = battle.roll(caster, total_multiplier).amount / maxf(duration, 1.0)


func _on_tick(delta: float, _battle: Battle) -> void:
	_accum += delta
	while _accum >= 1.0 and holder.is_alive():
		_accum -= 1.0
		holder.receive_heal(_per_tick, source, false, true)


func _utility(_caster: BattleUnit, target: BattleUnit, _battle: Battle) -> float:
	var missing := 1.0 - target.get_hp_ratio()
	return 0.0 if missing < 0.1 else 1.0 + missing * 3.0
