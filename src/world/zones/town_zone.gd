class_name TownZone
extends Zone
## Oakhaven: the starting village. Plaza with fountain, the Sleepy Griffin Inn (west),
## Tilda's Wares (east), Elder Maren's house (north-west) and the road north to Glimmerdeep.

const INN_POS := Vector3(-12, 0, -1)
const SHOP_POS := Vector3(12, 0, -1)


func _init() -> void:
	zone_id = &"town"
	display_name = "Oakhaven Village"


func _build_environment() -> void:
	make_environment({ "sun_rot": Vector3(-50, -35, 0) })


func _build_world() -> void:
	walkable.add_rect(Vector2(0, -6), Vector2(44, 50))
	_build_ground()
	_build_buildings()
	_build_plaza()
	_build_cave_approach()
	_build_nature()
	_build_npcs()
	add_spawn(&"default", Vector3(0, 0, 15), 0)
	add_spawn(&"inn_door", Vector3(-7.4, 0, -1), -90)
	add_spawn(&"shop_door", Vector3(7.4, 0, -1), 90)
	add_spawn(&"cave_exit", Vector3(0, 0, -28.5), 180)


func get_subtitle() -> String:
	return "A quiet village at the foot of the Glimmer Peaks"


# --- layout ------------------------------------------------------------------------------------

func _build_ground() -> void:
	Terrain.ground(self, Vector3(0, -0.05, -8), Vector2(96, 100), Color("7cc95a"), Color("a6d86a"), 11)
	var road := Color("dcbf8a")
	Terrain.slab(self, Vector3(0, 0, -6), Vector2(3.4, 52), road)
	Terrain.slab(self, Vector3(0, 0, 0), Vector2(34, 3.2), road)
	Terrain.slab(self, Vector3(-6, 0, -9), Vector2(2.2, 8), road)
	LowPoly.part(self, LowPoly.cylinder(7.5, 7.5, 0.08, 16), Color("cdbfa6"), Vector3(0, 0.04, 0))
	LowPoly.part(self, LowPoly.cylinder(6.6, 6.6, 0.09, 16), Color("d9ccb4"), Vector3(0, 0.045, 0))


func _build_buildings() -> void:
	_building(INN_POS, 90, Vector3(7, 3.4, 6), Color("d9534f"), Color("f2c45a"))
	add_door(&"inn", &"default", INN_POS + Vector3(3.8, 0, 0), "The Sleepy Griffin Inn")
	_building(SHOP_POS, -90, Vector3(6, 3.0, 5.5), Color("4a78c2"), Color("7fd8f2"))
	add_door(&"shop", &"default", SHOP_POS + Vector3(-3.55, 0, 0), "Tilda's Wares")
	_building(Vector3(-7, 0, -13), 0, Vector3(6, 3.0, 5), Color("3aa6a0"))
	_building(Vector3(9, 0, -13), 0, Vector3(5.5, 2.8, 5), Color("e8894a"))
	_building(Vector3(-15, 0, 11), 90, Vector3(5, 2.6, 5), Color("8e6bd6"))
	_building(Vector3(14, 0, 11), -90, Vector3(5, 2.8, 5.5), Color("d9534f"))
	_building(Vector3(-17, 0, -12), 90, Vector3(4.5, 2.6, 4.5), Color("4a78c2"))
	_building(Vector3(17, 0, -12), -90, Vector3(4.5, 2.6, 4.5), Color("3fa34d"))


func _building(pos: Vector3, yaw: float, size: Vector3, roof: Color, sign := Color(0, 0, 0, 0)) -> void:
	Props.house(self, pos, yaw, size, roof, Props.PLASTER, true, sign)
	var rotated := absf(fmod(yaw, 180.0)) > 45.0
	var footprint := Vector2(size.z, size.x) if rotated else Vector2(size.x, size.z)
	walkable.block_rect(Vector2(pos.x, pos.z), footprint + Vector2(0.8, 0.8))


func _build_plaza() -> void:
	Props.fountain(self, Vector3.ZERO)
	walkable.block_circle(Vector2.ZERO, 2.7)
	for i in 4:
		var ang := PI * 0.25 + i * PI * 0.5
		Props.lamp_post(self, Vector3(cos(ang) * 6.2, 0, sin(ang) * 6.2), i % 2 == 0)
		walkable.block_circle(Vector2(cos(ang) * 6.2, sin(ang) * 6.2), 0.3)
	Props.bench(self, Vector3(-3.5, 0, 4.6), 180)
	Props.bench(self, Vector3(3.5, 0, -4.6), 0)
	Props.market_stall(self, Vector3(6.5, 0, 6.5), 180, Color("e94f37"))
	walkable.block_rect(Vector2(6.5, 6.5), Vector2(2.6, 1.4))
	Props.market_stall(self, Vector3(-6.5, 0, -5.5), 0, Color("3b7dd8"))
	walkable.block_rect(Vector2(-6.5, -5.5), Vector2(2.6, 1.4))
	Props.well(self, Vector3(-7, 0, 7))
	walkable.block_circle(Vector2(-7, 7), 1.1)
	for p in [Vector3(-9.3, 0, 2.2), Vector3(-9.8, 0, -3.4), Vector3(9.2, 0, 2.4), Vector3(9.6, 0, -3.2)]:
		Props.barrel(self, p)
		walkable.block_circle(Vector2(p.x, p.z), 0.45)
	Props.crate(self, Vector3(10.2, 0, 3.4))
	Props.crate(self, Vector3(-10.4, 0, 3.0), 0.55)
	for z in [8.0, 14.0]:
		Props.lamp_post(self, Vector3(2.4, 0, z), z > 10.0)
		walkable.block_circle(Vector2(2.4, z), 0.3)
	for z in [-10.0, -18.0, -25.0]:
		Props.lamp_post(self, Vector3(-2.4, 0, z), true)
		walkable.block_circle(Vector2(-2.4, z), 0.3)
	Props.fence(self, Vector3(-2.4, 0, 18), Vector3(-2.4, 0, 6))
	Props.fence(self, Vector3(4.2, 0, 18), Vector3(4.2, 0, 12))
	Props.signpost(self, Vector3(2.6, 0, -20), -20)


func _build_cave_approach() -> void:
	# Mountain wall across the north with the cave mouth in the middle.
	for i in 13:
		var x := -48.0 + i * 8.0
		if absf(x) < 3.0:
			continue
		Props.mountain(self, Vector3(x, 0, -39 - (i % 3) * 2.0), 6.5, 6.0 + (i % 4) * 1.6, i)
	Props.mountain(self, Vector3(-6.5, 0, -35), 4.2, 4.2, 40, Color("8f897f"))
	Props.mountain(self, Vector3(6.5, 0, -35), 4.2, 4.4, 41, Color("8f897f"))
	Props.mountain(self, Vector3(0, 0, -38.5), 5.0, 5.8, 42, Color("8f897f"))
	LowPoly.part(self, LowPoly.sphere(2.6, 10, 6), Color("120e18"), Vector3(0, 0.2, -34.2), Vector3.ZERO, Vector3(1.1, 1.0, 0.5))
	Props.torch(self, Vector3(-2.8, 0, -31.5))
	Props.torch(self, Vector3(2.8, 0, -31.5))
	walkable.block_circle(Vector2(-2.8, -31.5), 0.3)
	walkable.block_circle(Vector2(2.8, -31.5), 0.3)
	for p in [Vector3(-4, 0, -30), Vector3(4.3, 0, -29.5), Vector3(-5.5, 0, -27.5)]:
		Props.boulder(self, p, 0.8, int(p.x * 7))
		walkable.block_circle(Vector2(p.x, p.z), 0.8)
	add_door(&"cave", &"default", Vector3(0, 0, -31.2), "Glimmerdeep Cave")


func _build_nature() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	# Tree border outside the walkable area
	for i in 60:
		var side := i % 4
		var p: Vector3
		match side:
			0: p = Vector3(rng.randf_range(-40, 40), 0, rng.randf_range(24.5, 36))
			1: p = Vector3(rng.randf_range(-40, -23.5), 0, rng.randf_range(-34, 20))
			2: p = Vector3(rng.randf_range(23.5, 40), 0, rng.randf_range(-34, 20))
			3: p = Vector3(rng.randf_range(-40, 40), 0, rng.randf_range(-36, -31.5))
		if side == 3 and absf(p.x) < 8.0:
			continue
		if i % 3 == 0:
			Props.pine_tree(self, p, rng.randf_range(1.0, 1.5), i)
		else:
			Props.round_tree(self, p, rng.randf_range(0.9, 1.4), i)
	# Trees and bushes inside the village
	for p in [Vector3(-19, 0, 2), Vector3(19, 0, 4), Vector3(-12, 0, -21), Vector3(13, 0, -22), Vector3(-19, 0, -22),
			Vector3(18.5, 0, -3.5), Vector3(-6, 0, 17), Vector3(8, 0, 17), Vector3(-20, 0, 17)]:
		Props.round_tree(self, p, rng.randf_range(0.9, 1.2), int(p.x + p.z))
		walkable.block_circle(Vector2(p.x, p.z), 0.6)
	for i in 26:
		var p := Vector3(rng.randf_range(-21, 21), 0, rng.randf_range(-29, 18))
		if absf(p.x) < 4.0 or (absf(p.z) < 2.5) or Vector2(p.x, p.z).length() < 8.5:
			continue
		if not walkable.is_walkable(p):
			continue
		if i % 3 == 0:
			Props.bush(self, p, rng.randf_range(0.7, 1.1), i)
			walkable.block_circle(Vector2(p.x, p.z), 0.5)
		else:
			Props.flower_patch(self, p, i)
	for i in 80:
		var p := Vector3(rng.randf_range(-30, 30), 0, rng.randf_range(-32, 22))
		if absf(p.x) > 2.2 or absf(p.z) > 30:
			Props.grass_tuft(self, p)


func _build_npcs() -> void:
	var elder := QuestGiver.new()
	elder.entity_id = &"maren"
	elder.display_name = "Elder Maren"
	elder.title = "Village Elder"
	elder.appearance = Appearance.humanoid(Appearance.Outfit.ELDER, Appearance.Headgear.HAIR_BUN, Appearance.Prop.BOOK,
		Color("7d5ba6"), Color("f2c45a"), Color("f0c8a0"), Color("eeeeee"))
	elder.quest_ids = [&"glimmerdeep"]
	elder.greeting = PackedStringArray(["Welcome to Oakhaven, Wayfarer. May the light of the Glimmer Peaks guide you."])
	add_entity(elder, Vector3(-5.2, 0, -8.6), 150)

	var captain := QuestGiver.new()
	captain.entity_id = &"aldric"
	captain.display_name = "Captain Aldric"
	captain.title = "Town Guard"
	captain.appearance = Appearance.humanoid(Appearance.Outfit.GUARD, Appearance.Headgear.HELMET, Appearance.Prop.SPEAR,
		Color("c0504d"), Color("cfd8e3"), Color("e8b88f"), Color("5a3a22"), 1.05)
	captain.quest_ids = [&"strength_in_numbers", &"prepared_for_worst"]
	captain.greeting = PackedStringArray(["Keep your wits about you. Things have been restless since the cave went dark."])
	add_entity(captain, Vector3(4.2, 0, 6.2), -60)
	walkable.block_circle(Vector2(4.2, 6.2), 0.4)

	_villager(&"pip", "Pip", Vector3(1.5, 0, 3.8), 0.72, Appearance.humanoid(Appearance.Outfit.VILLAGER,
		Appearance.Headgear.CAP, Appearance.Prop.NONE, Color("f6ae2d"), Color("3b7dd8"), Color("f2c9a0"), Color("b5651d")),
		["Are you a real adventurer?!", "I'm gonna be a hero too someday!", "Race you to the fountain!"],
		["Mister! Mister! Can I see your lantern? ...Woah."])
	_villager(&"hobb", "Farmer Hobb", Vector3(-4, 0, 11), 1.0, Appearance.humanoid(Appearance.Outfit.VILLAGER,
		Appearance.Headgear.CAP, Appearance.Prop.BROOM, Color("86bb4e"), Color("e6cf9f"), Color("e0a97a"), Color("6b4226")),
		["Rats got into my cellar again...", "Harvest's been poor since the crystals dimmed.", "Fine weather, at least."],
		["Rats the size of dogs, I tell you! Came up from the cave, they did."])
	_villager(&"nell", "Old Nell", Vector3(7, 0, -7), 0.95, Appearance.humanoid(Appearance.Outfit.VILLAGER,
		Appearance.Headgear.HAIR_BUN, Appearance.Prop.BROOM, Color("b28dff"), Color("fff3e0"), Color("f0c8a0"), Color("cfcfcf")),
		["In my day we fought goblins with ladles.", "Tilda's potions are worth every copper.", "Mind the flowers, dear."],
		["The Elder frets too much. But she's right about that cave."])


func _villager(id: StringName, name_: String, pos: Vector3, scale: float, appearance: Appearance,
		barks: Array, greeting: Array) -> void:
	appearance.scale = scale
	var v := Villager.new()
	v.entity_id = id
	v.display_name = name_
	v.appearance = appearance
	v.barks = PackedStringArray(barks)
	v.greeting = PackedStringArray(greeting)
	add_entity(v, pos, randf() * 360.0)
