class_name ShieldStatus
extends StatusEffect
## Absorbs incoming damage until depleted or expired.

@export var absorb_multiplier: float = 2.0

var absorb_left: float = 0.0


func _on_instantiated(caster: BattleUnit, battle: Battle) -> void:
	absorb_left = battle.roll(caster, absorb_multiplier).amount


func modify_incoming_damage(amount: float) -> float:
	var absorbed := minf(amount, absorb_left)
	absorb_left -= absorbed
	if absorbed > 0.0:
		holder.absorbed.emit(absorbed)
	if absorb_left <= 0.0:
		remaining = 0.0
	return amount - absorbed


func _utility(_caster: BattleUnit, target: BattleUnit, battle: Battle) -> float:
	var attackers := battle.count_attackers_of(target)
	return 1.2 + attackers * 0.8 + (1.0 - target.get_hp_ratio()) * 2.0
