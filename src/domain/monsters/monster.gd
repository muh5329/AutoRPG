class_name Monster
extends Combatant
## Runtime enemy created from a MonsterDefinition for one encounter.

var definition: MonsterDefinition


func _init(definition_: MonsterDefinition) -> void:
	definition = definition_
	display_name = definition.display_name
	current_hp = get_max_hp()


func get_stats() -> StatBlock:
	return definition.stats


func get_role() -> CombatTypes.Role:
	return definition.role


func get_battle_abilities() -> Array[Ability]:
	return definition.abilities


func get_basic_attack() -> Ability:
	return definition.basic_attack


func get_appearance() -> Appearance:
	return definition.appearance


func create_brain() -> BattleBrain:
	return MonsterBrain.new()
