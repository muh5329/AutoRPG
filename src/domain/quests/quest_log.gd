class_name QuestLog
extends RefCounted
## All quests the player has accepted, and the rules for offering new ones.

signal quest_accepted(state: QuestState)
signal quest_updated(state: QuestState)
signal quest_completed(state: QuestState)

var _states: Dictionary = {}   # quest id -> QuestState
## Remembered facts so objectives already satisfied count when accepted (e.g. party size).
var _party_size_hint: int = 0


func get_state(quest_id: StringName) -> QuestState:
	return _states.get(quest_id)


func states() -> Array[QuestState]:
	var out: Array[QuestState] = []
	for s in _states.values():
		out.append(s)
	return out


func active_states() -> Array[QuestState]:
	var out: Array[QuestState] = []
	for s in _states.values():
		if s.status != QuestState.Status.COMPLETED:
			out.append(s)
	return out


func is_completed(quest_id: StringName) -> bool:
	var s := get_state(quest_id)
	return s != null and s.status == QuestState.Status.COMPLETED


func can_offer(quest: Quest) -> bool:
	if _states.has(quest.id):
		return false
	return quest.prerequisite_id == &"" or is_completed(quest.prerequisite_id)


func accept(quest: Quest) -> QuestState:
	assert(can_offer(quest))
	var state := QuestState.new(quest)
	_states[quest.id] = state
	# Retro-apply world facts that are already true.
	state.handle(GameEvent.new(GameEvent.HERO_RECRUITED, &"", _party_size_hint))
	quest_accepted.emit(state)
	return state


func handle(event: GameEvent) -> void:
	if event.type == GameEvent.HERO_RECRUITED:
		_party_size_hint = maxi(_party_size_hint, event.amount)
	for state: QuestState in _states.values():
		if state.handle(event):
			quest_updated.emit(state)


## Marks a ready quest completed. Rewards are granted by the caller (GameState).
func complete(quest_id: StringName) -> bool:
	var s := get_state(quest_id)
	if s == null or s.status != QuestState.Status.READY_TO_TURN_IN:
		return false
	s.status = QuestState.Status.COMPLETED
	quest_completed.emit(s)
	return true
