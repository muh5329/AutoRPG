class_name PurchaseObjective
extends QuestObjective
## Buy a specific item from any vendor.

@export var item_id: StringName


func _matches(event: GameEvent) -> bool:
	return event.type == GameEvent.ITEM_PURCHASED and event.subject == item_id
