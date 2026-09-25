class_name BattleBrain
extends RefCounted
## Abstract utility-AI "decision tree" for one BattleUnit.
##
## For every usable ability: score = utility(situation) x role bias(tags) x preference(order).
## The highest score wins; the basic attack is the guaranteed fallback.
## Subclasses only override the bias table and focus selection, which is what
## gives each role its heavy personality without duplicating decision code.


func choose_action(unit: BattleUnit, battle: Battle) -> BattleAction:
	var best: BattleAction = null
	var abilities := unit.get_usable_abilities()
	var count := abilities.size()
	for i in count:
		var ability := abilities[i]
		var targets := ability.select_targets(unit, battle)
		if targets.is_empty():
			continue
		var utility := ability.evaluate(unit, targets, battle)
		if utility <= 0.0:
			continue
		var score := utility * bias_for(ability) * _preference_weight(i, count)
		if best == null or score > best.score:
			best = BattleAction.new(ability, targets, score)
	if best == null:
		var basic := unit.combatant.get_basic_attack()
		var targets := basic.select_targets(unit, battle)
		if not targets.is_empty():
			best = BattleAction.new(basic, targets, 0.0)
	return best


## Strongest matching tag bias from this brain's table (1.0 when no tag is listed).
func bias_for(ability: Ability) -> float:
	var table := _tag_biases()
	var best := -1.0
	for tag in ability.tags:
		if table.has(tag):
			best = maxf(best, table[tag])
	return 1.0 if best < 0.0 else best


## Which enemy single-target attacks go to. Taunts always win.
func pick_focus(unit: BattleUnit, battle: Battle) -> BattleUnit:
	var forced := unit.get_forced_target()
	if forced:
		unit.focus = forced
		return forced
	if unit.focus == null or not unit.focus.is_alive():
		unit.focus = _choose_new_focus(unit, battle)
	return unit.focus


# --- hooks ---------------------------------------------------------------------

## Tag -> multiplier. The heart of each role's personality.
func _tag_biases() -> Dictionary:
	return {}


## Bonus for the player's preferred order. Neutral by default.
func _preference_weight(_index: int, _count: int) -> float:
	return 1.0


func _choose_new_focus(unit: BattleUnit, battle: Battle) -> BattleUnit:
	var enemies := battle.enemies_of(unit)
	return null if enemies.is_empty() else enemies[0]
