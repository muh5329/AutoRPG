class_name InterruptEffect
extends AbilityEffect
## Cancels an interruptible cast. Extremely valuable while an enemy is casting, worthless otherwise.


func evaluate(_caster: BattleUnit, targets: Array[BattleUnit], _battle: Battle) -> float:
	for t in targets:
		if t.is_casting_interruptible():
			return 6.0
	return 0.0


func apply(_caster: BattleUnit, target: BattleUnit, battle: Battle) -> void:
	if target.interrupt():
		battle.announce("%s was interrupted!" % target.get_name())
