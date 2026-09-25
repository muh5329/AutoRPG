class_name GameEvent
extends RefCounted
## Something that happened in the world that quests (and others) may care about.
## Published through GameState.publish(); consumed by QuestLog.

const NPC_TALKED := &"npc_talked"
const ENCOUNTER_CLEARED := &"encounter_cleared"
const HERO_RECRUITED := &"hero_recruited"
const ITEM_PURCHASED := &"item_purchased"

var type: StringName
## Id of whatever the event is about (npc id, encounter id, item id...).
var subject: StringName
## Count or absolute value (e.g. party size for HERO_RECRUITED).
var amount: int


func _init(type_: StringName, subject_: StringName = &"", amount_: int = 1) -> void:
	type = type_
	subject = subject_
	amount = amount_
