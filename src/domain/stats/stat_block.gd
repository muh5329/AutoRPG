class_name StatBlock
extends Resource
## Immutable-by-convention bundle of combat stats.
## Used for class base stats, per-level growth, equipment bonuses and monster stats.
## Arithmetic helpers always return NEW blocks so shared definitions are never mutated.

@export var max_hp: float = 0.0
## Scales every outgoing damage and heal.
@export var power: float = 0.0
## Flat mitigation. Damage taken is multiplied by 100 / (100 + armor).
@export var armor: float = 0.0
## Percent (0.25 = 25%) faster action-bar recovery.
@export var haste: float = 0.0
## Chance (0..1) for damage/heal to critically strike for 1.5x.
@export var crit: float = 0.0


static func make(hp: float, pwr: float, arm: float, hst: float = 0.0, crt: float = 0.0) -> StatBlock:
	var s := StatBlock.new()
	s.max_hp = hp
	s.power = pwr
	s.armor = arm
	s.haste = hst
	s.crit = crt
	return s


func plus(other: StatBlock) -> StatBlock:
	if other == null:
		return copy()
	return StatBlock.make(max_hp + other.max_hp, power + other.power, armor + other.armor,
		haste + other.haste, crit + other.crit)


func times(factor: float) -> StatBlock:
	return StatBlock.make(max_hp * factor, power * factor, armor * factor, haste * factor, crit * factor)


func copy() -> StatBlock:
	return StatBlock.make(max_hp, power, armor, haste, crit)


## Multiplier applied to incoming raw damage.
func mitigation() -> float:
	return 100.0 / (100.0 + maxf(armor, 0.0))


## Short human readable list of non-zero stats, e.g. "+40 HP  +6 Power".
func describe_bonus() -> String:
	var parts: PackedStringArray = []
	if max_hp != 0.0: parts.append("%+d HP" % roundi(max_hp))
	if power != 0.0: parts.append("%+d Power" % roundi(power))
	if armor != 0.0: parts.append("%+d Armor" % roundi(armor))
	if haste != 0.0: parts.append("%+d%% Haste" % roundi(haste * 100.0))
	if crit != 0.0: parts.append("%+d%% Crit" % roundi(crit * 100.0))
	return "  ".join(parts)
