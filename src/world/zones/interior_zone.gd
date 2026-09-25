class_name InteriorZone
extends Zone
## Abstract cosy room: plank floor, three walls (the camera side is open),
## warm lighting and an exit door back to the town.

@export var room_size := Vector2(14, 10)
@export var wall_color := Color("e2cfae")
@export var floor_color := Color("9a6a42")
@export var exit_spawn: StringName = &"default"

const WALL_HEIGHT := 3.4


func _build_environment() -> void:
	make_environment({
		"use_sky": false, "background": Color("120f1a"), "ambient": Color("f0dcc8"), "ambient_energy": 0.3,
		"sun": Color("ffe8cc"), "sun_energy": 0.5, "sun_rot": Vector3(-60, -25, 0), "exposure": 1.0,
	})


func _camera_zoom() -> float:
	return 0.85


func _build_world() -> void:
	var hw := room_size.x * 0.5
	var hd := room_size.y * 0.5
	walkable.add_rect(Vector2.ZERO, room_size - Vector2(1.2, 1.2))
	# Dark void around the room so only the cosy interior reads.
	LowPoly.part(self, LowPoly.box(Vector3(80, 0.1, 80)), Color("120f1a"), Vector3(0, -0.12, 0))
	# Floor planks
	var planks := int(room_size.x / 0.9)
	for i in planks:
		var plank := floor_color if i % 2 == 0 else floor_color.darkened(0.08)
		Terrain.slab(self, Vector3(-hw + 0.45 + i * 0.9, 0, 0), Vector2(0.88, room_size.y), plank, 0.08)
	# Walls: back + sides, with timber posts
	LowPoly.part(self, LowPoly.box(Vector3(room_size.x + 0.6, WALL_HEIGHT, 0.4)), wall_color, Vector3(0, WALL_HEIGHT * 0.5, -hd - 0.2))
	for side: int in [-1, 1]:
		LowPoly.part(self, LowPoly.box(Vector3(0.4, WALL_HEIGHT, room_size.y + 0.4)), wall_color.darkened(0.08), Vector3(side * (hw + 0.2), WALL_HEIGHT * 0.5, 0))
		LowPoly.part(self, LowPoly.box(Vector3(hw - 1.0, 0.8, 0.3)), wall_color.darkened(0.12), Vector3(side * (hw * 0.5 + 0.55), 0.4, hd + 0.15))
	for i in 5:
		var x := -hw + i * room_size.x / 4.0
		LowPoly.part(self, LowPoly.box(Vector3(0.3, WALL_HEIGHT + 0.1, 0.3)), Props.WOOD_DARK, Vector3(x, WALL_HEIGHT * 0.5, -hd))
	LowPoly.part(self, LowPoly.box(Vector3(room_size.x + 0.6, 0.3, 0.45)), Props.WOOD_DARK, Vector3(0, WALL_HEIGHT, -hd - 0.1))
	# Exit mat & door
	Props.rug(self, Vector3(0, 0, hd - 0.5), Vector2(1.8, 1.2), Color("8a3b2e"))
	add_door(&"town", exit_spawn, Vector3(0, 0, hd - 0.3), "Oakhaven", "Leave to")
	add_spawn(&"default", Vector3(0, 0, hd - 1.8), 0)
	_furnish()


## Subclasses place furniture and NPCs.
func _furnish() -> void:
	pass


## Blocks a rectangle of floor for furniture.
func block(center: Vector3, size: Vector2) -> void:
	walkable.block_rect(Vector2(center.x, center.z), size)


func add_light(pos: Vector3, color := Color("ffcf87"), energy := 1.5, radius := 7.0) -> void:
	var l := OmniLight3D.new()
	l.light_color = color
	l.light_energy = energy
	l.omni_range = radius
	l.position = pos
	add_child(l)
