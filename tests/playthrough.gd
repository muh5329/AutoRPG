extends Node
## Automated end-to-end playthrough used for verification. Drives the real game
## through splash -> title -> town -> quests -> inn -> shop -> cave -> boss and
## saves screenshots. Run under a display:
##   godot --path . res://tests/playthrough.tscn -- --shots=/tmp/shots

var shots_dir := "user://shots"
var step := 0


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--shots="):
			shots_dir = arg.substr(8)
	DirAccess.make_dir_recursive_absolute(shots_dir)
	# Keep this harness alive across scene changes.
	var dummy := Node.new()
	get_tree().root.add_child.call_deferred(dummy)
	await get_tree().process_frame
	get_tree().current_scene = dummy
	_run()


func _run() -> void:
	get_tree().change_scene_to_file("res://scenes/screens/splash.tscn")
	await wait(1.2)
	await shot("splash")
	await wait(3.0)
	await shot("title")
	SceneRouter.start_new_game()
	await wait(0.5)
	await shot("loading")
	await until(func() -> bool: return zone() != null and not SceneRouter.is_busy(), 20)
	await wait(1.0)
	await shot("town_arrival")
	await wait(2.5)
	# Walk a bit so followers trail
	var p := zone().player
	for i in 40:
		p.move_with_velocity(Vector3(0.3, 0, -1).normalized() * 5.0, 0.033)
		p.moved.emit(p.global_position)
		await get_tree().physics_frame
	await wait(0.6)
	await shot("town_walk")
	# Talk to Elder Maren and accept the main quest
	await talk(&"maren")
	await shot("dialogue_elder")
	await choose_option("Quest")
	await wait(0.6)
	await shot("dialogue_offer")
	await choose_option("Accept")
	await wait(0.5)
	# Captain Aldric
	await talk(&"aldric")
	await choose_option("Quest")
	await choose_option("Accept")
	await wait(0.4)
	UI.toggle_window(&"quests")
	await wait(0.6)
	await shot("quest_window")
	UI.close_window()
	await wait(0.3)
	# Inn: recruit
	SceneRouter.go_to_zone(&"inn", &"default")
	await until(func() -> bool: return zone() != null and zone().zone_id == &"inn" and not SceneRouter.is_busy(), 20)
	await wait(1.0)
	await shot("inn")
	for id in [&"ignatius", &"lyra"]:
		await talk(id)
		if id == &"ignatius":
			await shot("dialogue_recruit")
		await choose_option("Join")
		await wait(0.4)
	await wait(1.0)
	await shot("inn_recruited")
	# Shop: buy potions and gear
	SceneRouter.go_to_zone(&"shop", &"default")
	await until(func() -> bool: return zone() != null and zone().zone_id == &"shop" and not SceneRouter.is_busy(), 20)
	await wait(0.8)
	await shot("shop_zone")
	await talk(&"tilda")
	await choose_option("Browse")
	await wait(0.6)
	await shot("shop_window")
	UI.close_window()
	await wait(0.3)
	# Back to town, turn in Aldric's quests
	SceneRouter.go_to_zone(&"town", &"shop_door")
	await until(func() -> bool: return zone() != null and zone().zone_id == &"town" and not SceneRouter.is_busy(), 20)
	await wait(0.5)
	await talk(&"aldric")
	await shot("dialogue_turnin")
	await choose_option("Complete")
	await wait(0.4)
	await choose_option("Accept")
	await wait(0.3)
	GameState.buy(Content.item(&"potion_health"))
	GameState.buy(Content.item(&"potion_health"))
	GameState.publish(GameEvent.new(GameEvent.NPC_TALKED, &"bram"))
	await wait(0.3)
	await talk(&"aldric")
	await choose_option("Complete")
	await wait(0.4)
	close_dialogue()
	# Spend skill points & look at party/bag
	for h in GameState.party.members():
		for a in h.get_hero_class().abilities:
			h.unlock(a)
	UI.toggle_window(&"party")
	await wait(0.8)
	await shot("party_window")
	UI.close_window()
	UI.toggle_window(&"bag")
	await wait(0.5)
	await shot("bag_window")
	UI.close_window()
	await wait(0.3)
	# Cave
	SceneRouter.go_to_zone(&"cave", &"default")
	await until(func() -> bool: return zone() != null and zone().zone_id == &"cave" and not SceneRouter.is_busy(), 20)
	await wait(1.2)
	await shot("cave_entrance")
	for enc_id in [&"cave_rats", &"cave_goblins", &"cave_spiders", &"cave_boss"]:
		var ok := await fight(enc_id)
		if not ok:
			print("PLAYTHROUGH: lost at ", enc_id)
			break
		for h in GameState.party.members():
			for a in h.get_hero_class().abilities:
				h.unlock(a)
		GameState.party.restore_all(0.8)
	await wait(1.0)
	await shot("cave_cleared")
	# Turn in main quest
	SceneRouter.go_to_zone(&"town", &"cave_exit")
	await until(func() -> bool: return zone() != null and zone().zone_id == &"town" and not SceneRouter.is_busy(), 20)
	await wait(0.5)
	await talk(&"maren")
	await shot("dialogue_final")
	await choose_option("Complete")
	await wait(1.0)
	await shot("finale")
	print("PLAYTHROUGH: quests completed = ", GameState.quest_log.states().filter(func(s: QuestState) -> bool: return s.status == QuestState.Status.COMPLETED).size())
	print("PLAYTHROUGH: party levels = ", GameState.party.members().map(func(h: Hero) -> int: return h.level))
	print("PLAYTHROUGH: gold = ", GameState.wallet.gold)
	print("PLAYTHROUGH DONE")
	get_tree().quit()


func fight(enc_id: StringName) -> bool:
	var enc: Encounter = null
	for c in zone().get_children():
		if c is Encounter and c.encounter_id == enc_id:
			enc = c
	if enc == null:
		print("PLAYTHROUGH: missing encounter ", enc_id)
		return false
	var z := zone()
	z.player.teleport(enc.to_global(Vector3(0, 0, enc.trigger_radius + 3.0)))
	z.party_controller.reseed()
	await wait(0.5)
	await shot("approach_%s" % enc_id)
	z.player.teleport(enc.to_global(Vector3(0, 0, enc.trigger_radius - 0.5)))
	await wait(0.5)
	if enc is BossEncounter:
		await shot("boss_intro")
		await choose_option("Prepare")
	await until(func() -> bool: return UI._window is PreBattleWindow, 5)
	await wait(0.5)
	await shot("prebattle_%s" % enc_id)
	(UI._window as PreBattleWindow)._fight()
	var director := z.active_battle
	await wait(2.5)
	await shot("battle_%s_a" % enc_id)
	BattleDirector.speed_index = 2
	await wait(5.0)
	await shot("battle_%s_b" % enc_id)
	await until(func() -> bool: return UI._window is BattleResultWindow, 150)
	await wait(0.8)
	await shot("result_%s" % enc_id)
	var won := director.battle.victory
	print("PLAYTHROUGH: %s victory=%s time=%.1f" % [enc_id, won, director.battle.elapsed])
	(UI._window as BattleResultWindow)._continue()
	await wait(1.0)
	return won


# --- helpers -----------------------------------------------------------------------------------

func zone() -> Zone:
	var s := get_tree().current_scene
	return s as Zone


func find_npc(id: StringName) -> NPC:
	for n in get_tree().get_nodes_in_group(WorldEntity.INTERACTABLE_GROUP):
		if n is NPC and n.entity_id == id:
			return n
	return null


func talk(id: StringName) -> void:
	var npc := find_npc(id)
	if npc == null:
		print("PLAYTHROUGH: NPC not found ", id)
		return
	var p := zone().player
	p.teleport(npc.global_position + npc.global_transform.basis.z * -1.8 * -1.0)
	zone().party_controller.reseed()
	await wait(0.3)
	npc.interact(p)
	await wait(0.2)
	UI.dialogue.advance()   # finish typing
	await wait(0.3)
	while UI.dialogue.is_open() and UI.dialogue._options.get_child_count() == 0:
		UI.dialogue.advance()
		await wait(0.2)
		if UI.dialogue._typing:
			UI.dialogue.advance()


func choose_option(prefix: String) -> void:
	await until(func() -> bool: return UI.dialogue.is_open() and UI.dialogue._options.get_child_count() > 0 or not UI.dialogue.is_open(), 3)
	if not UI.dialogue.is_open():
		UI.dialogue.advance()
	if UI.dialogue._typing:
		UI.dialogue.advance()
	await wait(0.1)
	for b in UI.dialogue._options.get_children():
		if (b as Button).text.begins_with(prefix):
			(b as Button).pressed.emit()
			await wait(0.3)
			if UI.dialogue.is_open() and UI.dialogue._typing:
				UI.dialogue.advance()
			return
	print("PLAYTHROUGH: option not found: ", prefix, " in ", UI.dialogue._options.get_children().map(func(b: Node) -> String: return (b as Button).text))


func close_dialogue() -> void:
	if UI.dialogue.is_open():
		UI.dialogue.close()


func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while not cond.call() and t < timeout:
		await get_tree().process_frame
		t += get_process_delta_time()
	if t >= timeout:
		print("PLAYTHROUGH: timeout waiting (step %d)" % step)


func shot(name_: String) -> void:
	await RenderingServer.frame_post_draw
	step += 1
	var img := get_viewport().get_texture().get_image()
	img.save_png("%s/%02d_%s.png" % [shots_dir, step, name_])
