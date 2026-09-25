class_name SelfRule
extends TargetRule
## Only the caster.


func select(caster: BattleUnit, _battle: Battle) -> Array[BattleUnit]:
	return TargetRule.only(caster)
