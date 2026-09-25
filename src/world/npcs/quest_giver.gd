class_name QuestGiver
extends FriendlyNPC
## Offers a chain of quests and takes them back when complete.
## Shows a floating "!" (quest available) or "?" (ready to turn in).

@export var quest_ids: Array[StringName] = []

var _marker: Label3D
var _marker_time: float = 0.0


func _ready() -> void:
	super()
	_marker = NPC._make_label("!", 200, Color("ffd23f"))
	_marker.outline_size = 36
	_marker.pixel_size = 0.00028
	_marker.position.y = model.get_height() + 1.35
	add_child(_marker)
	var quests := GameState.quest_log
	quests.quest_accepted.connect(_refresh_marker.unbind(1))
	quests.quest_updated.connect(_refresh_marker.unbind(1))
	quests.quest_completed.connect(_refresh_marker.unbind(1))
	_refresh_marker()


func _process(delta: float) -> void:
	_marker_time += delta
	_marker.position.y = model.get_height() + 1.35 + sin(_marker_time * 3.0) * 0.1


func get_interaction_verb() -> String:
	return "Talk to"


# --- quest state queries -------------------------------------------------------------

func _quests() -> Array[Quest]:
	var out: Array[Quest] = []
	for id in quest_ids:
		out.append(Content.quest(id))
	return out


func _ready_to_turn_in() -> Quest:
	for q in _quests():
		var s := GameState.quest_log.get_state(q.id)
		if s and s.status == QuestState.Status.READY_TO_TURN_IN:
			return q
	return null


func _offerable() -> Quest:
	for q in _quests():
		if GameState.quest_log.can_offer(q):
			return q
	return null


func _in_progress() -> Quest:
	for q in _quests():
		var s := GameState.quest_log.get_state(q.id)
		if s and s.status == QuestState.Status.ACTIVE:
			return q
	return null


func _refresh_marker() -> void:
	if not is_instance_valid(_marker):
		return
	if _ready_to_turn_in():
		_marker.text = "?"
		_marker.modulate = Color("ffd23f")
		_marker.visible = true
	elif _offerable():
		_marker.text = "!"
		_marker.modulate = Color("ffd23f")
		_marker.visible = true
	elif _in_progress():
		_marker.text = "?"
		_marker.modulate = Color(0.85, 0.85, 0.9, 0.8)
		_marker.visible = true
	else:
		_marker.visible = false


# --- dialogue ---------------------------------------------------------------------------

func _greeting_pages() -> PackedStringArray:
	var ready_quest := _ready_to_turn_in()
	if ready_quest:
		return PackedStringArray([ready_quest.complete_text])
	var active := _in_progress()
	if active and _offerable() == null:
		return PackedStringArray([active.in_progress_text])
	return greeting


func _add_options(d: Dialogue) -> void:
	var ready_quest := _ready_to_turn_in()
	if ready_quest:
		d.add_option("Complete: %s" % ready_quest.title, func() -> void: _turn_in(ready_quest), true)
		return
	var offer := _offerable()
	if offer:
		d.add_option("Quest: %s" % offer.title, func() -> void: _present_offer(offer), true)


func _present_offer(quest: Quest) -> void:
	var d := Dialogue.new(display_name, [quest.offer_text])
	d.appearance = appearance
	var accept := func() -> void:
		GameState.accept_quest(quest)
		turn_back_home()
	d.add_option("Accept (%s)" % quest.describe_rewards(), accept, true)
	d.add_option("Not now", turn_back_home)
	EventBus.dialogue_requested.emit(d)


func _turn_in(quest: Quest) -> void:
	GameState.turn_in_quest(quest)
	# Chain straight into the next quest if there is one.
	var next := _offerable()
	if next:
		_present_offer(next)
	else:
		turn_back_home()
