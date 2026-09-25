class_name BattleAction
extends RefCounted
## A decision produced by a BattleBrain: use `ability` on `targets`.

var ability: Ability
var targets: Array[BattleUnit]
var score: float


func _init(ability_: Ability, targets_: Array[BattleUnit], score_: float) -> void:
	ability = ability_
	targets = targets_
	score = score_
