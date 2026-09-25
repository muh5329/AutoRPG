extends Node
## Autoload "Portraits": renders character busts from their real 3D models into
## textures (one tiny off-screen viewport each, rendered once and cached).

const SIZE := Vector2i(192, 192)

var _cache: Dictionary = {}


func for_hero(hero: Hero) -> Texture2D:
	return for_appearance(hero.definition.id, hero.get_appearance())


func for_appearance(key: StringName, appearance: Appearance) -> Texture2D:
	if _cache.has(key):
		return _cache[key]
	var vp := SubViewport.new()
	vp.size = SIZE
	vp.transparent_bg = true
	vp.own_world_3d = true
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(vp)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_CLEAR_COLOR
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("d9e2ff")
	e.ambient_light_energy = 0.75
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = e
	vp.add_child(env)
	var key_light := DirectionalLight3D.new()
	key_light.rotation_degrees = Vector3(-30, 150, 0)
	key_light.light_energy = 1.1
	vp.add_child(key_light)
	var model := ModelFactory.build(appearance)
	model.set_process(false)
	vp.add_child(model)
	var head := model.get_height() * 0.66
	var cam := Camera3D.new()
	cam.fov = 26.0
	vp.add_child(cam)
	cam.position = Vector3(0.45, head + 0.12, -2.2) * maxf(appearance.scale, 0.8)
	cam.look_at(Vector3(0, head - 0.05, 0))
	var tex := vp.get_texture()
	_cache[key] = tex
	return tex
