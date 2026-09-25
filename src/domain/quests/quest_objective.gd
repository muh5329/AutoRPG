class_name QuestObjective
extends Resource
## Abstract quest step. Subclasses decide how a GameEvent advances progress.

@export var description: String
@export var required: int = 1


## Returns the new progress value after `event` (unchanged if unrelated).
func advance(event: GameEvent, progress: int) -> int:
	if _matches(event):
		return mini(progress + event.amount, required)
	return progress


func _matches(_event: GameEvent) -> bool:
	return false
