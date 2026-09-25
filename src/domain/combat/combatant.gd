class_name Combatant
extends RefCounted
## Abstract persistent fighter (a Hero in your roster, or a spawned Monster).
## Owns identity, stats and current HP. Battle-only state lives in BattleUnit.

var display_name: String
var current_hp: float = 1.0


# --- abstract interface ------------------------------------------------------------

func get_stats() -> StatBlock:
	push_error("Combatant.get_stats is abstract")
	return StatBlock.new()


func get_role() -> CombatTypes.Role:
	push_error("Combatant.get_role is abstract")
	return CombatTypes.Role.MELEE_DPS


## Abilities the unit may use this battle, in priority order (basic attack excluded).
func get_battle_abilities() -> Array[Ability]:
	return []


func get_basic_attack() -> Ability:
	push_error("Combatant.get_basic_attack is abstract")
	return null


func get_appearance() -> Appearance:
	push_error("Combatant.get_appearance is abstract")
	return null


func create_brain() -> BattleBrain:
	push_error("Combatant.create_brain is abstract")
	return BattleBrain.new()


## Bosses shrug off stuns.
func is_control_immune() -> bool:
	return false


## Per-frame hook during battle (bosses use it for phase changes).
func on_battle_tick(_unit: BattleUnit, _battle: Battle) -> void:
	pass


# --- shared behaviour ------------------------------------------------------------------

func get_max_hp() -> float:
	return get_stats().max_hp


func is_alive() -> bool:
	return current_hp > 0.0


func get_hp_ratio() -> float:
	return current_hp / maxf(get_max_hp(), 1.0)


func set_hp(value: float) -> void:
	var clamped := clampf(value, 0.0, get_max_hp())
	if is_equal_approx(clamped, current_hp):
		return
	current_hp = clamped


## Returns damage actually removed.
func apply_damage(amount: float) -> float:
	var before := current_hp
	set_hp(current_hp - amount)
	return before - current_hp


## Returns health actually restored. The dead cannot be healed (use restore_percent).
func apply_heal(amount: float) -> float:
	if not is_alive():
		return 0.0
	var before := current_hp
	set_hp(current_hp + amount)
	return current_hp - before


## Restores to at least `ratio` of max HP, reviving if needed.
func restore_percent(ratio: float) -> void:
	set_hp(maxf(current_hp, get_max_hp() * ratio))