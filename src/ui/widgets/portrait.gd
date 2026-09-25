class_name Portrait
extends Control
## Circular hero portrait (rendered live from the 3D model by the Portraits service)
## with a coloured ring. Children are clipped to the circle.

var _clip: Panel
var _tex: TextureRect
var _ring: Panel
var _ring_color := UiKit.GOLD
var _dim := false


func setup(texture: Texture2D, size_px := 64.0, ring := UiKit.GOLD, background := Color("9fc9e8")) -> Portrait:
	custom_minimum_size = Vector2(size_px, size_px)
	mouse_filter = Control.MOUSE_FILTER_PASS
	_ring_color = ring
	_clip = Panel.new()
	_clip.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_clip.add_theme_stylebox_override("panel", UiKit.style(background, Color(0, 0, 0, 0), int(size_px), 0, 0, 0))
	_clip.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_clip)
	_tex = TextureRect.new()
	_tex.texture = texture
	_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_clip.add_child(_tex)
	_ring = Panel.new()
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_ring)
	_restyle_ring(size_px)
	return self


func set_dimmed(v: bool) -> void:
	if v == _dim:
		return
	_dim = v
	_tex.modulate = Color(0.35, 0.35, 0.4) if v else Color.WHITE


func _restyle_ring(size_px: float) -> void:
	var s := UiKit.style(Color(0, 0, 0, 0), _ring_color, int(size_px), maxi(3, int(size_px / 18.0)), 0, 0)
	_ring.add_theme_stylebox_override("panel", s)
