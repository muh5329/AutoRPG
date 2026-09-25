class_name DialogueBox
extends Control
## Bottom-screen conversation panel with speaker name, portrait, typewriter text
## and choice buttons. Advancing: click / E / Space.

signal finished

const CHARS_PER_SECOND := 70.0

var _dialogue: Dialogue
var _page := 0
var _panel: PanelContainer
var _speaker: Label
var _text: Label
var _options: VBoxContainer
var _continue_hint: Label
var _portrait_holder: Control
var _typing := false
var _type_tween: Tween


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(1000, 0)
	add_child(_panel)
	var row := UiKit.hbox(16)
	_panel.add_child(row)
	_portrait_holder = Control.new()
	_portrait_holder.custom_minimum_size = Vector2(110, 110)
	row.add_child(_portrait_holder)
	var col := UiKit.vbox(8)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(col)
	var name_tag := UiKit.panel(UiKit.NAVY, UiKit.GOLD, 10, 2, 6)
	name_tag.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_speaker = UiKit.label("", 20, UiKit.CREAM_TEXT, 650)
	name_tag.add_child(_speaker)
	col.add_child(name_tag)
	_text = UiKit.wrap(UiKit.label("", 21, UiKit.INK))
	_text.custom_minimum_size = Vector2(760, 60)
	col.add_child(_text)
	_options = UiKit.vbox(6)
	col.add_child(_options)
	_continue_hint = UiKit.label("Click or press E to continue", 14, UiKit.INK_SOFT)
	_continue_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	col.add_child(_continue_hint)
	_panel.gui_input.connect(_on_panel_input)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 24)


func is_open() -> bool:
	return visible


func open(dialogue: Dialogue, portrait: Texture2D = null) -> void:
	_dialogue = dialogue
	_page = 0
	visible = true
	_speaker.text = dialogue.speaker
	UiKit.clear(_portrait_holder)
	_portrait_holder.visible = portrait != null
	if portrait:
		_portrait_holder.add_child(Portrait.new().setup(portrait, 110, UiKit.GOLD))
	_show_page()
	_panel.modulate.a = 0.0
	create_tween().tween_property(_panel, "modulate:a", 1.0, 0.15)


func close() -> void:
	visible = false
	_dialogue = null
	finished.emit()


func _show_page() -> void:
	UiKit.clear(_options)
	_text.text = _dialogue.pages[_page] if _page < _dialogue.pages.size() else ""
	_text.visible_ratio = 0.0
	_typing = true
	var dur := _text.text.length() / CHARS_PER_SECOND
	_type_tween = create_tween()
	_type_tween.tween_property(_text, "visible_ratio", 1.0, dur)
	_type_tween.tween_callback(_on_typed)
	_continue_hint.visible = false


func _on_typed() -> void:
	_typing = false
	var last := _page >= _dialogue.pages.size() - 1
	_continue_hint.visible = not last or _dialogue.options.is_empty()
	if last:
		for opt in _dialogue.options:
			var b := UiKit.button(opt.label, _choose.bind(opt), "" if opt.highlighted else "SecondaryButton")
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			_options.add_child(b)
		if _options.get_child_count() > 0:
			(_options.get_child(0) as Button).grab_focus.call_deferred()


func advance() -> void:
	if _dialogue == null:
		return
	if _typing:
		if _type_tween:
			_type_tween.kill()
		_text.visible_ratio = 1.0
		_typing = false
		_on_typed()
		return
	if _page < _dialogue.pages.size() - 1:
		_page += 1
		_show_page()
	elif _dialogue.options.is_empty():
		close()


func _choose(opt: Dialogue.Option) -> void:
	close()
	if opt.action.is_valid():
		opt.action.call()


func _on_panel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"interact") and (_typing or _options.get_child_count() == 0):
		advance()
		get_viewport().set_input_as_handled()
