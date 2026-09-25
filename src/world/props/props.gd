class_name Props
extends RefCounted
## Static builders for low-poly scenery. Each returns the root Node3D it created.
## Colours follow a warm, saturated storybook palette.

const LP := preload("res://src/world/visuals/low_poly.gd")

const WOOD := Color("8a5a35")
const WOOD_DARK := Color("5e3b22")
const PLASTER := Color("efe0c4")
const STONE := Color("b8b2a7")
const STONE_DARK := Color("8e8a86")
const LEAF := [Color("6cc24a"), Color("8fd14f"), Color("4fae5d"), Color("a3d65c")]
const FLOWERS := [Color("ff7aa2"), Color("ffd23f"), Color("ffffff"), Color("b28dff"), Color("ff9b54")]


static func _root(parent: Node3D, pos: Vector3, yaw := 0.0, scl := 1.0) -> Node3D:
	var n := Node3D.new()
	parent.add_child(n)
	n.position = pos
	n.rotation_degrees.y = yaw
	n.scale = Vector3.ONE * scl
	return n


# --- nature ----------------------------------------------------------------------------------

static func round_tree(parent: Node3D, pos: Vector3, scl := 1.0, seed_value := 0) -> Node3D:
	var n := _root(parent, pos, seed_value * 37 % 360, scl)
	LP.part(n, LP.cylinder(0.16, 0.24, 1.6, 6), WOOD, Vector3(0, 0.8, 0))
	var leaf: Color = LEAF[seed_value % LEAF.size()]
	LP.part(n, LP.sphere(1.1, 8, 6), leaf, Vector3(0, 2.2, 0))
	LP.part(n, LP.sphere(0.8, 7, 5), leaf.lightened(0.08), Vector3(0.55, 2.7, 0.2))
	LP.part(n, LP.sphere(0.75, 7, 5), leaf.darkened(0.06), Vector3(-0.5, 2.55, -0.3))
	LP.blob_shadow(n, 1.1)
	return n


static func pine_tree(parent: Node3D, pos: Vector3, scl := 1.0, seed_value := 0) -> Node3D:
	var n := _root(parent, pos, seed_value * 53 % 360, scl)
	LP.part(n, LP.cylinder(0.14, 0.2, 1.0, 6), WOOD_DARK, Vector3(0, 0.5, 0))
	var green := Color("3f8f4e").lerp(Color("5aa84a"), (seed_value % 5) / 5.0)
	LP.part(n, LP.cone(1.2, 1.6, 7), green, Vector3(0, 1.6, 0))
	LP.part(n, LP.cone(0.95, 1.4, 7), green.lightened(0.06), Vector3(0, 2.4, 0))
	LP.part(n, LP.cone(0.65, 1.2, 7), green.lightened(0.12), Vector3(0, 3.1, 0))
	return n


static func bush(parent: Node3D, pos: Vector3, scl := 1.0, seed_value := 0) -> Node3D:
	var n := _root(parent, pos, seed_value * 71 % 360, scl)
	var leaf: Color = LEAF[(seed_value + 1) % LEAF.size()]
	LP.part(n, LP.sphere(0.5, 7, 5), leaf, Vector3(0, 0.35, 0), Vector3.ZERO, Vector3(1, 0.8, 1))
	LP.part(n, LP.sphere(0.38, 7, 4), leaf.lightened(0.1), Vector3(0.38, 0.3, 0.1))
	if seed_value % 2 == 0:
		for i in 4:
			var ang := i * 1.7 + seed_value
			LP.part(n, LP.sphere(0.07, 5, 3), FLOWERS[(seed_value + i) % FLOWERS.size()],
				Vector3(cos(ang) * 0.4, 0.6, sin(ang) * 0.4))
	return n


static func flower_patch(parent: Node3D, pos: Vector3, seed_value := 0, count := 7) -> Node3D:
	var n := _root(parent, pos)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in count:
		var p := Vector3(rng.randf_range(-0.8, 0.8), 0, rng.randf_range(-0.8, 0.8))
		LP.part(n, LP.cylinder(0.012, 0.012, 0.25, 4), Color("4f9e3f"), p + Vector3(0, 0.12, 0))
		LP.part(n, LP.sphere(0.07, 5, 3), FLOWERS[rng.randi() % FLOWERS.size()], p + Vector3(0, 0.27, 0))
	return n


static func grass_tuft(parent: Node3D, pos: Vector3, color := Color("7cc75a")) -> Node3D:
	var n := _root(parent, pos, randf() * 360.0)
	for i in 3:
		LP.part(n, LP.cone(0.06, 0.35, 4), color.lightened(i * 0.05), Vector3((i - 1) * 0.07, 0.17, 0), Vector3(0, 0, (i - 1) * 18))
	return n


static func boulder(parent: Node3D, pos: Vector3, radius := 0.6, seed_value := 0, color := STONE) -> Node3D:
	var n := _root(parent, pos, seed_value * 29 % 360)
	LP.part(n, LP.rock(radius, seed_value), color, Vector3(0, radius * 0.45, 0), Vector3.ZERO, Vector3(1, 0.75, 1))
	return n


static func mountain(parent: Node3D, pos: Vector3, radius: float, height: float, seed_value := 0,
		color := Color("9a948a")) -> Node3D:
	var n := _root(parent, pos, seed_value * 13 % 360)
	LP.part(n, LP.rock(1.0, seed_value), color, Vector3(0, height * 0.35, 0), Vector3.ZERO, Vector3(radius, height, radius))
	if height > 4.0:
		LP.part(n, LP.rock(0.5, seed_value + 5), Color("f4f6fb"), Vector3(0, height * 1.08, 0), Vector3.ZERO,
			Vector3(radius * 0.8, height * 0.35, radius * 0.8))
	return n


# --- village --------------------------------------------------------------------------------

## Timber-framed cottage. The door faces local +Z. Returns the root.
static func house(parent: Node3D, pos: Vector3, yaw: float, size: Vector3, roof: Color, plaster := PLASTER,
		with_chimney := true, sign_color := Color(0, 0, 0, 0)) -> Node3D:
	var n := _root(parent, pos, yaw)
	var w := size.x
	var h := size.y
	var d := size.z
	# Stone base + plaster walls
	LP.part(n, LP.box(Vector3(w + 0.2, 0.5, d + 0.2)), STONE, Vector3(0, 0.25, 0))
	LP.part(n, LP.box(Vector3(w, h, d)), plaster, Vector3(0, 0.5 + h * 0.5, 0))
	# Timber frame
	for sx: int in [-1, 1]:
		for sz: int in [-1, 1]:
			LP.part(n, LP.box(Vector3(0.22, h, 0.22)), WOOD_DARK, Vector3(sx * w * 0.5, 0.5 + h * 0.5, sz * d * 0.5))
	LP.part(n, LP.box(Vector3(w + 0.1, 0.2, 0.24)), WOOD_DARK, Vector3(0, 0.5 + h, d * 0.5))
	LP.part(n, LP.box(Vector3(w + 0.1, 0.2, 0.24)), WOOD_DARK, Vector3(0, 0.5 + h * 0.5, d * 0.5))
	# Roof (prism along X) with overhang
	var roof_h := minf(w, d) * 0.55 + 0.6
	LP.part(n, LP.prism(Vector3(d + 0.9, roof_h, w + 0.7)), roof, Vector3(0, 0.5 + h + roof_h * 0.5, 0), Vector3(0, 90, 0))
	LP.part(n, LP.box(Vector3(w + 0.8, 0.14, 0.3)), roof.darkened(0.2), Vector3(0, 0.5 + h + roof_h - 0.02, 0))
	if with_chimney:
		LP.part(n, LP.box(Vector3(0.5, 1.4, 0.5)), STONE_DARK, Vector3(w * 0.28, 0.5 + h + roof_h * 0.6, -d * 0.18))
	# Door + frame + step
	LP.part(n, LP.box(Vector3(1.0, 1.7, 0.12)), WOOD, Vector3(0, 1.35, d * 0.5 + 0.05))
	LP.part(n, LP.box(Vector3(1.25, 0.16, 0.2)), WOOD_DARK, Vector3(0, 2.25, d * 0.5 + 0.07))
	LP.part(n, LP.sphere(0.05, 5, 3), Color("f2c45a"), Vector3(0.32, 1.3, d * 0.5 + 0.13))
	LP.part(n, LP.box(Vector3(1.4, 0.12, 0.6)), STONE, Vector3(0, 0.06, d * 0.5 + 0.35))
	# Glowing windows
	for sx: int in [-1, 1]:
		var wx := sx * w * 0.3
		LP.part(n, LP.box(Vector3(0.7, 0.7, 0.08)), Color("ffd98a"), Vector3(wx, 0.5 + h * 0.6, d * 0.5 + 0.02), Vector3.ZERO, Vector3.ONE, 1.2)
		LP.part(n, LP.box(Vector3(0.84, 0.1, 0.14)), WOOD_DARK, Vector3(wx, 0.5 + h * 0.6 - 0.4, d * 0.5 + 0.05))
		LP.part(n, LP.box(Vector3(0.06, 0.7, 0.12)), WOOD_DARK, Vector3(wx, 0.5 + h * 0.6, d * 0.5 + 0.05))
		LP.part(n, LP.box(Vector3(0.7, 0.06, 0.12)), WOOD_DARK, Vector3(wx, 0.5 + h * 0.6, d * 0.5 + 0.05))
		# Flower box
		LP.part(n, LP.box(Vector3(0.8, 0.18, 0.2)), WOOD, Vector3(wx, 0.5 + h * 0.6 - 0.5, d * 0.5 + 0.15))
		for i in 3:
			LP.part(n, LP.sphere(0.08, 5, 3), FLOWERS[(i + sx + 2) % FLOWERS.size()], Vector3(wx + (i - 1) * 0.22, 0.5 + h * 0.6 - 0.36, d * 0.5 + 0.17))
	if sign_color.a > 0.0:
		LP.part(n, LP.box(Vector3(0.06, 0.06, 0.8)), WOOD_DARK, Vector3(w * 0.5 - 0.2, 0.5 + h * 0.8, d * 0.5 + 0.4))
		LP.part(n, LP.box(Vector3(0.08, 0.6, 0.7)), sign_color, Vector3(w * 0.5 - 0.2, 0.5 + h * 0.8 - 0.38, d * 0.5 + 0.55))
	return n


static func fence(parent: Node3D, from: Vector3, to: Vector3) -> Node3D:
	var n := _root(parent, Vector3.ZERO)
	var length := from.distance_to(to)
	var posts := maxi(2, int(length / 1.2) + 1)
	for i in posts:
		var p := from.lerp(to, float(i) / (posts - 1))
		LP.part(n, LP.box(Vector3(0.14, 0.8, 0.14)), WOOD, p + Vector3(0, 0.4, 0))
	var mid := (from + to) * 0.5
	var yaw := rad_to_deg(atan2(to.x - from.x, to.z - from.z))
	for y: float in [0.3, 0.6]:
		LP.part(n, LP.box(Vector3(0.07, 0.1, length)), WOOD.lightened(0.1), mid + Vector3(0, y, 0), Vector3(0, yaw, 0))
	return n


static func lamp_post(parent: Node3D, pos: Vector3, with_light := true) -> Node3D:
	var n := _root(parent, pos)
	LP.part(n, LP.cylinder(0.06, 0.09, 2.4, 6), Color("3b3f4a"), Vector3(0, 1.2, 0))
	LP.part(n, LP.box(Vector3(0.3, 0.36, 0.3)), Color("ffd27a"), Vector3(0, 2.55, 0), Vector3.ZERO, Vector3.ONE, 2.0)
	LP.part(n, LP.cone(0.28, 0.25, 4), Color("3b3f4a"), Vector3(0, 2.85, 0), Vector3(0, 45, 0))
	if with_light:
		var l := OmniLight3D.new()
		l.light_color = Color("ffcf87")
		l.light_energy = 1.2
		l.omni_range = 5.5
		l.position = Vector3(0, 2.5, 0)
		n.add_child(l)
	return n


static func barrel(parent: Node3D, pos: Vector3) -> Node3D:
	var n := _root(parent, pos, randf() * 360.0)
	LP.part(n, LP.cylinder(0.32, 0.32, 0.8, 8), WOOD, Vector3(0, 0.4, 0), Vector3.ZERO, Vector3(1, 1, 1))
	for y: float in [0.15, 0.65]:
		LP.part(n, LP.cylinder(0.335, 0.335, 0.06, 8), Color("5a5f68"), Vector3(0, y, 0))
	return n


static func crate(parent: Node3D, pos: Vector3, size := 0.7) -> Node3D:
	var n := _root(parent, pos, randf() * 30.0)
	LP.part(n, LP.box(Vector3.ONE * size), Color("c08a52"), Vector3(0, size * 0.5, 0))
	LP.part(n, LP.box(Vector3(size * 1.02, 0.08, size * 1.02)), WOOD_DARK, Vector3(0, size * 0.85, 0))
	LP.part(n, LP.box(Vector3(size * 1.02, 0.08, size * 1.02)), WOOD_DARK, Vector3(0, size * 0.15, 0))
	return n


static func fountain(parent: Node3D, pos: Vector3) -> Node3D:
	var n := _root(parent, pos)
	LP.part(n, LP.cylinder(2.2, 2.35, 0.6, 12), STONE, Vector3(0, 0.3, 0))
	LP.part(n, LP.cylinder(1.95, 1.95, 0.1, 12), Color("5fc7e8"), Vector3(0, 0.56, 0), Vector3.ZERO, Vector3.ONE, 0.3)
	LP.part(n, LP.cylinder(0.35, 0.5, 1.4, 8), STONE, Vector3(0, 1.0, 0))
	LP.part(n, LP.cylinder(1.0, 0.8, 0.25, 10), STONE, Vector3(0, 1.75, 0))
	LP.part(n, LP.cylinder(0.85, 0.85, 0.06, 10), Color("7fd8f2"), Vector3(0, 1.86, 0), Vector3.ZERO, Vector3.ONE, 0.4)
	LP.part(n, LP.sphere(0.3, 8, 5), Color("9fe6ff"), Vector3(0, 2.2, 0), Vector3.ZERO, Vector3(1, 1.4, 1), 0.6)
	var spray := CPUParticles3D.new()
	spray.amount = 40
	spray.lifetime = 1.0
	spray.direction = Vector3.UP
	spray.spread = 25.0
	spray.initial_velocity_min = 2.0
	spray.initial_velocity_max = 2.8
	spray.gravity = Vector3(0, -6, 0)
	spray.color = Color(0.75, 0.93, 1.0, 0.85)
	var m := SphereMesh.new()
	m.radius = 0.05
	m.height = 0.1
	m.radial_segments = 4
	m.rings = 2
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	m.material = mat
	spray.mesh = m
	spray.position = Vector3(0, 2.3, 0)
	n.add_child(spray)
	return n


static func market_stall(parent: Node3D, pos: Vector3, yaw: float, awning: Color) -> Node3D:
	var n := _root(parent, pos, yaw)
	LP.part(n, LP.box(Vector3(2.2, 0.9, 1.0)), WOOD, Vector3(0, 0.45, 0))
	for sx: int in [-1, 1]:
		LP.part(n, LP.box(Vector3(0.1, 2.2, 0.1)), WOOD_DARK, Vector3(sx * 1.0, 1.1, -0.4))
		LP.part(n, LP.box(Vector3(0.1, 1.8, 0.1)), WOOD_DARK, Vector3(sx * 1.0, 0.9, 0.45))
	for i in 5:
		var c := awning if i % 2 == 0 else Color("fff3e0")
		LP.part(n, LP.box(Vector3(0.48, 0.06, 1.3)), c, Vector3(-0.96 + i * 0.48, 2.05, 0.05), Vector3(-14, 0, 0))
	for i in 5:
		LP.part(n, LP.sphere(0.13, 6, 4), [Color("e94f37"), Color("f6ae2d"), Color("86bb4e")][i % 3], Vector3(-0.8 + i * 0.4, 0.98, 0.1))
	return n


static func bench(parent: Node3D, pos: Vector3, yaw: float) -> Node3D:
	var n := _root(parent, pos, yaw)
	LP.part(n, LP.box(Vector3(1.6, 0.1, 0.45)), WOOD, Vector3(0, 0.45, 0))
	LP.part(n, LP.box(Vector3(1.6, 0.4, 0.08)), WOOD, Vector3(0, 0.75, 0.2))
	for sx: int in [-1, 1]:
		LP.part(n, LP.box(Vector3(0.1, 0.45, 0.4)), WOOD_DARK, Vector3(sx * 0.7, 0.22, 0))
	return n


static func well(parent: Node3D, pos: Vector3) -> Node3D:
	var n := _root(parent, pos)
	LP.part(n, LP.cylinder(0.8, 0.85, 0.8, 10), STONE, Vector3(0, 0.4, 0))
	LP.part(n, LP.cylinder(0.62, 0.62, 0.05, 10), Color("2d5f7a"), Vector3(0, 0.78, 0))
	for sx: int in [-1, 1]:
		LP.part(n, LP.box(Vector3(0.12, 1.4, 0.12)), WOOD_DARK, Vector3(sx * 0.7, 1.4, 0))
	LP.part(n, LP.prism(Vector3(1.9, 0.6, 1.2)), Color("c0504d"), Vector3(0, 2.3, 0))
	return n


static func signpost(parent: Node3D, pos: Vector3, yaw: float) -> Node3D:
	var n := _root(parent, pos, yaw)
	LP.part(n, LP.box(Vector3(0.12, 1.8, 0.12)), WOOD_DARK, Vector3(0, 0.9, 0))
	LP.part(n, LP.box(Vector3(1.0, 0.3, 0.06)), WOOD, Vector3(0.35, 1.5, 0), Vector3(0, 0, 4))
	LP.part(n, LP.box(Vector3(0.9, 0.28, 0.06)), WOOD, Vector3(-0.3, 1.1, 0), Vector3(0, 0, -5))
	return n


# --- interiors --------------------------------------------------------------------------------

static func table(parent: Node3D, pos: Vector3, round_top := true) -> Node3D:
	var n := _root(parent, pos)
	if round_top:
		LP.part(n, LP.cylinder(0.75, 0.75, 0.1, 10), WOOD, Vector3(0, 0.8, 0))
		LP.part(n, LP.cylinder(0.08, 0.2, 0.8, 6), WOOD_DARK, Vector3(0, 0.4, 0))
	else:
		LP.part(n, LP.box(Vector3(1.8, 0.1, 0.9)), WOOD, Vector3(0, 0.8, 0))
		for sx: int in [-1, 1]:
			for sz: int in [-1, 1]:
				LP.part(n, LP.box(Vector3(0.1, 0.8, 0.1)), WOOD_DARK, Vector3(sx * 0.8, 0.4, sz * 0.35))
	return n


static func stool(parent: Node3D, pos: Vector3) -> Node3D:
	var n := _root(parent, pos)
	LP.part(n, LP.cylinder(0.25, 0.25, 0.08, 8), WOOD, Vector3(0, 0.5, 0))
	LP.part(n, LP.cylinder(0.06, 0.1, 0.5, 5), WOOD_DARK, Vector3(0, 0.25, 0))
	return n


static func mug(parent: Node3D, pos: Vector3) -> Node3D:
	var n := _root(parent, pos)
	LP.part(n, LP.cylinder(0.08, 0.07, 0.18, 7), WOOD, Vector3(0, 0.09, 0))
	LP.part(n, LP.cylinder(0.081, 0.081, 0.05, 7), Color("fff8e7"), Vector3(0, 0.19, 0))
	return n


static func counter(parent: Node3D, pos: Vector3, length: float, yaw := 0.0) -> Node3D:
	var n := _root(parent, pos, yaw)
	LP.part(n, LP.box(Vector3(length, 1.1, 0.8)), WOOD, Vector3(0, 0.55, 0))
	LP.part(n, LP.box(Vector3(length + 0.2, 0.1, 1.0)), WOOD.lightened(0.15), Vector3(0, 1.12, 0))
	return n


static func shelf(parent: Node3D, pos: Vector3, yaw: float, width := 2.4, item_colors: Array = []) -> Node3D:
	var n := _root(parent, pos, yaw)
	LP.part(n, LP.box(Vector3(width, 2.6, 0.5)), WOOD_DARK, Vector3(0, 1.3, 0))
	var colors := item_colors if not item_colors.is_empty() else [Color("e0453a"), Color("3b7dd8"), Color("3fa34d"), Color("ffd23f")]
	for row in 3:
		var y := 0.55 + row * 0.75
		LP.part(n, LP.box(Vector3(width - 0.1, 0.06, 0.52)), WOOD, Vector3(0, y, 0.02))
		var count := int(width / 0.32)
		for i in count:
			var c: Color = colors[(i + row) % colors.size()]
			var x := -width * 0.5 + 0.22 + i * 0.32
			LP.part(n, LP.cylinder(0.08, 0.1, 0.26, 6), c, Vector3(x, y + 0.16, 0.08), Vector3.ZERO, Vector3.ONE, 0.25)
			LP.part(n, LP.cylinder(0.03, 0.03, 0.08, 4), WOOD, Vector3(x, y + 0.33, 0.08))
	return n


static func fireplace(parent: Node3D, pos: Vector3, yaw: float) -> Node3D:
	var n := _root(parent, pos, yaw)
	LP.part(n, LP.box(Vector3(2.4, 2.2, 0.8)), STONE, Vector3(0, 1.1, 0))
	LP.part(n, LP.box(Vector3(1.4, 1.1, 0.3)), Color("2a2020"), Vector3(0, 0.6, 0.3))
	LP.part(n, LP.box(Vector3(2.7, 0.2, 1.0)), WOOD_DARK, Vector3(0, 2.2, 0.05))
	LP.part(n, LP.box(Vector3(1.0, 3.0, 0.6)), STONE_DARK, Vector3(0, 3.6, -0.05))
	for i in 3:
		LP.part(n, LP.cylinder(0.08, 0.08, 0.9, 5), WOOD, Vector3(0, 0.15, 0.35 + (i - 1) * 0.02), Vector3(0, (i - 1) * 40, 90))
	var fire := CPUParticles3D.new()
	fire.amount = 30
	fire.lifetime = 0.7
	fire.direction = Vector3.UP
	fire.spread = 15.0
	fire.initial_velocity_min = 0.6
	fire.initial_velocity_max = 1.2
	fire.gravity = Vector3(0, 0.6, 0)
	fire.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	fire.emission_box_extents = Vector3(0.35, 0.05, 0.1)
	var grad := Gradient.new()
	grad.set_color(0, Color("ffe066"))
	grad.set_color(1, Color(1.0, 0.3, 0.1, 0.0))
	fire.color_ramp = grad
	var m := SphereMesh.new()
	m.radius = 0.1
	m.height = 0.2
	m.radial_segments = 5
	m.rings = 3
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.material = mat
	fire.mesh = m
	fire.position = Vector3(0, 0.25, 0.35)
	n.add_child(fire)
	var light := OmniLight3D.new()
	light.light_color = Color("ff9f4a")
	light.light_energy = 2.2
	light.omni_range = 7.0
	light.position = Vector3(0, 0.8, 1.0)
	n.add_child(light)
	return n


static func rug(parent: Node3D, pos: Vector3, size: Vector2, color: Color) -> Node3D:
	var n := _root(parent, pos)
	LP.part(n, LP.box(Vector3(size.x, 0.03, size.y)), color, Vector3(0, 0.02, 0))
	LP.part(n, LP.box(Vector3(size.x - 0.4, 0.035, size.y - 0.4)), color.lightened(0.25), Vector3(0, 0.025, 0))
	return n


static func bed(parent: Node3D, pos: Vector3, yaw: float, blanket: Color) -> Node3D:
	var n := _root(parent, pos, yaw)
	LP.part(n, LP.box(Vector3(1.2, 0.45, 2.1)), WOOD, Vector3(0, 0.22, 0))
	LP.part(n, LP.box(Vector3(1.1, 0.2, 1.4)), blanket, Vector3(0, 0.52, 0.3))
	LP.part(n, LP.box(Vector3(0.8, 0.18, 0.4)), Color("fffaf0"), Vector3(0, 0.52, -0.7))
	LP.part(n, LP.box(Vector3(1.2, 0.9, 0.1)), WOOD_DARK, Vector3(0, 0.45, -1.05))
	return n


# --- cave ----------------------------------------------------------------------------------------

static func crystal_cluster(parent: Node3D, pos: Vector3, color: Color, scl := 1.0, with_light := true) -> Node3D:
	var n := _root(parent, pos, randf() * 360.0, scl)
	var shards := [[0.0, 0.0, 1.2, 0.0], [0.3, 0.1, 0.8, 25.0], [-0.25, 0.15, 0.7, -30.0], [0.1, -0.3, 0.6, 15.0]]
	for s in shards:
		LP.part(n, LP.prism(Vector3(0.28, s[2], 0.28)), color, Vector3(s[0], s[2] * 0.5, s[1]), Vector3(s[3] * 0.5, s[3], s[3]), Vector3.ONE, 1.8)
	if with_light:
		var l := OmniLight3D.new()
		l.light_color = color
		l.light_energy = 1.6
		l.omni_range = 5.5
		l.position = Vector3(0, 0.8, 0)
		n.add_child(l)
	return n


static func stalagmite(parent: Node3D, pos: Vector3, height := 1.5, color := Color("6e6573")) -> Node3D:
	var n := _root(parent, pos, randf() * 360.0)
	LP.part(n, LP.cone(height * 0.3, height, 6), color, Vector3(0, height * 0.5, 0))
	LP.part(n, LP.cone(height * 0.18, height * 0.6, 5), color.lightened(0.08), Vector3(height * 0.25, height * 0.3, 0.1))
	return n


static func glow_mushroom(parent: Node3D, pos: Vector3, color: Color) -> Node3D:
	var n := _root(parent, pos, randf() * 360.0)
	for i in 3:
		var h := 0.25 + i * 0.12
		var p := Vector3((i - 1) * 0.18, 0, (i % 2) * 0.12)
		LP.part(n, LP.cylinder(0.03, 0.04, h, 5), Color("efe6d0"), p + Vector3(0, h * 0.5, 0))
		LP.part(n, LP.sphere(0.12 + i * 0.03, 7, 4), color, p + Vector3(0, h, 0), Vector3.ZERO, Vector3(1, 0.5, 1), 1.6)
	return n


static func torch(parent: Node3D, pos: Vector3) -> Node3D:
	var n := _root(parent, pos)
	LP.part(n, LP.cylinder(0.05, 0.07, 1.6, 5), WOOD_DARK, Vector3(0, 0.8, 0))
	LP.part(n, LP.sphere(0.16, 6, 4), Color("ffb347"), Vector3(0, 1.7, 0), Vector3.ZERO, Vector3(1, 1.4, 1), 3.0)
	var l := OmniLight3D.new()
	l.light_color = Color("ff9f4a")
	l.light_energy = 1.6
	l.omni_range = 6.0
	l.position = Vector3(0, 1.8, 0)
	n.add_child(l)
	return n


static func bones(parent: Node3D, pos: Vector3) -> Node3D:
	var n := _root(parent, pos, randf() * 360.0)
	LP.part(n, LP.sphere(0.13, 6, 4), Color("efe6d0"), Vector3(0, 0.1, 0))
	for i in 3:
		LP.part(n, LP.cylinder(0.03, 0.03, 0.5, 4), Color("e6dcc4"), Vector3(0.2 + i * 0.1, 0.04, (i - 1) * 0.15), Vector3(0, i * 50, 90))
	return n


static func web(parent: Node3D, pos: Vector3, yaw: float, size := 2.0) -> Node3D:
	var n := _root(parent, pos, yaw)
	var c := Color(1, 1, 1, 0.45)
	for i in 6:
		var ang := PI * i / 6.0
		LP.part(n, LP.box(Vector3(size, 0.02, 0.02)), c, Vector3.ZERO, Vector3(0, 0, rad_to_deg(ang)))
	for r: float in [0.3, 0.6, 0.9]:
		LP.part(n, LP.torus(size * 0.5 * r - 0.01, size * 0.5 * r + 0.01, 12, 3), c, Vector3.ZERO, Vector3(90, 0, 0))
	return n
