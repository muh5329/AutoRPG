extends CanvasLayer
## Autoload "SceneRouter": every scene change goes through here, behind the
## loading screen, using background (threaded) resource loading.

const ZONES := {
	&"town": { "path": "res://scenes/zones/town.tscn", "title": "Oakhaven Village", "subtitle": "The village at the foot of the Glimmer Peaks" },
	&"inn": { "path": "res://scenes/zones/inn.tscn", "title": "The Sleepy Griffin Inn", "subtitle": "Warm beds and brave souls" },
	&"shop": { "path": "res://scenes/zones/shop.tscn", "title": "Tilda's Wares", "subtitle": "If it keeps you alive, she sells it" },
	&"cave": { "path": "res://scenes/zones/cave.tscn", "title": "Glimmerdeep Cave", "subtitle": "Something stirs in the dark" },
}
const TITLE_SCENE := "res://scenes/screens/title.tscn"
const MIN_LOADING_TIME := 0.9

var loading: LoadingScreen
var _busy := false


func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	loading = LoadingScreen.new()
	add_child(loading)


func is_busy() -> bool:
	return _busy


func go_to_zone(zone_id: StringName, spawn: StringName = &"default") -> void:
	var info: Dictionary = ZONES[zone_id]
	GameState.pending_spawn = spawn
	_transition(info.path, info.title, info.subtitle)


func go_to_title() -> void:
	_transition(TITLE_SCENE, "RPG Auto Battler", "Returning to the title screen")


func start_new_game() -> void:
	GameState.new_game()
	go_to_zone(&"town", &"default")


func _transition(path: String, title: String, subtitle: String) -> void:
	if _busy:
		return
	_busy = true
	GameState.reset_mode(GameState.Mode.TRANSITION)
	await loading.show_card(title, subtitle)
	UI.hide_all()
	var started := Time.get_ticks_msec()
	ResourceLoader.load_threaded_request(path)
	var progress: Array = []
	while true:
		var status := ResourceLoader.load_threaded_get_status(path, progress)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			break
		if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("SceneRouter: failed to load %s" % path)
			_busy = false
			return
		loading.set_progress(progress[0] * 0.6 if not progress.is_empty() else 0.1)
		await get_tree().process_frame
	var packed := ResourceLoader.load_threaded_get(path) as PackedScene
	loading.set_progress(0.7)
	await get_tree().process_frame
	get_tree().change_scene_to_packed(packed)
	# The zone builds itself in _ready; give it a couple of frames.
	await get_tree().process_frame
	await get_tree().process_frame
	loading.set_progress(1.0)
	while (Time.get_ticks_msec() - started) / 1000.0 < MIN_LOADING_TIME:
		await get_tree().process_frame
	await loading.hide_card()
	_busy = false
