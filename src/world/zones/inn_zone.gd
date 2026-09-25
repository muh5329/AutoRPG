class_name InnZone
extends InteriorZone
## The Sleepy Griffin: rest with Bram and recruit the heroes drinking here.


func _init() -> void:
	zone_id = &"inn"
	display_name = "The Sleepy Griffin Inn"
	room_size = Vector2(15, 11)
	exit_spawn = &"inn_door"


func get_subtitle() -> String:
	return "Rest your party and recruit new heroes"


func _furnish() -> void:
	Props.rug(self, Vector3(0, 0, 0.5), Vector2(5, 3.5), Color("b8413a"))
	# Bar
	Props.counter(self, Vector3(3.6, 0, -2.8), 5.0)
	block(Vector3(3.6, 0, -2.8), Vector2(5.4, 1.2))
	Props.shelf(self, Vector3(3.6, 0, -5.1), 0, 4.4, [Color("8a5a35"), Color("3fa34d"), Color("e0453a"), Color("f2c45a")])
	for x in [2.0, 3.4, 4.8]:
		Props.mug(self, Vector3(x, 1.17, -2.7))
	for x in [1.8, 3.6, 5.4]:
		Props.stool(self, Vector3(x, 0, -1.8))
	var bram := Innkeeper.new()
	bram.entity_id = &"bram"
	bram.display_name = "Bram"
	bram.title = "Innkeeper"
	bram.appearance = Appearance.humanoid(Appearance.Outfit.INNKEEPER, Appearance.Headgear.BALD, Appearance.Prop.MUG,
		Color("c0504d"), Color("fffaf0"), Color("e8b88f"), Color("5a3a22"), 1.1)
	bram.greeting = PackedStringArray(["Welcome to the Sleepy Griffin! Warm beds, cold ale and the best stew this side of the Peaks."])
	bram.stock_ids = [&"potion_health", &"potion_greater"]
	bram.shop_name = "Bram's Pantry"
	bram.rest_cost = 10
	add_entity(bram, Vector3(3.6, 0, -3.9), 180)
	# Fireplace corner
	Props.fireplace(self, Vector3(-4.2, 0, -5.0), 0)
	block(Vector3(-4.2, 0, -5.0), Vector2(2.8, 1.4))
	Props.rug(self, Vector3(-4.2, 0, -3.2), Vector2(3.0, 1.8), Color("3b6ea5"))
	# Tables
	for t in [Vector3(-4.0, 0, 1.2), Vector3(2.8, 0, 1.8)]:
		Props.table(self, t)
		block(t, Vector2(1.6, 1.6))
		for ang in [0.0, 2.1, 4.2]:
			Props.stool(self, t + Vector3(cos(ang) * 1.15, 0, sin(ang) * 1.15))
		Props.mug(self, t + Vector3(0.2, 0.85, 0.1))
	for p in [Vector3(-6.6, 0, 4.4), Vector3(6.6, 0, 4.2), Vector3(-6.6, 0, -2.4)]:
		Props.barrel(self, p)
		block(p, Vector2(0.9, 0.9))
	add_light(Vector3(0, 2.8, 0), Color("ffcf87"), 1.2, 9.0)
	add_light(Vector3(3.6, 2.5, -2.5), Color("ffd9a0"), 1.0, 6.0)
	# Recruitable heroes
	_recruit(&"ignatius", Vector3(-4.0, 0, 2.6), 170, PackedStringArray([
		"Ah! A fellow connoisseur of danger? Name's Ignatius. The Academy called me 'a hazard'. I prefer 'enthusiastic'.",
		"Point me at something flammable and I'm yours."]))
	_recruit(&"lyra", Vector3(4.6, 0, 2.9), -150, PackedStringArray([
		"Lyra Moonwhisper. I've been waiting for someone brave — or foolish — enough to go into Glimmerdeep.",
		"My bow is yours, if you'll have it."]))


func _recruit(id: StringName, pos: Vector3, yaw: float, greeting: PackedStringArray) -> void:
	var r := RecruitableHero.new()
	r.entity_id = id
	r.hero_id = id
	r.greeting = greeting
	add_entity(r, pos, yaw)
