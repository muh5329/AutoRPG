class_name TankBrain
extends HeroBrain
## Tanks taunt first, pop defensives when focused, interrupt, and peel enemies off allies.


func _tag_biases() -> Dictionary:
	return {
		CombatTypes.Tag.TANK: 2.4,
		CombatTypes.Tag.DEFENSIVE: 1.8,
		CombatTypes.Tag.INTERRUPT: 1.6,
		CombatTypes.Tag.AOE: 1.0,
		CombatTypes.Tag.DAMAGE: 0.9,
		CombatTypes.Tag.HEAL: 0.0,
	}


## Peel: go after an enemy that is hitting someone other than me.
func _choose_new_focus(unit: BattleUnit, battle: Battle) -> BattleUnit:
	for e in battle.enemies_of(unit):
		if e.focus != null and e.focus != unit and e.focus.is_alive():
			return e
	return super(unit, battle)
