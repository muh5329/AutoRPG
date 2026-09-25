class_name PartyFollowController
extends Node3D
## Keeps one PartyFollower per recruited hero trailing the player like a
## conga line, by replaying a breadcrumb trail of the player's path.

const SPACING := 1.3
const CRUMB_DISTANCE := 0.2
const MAX_CRUMBS := 200

var player: PlayerAvatar
var followers: Array[PartyFollower] = []
var paused := false

var _trail: Array[Vector3] = []


func setup(player_: PlayerAvatar) -> void:
	player = player_
	player.moved.connect(_record)
	GameState.party.changed.connect(_sync)
	_seed_trail()
	_sync()
	for i in followers.size():
		followers[i].global_position = _trail_point((i + 1) * SPACING)
		followers[i].face_point(player.global_position)


func follower_for(hero: Hero) -> PartyFollower:
	for f in followers:
		if f.hero == hero:
			return f
	return null


## Recruits appear where the NPC stood instead of popping in behind the player.
func spawn_follower_at(hero: Hero, pos: Vector3, yaw: float) -> void:
	var f := follower_for(hero)
	if f == null:
		f = _add_follower(hero)
	f.global_position = pos
	f.rotation.y = yaw


func set_followers_visible(v: bool) -> void:
	for f in followers:
		f.visible = v


func _physics_process(delta: float) -> void:
	if paused or player == null:
		return
	for i in followers.size():
		followers[i].follow(_trail_point((i + 1) * SPACING), delta, player.move_speed)


func _sync() -> void:
	for hero in GameState.party.members():
		if follower_for(hero) == null:
			var f := _add_follower(hero)
			f.global_position = player.global_position + player.global_transform.basis.z * SPACING * followers.size()


func _add_follower(hero: Hero) -> PartyFollower:
	var f := PartyFollower.new().setup(hero)
	add_child(f)
	followers.append(f)
	return f


func _seed_trail() -> void:
	_trail.clear()
	var back := player.global_transform.basis.z
	for i in 40:
		_trail.append(player.global_position + back * CRUMB_DISTANCE * i)


func _record(pos: Vector3) -> void:
	if _trail.is_empty() or _trail[0].distance_to(pos) >= CRUMB_DISTANCE:
		_trail.push_front(pos)
		if _trail.size() > MAX_CRUMBS:
			_trail.pop_back()


func reseed() -> void:
	_seed_trail()


## Point `distance` metres back along the player's path.
func _trail_point(distance: float) -> Vector3:
	var remaining := distance
	var prev := player.global_position
	for p in _trail:
		var seg := prev.distance_to(p)
		if seg >= remaining:
			return prev.lerp(p, remaining / maxf(seg, 0.0001))
		remaining -= seg
		prev = p
	return prev
