class_name ClearEncounterObjective
extends QuestObjective
## Win a specific encounter.

@export var encounter_id: StringName


func _matches(event: GameEvent) -> bool:
	return event.type == GameEvent.ENCOUNTER_CLEARED and event.subject == encounter_id
