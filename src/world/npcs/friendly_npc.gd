class_name FriendlyNPC
extends NPC
## An NPC you can hold a conversation with. Subclasses add dialogue options
## (quests, shops, recruiting) by overriding _add_options().

@export var greeting: PackedStringArray = ["Hello there, traveller."]


func _on_interact(_player: PlayerAvatar) -> void:
	GameState.publish(GameEvent.new(GameEvent.NPC_TALKED, entity_id))
	EventBus.dialogue_requested.emit(build_dialogue())


func build_dialogue() -> Dialogue:
	var d := Dialogue.new(display_name, _greeting_pages())
	d.appearance = appearance
	_add_options(d)
	d.add_option("Goodbye", turn_back_home)
	return d


## Hook: extra choices offered after the greeting.
func _add_options(_dialogue: Dialogue) -> void:
	pass


## Hook: what the NPC says first.
func _greeting_pages() -> PackedStringArray:
	return greeting
