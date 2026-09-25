class_name MonsterDefinition
extends Resource
## Authored data for an enemy type. `spawn()` is the factory for runtime Monsters.

@export var id: StringName
@export var display_name: String
@export var role: CombatTypes.Role = CombatTypes.Role.MELEE_DPS
@export var stats: StatBlock
@export var basic_attack: Ability
@export var abilities: Array[Ability] = []
@export var appearance: Appearance
@export var xp_reward: int = 10
@export var gold_reward: int = 5
@export var is_boss: bool = false
## Bosses only: HP ratio at which the enrage phase starts.
@export var enrage_threshold: float = 0.3
@export var enrage_status: StatusEffect


func spawn() -> Monster:
	return Boss.new(self) if is_boss else Monster.new(self)
