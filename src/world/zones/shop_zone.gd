class_name ShopZone
extends InteriorZone
## Tilda's Wares: potions, weapons and armour.


func _init() -> void:
	zone_id = &"shop"
	display_name = "Tilda's Wares"
	room_size = Vector2(12, 9)
	wall_color = Color("dfe8f2")
	floor_color = Color("a0714a")
	exit_spawn = &"shop_door"


func get_subtitle() -> String:
	return "Potions, weapons and armour"


func _furnish() -> void:
	Props.rug(self, Vector3(0, 0, 0.6), Vector2(4, 2.6), Color("3b7dd8"))
	Props.counter(self, Vector3(0, 0, -1.9), 4.4)
	block(Vector3(0, 0, -1.9), Vector2(4.8, 1.2))
	Props.shelf(self, Vector3(-2.6, 0, -4.2), 0, 3.4, [Color("e0453a"), Color("ff5f8f"), Color("e0453a"), Color("7fd8f2")])
	Props.shelf(self, Vector3(2.6, 0, -4.2), 0, 3.4, [Color("3fa34d"), Color("f2c45a"), Color("b28dff"), Color("e0453a")])
	# Weapon rack on the west wall
	var rack := Node3D.new()
	add_child(rack)
	rack.position = Vector3(-5.6, 0, -0.5)
	LowPoly.part(rack, LowPoly.box(Vector3(0.3, 0.12, 3.0)), Props.WOOD_DARK, Vector3(0, 1.0, 0))
	LowPoly.part(rack, LowPoly.box(Vector3(0.3, 0.12, 3.0)), Props.WOOD_DARK, Vector3(0, 2.0, 0))
	for i in 5:
		var z := -1.2 + i * 0.6
		LowPoly.part(rack, LowPoly.box(Vector3(0.06, 1.3, 0.08)), Color("dfe6ee"), Vector3(0.1, 1.55, z))
		LowPoly.part(rack, LowPoly.box(Vector3(0.1, 0.06, 0.26)), Color("f2c45a"), Vector3(0.1, 0.95, z))
	block(Vector3(-5.6, 0, -0.5), Vector2(0.8, 3.2))
	# Armour stand
	var stand := Node3D.new()
	add_child(stand)
	stand.position = Vector3(5.0, 0, -0.4)
	LowPoly.part(stand, LowPoly.cylinder(0.3, 0.35, 0.1, 8), Props.WOOD_DARK, Vector3(0, 0.05, 0))
	LowPoly.part(stand, LowPoly.cylinder(0.04, 0.04, 1.1, 5), Props.WOOD_DARK, Vector3(0, 0.6, 0))
	LowPoly.part(stand, LowPoly.cylinder(0.24, 0.3, 0.6, 8), Color("c3ccd8"), Vector3(0, 1.3, 0))
	LowPoly.part(stand, LowPoly.sphere(0.2, 8, 5), Color("c3ccd8"), Vector3(0, 1.8, 0), Vector3.ZERO, Vector3(1, 0.85, 1))
	block(Vector3(5.0, 0, -0.4), Vector2(1.0, 1.0))
	for p in [Vector3(-5.0, 0, 3.4), Vector3(5.0, 0, 3.2)]:
		Props.crate(self, p)
		block(p, Vector2(1.0, 1.0))
	Props.barrel(self, Vector3(4.6, 0, 1.8))
	block(Vector3(4.6, 0, 1.8), Vector2(0.9, 0.9))
	add_light(Vector3(0, 2.8, 0.5), Color("ffe0b0"), 1.3, 8.0)
	var tilda := Vendor.new()
	tilda.entity_id = &"tilda"
	tilda.display_name = "Tilda"
	tilda.title = "Merchant"
	tilda.appearance = Appearance.humanoid(Appearance.Outfit.MERCHANT, Appearance.Headgear.HAIR_BUN, Appearance.Prop.NONE,
		Color("3aa6a0"), Color("fff3e0"), Color("f6d3b3"), Color("c2562f"))
	tilda.greeting = PackedStringArray(["Oh! Customers! Potions, blades, armour — if it keeps you alive, I sell it."])
	tilda.shop_name = "Tilda's Wares"
	tilda.stock_ids = [&"potion_health", &"potion_greater", &"iron_longsword", &"blessed_mace", &"yew_longbow",
		&"ember_wand", &"reinforced_plate", &"ranger_leathers", &"silk_vestments"]
	add_entity(tilda, Vector3(0, 0, -3.0), 180)
