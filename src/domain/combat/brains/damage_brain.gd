class_name DamageBrain
extends HeroBrain
## Melee DPS: maximise damage, love interrupts and cleaves.


func _tag_biases() -> Dictionary:
	return {
		CombatTypes.Tag.INTERRUPT: 2.0,
		CombatTypes.Tag.DAMAGE: 1.2,
		CombatTypes.Tag.AOE: 1.25,
		CombatTypes.Tag.DOT: 1.1,
		CombatTypes.Tag.CONTROL: 1.2,
	}
