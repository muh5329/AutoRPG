class_name HumanoidModel
extends CharacterModel
## Chibi-proportioned low-poly person (big head, short body) in the AFK Journey spirit.
## Everything is driven by Appearance: outfit, headgear, prop and colours.

const O := Appearance.Outfit
const H := Appearance.Headgear
const P := Appearance.Prop

const EYE := Color("2b2440")
const BLUSH := Color(1.0, 0.55, 0.6, 0.55)
const LEATHER := Color("6b4a2f")
const WOOD := Color("8a5a35")
const STEEL := Color("dfe6ee")
const GOLD := Color("f2c45a")
const BONE := Color("efe6d0")

var _robed := false
var _head_y := 1.08
var _head_r := 0.3


func get_height() -> float:
	return 1.62 * _base_scale


func _shadow_radius() -> float:
	return 0.42 if appearance.outfit == O.OGRE else 0.34


func _build() -> void:
	var a := appearance
	_robed = a.outfit in [O.PRIEST, O.MAGE, O.ELDER, O.SHAMAN]
	if a.outfit == O.OGRE:
		_head_r = 0.26
		_head_y = 1.12
	_build_legs()
	_build_torso()
	_build_arms()
	_build_head()
	_build_headgear()
	_build_prop()


# --- body ----------------------------------------------------------------------------------

func _build_legs() -> void:
	var a := appearance
	if _robed:
		_p(body, LP.cylinder(0.2, 0.36, 0.8, 9), a.primary_color, Vector3(0, 0.42, 0))
		_p(body, LP.cylinder(0.365, 0.372, 0.07, 9), a.secondary_color, Vector3(0, 0.06, 0))
		return
	var pants := a.primary_color.darkened(0.45) if a.outfit != O.GOBLIN else LEATHER
	for side: int in [-1, 1]:
		_p(body, LP.cylinder(0.075, 0.085, 0.36, 6), pants, Vector3(0.11 * side, 0.2, 0))
		_p(body, LP.box(Vector3(0.15, 0.1, 0.22)), LEATHER.darkened(0.3), Vector3(0.11 * side, 0.05, -0.03))


func _build_torso() -> void:
	var a := appearance
	match a.outfit:
		O.OGRE:
			_p(body, LP.cylinder(0.28, 0.3, 0.45, 8), a.skin_color, Vector3(0, 0.62, 0))
			_p(body, LP.sphere(0.34), a.skin_color.lightened(0.05), Vector3(0, 0.56, -0.08), Vector3.ZERO, Vector3(1, 0.9, 0.9))
			_p(body, LP.cylinder(0.32, 0.36, 0.2, 8), a.primary_color, Vector3(0, 0.32, 0))
			_p(body, LP.sphere(0.16), a.secondary_color, Vector3(-0.32, 0.86, 0), Vector3.ZERO, Vector3(1, 0.7, 1))
			for i in 3:
				_p(body, LP.cone(0.04, 0.14, 5), BONE, Vector3(-0.32 + (i - 1) * 0.08, 0.98, 0))
			return
		O.INNKEEPER:
			_p(body, LP.cylinder(0.22, 0.3, 0.46, 8), a.primary_color, Vector3(0, 0.6, 0), Vector3.ZERO, Vector3(1.15, 1, 1.15))
		_:
			if not _robed:
				_p(body, LP.cylinder(0.2, 0.25, 0.46, 8), a.primary_color, Vector3(0, 0.6, 0))
			else:
				_p(body, LP.cylinder(0.19, 0.22, 0.3, 8), a.primary_color, Vector3(0, 0.84, 0))
	if not _robed:
		_p(body, LP.cylinder(0.258, 0.258, 0.06, 8), LEATHER, Vector3(0, 0.42, 0))
		_p(body, LP.box(Vector3(0.08, 0.07, 0.03)), GOLD, Vector3(0, 0.42, -0.26))
	match a.outfit:
		O.WARRIOR, O.GUARD:
			_p(body, LP.cylinder(0.215, 0.262, 0.28, 8), a.secondary_color, Vector3(0, 0.68, 0))
			for side: int in [-1, 1]:
				_p(body, LP.sphere(0.13), a.secondary_color, Vector3(0.27 * side, 0.85, 0), Vector3.ZERO, Vector3(1, 0.7, 1))
			_p(body, LP.box(Vector3(0.22, 0.3, 0.03)), a.primary_color, Vector3(0, 0.3, -0.24))
		O.PRIEST:
			for side: int in [-1, 1]:
				_p(body, LP.box(Vector3(0.07, 0.62, 0.03)), a.secondary_color, Vector3(0.08 * side, 0.55, -0.27), Vector3(8, 0, 0))
			_p(body, LP.torus(0.17, 0.24, 10, 5), a.secondary_color, Vector3(0, 0.96, 0))
		O.HUNTER:
			_p(body, LP.cylinder(0.215, 0.262, 0.26, 8), a.secondary_color, Vector3(0, 0.62, 0))
			_p(body, LP.cylinder(0.07, 0.07, 0.46, 6), WOOD, Vector3(0.12, 0.78, 0.24), Vector3(20, 0, -15))
			for i in 3:
				_p(body, LP.box(Vector3(0.04, 0.1, 0.02)), Color("f5f0e6") if i != 1 else Color("d9534f"),
					Vector3(0.19 + i * 0.03, 1.02, 0.3), Vector3(20, 0, -15))
		O.MAGE:
			_p(body, LP.cylinder(0.225, 0.23, 0.06, 8), a.secondary_color, Vector3(0, 0.72, 0))
			_p(body, LP.torus(0.16, 0.23, 10, 5), a.secondary_color, Vector3(0, 0.97, 0))
		O.WAYFARER:
			_p(body, LP.box(Vector3(0.52, 0.8, 0.05)), a.primary_color.darkened(0.25), Vector3(0, 0.5, 0.22), Vector3(-8, 0, 0))
			_p(body, LP.torus(0.15, 0.25, 10, 5), a.secondary_color, Vector3(0, 0.9, 0), Vector3(0, 0, 0), Vector3(1, 1.4, 1))
		O.MERCHANT, O.INNKEEPER:
			_p(body, LP.box(Vector3(0.36, 0.52, 0.03)), a.secondary_color, Vector3(0, 0.45, -0.27))
		O.ELDER:
			_p(body, LP.torus(0.17, 0.24, 10, 5), a.secondary_color, Vector3(0, 0.96, 0))
		O.GOBLIN:
			_p(body, LP.cylinder(0.3, 0.3, 0.16, 8), a.primary_color, Vector3(0, 0.34, 0))
		O.SHAMAN:
			for i in 7:
				var ang := deg_to_rad(-60 + i * 20)
				_p(body, LP.sphere(0.04, 5, 3), BONE, Vector3(sin(ang) * 0.22, 0.92 - cos(ang) * 0.02, -cos(ang) * 0.2))
		O.VILLAGER:
			_p(body, LP.box(Vector3(0.3, 0.2, 0.03)), a.secondary_color, Vector3(0, 0.72, -0.24))


func _build_arms() -> void:
	var a := appearance
	var sleeve := a.primary_color
	var arm_r := 0.07
	var arm_len := 0.42
	if a.outfit in [O.GOBLIN, O.OGRE]:
		sleeve = a.skin_color
	if a.outfit == O.OGRE:
		arm_r = 0.11
		arm_len = 0.58
	for side: int in [-1, 1]:
		_p(body, LP.capsule(arm_r, arm_len, 6), sleeve, Vector3(0.29 * side * (1.2 if a.outfit == O.OGRE else 1.0), 0.64, 0), Vector3(0, 0, 12 * side))
		_p(body, LP.sphere(arm_r + 0.01, 6, 4), a.skin_color, Vector3(0.34 * side * (1.2 if a.outfit == O.OGRE else 1.0), 0.4, 0))
	hand_anchor = Vector3(0.36, 0.45, -0.1)


func _build_head() -> void:
	var a := appearance
	var y := _head_y
	var r := _head_r
	_p(body, LP.sphere(r, 10, 7), a.skin_color, Vector3(0, y, 0), Vector3.ZERO, Vector3(1, 0.95, 1))
	for side: int in [-1, 1]:
		_p(body, LP.sphere(0.046, 6, 4), EYE, Vector3(0.1 * side, y, -r * 0.9), Vector3.ZERO, Vector3(1, 1.35, 0.5))
		_p(body, LP.sphere(0.016, 4, 3), Color.WHITE, Vector3(0.1 * side + 0.016, y + 0.025, -r * 0.94))
		_p(body, LP.sphere(0.042, 6, 3), BLUSH, Vector3(0.17 * side, y - 0.075, -r * 0.78), Vector3.ZERO, Vector3(1, 0.55, 0.4))
	if a.pointy_ears:
		for side: int in [-1, 1]:
			_p(body, LP.cone(0.07, 0.3, 5), a.skin_color, Vector3((r + 0.1) * side, y + 0.03, 0), Vector3(0, 0, -100 * side))
	if a.outfit == O.OGRE:
		for side: int in [-1, 1]:
			_p(body, LP.cone(0.035, 0.12, 5), BONE, Vector3(0.08 * side, y - 0.14, -r * 0.85))
	if a.outfit == O.ELDER:
		_p(body, LP.cone(0.17, 0.4, 7), a.hair_color, Vector3(0, y - 0.3, -0.16), Vector3(180 - 15, 0, 0))


func _build_headgear() -> void:
	var a := appearance
	var y := _head_y
	match a.headgear:
		H.HAIR_SHORT:
			_hair_cap(y)
		H.HAIR_LONG:
			_hair_cap(y)
			_p(body, LP.box(Vector3(0.5, 0.58, 0.2)), a.hair_color, Vector3(0, y - 0.22, 0.17))
		H.HAIR_BUN:
			_hair_cap(y)
			_p(body, LP.sphere(0.13), a.hair_color, Vector3(0, y + 0.33, 0.12))
		H.HELMET:
			_p(body, LP.sphere(0.33, 10, 6), a.secondary_color, Vector3(0, y + 0.16, 0.02), Vector3.ZERO, Vector3(1, 0.8, 1))
			_p(body, LP.torus(0.3, 0.36, 12, 4), a.secondary_color.darkened(0.15), Vector3(0, y + 0.07, 0.02))
			_p(body, LP.box(Vector3(0.05, 0.2, 0.04)), a.secondary_color, Vector3(0, y + 0.02, -0.31))
			_p(body, LP.box(Vector3(0.06, 0.16, 0.34)), a.primary_color, Vector3(0, y + 0.42, 0.05))
		H.HOOD:
			_p(body, LP.sphere(0.345, 10, 6), a.primary_color, Vector3(0, y + 0.03, 0.1))
			_p(body, LP.cone(0.2, 0.32, 7), a.primary_color, Vector3(0, y - 0.12, 0.34), Vector3(-120, 0, 0))
		H.WIZARD_HAT:
			_hair_cap(y)
			_p(body, LP.cylinder(0.46, 0.46, 0.04, 12), a.primary_color, Vector3(0, y + 0.24, 0))
			_p(body, LP.cone(0.27, 0.62, 9), a.primary_color, Vector3(0, y + 0.55, 0.06), Vector3(14, 0, 0))
			_p(body, LP.cylinder(0.27, 0.27, 0.07, 9), a.secondary_color, Vector3(0, y + 0.29, 0.01))
		H.CAP:
			_hair_cap(y)
			_p(body, LP.cylinder(0.3, 0.32, 0.12, 10), a.secondary_color, Vector3(0, y + 0.25, 0.02))
			_p(body, LP.box(Vector3(0.3, 0.03, 0.18)), a.secondary_color, Vector3(0, y + 0.2, -0.3))
		H.HORNS:
			for side: int in [-1, 1]:
				_p(body, LP.cone(0.07, 0.32, 6), BONE, Vector3(0.2 * side, y + 0.27, 0), Vector3(0, 0, -32 * side))
		H.BALD:
			for side: int in [-1, 1]:
				_p(body, LP.sphere(0.1, 6, 4), a.hair_color, Vector3(0.26 * side, y - 0.02, 0.08))


func _hair_cap(y: float) -> void:
	_p(body, LP.sphere(0.335, 10, 6), appearance.hair_color, Vector3(0, y + 0.12, 0.06), Vector3.ZERO, Vector3(1.03, 0.78, 1))
	# Fringe
	_p(body, LP.box(Vector3(0.36, 0.08, 0.1)), appearance.hair_color, Vector3(0, y + 0.2, -0.25), Vector3(-25, 0, 0))


# --- props ---------------------------------------------------------------------------------

func _build_prop() -> void:
	var a := appearance
	var hx := 0.36 * (1.2 if a.outfit == O.OGRE else 1.0)
	match a.prop:
		P.SWORD_SHIELD:
			_p(body, LP.box(Vector3(0.06, 0.6, 0.025)), STEEL, Vector3(hx, 0.68, -0.14), Vector3(-25, 0, 0))
			_p(body, LP.box(Vector3(0.22, 0.045, 0.06)), GOLD, Vector3(hx, 0.42, -0.02), Vector3(-25, 0, 0))
			_p(body, LP.cylinder(0.27, 0.27, 0.05, 10), a.primary_color, Vector3(-0.36, 0.56, -0.14), Vector3(90, 0, 0))
			_p(body, LP.torus(0.24, 0.29, 12, 4), a.secondary_color, Vector3(-0.36, 0.56, -0.15), Vector3(90, 0, 0))
			_p(body, LP.sphere(0.07, 6, 4), GOLD, Vector3(-0.36, 0.56, -0.19))
			hand_anchor = Vector3(hx, 0.9, -0.3)
		P.STAFF_ORB, P.STAFF_CRYSTAL:
			_p(body, LP.cylinder(0.025, 0.032, 1.3, 6), WOOD, Vector3(hx, 0.62, -0.06))
			if a.prop == P.STAFF_ORB:
				_p(body, LP.torus(0.07, 0.11, 8, 4), GOLD, Vector3(hx, 1.28, -0.06), Vector3(90, 0, 0))
				_p(body, LP.sphere(0.085, 8, 5), Color("fff2a8"), Vector3(hx, 1.33, -0.06), Vector3.ZERO, Vector3.ONE, 1.6)
				hand_anchor = Vector3(hx, 1.33, -0.06)
			else:
				_p(body, LP.prism(Vector3(0.16, 0.3, 0.16)), a.secondary_color, Vector3(hx, 1.4, -0.06), Vector3(0, 45, 180), Vector3.ONE, 1.4)
				_p(body, LP.prism(Vector3(0.16, 0.22, 0.16)), a.secondary_color, Vector3(hx, 1.6, -0.06), Vector3(0, 45, 0), Vector3.ONE, 1.4)
				hand_anchor = Vector3(hx, 1.45, -0.06)
		P.BOW:
			var c := Vector3(-0.38, 0.62, -0.12)
			var pts: Array[Vector3] = []
			for i in 7:
				var ang := deg_to_rad(-65 + i * (130.0 / 6.0))
				pts.append(c + Vector3(0, sin(ang) * 0.45, -cos(ang) * 0.14))
			for i in 6:
				_segment(body, pts[i], pts[i + 1], 0.022, WOOD)
			_segment(body, pts[0], pts[6], 0.006, Color("f5f0e6"))
			hand_anchor = c + Vector3(0, 0.05, -0.15)
		P.LANTERN:
			_p(body, LP.cylinder(0.012, 0.012, 0.22, 4), LEATHER, Vector3(hx, 0.44, -0.12))
			_p(body, LP.box(Vector3(0.14, 0.17, 0.14)), Color("ffd27a"), Vector3(hx, 0.26, -0.12), Vector3.ZERO, Vector3.ONE, 2.2)
			_p(body, LP.cone(0.11, 0.08, 4), LEATHER, Vector3(hx, 0.38, -0.12), Vector3(0, 45, 0))
			var light := OmniLight3D.new()
			light.light_color = Color("ffcf87")
			light.light_energy = 1.4
			light.omni_range = 6.0
			light.position = Vector3(hx, 0.35, -0.12)
			body.add_child(light)
		P.CLUB:
			_p(body, LP.cylinder(0.08, 0.035, 0.55, 6), WOOD, Vector3(hx, 0.6, -0.12), Vector3(-30, 0, 0))
		P.GREAT_CLUB:
			_p(body, LP.cylinder(0.15, 0.06, 1.0, 7), WOOD.darkened(0.2), Vector3(hx, 0.75, -0.25), Vector3(-35, 0, 0))
			for i in 4:
				var ang := deg_to_rad(i * 90.0)
				_p(body, LP.cone(0.04, 0.14, 4), BONE, Vector3(hx + cos(ang) * 0.14, 1.1, -0.5 + sin(ang) * 0.06), Vector3(-35, 0, rad_to_deg(ang) + 90))
			hand_anchor = Vector3(hx, 1.1, -0.5)
		P.SPEAR:
			_p(body, LP.cylinder(0.018, 0.018, 1.35, 5), WOOD, Vector3(hx, 0.65, -0.08))
			_p(body, LP.cone(0.05, 0.18, 5), STEEL, Vector3(hx, 1.4, -0.08))
			hand_anchor = Vector3(hx, 1.4, -0.08)
		P.TOTEM:
			_p(body, LP.cylinder(0.022, 0.028, 1.1, 5), WOOD, Vector3(hx, 0.55, -0.06))
			_p(body, LP.sphere(0.1, 6, 4), BONE, Vector3(hx, 1.15, -0.06))
			for side: int in [-1, 1]:
				_p(body, LP.box(Vector3(0.03, 0.16, 0.05)), Color("d9534f"), Vector3(hx + 0.08 * side, 1.02, -0.06), Vector3(0, 0, 20 * side))
			hand_anchor = Vector3(hx, 1.15, -0.06)
		P.BROOM:
			_p(body, LP.cylinder(0.018, 0.018, 1.1, 5), WOOD, Vector3(hx, 0.55, -0.06), Vector3(-10, 0, 0))
			_p(body, LP.cone(0.12, 0.3, 7), Color("e3c26d"), Vector3(hx, 0.02, 0.02), Vector3(-10, 0, 0))
		P.BOOK:
			_p(body, LP.box(Vector3(0.22, 0.28, 0.07)), a.secondary_color, Vector3(-0.3, 0.5, -0.2), Vector3(-20, 20, 0))
		P.MUG:
			_p(body, LP.cylinder(0.065, 0.06, 0.14, 7), WOOD, Vector3(hx, 0.46, -0.1))
			_p(body, LP.cylinder(0.066, 0.066, 0.04, 7), Color("fff8e7"), Vector3(hx, 0.54, -0.1))
