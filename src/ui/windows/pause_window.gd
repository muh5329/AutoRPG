class_name PauseWindow
extends UiWindow
## Esc menu: resume, controls reference, return to title, quit.


func _init() -> void:
	window_title = "Menu"
	window_size = Vector2(560, 0)


func _build(b: VBoxContainer) -> void:
	b.add_child(UiKit.button("Resume", close, "", 0))
	b.add_child(HSeparator.new())
	b.add_child(UiKit.label("Controls", 20, UiKit.INK, 650))
	for pair in [
			["Move", "WASD / Arrow keys, or click the ground"],
			["Interact", "E / Space, or click an NPC or door"],
			["Party", "P"], ["Bag", "I"], ["Quests", "J"],
			["Zoom", "Mouse wheel"], ["Battle speed", "Tab"], ["Menu", "Esc"]]:
		var r := UiKit.hbox()
		r.add_child(UiKit.label(pair[0], 16, UiKit.INK_SOFT))
		r.add_child(UiKit.spacer())
		r.add_child(UiKit.label(pair[1], 16, UiKit.INK, 600))
		b.add_child(r)
	b.add_child(HSeparator.new())
	var row := UiKit.hbox(10)
	var to_title := func() -> void:
		force_close()
		SceneRouter.go_to_title()
	var title_btn := UiKit.button("Title Screen", to_title, "SecondaryButton")
	title_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title_btn)
	var quit := UiKit.button("Quit Game", func() -> void: get_tree().quit(), "DangerButton")
	quit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(quit)
	b.add_child(row)
