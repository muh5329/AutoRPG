class_name BattleUnit
extends RefCounted
## Transient per-battle wrapper around a persistent Combatant.
## Owns everything that only exists during a fight: action bar, cooldowns,
## casts, statuses, focus target and brain. HP lives on the Combatant so hero
## damage persists between encounters.
## Views observe it purely through signals (model never touches nodes).

signal acted(ability: Ability, targets: Array[BattleUnit])
signal cast_started(ability: Ability, duration: float)
signal cast_ended(interrupted: bool)
signal damaged(amount: float, is_crit: bool, school: int, is_tick: bool)
signal healed(amount: float, is_crit: bool, is_tick: bool)
signal absorbed(amount: float)
signal status_added(status: StatusEffect)
signal status_removed(status: StatusEffect)
signal died

const CRIT_MULTIPLIER := 1.5

var combatant: Combatant
var team: CombatTypes.Team
## Formation index within its team (0 = front).
var slot: int
var brain: BattleBrain
var focus: BattleUnit
var statuses: Array[StatusEffect] = []
var last_ability: Ability

var recovery_total: float = 1.0
var recovery_remaining: float = 0.0

var cast_ability: Ability
var cast_targets: Array[BattleUnit] = []
var cast_total: float = 0.0
var cast_remaining: float = 0.0

var _cooldowns: Dictionary = {}  # Ability -> seconds remaining


func _init(combatant_: Combatant, team_: CombatTypes.Team, slot_: int) -> void:
	combatant = combatant_
	team = team_
	slot = slot_
	brain = combatant.create_brain()
	# Stagger openers so units don't all act on the same frame.
	recovery_total = 0.6 + slot * 0.25
	recovery_remaining = recovery_total


# --- queries -------------------------------------------------------------------

func get_name() -> String:
	return combatant.display_name


func is_alive() -> bool:
	return combatant.is_alive()


func get_hp_ratio() -> float:
	return combatant.current_hp / maxf(get_stats().max_hp, 1.0)


func get_stats() -> StatBlock:
	var s := combatant.get_stats().copy()
	for st in statuses:
		st.modify_stats(s)
	return s


func is_casting() -> bool:
	return cast_ability != null


func is_casting_interruptible() -> bool:
	return cast_ability != null and cast_ability.interruptible


func is_stunned() -> bool:
	for st in statuses:
		if st.prevents_action():
			return true
	return false


func get_forced_target() -> BattleUnit:
	for st in statuses:
		var t := st.get_forced_target()
		if t:
			return t
	return null


func has_status(status_id: StringName) -> bool:
	return get_status(status_id) != null


func get_status(status_id: StringName) -> StatusEffect:
	for st in statuses:
		if st.id == status_id:
			return st
	return null


## 0..1 fill of the action bar shown under the health bar.
func action_progress() -> float:
	if recovery_total <= 0.0:
		return 1.0
	return clampf(1.0 - recovery_remaining / recovery_total, 0.0, 1.0)


func cast_progress() -> float:
	if not is_casting() or cast_total <= 0.0:
		return 0.0
	return clampf(1.0 - cast_remaining / cast_total, 0.0, 1.0)


func cooldown_remaining(ability: Ability) -> float:
	return _cooldowns.get(ability, 0.0)


## Enabled, unlocked, off-cooldown abilities in the player's priority order, then the basic attack.
func get_usable_abilities() -> Array[Ability]:
	var out: Array[Ability] = []
	for a in combatant.get_battle_abilities():
		if cooldown_remaining(a) <= 0.0:
			out.append(a)
	out.append(combatant.get_basic_attack())
	return out


# --- combat operations -----------------------------------------------------------

func take_damage(raw: float, _school: int, attacker: BattleUnit, is_crit: bool, is_tick := false) -> float:
	if not is_alive():
		return 0.0
	var amount := raw * (CRIT_MULTIPLIER if is_crit else 1.0) * get_stats().mitigation()
	for st in statuses.duplicate():
		amount = st.modify_incoming_damage(amount)
	amount = maxf(amount, 0.0)
	var dealt := combatant.apply_damage(amount)
	if dealt > 0.0:
		damaged.emit(dealt, is_crit, _school, is_tick)
	if attacker and attacker != self and attacker.team != team and focus == null:
		focus = attacker
	if not is_alive():
		_on_death()
	return dealt


func receive_heal(raw: float, _healer: BattleUnit, is_crit: bool, is_tick := false) -> float:
	if not is_alive():
		return 0.0
	var healed_amount := combatant.apply_heal(raw * (CRIT_MULTIPLIER if is_crit else 1.0))
	healed.emit(healed_amount, is_crit, is_tick)
	return healed_amount


func add_status(status: StatusEffect, battle: Battle) -> void:
	if not is_alive():
		return
	if status.prevents_action() and combatant.is_control_immune():
		battle.announce("%s is immune!" % get_name())
		return
	var existing := get_status(status.id)
	if existing:
		_remove_status(existing, null)
	statuses.append(status)
	status.on_applied(battle)
	status_added.emit(status)


## Cancels the current cast. `force` ignores the interruptible flag (stuns).
func interrupt(force := false) -> bool:
	if not is_casting() or (not force and not cast_ability.interruptible):
		return false
	cast_ability = null
	cast_targets.clear()
	cast_ended.emit(true)
	begin_recovery(1.2)
	return true


func begin_recovery(duration: float) -> void:
	recovery_total = maxf(duration / (1.0 + get_stats().haste), 0.2)
	recovery_remaining = recovery_total


func start_cooldown(ability: Ability) -> void:
	if ability.cooldown > 0.0:
		_cooldowns[ability] = ability.cooldown


# --- simulation step ---------------------------------------------------------------

func tick(delta: float, battle: Battle) -> void:
	if not is_alive():
		return
	_tick_statuses(delta, battle)
	if not is_alive():
		return
	for a in _cooldowns.keys():
		_cooldowns[a] = maxf(_cooldowns[a] - delta, 0.0)
	if is_stunned():
		return
	if is_casting():
		cast_remaining -= delta
		if cast_remaining <= 0.0:
			_finish_cast(battle)
		return
	if recovery_remaining > 0.0:
		recovery_remaining -= delta
		return
	var action := brain.choose_action(self, battle)
	if action:
		_begin_action(action, battle)


func _begin_action(action: BattleAction, battle: Battle) -> void:
	start_cooldown(action.ability)
	if action.ability.cast_time > 0.0:
		cast_ability = action.ability
		cast_targets = action.targets
		cast_total = action.ability.cast_time
		cast_remaining = cast_total
		cast_started.emit(action.ability, cast_total)
	else:
		battle.execute(self, action.ability, action.targets)


func _finish_cast(battle: Battle) -> void:
	var ability := cast_ability
	var targets := cast_targets.filter(func(t: BattleUnit) -> bool: return t.is_alive())
	cast_ability = null
	cast_targets = []
	cast_ended.emit(false)
	var typed: Array[BattleUnit] = []
	typed.assign(targets)
	if typed.is_empty():
		typed = ability.select_targets(self, battle)
	if typed.is_empty():
		begin_recovery(0.5)
		return
	battle.execute(self, ability, typed)


func _tick_statuses(delta: float, battle: Battle) -> void:
	for st in statuses.duplicate():
		st.tick(delta, battle)
		if st.is_expired() and statuses.has(st):
			_remove_status(st, battle)


func _remove_status(st: StatusEffect, battle: Battle) -> void:
	statuses.erase(st)
	if battle:
		st.on_removed(battle)
	status_removed.emit(st)


func _on_death() -> void:
	if is_casting():
		cast_ability = null
		cast_ended.emit(true)
	for st in statuses.duplicate():
		_remove_status(st, null)
	died.emit()
