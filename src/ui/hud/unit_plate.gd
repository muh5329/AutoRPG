class_name UnitPlate
extends Control
## Floating bars over a combatant: HP, action (cooldown) bar beneath it, and a
## cast bar with the spell name while channelling. Follows its view on screen.

const WIDTH := 96.0

var view: CombatUnitView
var _name: Label
var _hp: Bar
var _action: Bar
var _cast_box: VBoxContainer
var _cast_bar: Bar
var _cast_label: Label
var _statuses: HBoxContainer
var _skill: Label
var _skill_tween: Tween


func setup(view_: CombatUnitView) -> UnitPlate:
	view = view_
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hero := view.unit.team == CombatTypes.Team.HEROES
	var box := UiKit.vbox(2)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.custom_minimum_size.x = WIDTH
	add_child(box)
	_cast_box = UiKit.vbox(0)
	_cast_label = UiKit.outlined(UiKit.label("", 13, Color("ffe38a"), 650), Color(0.1, 0.07, 0.15), 5)
	_cast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cast_box.add_child(_cast_label)
	_cast_bar = UiKit.bar(Color("ffcf5a"), 8, WIDTH)
	_cast_box.add_child(_cast_bar)
	_cast_box.visible = false
	box.add_child(_cast_box)
	_skill = UiKit.outlined(UiKit.label("", 15, Color("fff3d1"), 650), Color(0.1, 0.07, 0.15), 6)
	_skill.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_skill.modulate.a = 0.0
	box.add_child(_skill)
	view.unit.acted.connect(_on_acted)
	_name = UiKit.outlined(UiKit.label(view.unit.get_name().split(" ")[0] if hero else view.unit.get_name(), 13,
		Color.WHITE if hero else Color("ffb4a8"), 650), Color(0.1, 0.07, 0.15), 5)
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_name)
	_hp = UiKit.bar(UiKit.GREEN if hero else Color("e0584a"), 12, WIDTH)
	box.add_child(_hp)
	_action = UiKit.bar(Color("6fd3ff") if hero else Color("ffa24a"), 6, WIDTH)
	_action.back_color = Color(0.1, 0.08, 0.16, 0.5)
	box.add_child(_action)
	_statuses = UiKit.hbox(2)
	_statuses.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(_statuses)
	_hp.set_value(view.unit.combatant.current_hp, view.unit.get_stats().max_hp, true)
	return self


func _process(_delta: float) -> void:
	if not is_instance_valid(view):
		queue_free()
		return
	var cam := view.get_viewport().get_camera_3d()
	var anchor := view.get_bar_anchor()
	if cam == null or cam.is_position_behind(anchor):
		visible = false
		return
	var u := view.unit
	visible = true
	var p := cam.unproject_position(anchor)
	position = p - Vector2(WIDTH * 0.5, 84)
	_hp.set_value(u.combatant.current_hp, u.get_stats().max_hp)
	if not u.is_alive():
		modulate.a = move_toward(modulate.a, 0.0, _delta * 2.0)
		return
	_action.set_ratio(u.cast_progress() if u.is_casting() else u.action_progress(), true)
	_cast_box.visible = u.is_casting()
	if u.is_casting():
		_cast_label.text = u.cast_ability.display_name + ("" if u.cast_ability.interruptible else " (!)")
		_cast_bar.fill_color = Color("ffcf5a") if u.cast_ability.interruptible else Color("c9c3d6")
		_cast_bar.set_ratio(u.cast_progress(), true)
	_sync_statuses(u)


func _on_acted(ability: Ability, _targets: Array[BattleUnit]) -> void:
	if ability == view.unit.combatant.get_basic_attack():
		return
	_skill.text = ability.display_name
	_skill.add_theme_color_override("font_color", ability.fx_color.lerp(Color.WHITE, 0.45))
	if _skill_tween:
		_skill_tween.kill()
	_skill.modulate.a = 1.0
	_skill_tween = create_tween()
	_skill_tween.tween_interval(0.9)
	_skill_tween.tween_property(_skill, "modulate:a", 0.0, 0.4)


func _sync_statuses(u: BattleUnit) -> void:
	if _statuses.get_child_count() == u.statuses.size():
		return
	UiKit.clear(_statuses)
	for st in u.statuses:
		var chip := ColorRect.new()
		chip.color = st.color
		chip.custom_minimum_size = Vector2(12, 12)
		chip.tooltip_text = st.display_name
		_statuses.add_child(chip)
