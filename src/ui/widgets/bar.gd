class_name Bar
extends Control
## Rounded progress bar with smooth animation and a trailing "damage ghost".

@export var fill_color := Color("5cc46a")
@export var back_color := Color(0.1, 0.08, 0.16, 0.65)
@export var ghost_color := Color(1.0, 0.95, 0.8, 0.8)
@export var show_text := false
@export var text_format := "%d / %d"

var ratio := 1.0
var _shown := 1.0
var _ghost := 1.0
var _value := 0.0
var _max := 0.0
var _initialized := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_value(value: float, maximum: float, instant := false) -> void:
	_value = value
	_max = maximum
	ratio = clampf(value / maxf(maximum, 0.0001), 0.0, 1.0)
	if instant or not _initialized:
		_shown = ratio
		_ghost = ratio
		_initialized = true
	queue_redraw()


func set_ratio(r: float, instant := false) -> void:
	set_value(r, 1.0, instant)


func _process(delta: float) -> void:
	var changed := false
	if not is_equal_approx(_shown, ratio):
		_shown = move_toward(_shown, ratio, delta * 2.5) if ratio < _shown else lerpf(_shown, ratio, clampf(delta * 10.0, 0, 1))
		changed = true
	if _ghost > _shown:
		_ghost = move_toward(_ghost, _shown, delta * 0.9)
		changed = true
	elif _ghost < _shown:
		_ghost = _shown
	if changed:
		queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var radius := int(size.y * 0.5)
	draw_style_box(_box(back_color, radius), r)
	var inset := Rect2(r.position + Vector2(2, 2), r.size - Vector2(4, 4))
	if _ghost > _shown:
		draw_style_box(_box(ghost_color, radius - 2), Rect2(inset.position, Vector2(inset.size.x * _ghost, inset.size.y)))
	if _shown > 0.001:
		var w := maxf(inset.size.x * _shown, inset.size.y)
		draw_style_box(_box(fill_color, radius - 2), Rect2(inset.position, Vector2(w, inset.size.y)))
		# glossy highlight
		draw_style_box(_box(Color(1, 1, 1, 0.22), radius - 2),
			Rect2(inset.position + Vector2(2, 1), Vector2(maxf(w - 4, 0), inset.size.y * 0.38)))
	if show_text and size.y >= 14:
		var f := UiKit.font(600)
		var fs := int(size.y * 0.72)
		var text := text_format % [roundi(_value), roundi(_max)]
		var tw := f.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
		var pos := Vector2((size.x - tw.x) * 0.5, (size.y + fs * 0.72) * 0.5)
		draw_string_outline(f, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, Color(0.1, 0.07, 0.15))
		draw_string(f, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)


static func _box(color: Color, radius: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(maxi(radius, 0))
	s.anti_aliasing = true
	return s
