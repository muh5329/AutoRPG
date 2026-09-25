class_name ToastStack
extends VBoxContainer
## Transient notifications (quest updates, loot, level ups) stacked at the top.

const KIND_COLORS := {
	&"info": Color("45558f"),
	&"quest": Color("c98a1e"),
	&"reward": Color("3f9e5a"),
	&"warning": Color("c0504d"),
	&"level": Color("8e6bd6"),
}
const KIND_GLYPH := {
	&"info": &"dot", &"quest": &"book", &"reward": &"star", &"warning": &"cross", &"level": &"up",
}
const MAX_TOASTS := 5


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", 6)
	alignment = BoxContainer.ALIGNMENT_BEGIN
	custom_minimum_size.x = 420
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE, 18)
	offset_top += 340
	offset_bottom += 340


func push(text: String, kind: StringName) -> void:
	var color: Color = KIND_COLORS.get(kind, KIND_COLORS[&"info"])
	var p := UiKit.panel(Color(color, 0.92), Color(1, 1, 1, 0.5), 18, 2, 8)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var row := UiKit.hbox(8)
	row.add_child(UiKit.icon(KIND_GLYPH.get(kind, &"dot"), Color("fff3d1"), 22))
	row.add_child(UiKit.label(text, 18, Color.WHITE, 600))
	p.add_child(row)
	add_child(p)
	while get_child_count() > MAX_TOASTS:
		get_child(0).queue_free()
		remove_child(get_child(0))
	p.modulate.a = 0.0
	var t := p.create_tween()
	t.tween_property(p, "modulate:a", 1.0, 0.2)
	t.tween_interval(2.8)
	t.tween_property(p, "modulate:a", 0.0, 0.5)
	t.tween_callback(p.queue_free)
