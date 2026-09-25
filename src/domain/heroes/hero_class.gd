class_name HeroClass
extends Resource
## Definition of a class (Warrior, Priest, Hunter, Mage): role, stat curve,
## ability kit and gear permissions. Shared by every hero of that class.

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var role: CombatTypes.Role = CombatTypes.Role.MELEE_DPS
@export var color: Color = Color.WHITE
@export var base_stats: StatBlock
## Added once per level above 1.
@export var growth: StatBlock
@export var basic_attack: Ability
## The class's choosable kit (4 in this iteration).
@export var abilities: Array[Ability] = []
@export var weapon_types: Array[Weapon.WeaponType] = []
@export var armor_types: Array[Armor.ArmorType] = []


func stats_at_level(level: int) -> StatBlock:
	return base_stats.plus(growth.times(float(level - 1)))


## Factory: every role gets its own decision-making personality.
func create_brain() -> BattleBrain:
	match role:
		CombatTypes.Role.TANK: return TankBrain.new()
		CombatTypes.Role.HEALER: return HealerBrain.new()
		CombatTypes.Role.RANGED_DPS: return RangedBrain.new()
		_: return DamageBrain.new()
