class_name CharacterModel
extends Node3D
## Abstract procedural low-poly character. Subclasses build geometry under
## `body` in _build(); this base class owns all shared procedural animation
## (idle breathing, walk bounce, lunges, hit flash, death, cast glow).
## Models face -Z (Godot's forward).

const LP := preload("res://src/world/visuals/low_poly.gd")

var appearance: Appearance
## Animated root; every visible part hangs under it.
var body: Node3D
## Where the right-hand prop / projectile origin sits (local to body).
var hand_anchor := Vector3(0.3, 0.8, -0.2)

var _moving := false
var _time := 0.0
var _flash_material: StandardMaterial3D
var _action_tween: Tween
var _dead := false
var _base_scale := 1.0


func setup(appearance_: Appearance) -> CharacterModel:
	appearance = appearance_
	_base_scale = appearance.scale
	body = Node3D.new()
	body.name = "Body"
	add_child(body)
	LP.blob_shadow(self, _shadow_radius() * _base_scale)
	_build()
	body.scale = Vector3.ONE * _base_scale
	_time = randf() * TAU
	_install_flash_overlay()
	return self


# --- abstract ------------------------------------------------------------------------

func _build() -> void:
	push_error("CharacterModel._build is abstract")


func _shadow_radius() -> float:
	return 0.38


## Height of the head top in local space (for name plates / bars).
func get_height() -> float:
	return 1.7 * _base_scale


# --- public animation API ---------------------------------------------------------------

func set_moving(moving: bool) -> void:
	_moving = moving


func get_hand_position() -> Vector3:
	return body.to_global(hand_anchor)


## Dash toward `target_global` and come back (melee), or a short recoil (ranged).
func play_attack(target_global: Vector3, lunge: bool) -> void:
	if _dead:
		return
	_kill_action_tween()
	_action_tween = create_tween()
	var local_target := to_local(target_global)
	local_target.y = 0.0
	if lunge:
		var dist := local_target.length()
		var reach := local_target.normalized() * maxf(dist - 1.1, 0.0)
		_action_tween.tween_property(body, "position", reach, 0.16).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		_action_tween.tween_property(body, "rotation:x", -0.35, 0.06)
		_action_tween.tween_property(body, "rotation:x", 0.0, 0.1)
		_action_tween.tween_interval(0.08)
		_action_tween.tween_property(body, "position", Vector3.ZERO, 0.22).set_ease(Tween.EASE_IN_OUT)
	else:
		var back := -local_target.normalized() * 0.18
		_action_tween.tween_property(body, "position", back, 0.08)
		_action_tween.tween_property(body, "position", Vector3.ZERO, 0.18)


func play_cast_pose() -> void:
	if _dead:
		return
	_kill_action_tween()
	_action_tween = create_tween()
	_action_tween.tween_property(body, "position:y", 0.12, 0.2).set_trans(Tween.TRANS_SINE)
	_action_tween.tween_property(body, "position:y", 0.0, 0.2).set_trans(Tween.TRANS_SINE)


func play_hit() -> void:
	if _dead:
		return
	_flash(Color(1, 1, 1, 0.75))
	var t := create_tween()
	t.tween_property(body, "rotation:z", 0.12, 0.05)
	t.tween_property(body, "rotation:z", -0.08, 0.06)
	t.tween_property(body, "rotation:z", 0.0, 0.08)


func play_heal() -> void:
	_flash(Color(0.6, 1.0, 0.6, 0.55))


func play_death() -> void:
	_dead = true
	_kill_action_tween()
	var t := create_tween().set_parallel()
	t.tween_property(body, "rotation:x", deg_to_rad(80), 0.45).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	t.tween_property(body, "position:y", -0.15, 0.45)
	_flash(Color(0.2, 0.2, 0.3, 0.5), 1.2)


func play_victory() -> void:
	if _dead:
		return
	_kill_action_tween()
	_action_tween = create_tween().set_loops(2)
	_action_tween.tween_property(body, "position:y", 0.45, 0.18).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_action_tween.tween_property(body, "position:y", 0.0, 0.18).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)


# --- procedural idle / walk -----------------------------------------------------------------

func _process(delta: float) -> void:
	if _dead or body == null:
		return
	_time += delta
	var s := _base_scale
	if _moving:
		var bounce := absf(sin(_time * 11.0))
		body.position.y = bounce * 0.09 if (_action_tween == null or not _action_tween.is_running()) else body.position.y
		body.rotation.z = sin(_time * 11.0) * 0.07
		body.scale = Vector3(s, s * (1.0 - bounce * 0.04), s)
	else:
		var breath := sin(_time * 2.4) * 0.025
		body.scale = Vector3(s * (1.0 - breath * 0.5), s * (1.0 + breath), s * (1.0 - breath * 0.5))
		body.rotation.z = lerpf(body.rotation.z, 0.0, delta * 8.0)


# --- helpers ----------------------------------------------------------------------------------

func _install_flash_overlay() -> void:
	_flash_material = StandardMaterial3D.new()
	_flash_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_flash_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_flash_material.albedo_color = Color(1, 1, 1, 0)
	for mi in _mesh_instances(body):
		mi.material_overlay = _flash_material


func _flash(color: Color, duration := 0.25) -> void:
	_flash_material.albedo_color = color
	var t := create_tween()
	t.tween_property(_flash_material, "albedo_color:a", 0.0, duration)


func _kill_action_tween() -> void:
	if _action_tween and _action_tween.is_valid():
		_action_tween.kill()
	body.position = Vector3.ZERO
	body.rotation.x = 0.0


static func _mesh_instances(root: Node) -> Array[MeshInstance3D]:
	var out: Array[MeshInstance3D] = []
	for c in root.get_children():
		if c is MeshInstance3D:
			out.append(c)
		out.append_array(_mesh_instances(c))
	return out


## Shorthand used by subclasses.
func _p(parent: Node3D, mesh: Mesh, color: Color, pos := Vector3.ZERO, rot := Vector3.ZERO,
		scl := Vector3.ONE, emission := 0.0) -> MeshInstance3D:
	return LP.part(parent, mesh, color, pos, rot, scl, emission)


## A cylinder spanning from a to b (local to parent). Used for limbs, bows, legs.
func _segment(parent: Node3D, a: Vector3, b: Vector3, radius: float, color: Color) -> MeshInstance3D:
	var dir := b - a
	var length := dir.length()
	var y := dir / maxf(length, 0.0001)
	var ref := Vector3.UP if absf(y.dot(Vector3.UP)) < 0.95 else Vector3.FORWARD
	var x := ref.cross(y).normalized()
	var z := x.cross(y).normalized()
	var mi := _p(parent, LP.cylinder(radius, radius, 1.0, 6), color)
	mi.transform = Transform3D(Basis(x, y * length, z), (a + b) * 0.5)
	return mi
