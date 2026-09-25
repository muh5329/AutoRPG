class_name WorldEntity
extends Node3D
## Abstract root of everything placed in a Zone.
## Declares the Interactable protocol as overridable template methods so any
## entity (NPC, door, chest...) can opt in without multiple inheritance.

const INTERACTABLE_GROUP := &"interactable"

@export var entity_id: StringName
@export var display_name: String


func _ready() -> void:
	if is_interactable():
		add_to_group(INTERACTABLE_GROUP)


## Owning zone (entities are always children somewhere under a Zone).
func get_zone() -> Zone:
	var n := get_parent()
	while n and not (n is Zone):
		n = n.get_parent()
	return n as Zone


# --- Interactable protocol ------------------------------------------------------------

func is_interactable() -> bool:
	return false


func can_interact() -> bool:
	return is_interactable() and visible


func get_interaction_radius() -> float:
	return 2.2


## Verb shown in the prompt, e.g. "Talk", "Enter".
func get_interaction_verb() -> String:
	return "Use"


func get_interaction_prompt() -> String:
	return "%s %s" % [get_interaction_verb(), display_name]


func interact(_player: PlayerAvatar) -> void:
	pass
