extends Control
## Studio / engine splash, then hands over to the title screen. Any key skips.

var _done := false


func _ready() -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("141226")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var col := UiKit.vbox(10)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(col)
	var logo_holder := CenterContainer.new()
	var logo := UiKit.icon(&"gem", Color("f6c65b"), 140)
	logo_holder.add_child(logo)
	col.add_child(logo_holder)
	var title := UiKit.outlined(UiKit.title("RPG AUTO BATTLER", 64, Color("fff3d1")), Color(0.3, 0.15, 0.05), 10)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var sub := UiKit.label("working title  ·  first iteration", 20, Color(1, 1, 1, 0.6))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(sub)
	var made := UiKit.label("Made with Godot Engine", 16, Color(1, 1, 1, 0.45))
	made.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(made)
	col.modulate.a = 0.0
	logo.pivot_offset = Vector2(70, 70)
	logo.scale = Vector2(0.6, 0.6)
	var t := create_tween()
	t.tween_property(col, "modulate:a", 1.0, 0.8)
	t.parallel().tween_property(logo, "scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_interval(1.4)
	t.tween_property(col, "modulate:a", 0.0, 0.6)
	t.tween_callback(_finish)


func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
		_finish()


func _finish() -> void:
	if _done:
		return
	_done = true
	SceneRouter.go_to_title()
