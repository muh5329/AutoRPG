class_name Hud
extends Control
## Exploration overlay: party frames, gold, quest tracker, menu buttons,
## interaction prompt and the zone title card.

var _party_box: VBoxContainer
var _gold_label: Label
var _zone_label: Label
var _tracker: VBoxContainer
var _prompt: PanelContainer
var _prompt_label: Label
var _title_card: VBoxContainer
var _party_badge: PanelContainer
var _frames: Array = []   # [{hero, bar, portrait}]
var _dirty := true


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_party_frames()
	_build_top_right()
	_build_tracker()
	_build_menu_buttons()
	_build_prompt()
	_build_title_card()
	_build_hint()
	EventBus.interaction_target_changed.connect(_on_focus_changed)


func bind_session() -> void:
	var s := GameState.session
	if not s.party.changed.is_connected(_mark_dirty):
		s.party.changed.connect(_mark_dirty)
		s.quest_log.quest_accepted.connect(_mark_dirty.unbind(1))
		s.quest_log.quest_updated.connect(_mark_dirty.unbind(1))
		s.quest_log.quest_completed.connect(_mark_dirty.unbind(1))
	_dirty = true


func show_zone(zone: Zone) -> void:
	bind_session()
	_zone_label.text = zone.display_name
	_prompt.visible = false
	(_title_card.get_child(0) as Label).text = zone.display_name
	(_title_card.get_child(1) as Label).text = zone.get_subtitle()
	_title_card.modulate.a = 0.0
	var t := create_tween()
	t.tween_interval(0.35)
	t.tween_property(_title_card, "modulate:a", 1.0, 0.5)
	t.tween_interval(2.2)
	t.tween_property(_title_card, "modulate:a", 0.0, 0.8)


func _mark_dirty() -> void:
	_dirty = true


func _process(_delta: float) -> void:
	if not visible or GameState.session == null:
		return
	if _dirty:
		_dirty = false
		_rebuild_party()
		_rebuild_tracker()
	for f in _frames:
		var hero: Hero = f.hero
		(f.bar as Bar).set_value(hero.current_hp, hero.get_max_hp())
		(f.portrait as Portrait).set_dimmed(not hero.is_alive())
	_gold_label.text = "%d" % GameState.wallet.gold
	_party_badge.visible = GameState.party.total_skill_points() > 0
	if _party_badge.visible:
		(_party_badge.get_child(0) as Label).text = "%d" % GameState.party.total_skill_points()


# --- party frames --------------------------------------------------------------------------

func _build_party_frames() -> void:
	_party_box = UiKit.vbox(6)
	_party_box.position = Vector2(18, 18)
	add_child(_party_box)


func _rebuild_party() -> void:
	UiKit.clear(_party_box)
	_frames.clear()
	for hero in GameState.party.members():
		var card := UiKit.panel(Color(0.12, 0.1, 0.22, 0.72), Color(1, 1, 1, 0.15), 30, 1, 5)
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var row := UiKit.hbox(8)
		card.add_child(row)
		var p := Portrait.new().setup(Portraits.for_hero(hero), 48, hero.get_hero_class().color)
		row.add_child(p)
		var v := UiKit.vbox(3)
		var name_row := UiKit.hbox(6)
		name_row.add_child(UiKit.outlined(UiKit.label(hero.display_name.split(" ")[0], 16, Color.WHITE, 650), Color(0.1, 0.07, 0.15), 5))
		name_row.add_child(UiKit.label("Lv%d" % hero.level, 13, Color("ffd97a"), 650))
		v.add_child(name_row)
		var bar := UiKit.bar(UiKit.GREEN, 11, 130)
		bar.set_value(hero.current_hp, hero.get_max_hp(), true)
		v.add_child(bar)
		row.add_child(v)
		_party_box.add_child(card)
		_frames.append({ "hero": hero, "bar": bar, "portrait": p })


# --- top right -------------------------------------------------------------------------------

func _build_top_right() -> void:
	var box := UiKit.vbox(6)
	box.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	box.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 18)
	box.alignment = BoxContainer.ALIGNMENT_END
	add_child(box)
	_zone_label = UiKit.outlined(UiKit.title("", 24, Color.WHITE), Color(0.1, 0.07, 0.15), 8)
	_zone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	box.add_child(_zone_label)
	var gold := UiKit.panel(Color(0.12, 0.1, 0.22, 0.72), UiKit.GOLD, 20, 2, 8)
	gold.size_flags_horizontal = Control.SIZE_SHRINK_END
	var g := UiKit.hbox(6)
	g.add_child(UiKit.icon(&"coin", Color.WHITE, 26))
	_gold_label = UiKit.label("0", 20, Color("ffd97a"), 650)
	_gold_label.custom_minimum_size.x = 60
	_gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	g.add_child(_gold_label)
	gold.add_child(g)
	box.add_child(gold)


# --- quest tracker ----------------------------------------------------------------------------

func _build_tracker() -> void:
	var holder := UiKit.panel(Color(0.12, 0.1, 0.22, 0.6), Color(1, 1, 1, 0.12), 16, 1, 12)
	holder.custom_minimum_size.x = 330
	holder.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	holder.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 18)
	holder.offset_top += 104
	holder.offset_bottom += 104
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(holder)
	_tracker = UiKit.vbox(4)
	holder.add_child(_tracker)


func _rebuild_tracker() -> void:
	UiKit.clear(_tracker)
	var head := UiKit.hbox(6)
	head.add_child(UiKit.icon(&"book", Color("ffd97a"), 22))
	head.add_child(UiKit.label("Quests", 18, Color("ffd97a"), 650))
	head.add_child(UiKit.spacer())
	head.add_child(UiKit.label("[%s]" % Controls.key_label(&"open_quests"), 13, Color(1, 1, 1, 0.6)))
	_tracker.add_child(head)
	var states := GameState.quest_log.active_states()
	if states.is_empty():
		_tracker.add_child(UiKit.wrap(UiKit.label("Talk to villagers with a golden ! to find work.", 14, Color(1, 1, 1, 0.75))))
		return
	for s in states:
		var title := UiKit.outlined(UiKit.label(s.quest.title, 16, Color("ffe6a3") if s.quest.is_main_story else Color.WHITE, 650), Color(0.1, 0.07, 0.15), 4)
		_tracker.add_child(title)
		if s.status == QuestState.Status.READY_TO_TURN_IN:
			var r := UiKit.hbox(6)
			r.add_child(UiKit.icon(&"star", UiKit.GOLD, 16))
			r.add_child(UiKit.label("Return to %s" % s.quest.giver_name, 14, Color("ffd97a"), 600))
			_tracker.add_child(r)
			continue
		for i in s.quest.objectives.size():
			var r := UiKit.hbox(6)
			var done := s.is_objective_done(i)
			r.add_child(UiKit.icon(&"check" if done else &"dot", UiKit.GREEN if done else Color(1, 1, 1, 0.8), 16))
			r.add_child(UiKit.label(s.objective_text(i), 14, Color(1, 1, 1, 0.55) if done else Color.WHITE))
			_tracker.add_child(r)


# --- menu buttons ------------------------------------------------------------------------------

func _build_menu_buttons() -> void:
	var row := UiKit.hbox(10)
	row.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	row.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(row)
	var party := _menu_button(&"party", "Party", &"open_party", func() -> void: UI.toggle_window(&"party"))
	_party_badge = UiKit.panel(UiKit.RED, Color.WHITE, 12, 2, 2)
	_party_badge.add_child(UiKit.label("0", 13, Color.WHITE, 650))
	_party_badge.position = Vector2(52, -6)
	_party_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_party_badge.tooltip_text = "Unspent skill points"
	party.get_child(0).add_child(_party_badge)
	row.add_child(party)
	row.add_child(_menu_button(&"bag", "Bag", &"open_bag", func() -> void: UI.toggle_window(&"bag")))
	row.add_child(_menu_button(&"book", "Quests", &"open_quests", func() -> void: UI.toggle_window(&"quests")))
	row.add_child(_menu_button(&"menu", "Menu", &"cancel", func() -> void: UI.toggle_window(&"pause")))
	row.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 18)


func _menu_button(glyph: StringName, text: String, action: StringName, on_press: Callable) -> Control:
	var v := UiKit.vbox(2)
	var b := UiKit.button("", on_press, "NavyButton")
	b.custom_minimum_size = Vector2(68, 68)
	b.tooltip_text = "%s (%s)" % [text, Controls.key_label(action)]
	var g := UiKit.icon(glyph, Color("ffe6a3"), 38)
	g.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	g.position -= Vector2(19, 19)
	b.add_child(g)
	v.add_child(b)
	var l := UiKit.outlined(UiKit.label("%s [%s]" % [text, Controls.key_label(action)], 13, Color.WHITE, 600), Color(0.1, 0.07, 0.15), 5)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(l)
	return v


# --- prompt / title card / hint -------------------------------------------------------------------

func _build_prompt() -> void:
	_prompt = UiKit.panel(Color(0.12, 0.1, 0.22, 0.85), UiKit.GOLD, 24, 2, 10)
	_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row := UiKit.hbox(8)
	var key := UiKit.panel(UiKit.GOLD, UiKit.GOLD_DARK, 8, 2, 4)
	key.add_child(UiKit.label(" %s " % Controls.key_label(&"interact"), 16, UiKit.INK, 650))
	row.add_child(key)
	_prompt_label = UiKit.label("", 19, Color.WHITE, 600)
	row.add_child(_prompt_label)
	_prompt.add_child(row)
	_prompt.visible = false
	add_child(_prompt)
	_prompt.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_prompt.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 150)


func _on_focus_changed(entity: WorldEntity) -> void:
	_prompt.visible = entity != null
	if entity:
		_prompt_label.text = entity.get_interaction_prompt()
		_prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 150)


func _build_title_card() -> void:
	_title_card = UiKit.vbox(0)
	_title_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var t := UiKit.outlined(UiKit.title("", 52, Color("fff3d1")), Color(0.15, 0.1, 0.25), 12)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_card.add_child(t)
	var s := UiKit.outlined(UiKit.label("", 20, Color.WHITE, 500), Color(0.15, 0.1, 0.25), 7)
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_card.add_child(s)
	_title_card.modulate.a = 0.0
	add_child(_title_card)
	_title_card.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_title_card.custom_minimum_size.x = 900
	_title_card.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 110)


func _build_hint() -> void:
	var l := UiKit.outlined(UiKit.label("WASD / click to move  ·  E interact  ·  wheel zoom", 14, Color(1, 1, 1, 0.8)), Color(0.1, 0.07, 0.15), 5)
	add_child(l)
	l.grow_vertical = Control.GROW_DIRECTION_BEGIN
	l.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, 18)
