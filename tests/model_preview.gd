extends Node3D
## Visual smoke test: renders every character appearance in a line-up.
## godot --path . res://tests/model_preview.tscn

func _ready() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("9fd3e6")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("c9d8ff")
	e.ambient_light_energy = 0.7
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -35, 0)
	sun.light_color = Color("fff1d6")
	sun.shadow_enabled = true
	add_child(sun)
	var ground := MeshInstance3D.new()
	ground.mesh = LowPoly.box(Vector3(30, 0.2, 10))
	ground.material_override = LowPoly.material(Color("8fcf6a"))
	ground.position.y = -0.1
	add_child(ground)
	var apps: Array[Appearance] = []
	var heroes := HeroCatalog.build(_idx(ClassCatalog.build()), _idx(ItemCatalog.build()))
	for h in heroes:
		apps.append(h.appearance)
	for m in MonsterCatalog.build_monsters():
		apps.append(m.appearance)
	var x := -(apps.size() - 1) * 0.9
	for a in apps:
		var model := ModelFactory.build(a)
		model.position = Vector3(x, 0, 0)
		model.rotation_degrees.y = 180
		add_child(model)
		x += 1.8
	var cam := Camera3D.new()
	cam.fov = 38
	cam.position = Vector3(0, 9, 15)
	add_child(cam)
	cam.look_at(Vector3(0, 0.8, 0))
	await get_tree().create_timer(0.5).timeout
	get_viewport().get_texture().get_image().save_png(OS.get_environment("SHOT") if OS.get_environment("SHOT") != "" else "/tmp/shot.png")
	get_tree().quit()


func _idx(arr: Array) -> Dictionary:
	var d := {}
	for e in arr:
		d[e.id] = e
	return d
