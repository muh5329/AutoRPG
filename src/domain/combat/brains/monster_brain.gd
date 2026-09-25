class_name MonsterBrain
extends BattleBrain
## Enemy AI: sticks to a target, prefers the front line, occasionally switches,
## which is exactly why the tank needs to taunt.

const SWITCH_CHANCE := 0.12
const FRONTLINE_CHANCE := 0.6


func _tag_biases() -> Dictionary:
	return {
		CombatTypes.Tag.HEAL: 2.2,
		CombatTypes.Tag.BUFF: 1.3,
		CombatTypes.Tag.AOE: 1.1,
	}


func pick_focus(unit: BattleUnit, battle: Battle) -> BattleUnit:
	if unit.get_forced_target() == null and unit.focus and unit.focus.is_alive() \
			and battle.rng.randf() < SWITCH_CHANCE:
		unit.focus = null
	return super(unit, battle)


func _choose_new_focus(unit: BattleUnit, battle: Battle) -> BattleUnit:
	var enemies := battle.enemies_of(unit)
	if enemies.is_empty():
		return null
	if battle.rng.randf() < FRONTLINE_CHANCE:
		for e in enemies:
			if not CombatTypes.is_ranged_role(e.combatant.get_role()):
				return e
	return enemies[battle.rng.randi() % enemies.size()]
