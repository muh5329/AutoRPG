class_name RangedBrain
extends DamageBrain
## Ranged DPS: stays in the back line and snipes enemy casters/healers first.


func _choose_new_focus(unit: BattleUnit, battle: Battle) -> BattleUnit:
	for e in battle.enemies_of(unit):
		if e.combatant.get_role() == CombatTypes.Role.HEALER:
			return e
	return super(unit, battle)


func _tag_biases() -> Dictionary:
	var biases := super()
	biases[CombatTypes.Tag.DOT] = 1.25
	return biases
