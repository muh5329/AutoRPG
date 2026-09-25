class_name LowestHealthAllyRule
extends TargetRule
## The living ally with the lowest health ratio.


func select(caster: BattleUnit, battle: Battle) -> Array[BattleUnit]:
	var best: BattleUnit = null
	for a in battle.allies_of(caster):
		if best == null or a.get_hp_ratio() < best.get_hp_ratio():
			best = a
	if best == null:
		return TargetRule.only(null)
	return TargetRule.only(best)
