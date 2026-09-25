extends Node
## Renders one zone for visual checks: godot --path . res://tests/zone_shot.tscn -- --zone=town --out=/tmp/x.png

func _ready() -> void:
	var zone_id := &"town"
	var out := "/tmp/zone.png"
	var spawn := &"default"
	var battle_id := &""
	var recruit := false
	var window := &""
	var title := false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--zone="): zone_id = StringName(arg.substr(7))
		if arg.begins_with("--out="): out = arg.substr(6)
		if arg.begins_with("--spawn="): spawn = StringName(arg.substr(8))
		if arg.begins_with("--battle="): battle_id = StringName(arg.substr(9))
		if arg.begins_with("--recruit"): recruit = true
		if arg.begins_with("--window="): window = StringName(arg.substr(9))
		if arg == "--title": title = true
	var dummy := Node.new()
	get_tree().root.add_child.call_deferred(dummy)
	await get_tree().process_frame
	get_tree().current_scene = dummy
	if recruit:
		GameState.recruit(Content.hero(&"ignatius"))
		GameState.recruit(Content.hero(&"lyra"))
		for h in GameState.party.members():
			h.add_xp(300)
			for a in h.get_hero_class().abilities:
				h.unlock(a)
	if title:
		SceneRouter.go_to_title()
	else:
		SceneRouter.go_to_zone(zone_id, spawn)
	await get_tree().create_timer(4.0).timeout
	if window != &"":
		UI.toggle_window(window)
		await get_tree().create_timer(1.0).timeout
	if battle_id != &"":
		var zone := get_tree().current_scene as Zone
		for c in zone.get_children():
			if c is Encounter and c.encounter_id == battle_id:
				zone.player.teleport(c.to_global(Vector3(0, 0, c.trigger_radius - 0.5)))
		await get_tree().create_timer(1.0).timeout
		if UI.dialogue.is_open():
			UI.dialogue._dialogue.options[0].action.call()
			UI.dialogue.close()
			await get_tree().create_timer(0.5).timeout
		(UI._window as PreBattleWindow)._fight()
		await get_tree().create_timer(7.0).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(out)
	get_tree().quit()
