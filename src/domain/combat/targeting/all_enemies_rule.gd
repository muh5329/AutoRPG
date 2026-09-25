class_name AllEnemiesRule
extends TargetRule
## Every living enemy.


func select(caster: BattleUnit, battle: Battle) -> Array[BattleUnit]:
	return battle.enemies_of(caster)
