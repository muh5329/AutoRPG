class_name QuestState
extends RefCounted
## Runtime progress of one accepted quest.

enum Status { ACTIVE, READY_TO_TURN_IN, COMPLETED }

var quest: Quest
var status: Status = Status.ACTIVE
var progress: Array[int] = []


func _init(quest_: Quest) -> void:
	quest = quest_
	for o in quest.objectives:
		progress.append(0)


## Returns true when anything changed.
func handle(event: GameEvent) -> bool:
	if status != Status.ACTIVE:
		return false
	var changed := false
	for i in quest.objectives.size():
		var updated := quest.objectives[i].advance(event, progress[i])
		if updated != progress[i]:
			progress[i] = updated
			changed = true
	if all_objectives_done():
		status = Status.READY_TO_TURN_IN
		changed = true
	return changed


func all_objectives_done() -> bool:
	for i in quest.objectives.size():
		if progress[i] < quest.objectives[i].required:
			return false
	return true


func is_objective_done(i: int) -> bool:
	return progress[i] >= quest.objectives[i].required


func objective_text(i: int) -> String:
	var o := quest.objectives[i]
	if o.required > 1:
		return "%s (%d/%d)" % [o.description, progress[i], o.required]
	return o.description
