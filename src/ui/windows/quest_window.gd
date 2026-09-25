class_name QuestWindow
extends UiWindow
## Quest journal: active and completed quests with objectives and rewards.

var _list: VBoxContainer
var _detail: VBoxContainer
var _selected: QuestState


func _init() -> void:
	window_title = "Quests"
	window_size = Vector2(1000, 620)


func _build(b: VBoxContainer) -> void:
	var cols := UiKit.hbox(16)
	cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	b.add_child(cols)
	_list = UiKit.vbox(8)
	var list_scroll := UiKit.scroll(_list, 480)
	list_scroll.custom_minimum_size.x = 340
	list_scroll.size_flags_horizontal = Control.SIZE_FILL
	cols.add_child(list_scroll)
	var dp := UiKit.panel(Color("fff8ea"), UiKit.BORDER, 14, 2, 18)
	dp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail = UiKit.vbox(10)
	dp.add_child(_detail)
	cols.add_child(dp)
	var states := GameState.quest_log.active_states()
	if not states.is_empty():
		_selected = states[0]


func refresh() -> void:
	UiKit.clear(_list)
	var active := GameState.quest_log.active_states()
	var done := GameState.quest_log.states().filter(func(s: QuestState) -> bool: return s.status == QuestState.Status.COMPLETED)
	_list.add_child(UiKit.label("Active", 18, UiKit.INK_SOFT, 650))
	if active.is_empty():
		_list.add_child(UiKit.wrap(UiKit.label("No active quests. Look for villagers marked with a golden !", 15, UiKit.INK_SOFT)))
	for s in active:
		_list.add_child(_entry(s))
	if not done.is_empty():
		_list.add_child(UiKit.label("Completed", 18, UiKit.INK_SOFT, 650))
		for s in done:
			_list.add_child(_entry(s))
	_build_detail()


func _entry(s: QuestState) -> Control:
	var sel := s == _selected
	var card := UiKit.panel(Color("fff0c2") if sel else Color("fff8ea"), UiKit.GOLD_DARK if sel else UiKit.BORDER, 12, 2, 10)
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			_selected = s
			refresh.call_deferred())
	var row := UiKit.hbox(8)
	card.add_child(row)
	var glyph := &"check" if s.status == QuestState.Status.COMPLETED else (&"star" if s.quest.is_main_story else &"book")
	row.add_child(UiKit.icon(glyph, UiKit.GOLD if s.quest.is_main_story else UiKit.TEAL, 26))
	var v := UiKit.vbox(0)
	v.add_child(UiKit.label(s.quest.title, 18, UiKit.INK, 650))
	var status := "Main Story" if s.quest.is_main_story else "Side Quest"
	if s.status == QuestState.Status.READY_TO_TURN_IN:
		status = "Ready to turn in!"
	v.add_child(UiKit.label(status, 13, UiKit.GOLD_DARK if s.status == QuestState.Status.READY_TO_TURN_IN else UiKit.INK_SOFT, 600))
	row.add_child(v)
	return card


func _build_detail() -> void:
	UiKit.clear(_detail)
	if _selected == null:
		_detail.add_child(UiKit.label("Select a quest.", 18, UiKit.INK_SOFT))
		return
	var q := _selected.quest
	_detail.add_child(UiKit.title(q.title, 28))
	_detail.add_child(UiKit.label("Given by %s" % q.giver_name, 15, UiKit.INK_SOFT))
	_detail.add_child(UiKit.wrap(UiKit.label(q.description, 17)))
	_detail.add_child(HSeparator.new())
	_detail.add_child(UiKit.label("Objectives", 19, UiKit.INK, 650))
	for i in q.objectives.size():
		var row := UiKit.hbox(8)
		var done := _selected.is_objective_done(i)
		row.add_child(UiKit.icon(&"check" if done else &"dot", UiKit.GREEN if done else UiKit.INK_SOFT, 22))
		row.add_child(UiKit.label(_selected.objective_text(i), 17, UiKit.INK_SOFT if done else UiKit.INK))
		_detail.add_child(row)
	if _selected.status == QuestState.Status.READY_TO_TURN_IN:
		var hint := UiKit.hbox(8)
		hint.add_child(UiKit.icon(&"star", UiKit.GOLD, 22))
		hint.add_child(UiKit.label("Return to %s to claim your reward." % q.giver_name, 17, UiKit.GOLD_DARK, 650))
		_detail.add_child(hint)
	_detail.add_child(HSeparator.new())
	var rw := UiKit.hbox(8)
	rw.add_child(UiKit.label("Rewards:", 17, UiKit.INK, 650))
	rw.add_child(UiKit.icon(&"coin", Color.WHITE, 22))
	rw.add_child(UiKit.label("%d" % q.reward_gold, 17))
	rw.add_child(UiKit.label("·  %d XP" % q.reward_xp, 17))
	for item in q.reward_items:
		rw.add_child(ItemSlot.new().setup(item, 1, 40))
	_detail.add_child(rw)
