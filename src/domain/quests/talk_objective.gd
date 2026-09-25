class_name TalkObjective
extends QuestObjective
## Speak with a specific NPC.

@export var npc_id: StringName


func _matches(event: GameEvent) -> bool:
	return event.type == GameEvent.NPC_TALKED and event.subject == npc_id
