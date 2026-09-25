class_name DamageEffect
extends AbilityEffect
## Deals caster.power * multiplier damage (±10%, can crit).

@export var multiplier: float = 1.0
@export var school: CombatTypes.School = CombatTypes.School.PHYSICAL


static func create(multiplier_: float, school_ := CombatTypes.School.PHYSICAL) -> DamageEffect:
	var e := DamageEffect.new()
	e.multiplier = multiplier_
	e.school = school_
	return e


func evaluate(_caster: BattleUnit, targets: Array[BattleUnit], _battle: Battle) -> float:
	return multiplier * targets.size()


func apply(caster: BattleUnit, target: BattleUnit, battle: Battle) -> void:
	var roll := battle.roll(caster, multiplier)
	target.take_damage(roll.amount, school, caster, roll.crit)
