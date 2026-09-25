class_name Hero
extends Combatant
## A recruited party member: levels, XP, skill points, equipment and loadout.

signal changed

const MAX_LEVEL := 20
const XP_PER_LEVEL := 100
const STARTING_SKILL_POINTS := 1

var definition: HeroDefinition
var level: int = 1
var xp: int = 0
var skill_points: int = STARTING_SKILL_POINTS
var loadout: AbilityLoadout

var _equipment: Dictionary = {}   # Equipment.Slot -> Equipment
var _unlocked: Dictionary = {}    # Ability -> true


func _init(definition_: HeroDefinition, start_level := 1) -> void:
	definition = definition_
	display_name = definition.display_name
	loadout = AbilityLoadout.new(get_hero_class().abilities)
	loadout.changed.connect(func() -> void: changed.emit())
	# First ability of the kit comes free; the rest cost skill points.
	_unlocked[get_hero_class().abilities[0]] = true
	if definition.starting_weapon:
		_equipment[Equipment.Slot.WEAPON] = definition.starting_weapon
	if definition.starting_armor:
		_equipment[Equipment.Slot.ARMOR] = definition.starting_armor
	level = start_level
	skill_points = STARTING_SKILL_POINTS + (start_level - 1)
	current_hp = get_max_hp()


# --- Combatant interface -------------------------------------------------------------

func get_hero_class() -> HeroClass:
	return definition.hero_class


func get_base_stats() -> StatBlock:
	return get_hero_class().stats_at_level(level)


func get_stats() -> StatBlock:
	var s := get_base_stats()
	for item in _equipment.values():
		s = s.plus((item as Equipment).stats)
	return s


func get_role() -> CombatTypes.Role:
	return get_hero_class().role


func get_battle_abilities() -> Array[Ability]:
	var out: Array[Ability] = []
	for slot in loadout.slots():
		if slot.enabled and is_unlocked(slot.ability):
			out.append(slot.ability)
	return out


func get_basic_attack() -> Ability:
	return get_hero_class().basic_attack


func get_appearance() -> Appearance:
	return definition.appearance


func create_brain() -> BattleBrain:
	return get_hero_class().create_brain()


# --- progression -------------------------------------------------------------------------

func xp_to_next_level() -> int:
	return XP_PER_LEVEL * level


## Returns number of levels gained.
func add_xp(amount: int) -> int:
	if level >= MAX_LEVEL:
		return 0
	xp += amount
	var gained := 0
	while level < MAX_LEVEL and xp >= xp_to_next_level():
		xp -= xp_to_next_level()
		var ratio := get_hp_ratio()
		level += 1
		skill_points += 1
		gained += 1
		current_hp = get_max_hp() * maxf(ratio, 0.5) if is_alive() else 0.0
	changed.emit()
	return gained


func is_unlocked(ability: Ability) -> bool:
	return _unlocked.has(ability)


func can_unlock(ability: Ability) -> bool:
	return not is_unlocked(ability) and skill_points > 0 and level >= ability.unlock_level


func unlock(ability: Ability) -> bool:
	if not can_unlock(ability):
		return false
	_unlocked[ability] = true
	skill_points -= 1
	changed.emit()
	return true


# --- equipment ----------------------------------------------------------------------------

func get_equipped(slot: Equipment.Slot) -> Equipment:
	return _equipment.get(slot)


## Equips and returns whatever was in that slot before (or null).
func equip(item: Equipment) -> Equipment:
	assert(item.can_be_equipped_by(self))
	var ratio := get_hp_ratio()
	var previous: Equipment = _equipment.get(item.get_slot())
	_equipment[item.get_slot()] = item
	_keep_hp_ratio(ratio)
	changed.emit()
	return previous


func unequip(slot: Equipment.Slot) -> Equipment:
	var ratio := get_hp_ratio()
	var previous: Equipment = _equipment.get(slot)
	_equipment.erase(slot)
	_keep_hp_ratio(ratio)
	changed.emit()
	return previous


func _keep_hp_ratio(ratio: float) -> void:
	if is_alive():
		current_hp = maxf(1.0, get_max_hp() * ratio)
