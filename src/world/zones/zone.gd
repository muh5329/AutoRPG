class_name Zone
extends Node3D
## Abstract playable area (town, interior, dungeon). Template method _ready():
##   _build_environment() -> _build_world() -> spawn player & party -> hand control to the player.
## Also hosts battles that start inside it.

@export var zone_id: StringName
@export var display_name: String

var walkable := WalkableArea.new()
var player: PlayerAvatar
var party_controller: PartyFollowController
var camera_rig: CameraRig
var world_environment: WorldEnvironment
var sun: DirectionalLight3D
var active_battle: BattleDirector

var _spawns: Dictionary = {}   # id -> { pos: Vector3, yaw: float }


func _ready() -> void:
	_build_environment()
	_build_world()
	_spawn_player()
	GameState.reset_mode(GameState.Mode.EXPLORE)
	UI.enter_zone(self)


# --- hooks -----------------------------------------------------------------------------------

func _build_environment() -> void:
	make_environment({})


func _build_world() -> void:
	push_error("Zone._build_world is abstract")


## Default camera zoom for this zone (interiors sit closer).
func _camera_zoom() -> float:
	return 1.0


## Background music/ambience would hook here; kept for the next iteration (YAGNI).
func get_subtitle() -> String:
	return ""


# --- building helpers ----------------------------------------------------------------------

func add_spawn(id: StringName, pos: Vector3, yaw_deg: float) -> void:
	_spawns[id] = { "pos": pos, "yaw": yaw_deg }


func add_entity(entity: WorldEntity, pos: Vector3, yaw_deg := 0.0) -> WorldEntity:
	entity.position = pos
	entity.rotation_degrees.y = yaw_deg
	add_child(entity)
	return entity


func add_door(target_zone: StringName, target_spawn: StringName, pos: Vector3, label: String, verb := "Enter") -> ZoneDoor:
	var door := ZoneDoor.new()
	door.display_name = label
	door.target_zone = target_zone
	door.target_spawn = target_spawn
	door.verb = verb
	add_entity(door, pos)
	return door


## Standard outdoor/indoor lighting rig. opts keys are optional overrides.
func make_environment(opts: Dictionary) -> void:
	var env := Environment.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = opts.get("sky_top", Color("6fb8f0"))
	sky_mat.sky_horizon_color = opts.get("sky_horizon", Color("d9eefc"))
	sky_mat.ground_horizon_color = opts.get("sky_horizon", Color("d9eefc"))
	sky_mat.ground_bottom_color = opts.get("ground_bottom", Color("8fbf7a"))
	sky_mat.sun_angle_max = 20.0
	var sky := Sky.new()
	sky.sky_material = sky_mat
	env.sky = sky
	env.background_mode = Environment.BG_SKY if opts.get("use_sky", true) else Environment.BG_COLOR
	env.background_color = opts.get("background", Color("1b1f33"))
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = opts.get("ambient", Color("b9c8f0"))
	env.ambient_light_energy = opts.get("ambient_energy", 0.38)
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = opts.get("exposure", 1.0)
	env.glow_enabled = true
	env.glow_intensity = 0.5
	env.glow_bloom = 0.0
	env.glow_hdr_threshold = 1.6
	env.ssao_enabled = true
	env.ssao_radius = 1.2
	env.ssao_intensity = 2.0
	env.adjustment_enabled = true
	env.adjustment_saturation = opts.get("saturation", 1.25)
	env.adjustment_contrast = 1.1
	if opts.has("fog"):
		env.fog_enabled = true
		env.fog_light_color = opts.get("fog")
		env.fog_density = opts.get("fog_density", 0.01)
		env.fog_sky_affect = 0.0
	world_environment = WorldEnvironment.new()
	world_environment.environment = env
	add_child(world_environment)
	sun = DirectionalLight3D.new()
	sun.light_color = opts.get("sun", Color("fff0d6"))
	sun.light_energy = opts.get("sun_energy", 1.15)
	sun.rotation_degrees = opts.get("sun_rot", Vector3(-52, -38, 0))
	sun.shadow_enabled = true
	sun.shadow_blur = 1.5
	sun.directional_shadow_max_distance = 60.0
	add_child(sun)


# --- runtime -----------------------------------------------------------------------------------

func _spawn_player() -> void:
	var spawn: Dictionary = _spawns.get(GameState.pending_spawn, _spawns.get(&"default", { "pos": Vector3.ZERO, "yaw": 0.0 }))
	player = PlayerAvatar.new()
	player.name = "Player"
	add_entity(player, spawn.pos, spawn.yaw)
	party_controller = PartyFollowController.new()
	party_controller.name = "Party"
	add_child(party_controller)
	party_controller.setup(player)
	camera_rig = CameraRig.new()
	camera_rig.name = "CameraRig"
	camera_rig.zoom = _camera_zoom()
	add_child(camera_rig)
	camera_rig.follow(player)


func start_encounter(encounter: Encounter) -> void:
	if active_battle:
		return
	active_battle = BattleDirector.new()
	active_battle.name = "BattleDirector"
	add_child(active_battle)
	active_battle.begin(self, encounter)


func on_battle_finished(director: BattleDirector) -> void:
	if active_battle == director:
		active_battle = null


## Moves the player out of an encounter's trigger radius (after retreating).
func push_player_back_from(encounter: Encounter) -> void:
	var away := player.global_position - encounter.global_position
	away.y = 0.0
	if away.length() < 0.1:
		away = encounter.global_transform.basis.z
	var pos := encounter.global_position + away.normalized() * (encounter.trigger_radius + 1.5)
	if not walkable.is_walkable(pos):
		pos = encounter.to_global(Vector3(0, 0, encounter.trigger_radius + 1.5))
	player.teleport(pos)
	player.face_point(encounter.global_position)
	party_controller.reseed()
	encounter.disarm()
