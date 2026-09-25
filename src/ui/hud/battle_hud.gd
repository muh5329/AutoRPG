class_name BattleHud
extends Control
## In-battle overlay: floating unit plates, hero cards along the bottom,
## encounter banner, speed toggle and the announcement line.

var director: BattleDirector
var _plates: Control
var _cards: HBoxContainer
var _speed_btn: Button
var _message: Label
var _banner: Label
var _timer: Label
var _card_refs: Array = []   # [{unit, hp, action, last, portrait}]


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plates = Control.new()
	_plates.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_plates.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_plates)
	var top := UiKit.vbox(2)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner = UiKit.outlined(UiKit.title("", 30, Color("fff3d1")), Color(0.15, 0.1, 0.25), 10)
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top.add_child(_banner)
	_timer = UiKit.outlined(UiKit.label("", 16, Color.WHITE), Color(0.15, 0.1, 0.25), 5)
	_timer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top.add_child(_timer)
	top.custom_minimum_size.x = 800
	add_child(top)
	top.grow_horizontal = Control.GROW_DIRECTION_BOTH
	top.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 16)
	_message = UiKit.outlined(UiKit.title("", 26, Color("ffe38a")), Color(0.15, 0.1, 0.25), 9)
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.custom_minimum_size.x = 900
	add_child(_message)
	_message.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_message.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 96)
	_speed_btn = UiKit.button("Speed x1", _cycle_speed, "NavyButton", 150)
	_speed_btn.tooltip_text = "Battle speed (Tab)"
	add_child(_speed_btn)
	_speed_btn.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_speed_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 18)
	var auto := UiKit.panel(UiKit.TEAL, Color.WHITE, 12, 2, 6)
	auto.add_child(UiKit.label("AUTO", 16, Color.WHITE, 650))
	auto.tooltip_text = "Heroes decide their own actions using your ability priorities."
	add_child(auto)
	auto.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	auto.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 18)
	auto.offset_right -= 170
	auto.offset_left -= 170
	_cards = UiKit.hbox(10)
	add_child(_cards)


func bind(director_: BattleDirector) -> void:
	director = director_
	var def := director.get_encounter_definition()
	_banner.text = ("BOSS — " if def.is_boss else "") + def.display_name
	_message.text = ""
	director.battle.message.connect(_show_message)
	director.speed_changed.connect(func(_m: float) -> void: _update_speed_label())
	_update_speed_label()
	UiKit.clear(_plates)
	for v in director.views():
		var plate := UnitPlate.new().setup(v)
		_plates.add_child(plate)
	_build_cards()


func unbind() -> void:
	UiKit.clear(_plates)
	UiKit.clear(_cards)
	_card_refs.clear()
	director = null


func _unhandled_input(event: InputEvent) -> void:
	if visible and director and event.is_action_pressed(&"battle_speed"):
		_cycle_speed()
		get_viewport().set_input_as_handled()


func _cycle_speed() -> void:
	if director:
		director.cycle_speed()


func _update_speed_label() -> void:
	_speed_btn.text = "Speed x%d" % roundi(director.speed())


func _show_message(text: String) -> void:
	_message.text = text
	_message.modulate.a = 1.0
	var t := create_tween()
	t.tween_interval(1.4)
	t.tween_property(_message, "modulate:a", 0.0, 0.5)


func _build_cards() -> void:
	UiKit.clear(_cards)
	_card_refs.clear()
	for u in director.battle.heroes:
		var hero := u.combatant as Hero
		var card := UiKit.panel(Color(0.12, 0.1, 0.22, 0.82), hero.get_hero_class().color, 16, 2, 8)
		card.custom_minimum_size.x = 230
		var row := UiKit.hbox(8)
		card.add_child(row)
		var p := Portrait.new().setup(Portraits.for_hero(hero), 58, hero.get_hero_class().color)
		row.add_child(p)
		var v := UiKit.vbox(3)
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v.add_child(UiKit.label(hero.display_name.split(" ")[0], 16, Color.WHITE, 650))
		var hp := UiKit.bar(UiKit.GREEN, 15, 0, true)
		hp.set_value(hero.current_hp, hero.get_max_hp(), true)
		v.add_child(hp)
		var action := UiKit.bar(Color("6fd3ff"), 7)
		v.add_child(action)
		var last := UiKit.label("Ready...", 13, Color(1, 1, 1, 0.7))
		v.add_child(last)
		row.add_child(v)
		_cards.add_child(card)
		_card_refs.append({ "unit": u, "hp": hp, "action": action, "last": last, "portrait": p })
	_cards.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_cards.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_cards.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 16)


func _process(_delta: float) -> void:
	if director == null or director.battle == null:
		return
	_timer.text = "%d:%02d" % [int(director.battle.elapsed) / 60, int(director.battle.elapsed) % 60]
	for ref in _card_refs:
		var u: BattleUnit = ref.unit
		(ref.hp as Bar).set_value(u.combatant.current_hp, u.get_stats().max_hp)
		(ref.action as Bar).set_ratio(u.cast_progress() if u.is_casting() else u.action_progress(), true)
		(ref.portrait as Portrait).set_dimmed(not u.is_alive())
		var l: Label = ref.last
		if not u.is_alive():
			l.text = "Fallen"
		elif u.is_casting():
			l.text = "Casting %s" % u.cast_ability.display_name
		elif u.is_stunned():
			l.text = "Stunned!"
		elif u.last_ability:
			l.text = u.last_ability.display_name
