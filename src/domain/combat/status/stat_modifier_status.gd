class_name StatModifierStatus
extends StatusEffect
## Generic buff/debuff: multiplies power, adds haste, scales damage taken.

enum Intent { DEFENSIVE, OFFENSIVE }

@export var intent: Intent = Intent.OFFENSIVE
@export var power_multiplier: float = 1.0
@export var bonus_haste: float = 0.0
@export var damage_taken_multiplier: float = 1.0


func modify_stats(stats: StatBlock) -> void:
	stats.power *= power_multiplier
	stats.haste += bonus_haste


func modify_incoming_damage(amount: float) -> float:
	return amount * damage_taken_multiplier


func _utility(_caster: BattleUnit, target: BattleUnit, battle: Battle) -> float:
	if intent == Intent.DEFENSIVE:
		return battle.count_attackers_of(target) * 0.9 + (1.0 - target.get_hp_ratio()) * 2.5
	return 1.8
