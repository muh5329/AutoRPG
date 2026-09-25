class_name Quest
extends Resource
## Authored quest definition. Runtime progress is tracked by QuestState.

@export var id: StringName
@export var title: String
@export var summary: String
@export_multiline var description: String
@export var giver_id: StringName
@export var giver_name: String
@export var is_main_story: bool = false
## Quest that must be completed before this one is offered ("" = none).
@export var prerequisite_id: StringName
@export var objectives: Array[QuestObjective] = []
@export var reward_gold: int = 0
@export var reward_xp: int = 0
@export var reward_items: Array[Item] = []
@export_multiline var offer_text: String
@export_multiline var in_progress_text: String
@export_multiline var complete_text: String


func describe_rewards() -> String:
	var parts: PackedStringArray = []
	if reward_gold > 0: parts.append("%d Gold" % reward_gold)
	if reward_xp > 0: parts.append("%d XP" % reward_xp)
	for item in reward_items:
		parts.append(item.display_name)
	return ", ".join(parts)
