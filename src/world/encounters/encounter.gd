class_name Encounter
extends WorldEntity
## A pack of monsters waiting in the world. Walking into its radius starts a battle
## on the spot (AFK Journey style). Local -Z is the monsters' side, +Z the heroes'.

@export var encounter_id: StringName
@export var trigger_radius: float = 4.5

var definition: EncounterDefinition
var avatars: Array[MonsterAvatar] = []
var _armed := true
var _ring: MeshInstance3D


func _ready() -> void:
	definition = Content.encounter(encounter_id)
	display_name = definition.display_name
	super()
	if GameState.session.is_cleared(encounter_id):
		queue_free()
		return
	_spawn_avatars()
	_ring = LowPoly.part(self, LowPoly.torus(trigger_radius - 0.12, trigger_radius, 40, 3),
		Color(1.0, 0.35, 0.3, 0.22), Vector3(0, 0.03, 0), Vector3.ZERO, Vector3(1, 0.3, 1), 0.8)


func _physics_process(_delta: float) -> void:
	var zone := get_zone()
	if zone == null or zone.player == null:
		return
	var d := zone.player.global_position.distance_to(global_position)
	if not _armed:
		if d > trigger_radius + 1.5:
			_armed = true
		return
	if d <= trigger_radius and GameState.is_exploring():
		_armed = false
		begin(zone)


## Template method: bosses override to add an intro.
func begin(zone: Zone) -> void:
	zone.start_encounter(self)


## Player backed out: wait until they leave before triggering again.
func disarm() -> void:
	_armed = false


func set_avatars_visible(v: bool) -> void:
	for a in avatars:
		a.visible = v
	if _ring:
		_ring.visible = v


func mark_cleared() -> void:
	queue_free()


# --- formation ---------------------------------------------------------------------------

func monster_slot(i: int, count: int) -> Vector3:
	var spacing := 2.0 if not definition.is_boss else 0.0
	return to_global(Vector3((i - (count - 1) * 0.5) * spacing, 0, -2.4 - (0.6 if definition.is_boss else 0.0)))


## Heroes: front row (tanks/melee) and back row (ranged/healers).
func hero_slot(index_in_row: int, row_count: int, back_row: bool) -> Vector3:
	var z := 3.4 if back_row else 1.4
	return to_global(Vector3((index_in_row - (row_count - 1) * 0.5) * 1.8, 0, z))


func facing_monsters_deg() -> float:
	return rotation_degrees.y


func facing_heroes_deg() -> float:
	return rotation_degrees.y + 180.0


func _spawn_avatars() -> void:
	var count := definition.monsters.size()
	for i in count:
		var a := MonsterAvatar.new().setup(definition.monsters[i])
		add_child(a)
		a.global_position = monster_slot(i, count)
		a.rotation_degrees.y = facing_heroes_deg()
		avatars.append(a)
