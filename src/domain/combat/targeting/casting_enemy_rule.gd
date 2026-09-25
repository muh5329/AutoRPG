class_name CastingEnemyRule
extends TargetRule
## An enemy currently channelling an interruptible cast.
## With fallback_to_focus the ability still works as a normal attack otherwise.

@export var fallback_to_focus: bool = false


func select(caster: BattleUnit, battle: Battle) -> Array[BattleUnit]:
	var best: BattleUnit = null
	for e in battle.enemies_of(caster):
		if e.is_casting_interruptible() and (best == null or e.cast_remaining < best.cast_remaining):
			best = e
	if best:
		return TargetRule.only(best)
	if fallback_to_focus:
		var f := caster.brain.pick_focus(caster, battle)
		if f:
			return TargetRule.only(f)
	return TargetRule.only(null)
