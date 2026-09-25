class_name MonsterAvatar
extends Character
## Overworld stand-in for an enemy waiting inside an Encounter.

var definition: MonsterDefinition


func setup(definition_: MonsterDefinition) -> MonsterAvatar:
	definition = definition_
	display_name = definition.display_name
	return self


func _get_appearance() -> Appearance:
	return definition.appearance
