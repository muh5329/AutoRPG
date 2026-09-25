class_name Character
extends WorldEntity
## Abstract: any entity with a CharacterModel that can walk around.
## Movement is resolved against the zone's WalkableArea (no physics bodies needed).

@export var move_speed: float = 5.0
@export var turn_speed: float = 12.0

var model: CharacterModel
var _facing: float = 0.0


func _ready() -> void:
	super()
	model = ModelFactory.build(_get_appearance())
	add_child(model)
	_facing = rotation.y


## Concrete characters say what they look like.
func _get_appearance() -> Appearance:
	push_error("Character._get_appearance is abstract")
	return Appearance.new()


## Moves by `velocity * delta` respecting walkable bounds. Returns true if it moved.
func move_with_velocity(velocity: Vector3, delta: float) -> bool:
	velocity.y = 0.0
	if velocity.length_squared() < 0.0001:
		model.set_moving(false)
		return false
	var target := global_position + velocity * delta
	var zone := get_zone()
	if zone:
		target = zone.walkable.resolve(global_position, target)
	var moved := global_position.distance_squared_to(target) > 0.000001
	global_position = target
	face_direction(velocity, delta)
	model.set_moving(moved)
	return moved


## Walks toward a point. Returns true when (nearly) there.
func walk_towards(point: Vector3, delta: float, stop_distance := 0.1, speed := -1.0) -> bool:
	var to := point - global_position
	to.y = 0.0
	var dist := to.length()
	if dist <= stop_distance:
		model.set_moving(false)
		return true
	var spd := move_speed if speed < 0.0 else speed
	move_with_velocity(to / dist * minf(spd, dist / delta), delta)
	return false


func face_direction(direction: Vector3, delta := 1.0) -> void:
	if direction.length_squared() < 0.0001:
		return
	var target_yaw := atan2(-direction.x, -direction.z)
	_facing = lerp_angle(_facing, target_yaw, clampf(turn_speed * delta, 0.0, 1.0))
	rotation.y = _facing


func face_point(point: Vector3) -> void:
	var d := point - global_position
	d.y = 0.0
	if d.length_squared() > 0.0001:
		_facing = atan2(-d.x, -d.z)
		rotation.y = _facing


func stop() -> void:
	model.set_moving(false)
