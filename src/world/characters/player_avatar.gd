class_name PlayerAvatar
extends Character
## The Wayfarer: the character the player steers (keyboard or click-to-move).
## Not a combatant itself — like AFK Journey, the heroes behind do the fighting.

signal moved(position: Vector3)

const CLICK_PICK_RADIUS_PX := 48.0

var focused: WorldEntity
var _click_target: Vector3
var _has_click_target := false
var _pending_interaction: WorldEntity


func _ready() -> void:
	display_name = "Wayfarer"
	move_speed = 5.6
	super()


func _get_appearance() -> Appearance:
	return Appearance.humanoid(Appearance.Outfit.WAYFARER, Appearance.Headgear.HAIR_SHORT, Appearance.Prop.LANTERN,
		Color("2f9e9a"), Color("f2c45a"), Color("f2c9a0"), Color("4a3226"))


func _physics_process(delta: float) -> void:
	if not GameState.is_exploring():
		stop()
		_has_click_target = false
		return
	var input := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	var moved_now := false
	if input.length_squared() > 0.01:
		_has_click_target = false
		_pending_interaction = null
		moved_now = move_with_velocity(Vector3(input.x, 0, input.y) * move_speed, delta)
	elif _has_click_target:
		var stop_dist := _pending_interaction.get_interaction_radius() * 0.7 if _pending_interaction else 0.15
		if walk_towards(_click_target, delta, stop_dist):
			_has_click_target = false
			if _pending_interaction and _pending_interaction.can_interact():
				_pending_interaction.interact(self)
			_pending_interaction = null
		else:
			moved_now = true
	else:
		stop()
	if moved_now:
		moved.emit(global_position)
	_update_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not GameState.is_exploring():
		return
	if event.is_action_pressed(&"interact") and focused and focused.can_interact():
		get_viewport().set_input_as_handled()
		stop()
		focused.interact(self)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(event.position)


func _handle_click(screen_pos: Vector2) -> void:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	# Clicking near an interactable walks to it and interacts.
	var best: WorldEntity = null
	var best_d := CLICK_PICK_RADIUS_PX
	for node in get_tree().get_nodes_in_group(WorldEntity.INTERACTABLE_GROUP):
		var e := node as WorldEntity
		if not e.can_interact() or cam.is_position_behind(e.global_position):
			continue
		var sp := cam.unproject_position(e.global_position + Vector3.UP * 0.9)
		var d := sp.distance_to(screen_pos)
		if d < best_d:
			best_d = d
			best = e
	if best:
		_pending_interaction = best
		_click_target = best.global_position
		_has_click_target = true
		return
	var origin := cam.project_ray_origin(screen_pos)
	var dir := cam.project_ray_normal(screen_pos)
	if absf(dir.y) < 0.001:
		return
	var t := -origin.y / dir.y
	if t > 0.0:
		_pending_interaction = null
		_click_target = origin + dir * t
		_has_click_target = true


func _update_focus() -> void:
	var best: WorldEntity = null
	var best_d := INF
	for node in get_tree().get_nodes_in_group(WorldEntity.INTERACTABLE_GROUP):
		var e := node as WorldEntity
		if not e.can_interact():
			continue
		var d := e.global_position.distance_to(global_position)
		if d <= e.get_interaction_radius() and d < best_d:
			best_d = d
			best = e
	if best != focused:
		focused = best
		EventBus.interaction_target_changed.emit(focused)


## Used by the zone to place the player (spawns, pushed back from fights).
func teleport(pos: Vector3, facing_deg := NAN) -> void:
	global_position = pos
	_has_click_target = false
	if not is_nan(facing_deg):
		rotation_degrees.y = facing_deg
		_facing = rotation.y
	moved.emit(global_position)
