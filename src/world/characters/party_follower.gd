class_name PartyFollower
extends Character
## Overworld avatar of a recruited Hero, trailing the player.

var hero: Hero


func setup(hero_: Hero) -> PartyFollower:
	hero = hero_
	display_name = hero.display_name
	name = "Follower_%s" % hero.definition.id
	return self


func _get_appearance() -> Appearance:
	return hero.get_appearance()


## Called by PartyFollowController each frame with the trail point to chase.
func follow(point: Vector3, delta: float, leader_speed: float) -> void:
	var dist := global_position.distance_to(point)
	# Catch up faster when lagging so the line never breaks.
	var speed := leader_speed * clampf(dist / 1.2, 0.6, 1.8)
	walk_towards(point, delta, 0.25, speed)
