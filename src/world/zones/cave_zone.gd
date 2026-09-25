class_name CaveZone
extends Zone
## Glimmerdeep Cave: a winding tunnel of four chambers — rats, goblins, spiders
## and Gorrak's throne room. Walls are generated from the walkable layout.

const ROOMS := [
	# [type, center(x,z), size-or-radius]
	["rect", Vector2(0, -3), Vector2(10, 12)],
	["rect", Vector2(0, -14), Vector2(5, 12)],
	["circle", Vector2(0, -24), 7.5],
	["rect", Vector2(0, -32), Vector2(5, 7)],
	["rect", Vector2(4, -35), Vector2(13, 5)],
	["circle", Vector2(8, -44), 8.0],
	["rect", Vector2(8, -55), Vector2(5, 8)],
	["rect", Vector2(2, -60), Vector2(17, 5)],
	["circle", Vector2(-4, -68), 8.0],
	["rect", Vector2(-4, -79.5), Vector2(5, 9)],
	["circle", Vector2(-4, -94), 11.0],
]

const CRYSTAL_BLUE := Color("6ee7ff")
const CRYSTAL_PURPLE := Color("c77dff")
const CRYSTAL_RED := Color("ff5a6e")


func _init() -> void:
	zone_id = &"cave"
	display_name = "Glimmerdeep Cave"


func get_subtitle() -> String:
	return "Clear the tunnels and face what waits in the deep"


func _build_environment() -> void:
	make_environment({
		"use_sky": false, "background": Color("0b0a12"), "ambient": Color("7d6fb0"), "ambient_energy": 0.42,
		"sun": Color("a9b8ff"), "sun_energy": 0.35, "sun_rot": Vector3(-75, -20, 0), "exposure": 1.05,
		"fog": Color("1d1830"), "fog_density": 0.006, "saturation": 1.2,
	})


func _build_world() -> void:
	for r in ROOMS:
		if r[0] == "rect":
			walkable.add_rect(r[1], r[2])
		else:
			walkable.add_circle(r[1], r[2])
	Terrain.ground(self, Vector3(0, -0.05, -48), Vector2(60, 125), Color("4f4859"), Color("6a6078"), 23, 1.4, 0.08)
	_build_walls()
	_build_entrance()
	_decorate_rat_tunnels()
	_decorate_goblin_camp()
	_decorate_spider_nest()
	_decorate_throne()
	_place_encounters()
	add_spawn(&"default", Vector3(0, 0, 1.5), 0)


# --- structure -----------------------------------------------------------------------------------

## Scatters rocks just outside the walkable area so every tunnel reads as carved stone.
## Rocks on the camera side (south of a walkable tile) are kept low so they never hide the party.
func _build_walls() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var step := 1.5
	for gx in range(-24, 25):
		for gz in range(-75, 8):
			var p := Vector3(gx * step * 0.8, 0, gz * step)
			if walkable.is_walkable(p):
				continue
			var near := false
			for dir: Vector3 in [Vector3(step, 0, 0), Vector3(-step, 0, 0), Vector3(0, 0, step), Vector3(0, 0, -step),
					Vector3(step, 0, step), Vector3(-step, 0, -step), Vector3(step, 0, -step), Vector3(-step, 0, step)]:
				if walkable.is_walkable(p + dir):
					near = true
					break
			var camera_side := _is_camera_side(p)
			if near:
				var jitter := Vector3(rng.randf_range(-0.4, 0.4), 0, rng.randf_range(-0.4, 0.4))
				var tint := Color("5c5468").lerp(Color("776c86"), rng.randf())
				if camera_side:
					Props.boulder(self, p + jitter, rng.randf_range(0.7, 1.1), gx * 131 + gz, tint)
				else:
					Props.mountain(self, p + jitter, rng.randf_range(1.1, 1.6), rng.randf_range(1.4, 2.6), gx * 131 + gz, tint)
					if rng.randf() < 0.14:
						var c := CRYSTAL_BLUE if rng.randf() < 0.6 else CRYSTAL_PURPLE
						Props.crystal_cluster(self, p + jitter * 0.3 + Vector3(0, 0.2, 0), c, rng.randf_range(0.7, 1.2), rng.randf() < 0.5)
			elif not camera_side and rng.randf() < 0.06 and _near_walkable(p, 4.5):
				Props.mountain(self, p, rng.randf_range(1.8, 2.6), rng.randf_range(2.4, 3.6), gx * 7 + gz * 3, Color("3e3848"))


## True when walkable floor lies just north of p, i.e. p sits between the camera and the play area.
func _is_camera_side(p: Vector3) -> bool:
	for k in range(1, 6):
		if walkable.is_walkable(p + Vector3(0, 0, -k * 1.5)):
			return true
	return false


func _near_walkable(p: Vector3, dist: float) -> bool:
	for dx in [-dist, 0.0, dist]:
		for dz in [-dist, 0.0, dist]:
			if walkable.is_walkable(p + Vector3(dx, 0, dz)):
				return true
	return false


func _build_entrance() -> void:
	add_door(&"town", &"cave_exit", Vector3(0, 0, 3.6), "Oakhaven", "Return to")
	add_child(_light(Vector3(0, 2.5, 4.0), Color("ffe6b0"), 1.5, 8.0))
	# Mine rails and an abandoned cart
	for side: int in [-1, 1]:
		LowPoly.part(self, LowPoly.box(Vector3(0.08, 0.08, 18)), Color("7d7f86"), Vector3(3.2 + side * 0.45, 0.06, -8))
	for i in 18:
		LowPoly.part(self, LowPoly.box(Vector3(1.3, 0.06, 0.25)), Props.WOOD_DARK, Vector3(3.2, 0.03, 0.5 - i * 1.0))
	var cart := Node3D.new()
	add_child(cart)
	cart.position = Vector3(3.2, 0, -5)
	LowPoly.part(cart, LowPoly.cylinder(0.7, 0.55, 0.8, 4), Color("7a5236"), Vector3(0, 0.75, 0), Vector3(0, 45, 0), Vector3(1, 1, 1.3))
	for sx: int in [-1, 1]:
		for sz: int in [-1, 1]:
			LowPoly.part(cart, LowPoly.cylinder(0.2, 0.2, 0.08, 8), Color("3b3f4a"), Vector3(sx * 0.45, 0.22, sz * 0.5), Vector3(0, 0, 90))
	for i in 5:
		LowPoly.part(cart, LowPoly.prism(Vector3(0.25, 0.4, 0.25)), CRYSTAL_BLUE, Vector3(randf_range(-0.3, 0.3), 1.2, randf_range(-0.3, 0.3)), Vector3(0, randf() * 90, 0), Vector3.ONE, 1.4)
	walkable.block_rect(Vector2(3.2, -5), Vector2(1.6, 2.2))
	Props.torch(self, Vector3(-3.8, 0, -1))
	Props.crate(self, Vector3(-3.6, 0, -6))
	Props.barrel(self, Vector3(-4.0, 0, -7.2))
	walkable.block_rect(Vector2(-3.8, -6.6), Vector2(1.6, 2.6))


func _decorate_rat_tunnels() -> void:
	for p in [Vector3(-5.5, 0, -20), Vector3(5.8, 0, -26), Vector3(-4.8, 0, -28.5)]:
		Props.bones(self, p)
	Props.glow_mushroom(self, Vector3(-6.0, 0, -24.5), Color("7dffb0"))
	Props.glow_mushroom(self, Vector3(6.2, 0, -21), Color("7dffb0"))
	Props.stalagmite(self, Vector3(-6.2, 0, -18.5), 1.6)
	Props.stalagmite(self, Vector3(6.5, 0, -28), 1.3)


func _decorate_goblin_camp() -> void:
	var c := Vector3(8, 0, -44)
	# Tents
	for off in [Vector3(-5.2, 0, -3.8), Vector3(5.0, 0, -4.2)]:
		var p: Vector3 = c + off
		LowPoly.part(self, LowPoly.cone(1.5, 2.2, 6), Color("8a6a3f"), p + Vector3(0, 1.1, 0))
		LowPoly.part(self, LowPoly.cone(0.5, 0.9, 6), Color("3b2a1e"), p + Vector3(0, 0.45, 1.05), Vector3(-20, 0, 0))
		walkable.block_circle(Vector2(p.x, p.z), 1.5)
	# Campfire
	var fire_pos := c + Vector3(-5.5, 0, 2.5)
	for i in 7:
		var ang := TAU * i / 7.0
		Props.boulder(self, fire_pos + Vector3(cos(ang) * 0.7, 0, sin(ang) * 0.7), 0.22, i, Color("6b6573"))
	LowPoly.part(self, LowPoly.cone(0.35, 0.7, 5), Color("ffb347"), fire_pos + Vector3(0, 0.35, 0), Vector3.ZERO, Vector3.ONE, 3.0)
	add_child(_light(fire_pos + Vector3(0, 1.2, 0), Color("ff9f4a"), 2.2, 9.0))
	walkable.block_circle(Vector2(fire_pos.x, fire_pos.z), 1.0)
	Props.torch(self, c + Vector3(3.5, 0, 5.5))
	Props.crate(self, c + Vector3(6.0, 0, 1.5))
	Props.barrel(self, c + Vector3(6.4, 0, 0.2))


func _decorate_spider_nest() -> void:
	var c := Vector3(-4, 0, -68)
	Props.web(self, c + Vector3(-6.2, 1.6, -3), 60, 2.6)
	Props.web(self, c + Vector3(5.8, 1.4, -4), -50, 2.2)
	Props.web(self, c + Vector3(0, 1.8, -7.4), 0, 3.0)
	for i in 6:
		var ang := TAU * i / 6.0 + 0.3
		LowPoly.part(self, LowPoly.sphere(0.35, 7, 5), Color("efe9f5"), c + Vector3(cos(ang) * 6.3, 0.3, sin(ang) * 6.3), Vector3.ZERO, Vector3(1, 1.3, 1), 0.2)
	Props.glow_mushroom(self, c + Vector3(-6, 0, 3), Color("d68bff"))
	Props.glow_mushroom(self, c + Vector3(6, 0, 2), Color("d68bff"))
	Props.bones(self, c + Vector3(3.5, 0, -5))


func _decorate_throne() -> void:
	var c := Vector3(-4, 0, -94)
	# Throne of stacked stone
	Props.boulder(self, c + Vector3(0, 0, -8.2), 2.2, 5, Color("5c5468"))
	Props.boulder(self, c + Vector3(-1.6, 0, -7.6), 1.4, 6, Color("6a6078"))
	Props.boulder(self, c + Vector3(1.6, 0, -7.6), 1.4, 7, Color("6a6078"))
	walkable.block_circle(Vector2(c.x, c.z - 8), 2.6)
	for i in 6:
		var ang := PI + PI * (i + 0.5) / 6.0
		var p := c + Vector3(cos(ang) * 9.0, 0, sin(ang) * 9.0 * 0.9 + 0.5)
		Props.crystal_cluster(self, p, CRYSTAL_RED, 1.4, i % 2 == 0)
	for side: int in [-1, 1]:
		var pillar := c + Vector3(side * 6.5, 0, 3.5)
		LowPoly.part(self, LowPoly.cylinder(0.7, 0.9, 5.0, 7), Color("5a5266"), pillar + Vector3(0, 2.5, 0))
		walkable.block_circle(Vector2(pillar.x, pillar.z), 0.9)
		Props.torch(self, pillar + Vector3(-side * 1.2, 0, 0))
	for i in 5:
		Props.bones(self, c + Vector3(randf_range(-7, 7), 0, randf_range(-5, 6)))


func _place_encounters() -> void:
	_encounter(Encounter.new(), &"cave_rats", Vector3(0, 0, -24.5), 4.2)
	_encounter(Encounter.new(), &"cave_goblins", Vector3(8, 0, -44), 4.6)
	_encounter(Encounter.new(), &"cave_spiders", Vector3(-4, 0, -68), 4.6)
	_encounter(BossEncounter.new(), &"cave_boss", Vector3(-4, 0, -93), 6.0)


func _encounter(e: Encounter, id: StringName, pos: Vector3, radius: float) -> void:
	e.encounter_id = id
	e.trigger_radius = radius
	add_entity(e, pos)


static func _light(pos: Vector3, color: Color, energy: float, radius: float) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.light_color = color
	l.light_energy = energy
	l.omni_range = radius
	l.position = pos
	return l
