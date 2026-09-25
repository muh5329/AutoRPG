extends Node3D
## Title screen: a cosy low-poly campfire diorama with the starting heroes,
## a slowly orbiting camera, and the main menu.

var _camera: Camera3D
var _angle := 0.0
var _fire_light: OmniLight3D
var _time := 0.0


func _ready() -> void:
	GameState.reset_mode(GameState.Mode.MENU)
	_build_scene()
	_build_menu()


func _build_scene() -> void:
	var env := Environment.new()
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("26315e")
	sky_mat.sky_horizon_color = Color("e9876a")
	sky_mat.ground_horizon_color = Color("e9876a")
	sky_mat.ground_bottom_color = Color("2d3a2a")
	sky.sky_material = sky_mat
	env.sky = sky
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("8f86c9")
	env.ambient_light_energy = 0.5
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.8
	env.fog_enabled = true
	env.fog_light_color = Color("c9708a")
	env.fog_density = 0.006
	env.fog_sky_affect = 0.0
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color("ffb38a")
	sun.light_energy = 0.7
	sun.rotation_degrees = Vector3(-18, 60, 0)
	sun.shadow_enabled = true
	add_child(sun)
	Terrain.ground(self, Vector3(0, -0.05, 0), Vector2(70, 70), Color("5e9e4a"), Color("86bb4e"), 3)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for i in 40:
		var ang := rng.randf() * TAU
		var r := rng.randf_range(9.0, 26.0)
		var p := Vector3(cos(ang) * r, 0, sin(ang) * r)
		if i % 3 == 0:
			Props.pine_tree(self, p, rng.randf_range(1.0, 1.6), i)
		else:
			Props.round_tree(self, p, rng.randf_range(0.9, 1.4), i)
	for i in 14:
		var ang := rng.randf() * TAU
		Props.flower_patch(self, Vector3(cos(ang), 0, sin(ang)) * rng.randf_range(4.0, 8.0), i)
	Props.boulder(self, Vector3(-2.6, 0, -1.8), 0.7, 3)
	Props.mountain(self, Vector3(-18, 0, -30), 10, 9, 1)
	Props.mountain(self, Vector3(10, 0, -34), 12, 12, 2)
	# Campfire
	for i in 8:
		var ang := TAU * i / 8.0
		Props.boulder(self, Vector3(cos(ang) * 0.75, 0, sin(ang) * 0.75), 0.22, i, Color("8e8a86"))
	LowPoly.part(self, LowPoly.cone(0.38, 0.8, 6), Color("ffb347"), Vector3(0, 0.4, 0), Vector3.ZERO, Vector3.ONE, 3.0)
	LowPoly.part(self, LowPoly.cone(0.22, 0.5, 5), Color("ffe066"), Vector3(0, 0.35, 0), Vector3.ZERO, Vector3.ONE, 3.5)
	_fire_light = OmniLight3D.new()
	_fire_light.light_color = Color("ff9f4a")
	_fire_light.light_energy = 2.5
	_fire_light.omni_range = 9.0
	_fire_light.position = Vector3(0, 1.0, 0)
	add_child(_fire_light)
	# Heroes around the fire
	var ids := [&"garrick", &"seraphine", &"wren", &"ignatius", &"lyra"]
	for i in ids.size():
		var ang := -PI * 0.5 + (i - 2) * 0.62
		var model := ModelFactory.build(Content.hero(ids[i]).appearance)
		add_child(model)
		model.position = Vector3(cos(ang) * 2.1, 0, sin(ang) * 2.1 + 0.4)
		model.rotation.y = atan2(model.position.x, model.position.z)
	_camera = Camera3D.new()
	_camera.fov = 40
	add_child(_camera)


func _build_menu() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.theme = UiKit.theme()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	var col := UiKit.vbox(14)
	col.custom_minimum_size.x = 520
	root.add_child(col)
	col.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT, Control.PRESET_MODE_MINSIZE, 90)
	var title := UiKit.outlined(UiKit.title("RPG Auto Battler", 76, Color("fff3d1")), Color(0.25, 0.1, 0.2), 14)
	col.add_child(title)
	var sub := UiKit.outlined(UiKit.label("A party adventure in the Glimmer Peaks  ·  working title", 20, Color("ffe6a3")), Color(0.25, 0.1, 0.2), 6)
	col.add_child(sub)
	col.add_child(UiKit.spacer(false))
	var new_game := UiKit.button("New Game", SceneRouter.start_new_game, "", 320)
	new_game.add_theme_font_size_override("font_size", 28)
	col.add_child(new_game)
	var quit := UiKit.button("Quit", func() -> void: get_tree().quit(), "SecondaryButton", 320)
	quit.add_theme_font_size_override("font_size", 22)
	col.add_child(quit)
	for b in [new_game, quit]:
		b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	new_game.grab_focus.call_deferred()
	var footer := UiKit.outlined(UiKit.label("v0.1 · First iteration · Warrior · Priest · Hunter · Mage", 15, Color(1, 1, 1, 0.75)), Color(0.1, 0.05, 0.15), 5)
	root.add_child(footer)
	footer.grow_vertical = Control.GROW_DIRECTION_BEGIN
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, 18)


func _process(delta: float) -> void:
	_time += delta
	_angle += delta * 0.08
	_camera.position = Vector3(sin(_angle) * 9.0 + 3.0, 3.6, cos(_angle) * 9.0)
	_camera.look_at(Vector3(1.2, 0.9, 0), Vector3.UP)
	_fire_light.light_energy = 2.4 + sin(_time * 9.0) * 0.25 + sin(_time * 23.0) * 0.15
