class_name FocusEnemyRule
extends TargetRule
## The enemy the caster's brain is focusing (respects taunts).


func select(caster: BattleUnit, battle: Battle) -> Array[BattleUnit]:
	var t := caster.brain.pick_focus(caster, battle)
	if t == null:
		return TargetRule.only(null)
	return TargetRule.only(t)
