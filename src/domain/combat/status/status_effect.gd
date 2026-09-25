class_name StatusEffect
extends Resource
## Abstract timed buff/debuff living on a BattleUnit.
## Definitions are templates; `instantiate_for` makes the per-application copy.
## Hooks (template methods) let subclasses change stats, damage, targeting or action.

@export var id: StringName
@export var display_name: String
@export var duration: float = 5.0
@export var is_harmful: bool = false
@export var color: Color = Color.WHITE

var remaining: float = 0.0
var source: BattleUnit
var holder: BattleUnit


func instantiate_for(caster: BattleUnit, target: BattleUnit, battle: Battle) -> StatusEffect:
	var s := duplicate() as StatusEffect
	s.source = caster
	s.holder = target
	s.remaining = duration
	s._on_instantiated(caster, battle)
	return s


## AI utility of applying this status to `target`. Re-applying an active status is pointless.
func evaluate_on(caster: BattleUnit, target: BattleUnit, battle: Battle) -> float:
	if target.has_status(id):
		return 0.0
	return _utility(caster, target, battle)


func tick(delta: float, battle: Battle) -> void:
	remaining -= delta
	_on_tick(delta, battle)


func is_expired() -> bool:
	return remaining <= 0.0


func progress() -> float:
	return clampf(remaining / duration, 0.0, 1.0) if duration > 0.0 else 0.0


# --- overridable hooks -------------------------------------------------------

func _utility(_caster: BattleUnit, _target: BattleUnit, _battle: Battle) -> float:
	return 1.0


func _on_instantiated(_caster: BattleUnit, _battle: Battle) -> void:
	pass


func _on_tick(_delta: float, _battle: Battle) -> void:
	pass


func on_applied(_battle: Battle) -> void:
	pass


func on_removed(_battle: Battle) -> void:
	pass


func modify_stats(_stats: StatBlock) -> void:
	pass


func modify_incoming_damage(amount: float) -> float:
	return amount


func prevents_action() -> bool:
	return false


func get_forced_target() -> BattleUnit:
	return null
