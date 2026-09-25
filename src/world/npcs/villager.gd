class_name Villager
extends FriendlyNPC
## Ambient townsfolk: wanders around home and mutters barks when you walk by.

@export var wander_radius: float = 3.0
@export var barks: PackedStringArray = []

const BARK_DISTANCE := 5.0
const BARK_COOLDOWN := 9.0

var _home: Vector3
var _target: Vector3
var _idle_timer: float = 0.0
var _bark_timer: float = 0.0


func _ready() -> void:
	move_speed = 1.4
	super()
	_home = global_position
	_target = _home
	_idle_timer = randf_range(1.0, 4.0)


func _physics_process(delta: float) -> void:
	if not GameState.is_exploring():
		stop()
		return
	_bark_timer -= delta
	_maybe_bark()
	if _idle_timer > 0.0:
		_idle_timer -= delta
		stop()
		return
	if walk_towards(_target, delta, 0.2):
		_idle_timer = randf_range(2.0, 5.0)
		var ang := randf() * TAU
		_target = _home + Vector3(cos(ang), 0, sin(ang)) * randf() * wander_radius


func _maybe_bark() -> void:
	if barks.is_empty() or _bark_timer > 0.0:
		return
	var zone := get_zone()
	if zone and zone.player and zone.player.global_position.distance_to(global_position) < BARK_DISTANCE:
		say(barks[randi() % barks.size()])
		_bark_timer = BARK_COOLDOWN


func _on_interact(player: PlayerAvatar) -> void:
	_idle_timer = 3.0
	super(player)
