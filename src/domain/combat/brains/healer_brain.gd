class_name HealerBrain
extends HeroBrain
## Healers heal and shield first and only attack when everyone is healthy.


func _tag_biases() -> Dictionary:
	return {
		CombatTypes.Tag.HEAL: 3.0,
		CombatTypes.Tag.DEFENSIVE: 1.6,
		CombatTypes.Tag.INTERRUPT: 1.2,
		CombatTypes.Tag.DAMAGE: 0.6,
	}
