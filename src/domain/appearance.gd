class_name Appearance
extends Resource
## Data-only description of how a creature looks. The domain layer owns it;
## the world layer (ModelFactory) interprets it into low-poly meshes.
## Keeps game rules free of any Node/mesh dependencies.

enum Body { HUMANOID, RAT, SPIDER }
enum Outfit { VILLAGER, WARRIOR, PRIEST, HUNTER, MAGE, WAYFARER, MERCHANT, INNKEEPER, ELDER, GUARD, GOBLIN, SHAMAN, OGRE }
enum Headgear { NONE, HAIR_SHORT, HAIR_LONG, HAIR_BUN, HELMET, HOOD, WIZARD_HAT, MITRE, CAP, HORNS, BALD }
enum Prop { NONE, SWORD_SHIELD, STAFF_ORB, BOW, STAFF_CRYSTAL, LANTERN, CLUB, SPEAR, TOTEM, BROOM, BOOK, MUG, GREAT_CLUB }

@export var body: Body = Body.HUMANOID
@export var outfit: Outfit = Outfit.VILLAGER
@export var headgear: Headgear = Headgear.HAIR_SHORT
@export var prop: Prop = Prop.NONE
@export var skin_color: Color = Color("f2c9a0")
@export var hair_color: Color = Color("6b4226")
@export var primary_color: Color = Color("5b8bd9")
@export var secondary_color: Color = Color("f0e6d2")
@export var scale: float = 1.0
@export var pointy_ears: bool = false


static func humanoid(outfit_: Outfit, headgear_: Headgear, prop_: Prop, primary: Color,
		secondary: Color, skin := Color("f2c9a0"), hair := Color("6b4226"), scale_ := 1.0) -> Appearance:
	var a := Appearance.new()
	a.body = Body.HUMANOID
	a.outfit = outfit_
	a.headgear = headgear_
	a.prop = prop_
	a.primary_color = primary
	a.secondary_color = secondary
	a.skin_color = skin
	a.hair_color = hair
	a.scale = scale_
	return a


static func creature(body_: Body, primary: Color, secondary: Color, scale_ := 1.0) -> Appearance:
	var a := Appearance.new()
	a.body = body_
	a.primary_color = primary
	a.secondary_color = secondary
	a.scale = scale_
	return a
