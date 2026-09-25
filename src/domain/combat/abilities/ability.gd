class_name Ability
extends Resource
## A combat move. Composed (not subclassed) from:
##   - one TargetRule   : WHO it hits
##   - N AbilityEffects : WHAT happens to each target
## Its AI utility is the sum of its effects' utilities, so new abilities are pure data.

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var tags: Array[CombatTypes.Tag] = []
## Seconds before THIS ability can be used again.
@export var cooldown: float = 0.0
## Seconds the unit's action bar needs to refill after using it (the bar under the HP bar).
@export var recovery: float = 1.6
## >0 means the unit channels a visible cast bar first (can be interrupted if allowed).
@export var cast_time: float = 0.0
@export var interruptible: bool = true
@export var delivery: CombatTypes.Delivery = CombatTypes.Delivery.MELEE
@export var target_rule: TargetRule
@export var effects: Array[AbilityEffect] = []
## Minimum hero level required to unlock with a skill point.
@export var unlock_level: int = 1
@export var fx_color: Color = Color.WHITE


func has_tag(tag: CombatTypes.Tag) -> bool:
	return tags.has(tag)


func is_ranged() -> bool:
	return delivery != CombatTypes.Delivery.MELEE


func impact_delay() -> float:
	return CombatTypes.IMPACT_DELAY[delivery]


func select_targets(caster: BattleUnit, battle: Battle) -> Array[BattleUnit]:
	return target_rule.select(caster, battle)


## Situational value of using this ability now on these targets (0 = pointless).
func evaluate(caster: BattleUnit, targets: Array[BattleUnit], battle: Battle) -> float:
	if targets.is_empty():
		return 0.0
	var total := 0.0
	for effect in effects:
		total += effect.evaluate(caster, targets, battle)
	return total


## Resolve every effect on every living target.
func apply(caster: BattleUnit, targets: Array[BattleUnit], battle: Battle) -> void:
	for target in targets:
		if not target.is_alive():
			continue
		for effect in effects:
			effect.apply(caster, target, battle)


func get_tag_names() -> PackedStringArray:
	var out: PackedStringArray = []
	for t in tags:
		out.append(CombatTypes.TAG_NAMES[t])
	return out


func get_tooltip() -> String:
	var lines: PackedStringArray = [description]
	var meta: PackedStringArray = []
	if cast_time > 0.0:
		meta.append("Cast %.1fs" % cast_time)
	else:
		meta.append("Instant")
	if cooldown > 0.0:
		meta.append("Cooldown %ds" % roundi(cooldown))
	meta.append("Recovery %.1fs" % recovery)
	lines.append(" · ".join(meta))
	return "\n".join(lines)
