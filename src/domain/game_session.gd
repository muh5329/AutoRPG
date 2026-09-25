class_name GameSession
extends RefCounted
## Aggregate root of one playthrough: everything that would be saved.
## Pure data + rules; GameState (autoload) exposes it to the scene tree.

const STARTING_GOLD := 120
## After a won fight, fallen heroes get back up with this much health.
const POST_BATTLE_REVIVE := 0.25

var party := Party.new()
var inventory := Inventory.new()
var wallet := Wallet.new(STARTING_GOLD)
var quest_log := QuestLog.new()
var cleared_encounters: Dictionary = {}   # encounter id -> true


func is_cleared(encounter_id: StringName) -> bool:
	return cleared_encounters.has(encounter_id)


func mark_cleared(encounter_id: StringName) -> void:
	cleared_encounters[encounter_id] = true


## XP is shared by the whole party (dead heroes included), AFK style.
func grant(xp: int, gold: int, items: Array[Item]) -> RewardReport:
	var report := RewardReport.new()
	report.xp = xp
	report.gold = gold
	wallet.earn(gold)
	for item in items:
		inventory.add(item)
		report.items.append(item)
	for hero in party.members():
		var gained := hero.add_xp(xp)
		if gained > 0:
			report.level_ups.append({ "hero": hero, "level": hero.level })
	return report


func recover_after_victory() -> void:
	for hero in party.members():
		if not hero.is_alive():
			hero.restore_percent(POST_BATTLE_REVIVE)
