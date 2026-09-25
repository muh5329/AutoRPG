class_name Terrain
extends RefCounted
## Faceted ground planes with painterly colour patches.


## A size.x by size.y grid of flat-shaded triangles, gently bumped, tinted between two colours.
static func ground(parent: Node3D, center: Vector3, size: Vector2, color_a: Color, color_b: Color,
		seed_value := 1, cell := 1.6, bump := 0.12) -> MeshInstance3D:
	var noise := FastNoiseLite.new()
	noise.seed = seed_value
	noise.frequency = 0.045
	var nx := int(size.x / cell)
	var nz := int(size.y / cell)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var heights := {}
	for x in nx + 1:
		for z in nz + 1:
			heights[Vector2i(x, z)] = rng.randf_range(-bump, bump)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var origin := Vector3(-size.x * 0.5, 0, -size.y * 0.5)
	for x in nx:
		for z in nz:
			var p00 := _v(origin, x, z, cell, heights)
			var p10 := _v(origin, x + 1, z, cell, heights)
			var p01 := _v(origin, x, z + 1, cell, heights)
			var p11 := _v(origin, x + 1, z + 1, cell, heights)
			for tri: Array in [[p00, p10, p11], [p00, p11, p01]]:
				var t0: Vector3 = tri[0]
				var t1: Vector3 = tri[1]
				var t2: Vector3 = tri[2]
				var c := (t0 + t1 + t2) / 3.0
				var t := clampf(noise.get_noise_2d(c.x + center.x, c.z + center.z) * 0.8 + 0.5, 0.0, 1.0)
				var col := color_a.lerp(color_b, t) * rng.randf_range(0.95, 1.03)
				col.a = 1.0
				var n: Vector3 = (t2 - t0).cross(t1 - t0).normalized()
				if n.y < 0.0:
					n = -n
				for v: Vector3 in tri:
					st.set_color(col)
					st.set_normal(n)
					st.add_vertex(v)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.vertex_color_is_srgb = true
	mat.roughness = 1.0
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = mat
	mi.position = center
	parent.add_child(mi)
	return mi


static func _v(origin: Vector3, x: int, z: int, cell: float, heights: Dictionary) -> Vector3:
	return origin + Vector3(x * cell, heights[Vector2i(x, z)], z * cell)


## Flat coloured slab (paths, plazas, floors).
static func slab(parent: Node3D, center: Vector3, size: Vector2, color: Color, height := 0.06, yaw := 0.0) -> MeshInstance3D:
	return LowPoly.part(parent, LowPoly.box(Vector3(size.x, height, size.y)), color, center + Vector3(0, height * 0.5, 0), Vector3(0, yaw, 0))
