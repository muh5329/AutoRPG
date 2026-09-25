class_name HeroBrain
extends BattleBrain
## Base brain for player heroes: honours the player's ability order and focuses
## the party's shared kill target so damage is not spread thin.

## Top-priority ability gets up to this much extra weight.
const MAX_PREFERENCE_BONUS := 0.35


func _preference_weight(index: int, count: int) -> float:
	if count <= 1:
		return 1.0 + MAX_PREFERENCE_BONUS
	return 1.0 + MAX_PREFERENCE_BONUS * float(count - 1 - index) / float(count - 1)


func _choose_new_focus(unit: BattleUnit, battle: Battle) -> BattleUnit:
	return battle.get_team_focus(unit.team)
