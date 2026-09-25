extends CanvasLayer
## Autoload "UI": owns every piece of screen UI and routes requests to it.
## Game code asks for UI through this facade (open_window, show_battle_hud...)
## so no gameplay class ever builds widgets itself.

var root: Control
var hud: Hud
var battle_hud: BattleHud
var dialogue: DialogueBox
var toasts: ToastStack
var _window_layer: Control
var _window: UiWindow
var _window_kind: StringName = &""


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	root = Control.new()
	root.name = "Root"
	root.theme = UiKit.theme()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud = Hud.new()
	root.add_child(hud)
	battle_hud = BattleHud.new()
	root.add_child(battle_hud)
	dialogue = DialogueBox.new()
	root.add_child(dialogue)
	_window_layer = Control.new()
	_window_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_window_layer)
	_window_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	toasts = ToastStack.new()
	root.add_child(toasts)
	hide_all()
	EventBus.toast.connect(toasts.push)
	EventBus.dialogue_requested.connect(show_dialogue)
	EventBus.shop_requested.connect(func(v: Vendor) -> void: open_window(ShopWindow.new(v), &"shop"))
	dialogue.finished.connect(func() -> void: GameState.pop_mode(GameState.Mode.DIALOGUE))


# --- zone lifecycle ---------------------------------------------------------------------------

func enter_zone(zone: Zone) -> void:
	close_window()
	battle_hud.visible = false
	hud.visible = true
	hud.show_zone(zone)


func hide_all() -> void:
	close_window()
	if dialogue.is_open():
		dialogue.close()
	hud.visible = false
	battle_hud.visible = false
	battle_hud.unbind()


# --- windows ----------------------------------------------------------------------------------

func is_window_open() -> bool:
	return _window != null and is_instance_valid(_window)


func open_window(window: UiWindow, kind: StringName = &"") -> void:
	close_window()
	_window = window
	_window_kind = kind
	_window_layer.add_child(window)
	if window.pauses_exploration:
		GameState.push_mode(GameState.Mode.WINDOW)
	window.closed.connect(_on_window_closed.bind(window))


func close_window() -> void:
	if is_window_open():
		_window.force_close()


func toggle_window(kind: StringName) -> void:
	if is_window_open() and _window_kind == kind:
		_window.close()
		return
	if is_window_open() and not _window.closable:
		return
	if not (GameState.is_exploring() or GameState.mode() == GameState.Mode.WINDOW):
		return
	match kind:
		&"party": open_window(PartyWindow.new(), kind)
		&"bag": open_window(InventoryWindow.new(), kind)
		&"quests": open_window(QuestWindow.new(), kind)
		&"pause": open_window(PauseWindow.new(), kind)


func _on_window_closed(window: UiWindow) -> void:
	if window.pauses_exploration:
		GameState.pop_mode(GameState.Mode.WINDOW)
	if _window == window:
		_window = null
		_window_kind = &""


func _unhandled_input(event: InputEvent) -> void:
	if not hud.visible and not battle_hud.visible:
		return
	if event.is_action_pressed(&"cancel"):
		if is_window_open():
			_window.close()
		elif dialogue.is_open():
			pass
		else:
			toggle_window(&"pause")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"open_party"):
		toggle_window(&"party")
	elif event.is_action_pressed(&"open_bag"):
		toggle_window(&"bag")
	elif event.is_action_pressed(&"open_quests"):
		toggle_window(&"quests")


# --- dialogue ------------------------------------------------------------------------------------

func show_dialogue(d: Dialogue) -> void:
	if not dialogue.is_open():
		GameState.push_mode(GameState.Mode.DIALOGUE)
	var portrait: Texture2D = null
	if d.appearance:
		portrait = Portraits.for_appearance(StringName("npc_" + d.speaker), d.appearance)
	dialogue.open(d, portrait)


# --- battle -----------------------------------------------------------------------------------------

func open_pre_battle(director: BattleDirector) -> void:
	open_window(PreBattleWindow.new(director), &"pre_battle")


func show_battle_hud(director: BattleDirector) -> void:
	hud.visible = false
	battle_hud.visible = true
	battle_hud.bind(director)


func hide_battle_hud() -> void:
	battle_hud.unbind()
	battle_hud.visible = false
	hud.visible = true


func show_battle_result(victory: bool, def: EncounterDefinition, report: RewardReport, on_continue: Callable) -> void:
	open_window(BattleResultWindow.new(victory, def, report, on_continue), &"result")
