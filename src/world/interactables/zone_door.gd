class_name ZoneDoor
extends WorldEntity
## Portal to another zone (building doors, cave mouth, exits).
## Shows a soft pulsing marker on the ground.

@export var target_zone: StringName
@export var target_spawn: StringName = &"default"
@export var verb: String = "Enter"

var _marker: MeshInstance3D
var _time := 0.0


func _ready() -> void:
	super()
	_marker = LowPoly.part(self, LowPoly.torus(0.45, 0.6, 16, 4), Color(1.0, 0.9, 0.55, 0.55), Vector3(0, 0.05, 0), Vector3.ZERO, Vector3.ONE, 1.5)


func _process(delta: float) -> void:
	_time += delta
	var s := 1.0 + sin(_time * 3.0) * 0.08
	_marker.scale = Vector3(s, 1, s)


func is_interactable() -> bool:
	return true


func get_interaction_radius() -> float:
	return 1.8


func get_interaction_verb() -> String:
	return verb


func interact(_player: PlayerAvatar) -> void:
	SceneRouter.go_to_zone(target_zone, target_spawn)
