class_name TargetRule
extends Resource
## Abstract strategy answering "who does this ability hit?".
## Returning an empty array means the ability is not usable right now.


func select(_caster: BattleUnit, _battle: Battle) -> Array[BattleUnit]:
	push_error("TargetRule.select is abstract")
	return []


## Typed single-element (or empty) result helper.
static func only(unit: BattleUnit) -> Array[BattleUnit]:
	var out: Array[BattleUnit] = []
	if unit != null:
		out.append(unit)
	return out
