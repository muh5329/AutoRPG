class_name ItemSlot
extends PanelContainer
## Square item tile: rarity border, glyph and stack count. Emits pressed when clicked.

signal pressed

var item: Item
var quantity := 1
var selected := false:
	set(v):
		selected = v
		_restyle()


func setup(item_: Item, quantity_ := 1, size_px := 72.0) -> ItemSlot:
	item = item_
	quantity = quantity_
	custom_minimum_size = Vector2(size_px, size_px)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = "%s\n%s\n%s" % [item.display_name, item.get_category(), item.get_tooltip()]
	var holder := Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(holder)
	var g := UiKit.icon(UiKit.item_glyph(item), item.icon_color, size_px - 22)
	g.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	holder.add_child(g)
	if quantity > 1:
		var q := UiKit.outlined(UiKit.label("x%d" % quantity, 16, Color.WHITE, 650), Color(0.1, 0.07, 0.15), 6)
		q.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
		q.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		q.grow_vertical = Control.GROW_DIRECTION_BEGIN
		holder.add_child(q)
	_restyle()
	return self


func _restyle() -> void:
	if item == null:
		return
	var s := UiKit.style(Color("fff8ea") if not selected else Color("fff0c2"), item.get_rarity_color() if not selected else UiKit.GOLD_DARK, 12, 3 if not selected else 4, 0, 6)
	add_theme_stylebox_override("panel", s)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit()
		accept_event()
