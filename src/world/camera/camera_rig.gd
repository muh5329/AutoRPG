class_name CameraRig
extends Node3D
## Smooth AFK-style high-angle follow camera with scroll zoom and a battle framing mode.

@export var offset := Vector3(0, 11.5, 9.6)
@export var fov := 36.0
@export var follow_speed := 6.0
@export var min_zoom := 0.55
@export var max_zoom := 1.35

var camera: Camera3D
var target: Node3D
var zoom := 1.0

var _focus: Vector3
var _override_active := false
var _override_point: Vector3
var _override_zoom := 1.0


func _ready() -> void:
	camera = Camera3D.new()
	camera.fov = fov
	camera.current = true
	add_child(camera)


func follow(node: Node3D) -> void:
	target = node
	snap()


func snap() -> void:
	_focus = _desired_point()
	_apply(1.0)


func frame_point(point: Vector3, zoom_factor: float) -> void:
	_override_active = true
	_override_point = point
	_override_zoom = zoom_factor


func release() -> void:
	_override_active = false


func _process(delta: float) -> void:
	var w := clampf(follow_speed * delta, 0.0, 1.0)
	_focus = _focus.lerp(_desired_point(), w)
	_apply(w)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = clampf(zoom - 0.08, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = clampf(zoom + 0.08, min_zoom, max_zoom)


var _current_zoom := 1.0


func _apply(weight: float) -> void:
	var z := _override_zoom if _override_active else zoom
	_current_zoom = lerpf(_current_zoom, z, weight)
	camera.global_position = _focus + offset * _current_zoom
	camera.look_at(_focus + Vector3(0, 0.6, 0), Vector3.UP)


func _desired_point() -> Vector3:
	if _override_active:
		return _override_point
	return target.global_position if target else Vector3.ZERO
