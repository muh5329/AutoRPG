class_name CombatTypes
extends RefCounted
## Shared combat vocabulary. Pure enums/constants, never instanced.

enum Team { HEROES, MONSTERS }

## Battle role. Drives the AI brain bias and battle formation (front/back line).
enum Role { TANK, HEALER, MELEE_DPS, RANGED_DPS }

enum School { PHYSICAL, MAGIC }

## Semantic tags on abilities. Brains weigh abilities by tag, which is what gives
## each role its "heavy bias" (tanks tank, healers heal, DPS deal damage/interrupt).
enum Tag { DAMAGE, AOE, HEAL, TANK, DEFENSIVE, INTERRUPT, CONTROL, DOT, BUFF }

## How an ability travels. Controls impact delay and which animation/VFX plays.
enum Delivery { MELEE, PROJECTILE, INSTANT, SELF }

const IMPACT_DELAY := {
	Delivery.MELEE: 0.28,
	Delivery.PROJECTILE: 0.45,
	Delivery.INSTANT: 0.15,
	Delivery.SELF: 0.05,
}

const ROLE_NAMES := {
	Role.TANK: "Tank",
	Role.HEALER: "Healer",
	Role.MELEE_DPS: "Melee DPS",
	Role.RANGED_DPS: "Ranged DPS",
}

const TAG_NAMES := {
	Tag.DAMAGE: "Damage",
	Tag.AOE: "Area",
	Tag.HEAL: "Heal",
	Tag.TANK: "Taunt",
	Tag.DEFENSIVE: "Defensive",
	Tag.INTERRUPT: "Interrupt",
	Tag.CONTROL: "Control",
	Tag.DOT: "Over Time",
	Tag.BUFF: "Buff",
}


static func is_ranged_role(role: int) -> bool:
	return role == Role.HEALER or role == Role.RANGED_DPS


static func role_name(role: int) -> String:
	return ROLE_NAMES.get(role, "?")
