class_name ContentKit
extends RefCounted
## Terse static builders used by the catalogs. Keeps content files readable
## while every product is still a plain Resource (easy to move to .tres later).

const T := CombatTypes.Tag
const D := CombatTypes.Delivery


static func ability(id: StringName, name: String, desc: String, tags: Array, rule: TargetRule,
		effects: Array, opts: Dictionary = {}) -> Ability:
	var a := Ability.new()
	a.id = id
	a.display_name = name
	a.description = desc
	a.tags.assign(tags)
	a.target_rule = rule
	a.effects.assign(effects)
	a.cooldown = opts.get("cooldown", 0.0)
	a.recovery = opts.get("recovery", 1.6)
	a.cast_time = opts.get("cast", 0.0)
	a.interruptible = opts.get("interruptible", true)
	a.delivery = opts.get("delivery", D.MELEE)
	a.unlock_level = opts.get("unlock", 1)
	a.fx_color = opts.get("color", Color.WHITE)
	return a


# --- target rules -------------------------------------------------------------------------

static func focus() -> TargetRule: return FocusEnemyRule.new()
static func all_enemies() -> TargetRule: return AllEnemiesRule.new()
static func all_allies() -> TargetRule: return AllAlliesRule.new()
static func self_only() -> TargetRule: return SelfRule.new()
static func lowest_ally() -> TargetRule: return LowestHealthAllyRule.new()
static func threatened_ally() -> TargetRule: return MostThreatenedAllyRule.new()


static func casting_enemy(fallback := false) -> TargetRule:
	var r := CastingEnemyRule.new()
	r.fallback_to_focus = fallback
	return r


# --- effects ---------------------------------------------------------------------------------

static func dmg(mult: float, magic := false) -> AbilityEffect:
	return DamageEffect.create(mult, CombatTypes.School.MAGIC if magic else CombatTypes.School.PHYSICAL)


static func heal(mult: float, min_missing := 0.18) -> AbilityEffect:
	return HealEffect.create(mult, min_missing)


static func interrupt() -> AbilityEffect:
	return InterruptEffect.new()


static func status(s: StatusEffect) -> AbilityEffect:
	return ApplyStatusEffect.create(s)


# --- statuses ----------------------------------------------------------------------------------

static func _named(s: StatusEffect, id: StringName, name: String, duration: float, color: Color, harmful: bool) -> StatusEffect:
	s.id = id
	s.display_name = name
	s.duration = duration
	s.color = color
	s.is_harmful = harmful
	return s


static func taunt(duration: float) -> StatusEffect:
	return _named(TauntStatus.new(), &"taunt", "Taunted", duration, Color("e0583a"), true)


static func stun(id: StringName, name: String, duration: float, color := Color("8fd3ff")) -> StatusEffect:
	return _named(StunStatus.new(), id, name, duration, color, true)


static func shield(id: StringName, name: String, absorb_mult: float, duration: float) -> StatusEffect:
	var s := ShieldStatus.new()
	s.absorb_multiplier = absorb_mult
	return _named(s, id, name, duration, Color("ffe38a"), false)


static func dot(id: StringName, name: String, total_mult: float, duration: float, color: Color) -> StatusEffect:
	var s := DamageOverTimeStatus.new()
	s.total_multiplier = total_mult
	return _named(s, id, name, duration, color, true)


static func hot(id: StringName, name: String, total_mult: float, duration: float) -> StatusEffect:
	var s := HealOverTimeStatus.new()
	s.total_multiplier = total_mult
	return _named(s, id, name, duration, Color("9cf29a"), false)


static func modifier(id: StringName, name: String, duration: float, color: Color, opts: Dictionary) -> StatusEffect:
	var s := StatModifierStatus.new()
	s.intent = opts.get("intent", StatModifierStatus.Intent.OFFENSIVE)
	s.power_multiplier = opts.get("power", 1.0)
	s.bonus_haste = opts.get("haste", 0.0)
	s.damage_taken_multiplier = opts.get("taken", 1.0)
	return _named(s, id, name, duration, color, opts.get("harmful", false))
