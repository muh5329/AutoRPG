class_name BattleDirector
extends Node
## Orchestrates one in-place battle inside a Zone:
## pre-battle setup -> spawn views -> tick the Battle model -> rewards/defeat -> restore exploring.
## Owns no rules itself; the Battle model does all the maths.

signal speed_changed(multiplier: float)

enum Phase { SETUP, ENTERING, FIGHTING, RESOLVING, DONE }

const SPEEDS: Array[float] = [1.0, 2.0, 3.0]
const END_DELAY := 1.1
## Heroes walk into formation before the fight starts (capped so it never stalls).
const MAX_ENTER_TIME := 2.2

## Remembered between battles so players don't have to re-toggle.
static var speed_index := 0

var zone: Zone
var encounter: Encounter
var battle: Battle
var phase := Phase.SETUP

var _views: Dictionary = {}   # BattleUnit -> CombatUnitView
var _enter_time := 0.0


func begin(zone_: Zone, encounter_: Encounter) -> void:
	zone = zone_
	encounter = encounter_
	GameState.push_mode(GameState.Mode.BATTLE)
	zone.player.stop()
	var boss := encounter.definition.is_boss
	zone.camera_rig.frame_point(encounter.to_global(Vector3(0, 0, 0.2 if boss else 0.6)), 1.15 if boss else 1.0)
	UI.open_pre_battle(self)


func get_encounter_definition() -> EncounterDefinition:
	return encounter.definition


func speed() -> float:
	return SPEEDS[speed_index]


func cycle_speed() -> void:
	speed_index = (speed_index + 1) % SPEEDS.size()
	speed_changed.emit(speed())


func view_for(unit: BattleUnit) -> CombatUnitView:
	return _views.get(unit)


func views() -> Array:
	return _views.values()


# --- flow --------------------------------------------------------------------------------

func retreat() -> void:
	GameState.pop_mode(GameState.Mode.BATTLE)
	zone.camera_rig.release()
	zone.push_player_back_from(encounter)
	_done()


func start_fight() -> void:
	var fighters := GameState.party.living()
	if fighters.is_empty():
		EventBus.toast.emit("Your heroes are too wounded to fight. Rest at the inn!", &"warning")
		retreat()
		return
	battle = Battle.new(fighters, encounter.definition.spawn_monsters(), GameState.inventory)
	battle.ended.connect(_on_battle_ended)
	battle.ability_impact.connect(_on_impact)
	battle.potion_used.connect(func(u: BattleUnit, p: Potion) -> void:
		var v := view_for(u)
		if v:
			Vfx.burst(zone, v.get_chest(), p.icon_color, 18, 2.0))
	zone.party_controller.paused = true
	zone.party_controller.set_followers_visible(false)
	encounter.set_avatars_visible(false)
	zone.player.teleport(encounter.to_global(Vector3(-5.2, 0, 3.6)))
	zone.player.face_point(encounter.global_position)
	_spawn_views()
	UI.show_battle_hud(self)
	phase = Phase.ENTERING
	_enter_time = 0.0


func _process(delta: float) -> void:
	if phase == Phase.ENTERING:
		_enter_time += delta
		if _enter_time >= MAX_ENTER_TIME or _views.values().all(func(v: CombatUnitView) -> bool: return v.is_in_formation()):
			phase = Phase.FIGHTING
			battle.announce("Fight!")
	elif phase == Phase.FIGHTING:
		battle.tick(delta * speed())


func _spawn_views() -> void:
	var front: Array[BattleUnit] = []
	var back: Array[BattleUnit] = []
	for u in battle.heroes:
		if CombatTypes.is_ranged_role(u.combatant.get_role()):
			back.append(u)
		else:
			front.append(u)
	for r in 2:
		var row := front if r == 0 else back
		for i in row.size():
			var u: BattleUnit = row[i]
			var follower := zone.party_controller.follower_for(u.combatant as Hero)
			var start := follower.global_position if follower else zone.player.global_position
			var home := encounter.hero_slot(i, row.size(), r == 1)
			_add_view(u, start, home, encounter.facing_monsters_deg())
	for i in battle.monsters.size():
		var u := battle.monsters[i]
		var home := encounter.monster_slot(i, battle.monsters.size())
		_add_view(u, home, home, encounter.facing_heroes_deg())


func _add_view(unit: BattleUnit, start: Vector3, home: Vector3, yaw: float) -> void:
	var v := CombatUnitView.new().setup(unit, self, start, home, yaw)
	zone.add_child(v)
	_views[unit] = v


func _on_impact(_caster: BattleUnit, ability: Ability, target: BattleUnit) -> void:
	var v := view_for(target)
	if v and ability.delivery != CombatTypes.Delivery.PROJECTILE:
		Vfx.burst(zone, v.get_chest(), ability.fx_color, 12, 2.5)


func _on_battle_ended(victory: bool) -> void:
	phase = Phase.RESOLVING
	await get_tree().create_timer(END_DELAY).timeout
	if victory:
		for u in battle.heroes:
			if u.is_alive():
				view_for(u).model.play_victory()
		var report := GameState.grant_encounter_rewards(encounter.definition)
		GameState.session.recover_after_victory()
		UI.show_battle_result(true, encounter.definition, report, _finish_victory)
	else:
		UI.show_battle_result(false, encounter.definition, null, _finish_defeat)


func _finish_victory() -> void:
	UI.hide_battle_hud()
	for u in battle.heroes:
		var f := zone.party_controller.follower_for(u.combatant as Hero)
		if f:
			f.global_position = view_for(u).global_position
	_clear_views()
	zone.party_controller.set_followers_visible(true)
	zone.party_controller.paused = false
	zone.party_controller.reseed()
	encounter.mark_cleared()
	GameState.pop_mode(GameState.Mode.BATTLE)
	zone.camera_rig.release()
	_done()


func _finish_defeat() -> void:
	UI.hide_battle_hud()
	GameState.party.restore_all(1.0)
	phase = Phase.DONE
	SceneRouter.go_to_zone(&"inn", &"default")
	EventBus.toast.emit("Your party was carried back to the Sleepy Griffin to recover.", &"warning")


func _clear_views() -> void:
	for v in _views.values():
		v.queue_free()
	_views.clear()


func _done() -> void:
	phase = Phase.DONE
	zone.on_battle_finished(self)
	queue_free()
