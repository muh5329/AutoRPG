class_name Controls
extends RefCounted
## Registers input actions at startup so bindings live in one readable place.

const BINDINGS := {
	&"move_up": [KEY_W, KEY_UP],
	&"move_down": [KEY_S, KEY_DOWN],
	&"move_left": [KEY_A, KEY_LEFT],
	&"move_right": [KEY_D, KEY_RIGHT],
	&"interact": [KEY_E, KEY_SPACE, KEY_ENTER],
	&"open_party": [KEY_P, KEY_C],
	&"open_bag": [KEY_I, KEY_B],
	&"open_quests": [KEY_J, KEY_L],
	&"cancel": [KEY_ESCAPE],
	&"battle_speed": [KEY_TAB],
}


static func register_actions() -> void:
	for action: StringName in BINDINGS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for keycode: Key in BINDINGS[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = keycode
			InputMap.action_add_event(action, ev)


static func key_label(action: StringName) -> String:
	var keys: Array = BINDINGS.get(action, [])
	return OS.get_keycode_string(keys[0]) if not keys.is_empty() else ""
