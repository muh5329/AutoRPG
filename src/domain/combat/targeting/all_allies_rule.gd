class_name AllAlliesRule
extends TargetRule
## Every living ally including the caster.


func select(caster: BattleUnit, battle: Battle) -> Array[BattleUnit]:
	return battle.allies_of(caster)
