class_name MostThreatenedAllyRule
extends TargetRule
## The ally being attacked by the most enemies (ties: lower health). Ideal for shields.


func select(caster: BattleUnit, battle: Battle) -> Array[BattleUnit]:
	var best: BattleUnit = null
	var best_score := -1.0
	for a in battle.allies_of(caster):
		var score := battle.count_attackers_of(a) + (1.0 - a.get_hp_ratio())
		if score > best_score:
			best_score = score
			best = a
	if best == null:
		return TargetRule.only(null)
	return TargetRule.only(best)
