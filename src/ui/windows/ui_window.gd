class_name UiWindow
extends Control
## Abstract modal window: dimmed backdrop + parchment panel with a navy title ribbon.
## Subclasses implement _build(body) and optionally refresh().

signal closed

var window_title := "Window"
var window_size := Vector2(900, 620)
## Whether opening this window switches the game into WINDOW mode (pauses exploring).
var pauses_exploration := true
## Whether Esc / the X button may close it.
var closable := true

var body: VBoxContainer
var _panel: PanelContainer
var _title_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = UiKit.DIM
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = window_size
	center.add_child(_panel)
	var outer := UiKit.vbox(12)
	_panel.add_child(outer)
	outer.add_child(_make_header())
	body = UiKit.vbox(10)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(body)
	_build(body)
	refresh()
	_animate_in()


func _make_header() -> Control:
	var row := UiKit.hbox(10)
	var ribbon := UiKit.panel(UiKit.NAVY, UiKit.GOLD, 12, 2, 10)
	ribbon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label = UiKit.title(window_title, 28, UiKit.CREAM_TEXT)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ribbon.add_child(_title_label)
	row.add_child(ribbon)
	if closable:
		var x := UiKit.button("", close, "DangerButton")
		x.custom_minimum_size = Vector2(52, 52)
		var g := UiKit.icon(&"cross", Color.WHITE, 26)
		g.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		g.position -= Vector2(13, 13)
		x.add_child(g)
		row.add_child(x)
	return row


## Build static layout once.
func _build(_body: VBoxContainer) -> void:
	pass


## Re-read game state into the widgets.
func refresh() -> void:
	pass


func close() -> void:
	if not closable:
		return
	force_close()


func force_close() -> void:
	closed.emit()
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.12)
	t.tween_callback(queue_free)


func _animate_in() -> void:
	modulate.a = 0.0
	_panel.pivot_offset = window_size * 0.5
	_panel.scale = Vector2(0.92, 0.92)
	var t := create_tween().set_parallel()
	t.tween_property(self, "modulate:a", 1.0, 0.15)
	t.tween_property(_panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
