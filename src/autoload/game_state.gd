extends Node
## Autoload "GameState": owns the current GameSession and the game's input mode,
## and is the single entry point for world-changing actions (recruit, buy, rewards).

enum Mode { MENU, EXPLORE, DIALOGUE, WINDOW, BATTLE, TRANSITION }

var session: GameSession
## Marker name the next zone should place the party at.
var pending_spawn: StringName = &"default"

var _mode_stack: Array[Mode] = [Mode.MENU]


func _ready() -> void:
	Controls.register_actions()
	new_game()


func new_game() -> void:
	session = GameSession.new()
	session.quest_log.quest_updated.connect(_on_quest_updated)
	session.quest_log.quest_accepted.connect(func(s: QuestState) -> void:
		EventBus.toast.emit("New Quest: %s" % s.quest.title, &"quest"))
	for id in [&"garrick", &"seraphine", &"wren"]:
		session.party.add(Hero.new(Content.hero(id)))
	session.inventory.add(Content.item(&"potion_health"), 2)
	pending_spawn = &"default"


# --- mode stack ----------------------------------------------------------------------

func mode() -> Mode:
	return _mode_stack.back()


func is_exploring() -> bool:
	return mode() == Mode.EXPLORE


func push_mode(m: Mode) -> void:
	_mode_stack.append(m)


func pop_mode(expected: Mode) -> void:
	if _mode_stack.size() > 1 and _mode_stack.back() == expected:
		_mode_stack.pop_back()


func reset_mode(m: Mode) -> void:
	_mode_stack = [m]


# --- convenience accessors -------------------------------------------------------------

var party: Party:
	get: return session.party
var inventory: Inventory:
	get: return session.inventory
var wallet: Wallet:
	get: return session.wallet
var quest_log: QuestLog:
	get: return session.quest_log


# --- world actions --------------------------------------------------------------------------

func publish(event: GameEvent) -> void:
	session.quest_log.handle(event)


func recruit(definition: HeroDefinition) -> Hero:
	if party.is_full() or party.has_definition(definition.id):
		return null
	var hero := Hero.new(definition, party.average_level())
	party.add(hero)
	EventBus.toast.emit("%s joined the party!" % hero.display_name, &"reward")
	publish(GameEvent.new(GameEvent.HERO_RECRUITED, definition.id, party.size()))
	return hero


func buy(item: Item) -> bool:
	if not wallet.spend(item.price):
		EventBus.toast.emit("Not enough gold.", &"warning")
		return false
	inventory.add(item)
	publish(GameEvent.new(GameEvent.ITEM_PURCHASED, item.id))
	return true


func sell(item: Item) -> bool:
	if not inventory.remove(item):
		return false
	wallet.earn(item.get_sell_price())
	return true


func rest(cost: int) -> bool:
	if not wallet.spend(cost):
		EventBus.toast.emit("Not enough gold to rest.", &"warning")
		return false
	party.restore_all(1.0)
	EventBus.toast.emit("Your party is fully rested.", &"info")
	return true


func accept_quest(quest: Quest) -> void:
	session.quest_log.accept(quest)


func turn_in_quest(quest: Quest) -> RewardReport:
	if not session.quest_log.complete(quest.id):
		return null
	EventBus.toast.emit("Quest Complete: %s" % quest.title, &"quest")
	var report := session.grant(quest.reward_xp, quest.reward_gold, quest.reward_items)
	announce_rewards(report)
	return report


func grant_encounter_rewards(def: EncounterDefinition) -> RewardReport:
	session.mark_cleared(def.id)
	var report := session.grant(def.total_xp(), def.total_gold(), def.loot)
	publish(GameEvent.new(GameEvent.ENCOUNTER_CLEARED, def.id))
	return report


func announce_rewards(report: RewardReport) -> void:
	if report.gold > 0:
		EventBus.toast.emit("+%d Gold" % report.gold, &"reward")
	for item in report.items:
		EventBus.toast.emit("Received %s" % item.display_name, &"reward")
	for lu in report.level_ups:
		EventBus.toast.emit("%s reached level %d!" % [lu.hero.display_name, lu.level], &"level")


func _on_quest_updated(state: QuestState) -> void:
	if state.status == QuestState.Status.READY_TO_TURN_IN:
		EventBus.toast.emit("%s — return to %s" % [state.quest.title, state.quest.giver_name], &"quest")
	else:
		EventBus.toast.emit("Quest updated: %s" % state.quest.title, &"quest")
