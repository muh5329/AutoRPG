class_name Battle
extends RefCounted
## Pure, deterministic-per-seed battle simulation. Has no knowledge of nodes,
## so it can run headless (balance tests) or be presented by BattleDirector.
## Drive it by calling tick(delta) every frame.

signal unit_acted(unit: BattleUnit, ability: Ability, targets: Array[BattleUnit])
signal ability_impact(unit: BattleUnit, ability: Ability, target: BattleUnit)
signal potion_used(unit: BattleUnit, potion: Potion)
signal message(text: String)
signal ended(victory: bool)

const AUTO_POTION_THRESHOLD := 0.3
const POTION_COOLDOWN := 6.0
const DAMAGE_VARIANCE := 0.1

var heroes: Array[BattleUnit] = []
var monsters: Array[BattleUnit] = []
var rng := RandomNumberGenerator.new()
var elapsed: float = 0.0
var is_over: bool = false
var victory: bool = false

var _inventory: Inventory
var _pending: Array[Dictionary] = []   # { at, caster, ability, targets }
var _team_focus: Dictionary = {}       # Team -> BattleUnit
var _potion_timer: float = 0.0


class Roll:
	extends RefCounted
	var amount: float
	var crit: bool

	func _init(amount_: float, crit_: bool) -> void:
		amount = amount_
		crit = crit_


func _init(hero_list: Array[Hero], monster_list: Array[Monster], inventory: Inventory = null, seed_value := -1) -> void:
	_inventory = inventory
	if seed_value >= 0:
		rng.seed = seed_value
	else:
		rng.randomize()
	var ordered := hero_list.duplicate()
	ordered.sort_custom(func(a: Hero, b: Hero) -> bool: return _formation_rank(a) < _formation_rank(b))
	for i in ordered.size():
		heroes.append(BattleUnit.new(ordered[i], CombatTypes.Team.HEROES, i))
	for i in monster_list.size():
		monsters.append(BattleUnit.new(monster_list[i], CombatTypes.Team.MONSTERS, i))


# --- queries ---------------------------------------------------------------------

func all_units() -> Array[BattleUnit]:
	var out: Array[BattleUnit] = []
	out.append_array(heroes)
	out.append_array(monsters)
	return out


func team_of(team: CombatTypes.Team) -> Array[BattleUnit]:
	return heroes if team == CombatTypes.Team.HEROES else monsters


func living(units: Array[BattleUnit]) -> Array[BattleUnit]:
	var out: Array[BattleUnit] = []
	for u in units:
		if u.is_alive():
			out.append(u)
	return out


func allies_of(unit: BattleUnit) -> Array[BattleUnit]:
	return living(team_of(unit.team))


func enemies_of(unit: BattleUnit) -> Array[BattleUnit]:
	var other := CombatTypes.Team.MONSTERS if unit.team == CombatTypes.Team.HEROES else CombatTypes.Team.HEROES
	return living(team_of(other))


func count_attackers_of(unit: BattleUnit) -> int:
	var n := 0
	for e in enemies_of(unit):
		if e.focus == unit:
			n += 1
	return n


## Shared "kill target" for a team: squishiest enemy first, sticky until it dies.
func get_team_focus(team: CombatTypes.Team) -> BattleUnit:
	var current: BattleUnit = _team_focus.get(team)
	if current and current.is_alive():
		return current
	var other := CombatTypes.Team.MONSTERS if team == CombatTypes.Team.HEROES else CombatTypes.Team.HEROES
	var best: BattleUnit = null
	for e in living(team_of(other)):
		if best == null or e.get_stats().max_hp < best.get_stats().max_hp:
			best = e
	_team_focus[team] = best
	return best


## Damage/heal roll from the caster's power, with variance and crit.
func roll(caster: BattleUnit, multiplier: float) -> Roll:
	var stats := caster.get_stats()
	var base := stats.power * multiplier * rng.randf_range(1.0 - DAMAGE_VARIANCE, 1.0 + DAMAGE_VARIANCE)
	return Roll.new(base, rng.randf() < stats.crit)


# --- simulation --------------------------------------------------------------------

func tick(delta: float) -> void:
	if is_over:
		return
	elapsed += delta
	_potion_timer = maxf(_potion_timer - delta, 0.0)
	_resolve_pending()
	for unit in all_units():
		unit.tick(delta, self)
		if unit.team == CombatTypes.Team.MONSTERS and unit.is_alive():
			unit.combatant.on_battle_tick(unit, self)
	_try_auto_potion()
	_check_end()


## Called by a unit when it commits to an ability. Effects land after the delivery delay.
func execute(caster: BattleUnit, ability: Ability, targets: Array[BattleUnit]) -> void:
	caster.last_ability = ability
	caster.begin_recovery(ability.recovery)
	caster.acted.emit(ability, targets)
	unit_acted.emit(caster, ability, targets)
	_pending.append({ "at": elapsed + ability.impact_delay(), "caster": caster, "ability": ability, "targets": targets })


func announce(text: String) -> void:
	message.emit(text)


func _resolve_pending() -> void:
	var due: Array[Dictionary] = []
	for p in _pending:
		if p.at <= elapsed:
			due.append(p)
	for p in due:
		_pending.erase(p)
		var caster: BattleUnit = p.caster
		if not caster.is_alive():
			continue
		var ability: Ability = p.ability
		var targets: Array[BattleUnit] = p.targets
		ability.apply(caster, targets, self)
		for t in targets:
			ability_impact.emit(caster, ability, t)


func _try_auto_potion() -> void:
	if _inventory == null or _potion_timer > 0.0:
		return
	var potion := _inventory.first_of(Potion) as Potion
	if potion == null:
		return
	for unit in living(heroes):
		if unit.get_hp_ratio() < AUTO_POTION_THRESHOLD:
			var before := unit.combatant.current_hp
			unit.combatant.apply_heal(potion.heal_amount_for(unit.get_stats().max_hp))
			_inventory.remove(potion)
			_potion_timer = POTION_COOLDOWN
			unit.healed.emit(unit.combatant.current_hp - before, false, false)
			potion_used.emit(unit, potion)
			announce("%s drinks a %s!" % [unit.get_name(), potion.display_name])
			return


func _check_end() -> void:
	if living(monsters).is_empty():
		_finish(true)
	elif living(heroes).is_empty():
		_finish(false)


func _finish(won: bool) -> void:
	is_over = true
	victory = won
	ended.emit(won)


## Tanks in front, then melee, then ranged, then healers.
static func _formation_rank(hero: Hero) -> int:
	match hero.get_role():
		CombatTypes.Role.TANK: return 0
		CombatTypes.Role.MELEE_DPS: return 1
		CombatTypes.Role.RANGED_DPS: return 2
		_: return 3
