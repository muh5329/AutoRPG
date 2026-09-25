class_name EncounterDefinition
extends Resource
## A fight: which monsters, and what winning it is worth.

@export var id: StringName
@export var display_name: String
@export var monsters: Array[MonsterDefinition] = []
@export var bonus_gold: int = 0
@export var loot: Array[Item] = []
@export var is_boss: bool = false
## Line the boss shouts before the fight.
@export var intro_line: String


func spawn_monsters() -> Array[Monster]:
	var out: Array[Monster] = []
	for def in monsters:
		out.append(def.spawn())
	return out


func total_xp() -> int:
	var xp := 0
	for m in monsters:
		xp += m.xp_reward
	return xp


func total_gold() -> int:
	var g := bonus_gold
	for m in monsters:
		g += m.gold_reward
	return g
