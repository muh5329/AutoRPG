class_name Vfx
extends RefCounted
## Fire-and-forget visual effects for battles (all self-freeing).


static func floating_text(parent: Node, pos: Vector3, text: String, color: Color, size := 44,
		rise := 1.1, duration := 0.95) -> void:
	var l := Label3D.new()
	l.text = text
	l.font_size = size
	l.outline_size = 12
	l.modulate = color
	l.outline_modulate = Color(0.1, 0.07, 0.15, 0.9)
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.render_priority = 10
	l.outline_render_priority = 9
	l.pixel_size = 0.006
	parent.add_child(l)
	l.global_position = pos + Vector3(randf_range(-0.25, 0.25), 0, randf_range(-0.1, 0.1))
	l.scale = Vector3.ONE * 0.4
	var t := l.create_tween()
	t.tween_property(l, "scale", Vector3.ONE * 1.15, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(l, "scale", Vector3.ONE, 0.08)
	t.parallel().tween_property(l, "global_position:y", l.global_position.y + rise, duration).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(l, "modulate:a", 0.0, duration * 0.45).set_delay(duration * 0.55)
	t.parallel().tween_property(l, "outline_modulate:a", 0.0, duration * 0.45).set_delay(duration * 0.55)
	t.tween_callback(l.queue_free)


static func burst(parent: Node, pos: Vector3, color: Color, amount := 16, speed := 3.0, size := 0.07) -> void:
	var p := CPUParticles3D.new()
	p.one_shot = true
	p.emitting = false
	p.amount = amount
	p.lifetime = 0.55
	p.explosiveness = 0.95
	p.direction = Vector3.UP
	p.spread = 180.0
	p.initial_velocity_min = speed * 0.5
	p.initial_velocity_max = speed
	p.gravity = Vector3(0, -4.0, 0)
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.2
	p.color = color
	var curve := Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(1, 0))
	p.scale_amount_curve = curve
	var mesh := SphereMesh.new()
	mesh.radius = size
	mesh.height = size * 2.0
	mesh.radial_segments = 6
	mesh.rings = 3
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mesh.material = mat
	p.mesh = mesh
	parent.add_child(p)
	p.global_position = pos
	p.emitting = true
	parent.get_tree().create_timer(1.2).timeout.connect(p.queue_free)


## Glowing orb travelling in a slight arc; bursts on arrival.
static func projectile(parent: Node, from: Vector3, to: Vector3, color: Color, duration: float) -> void:
	var orb := LowPoly.part(parent as Node3D, LowPoly.sphere(0.12, 8, 5), color, Vector3.ZERO, Vector3.ZERO, Vector3.ONE, 3.0)
	orb.global_position = from
	var trail := CPUParticles3D.new()
	trail.amount = 16
	trail.lifetime = 0.25
	trail.local_coords = false
	trail.gravity = Vector3.ZERO
	trail.initial_velocity_min = 0.0
	trail.initial_velocity_max = 0.2
	trail.color = Color(color, 0.8)
	var m := SphereMesh.new()
	m.radius = 0.06
	m.height = 0.12
	m.radial_segments = 5
	m.rings = 3
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.material = mat
	trail.mesh = m
	orb.add_child(trail)
	var t := orb.create_tween()
	var mid := (from + to) * 0.5 + Vector3.UP * (0.4 + from.distance_to(to) * 0.08)
	var fly := func(k: float) -> void:
		var a := from.lerp(mid, k)
		var b := mid.lerp(to, k)
		orb.global_position = a.lerp(b, k)
	var land := func() -> void:
		burst(parent, to, color, 10, 2.2)
		orb.queue_free()
	t.tween_method(fly, 0.0, 1.0, duration)
	t.tween_callback(land)


## Expanding ring on the ground (casts, auras, heals).
static func ring(parent: Node, pos: Vector3, color: Color, radius := 1.2, duration := 0.5) -> void:
	var r := LowPoly.part(parent as Node3D, LowPoly.torus(0.8, 1.0, 20, 3), Color(color, 0.8), Vector3.ZERO, Vector3.ZERO, Vector3(0.2, 0.3, 0.2), 2.0)
	r.global_position = pos + Vector3.UP * 0.06
	var t := r.create_tween().set_parallel()
	t.tween_property(r, "scale", Vector3(radius, 0.3, radius), duration).set_ease(Tween.EASE_OUT)
	t.chain().tween_callback(r.queue_free)


## Soft column of light (heals, buffs).
static func pillar(parent: Node, pos: Vector3, color: Color, height := 2.2, duration := 0.6) -> void:
	var p := LowPoly.part(parent as Node3D, LowPoly.cylinder(0.5, 0.6, 1.0, 10), Color(color, 0.35), Vector3.ZERO, Vector3.ZERO, Vector3(1, height, 1), 2.0)
	p.global_position = pos + Vector3.UP * height * 0.5
	var t := p.create_tween()
	t.tween_property(p, "scale:x", 0.05, duration).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(p, "scale:z", 0.05, duration).set_ease(Tween.EASE_IN)
	t.tween_callback(p.queue_free)
