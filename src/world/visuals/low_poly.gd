class_name LowPoly
extends RefCounted
## Factory for the game's low-poly look: faceted (flat-normal) meshes with a
## subtle per-face brightness jitter, and soft-lit pastel materials.
## Meshes and materials are cached, so thousands of props share a handful of resources.

static var _meshes: Dictionary = {}
static var _materials: Dictionary = {}


# --- materials -------------------------------------------------------------------------

static func material(color: Color, emission := 0.0, unshaded := false) -> StandardMaterial3D:
	var key := "%s|%.2f|%s" % [color.to_html(), emission, unshaded]
	if _materials.has(key):
		return _materials[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.vertex_color_use_as_albedo = true
	m.vertex_color_is_srgb = true
	m.roughness = 0.9
	m.metallic_specular = 0.25
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT_WRAP
	m.rim_enabled = true
	m.rim = 0.12
	m.rim_tint = 0.8
	if unshaded:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if emission > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emission
	if color.a < 0.999:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
	_materials[key] = m
	return m


# --- meshes --------------------------------------------------------------------------------

static func sphere(radius: float, segments := 8, rings := 5) -> Mesh:
	return _cached("sphere|%.3f|%d|%d" % [radius, segments, rings], func() -> Mesh:
		var m := SphereMesh.new()
		m.radius = radius
		m.height = radius * 2.0
		m.radial_segments = segments
		m.rings = rings
		return m)


static func box(size: Vector3) -> Mesh:
	return _cached("box|%s" % size, func() -> Mesh:
		var m := BoxMesh.new()
		m.size = size
		return m)


static func cylinder(top: float, bottom: float, height: float, sides := 8) -> Mesh:
	return _cached("cyl|%.3f|%.3f|%.3f|%d" % [top, bottom, height, sides], func() -> Mesh:
		var m := CylinderMesh.new()
		m.top_radius = top
		m.bottom_radius = bottom
		m.height = height
		m.radial_segments = sides
		m.rings = 1
		return m)


static func cone(radius: float, height: float, sides := 8) -> Mesh:
	return cylinder(0.0, radius, height, sides)


static func capsule(radius: float, height: float, sides := 8) -> Mesh:
	return _cached("cap|%.3f|%.3f|%d" % [radius, height, sides], func() -> Mesh:
		var m := CapsuleMesh.new()
		m.radius = radius
		m.height = height
		m.radial_segments = sides
		m.rings = 2
		return m)


static func prism(size: Vector3) -> Mesh:
	return _cached("prism|%s" % size, func() -> Mesh:
		var m := PrismMesh.new()
		m.size = size
		return m)


static func torus(inner: float, outer: float, rings := 12, segments := 6) -> Mesh:
	return _cached("torus|%.3f|%.3f|%d|%d" % [inner, outer, rings, segments], func() -> Mesh:
		var m := TorusMesh.new()
		m.inner_radius = inner
		m.outer_radius = outer
		m.rings = rings
		m.ring_segments = segments
		return m)


## Irregular boulder: a low-res sphere with deterministic vertex noise.
static func rock(radius: float, seed_value: int) -> Mesh:
	return _cached("rock|%.3f|%d" % [radius, seed_value], func() -> Mesh:
		var base := SphereMesh.new()
		base.radius = radius
		base.height = radius * 2.0
		base.radial_segments = 7
		base.rings = 4
		var arrays := base.surface_get_arrays(0)
		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var rng := RandomNumberGenerator.new()
		var offsets := {}
		for i in verts.size():
			var key := Vector3i(roundi(verts[i].x * 100), roundi(verts[i].y * 100), roundi(verts[i].z * 100))
			if not offsets.has(key):
				rng.seed = hash(key) ^ seed_value
				offsets[key] = rng.randf_range(0.78, 1.18)
			verts[i] *= offsets[key]
		arrays[Mesh.ARRAY_VERTEX] = verts
		var m := ArrayMesh.new()
		m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		return m)


# --- scene helpers --------------------------------------------------------------------------

## Adds a faceted mesh part under `parent` and returns it.
static func part(parent: Node3D, mesh: Mesh, color: Color, pos := Vector3.ZERO, rot_deg := Vector3.ZERO,
		scl := Vector3.ONE, emission := 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material(color, emission)
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.scale = scl
	if color.a < 0.999 or emission > 0.0:
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi


## Soft dark disc under characters (AFK-style contact shadow).
static func blob_shadow(parent: Node3D, radius: float) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = cylinder(radius, radius, 0.01, 14)
	mi.material_override = material(Color(0.05, 0.05, 0.12, 0.28), 0.0, true)
	mi.position.y = 0.02
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi


# --- internals --------------------------------------------------------------------------------

static func _cached(key: String, builder: Callable) -> Mesh:
	if not _meshes.has(key):
		_meshes[key] = flatten(builder.call())
	return _meshes[key]


## Converts any mesh into flat-shaded triangles with per-face normals and a
## gentle per-face brightness variation (the "painted facet" look).
static func flatten(src: Mesh) -> ArrayMesh:
	var arrays := src.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var idx: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
	if idx.is_empty():
		idx.resize(verts.size())
		for i in verts.size():
			idx[i] = i
	var out_v := PackedVector3Array()
	var out_n := PackedVector3Array()
	var out_c := PackedColorArray()
	var rng := RandomNumberGenerator.new()
	rng.seed = verts.size()
	for i in range(0, idx.size(), 3):
		var a := verts[idx[i]]
		var b := verts[idx[i + 1]]
		var c := verts[idx[i + 2]]
		var n := (b - a).cross(c - a)
		var reference := Vector3.ZERO
		if not normals.is_empty():
			reference = normals[idx[i]] + normals[idx[i + 1]] + normals[idx[i + 2]]
		if n.length_squared() < 1e-12:
			n = reference
		elif reference != Vector3.ZERO and n.dot(reference) < 0.0:
			n = -n
		n = n.normalized()
		var shade := rng.randf_range(0.9, 1.0)
		var col := Color(shade, shade, shade)
		for v in [a, b, c]:
			out_v.append(v)
			out_n.append(n)
			out_c.append(col)
	var out := []
	out.resize(Mesh.ARRAY_MAX)
	out[Mesh.ARRAY_VERTEX] = out_v
	out[Mesh.ARRAY_NORMAL] = out_n
	out[Mesh.ARRAY_COLOR] = out_c
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, out)
	return mesh
