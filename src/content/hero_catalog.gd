class_name HeroCatalog
extends RefCounted
## The five recruitable heroes of the first iteration.

const O := Appearance.Outfit
const H := Appearance.Headgear
const P := Appearance.Prop


static func build(classes: Dictionary, items: Dictionary) -> Array[HeroDefinition]:
	var out: Array[HeroDefinition] = [
		_hero(&"garrick", "Garrick Stoneheart", "Shield of Oakhaven",
			"A retired town guard who never quite retired. Steady, stubborn and loyal.",
			classes[&"warrior"], items[&"rusty_sword"], items[&"worn_plate"],
			Appearance.humanoid(O.WARRIOR, H.HELMET, P.SWORD_SHIELD, Color("4a78c2"), Color("d9d2c5"), Color("e8b88f"), Color("6b4226"), 1.08)),
		_hero(&"seraphine", "Seraphine Dawnlight", "Acolyte of the Dawn",
			"A soft-spoken priestess who believes every wound can be mended.",
			classes[&"priest"], items[&"apprentice_staff"], items[&"linen_robe"],
			Appearance.humanoid(O.PRIEST, H.HAIR_LONG, P.STAFF_ORB, Color("f4f1ea"), Color("e7b84a"), Color("f6d3b3"), Color("f3d17a"))),
		_hero(&"wren", "Wren Swiftarrow", "Warden of the Wilds",
			"Grew up in the Whisperwood. Can split an arrow at sixty paces.",
			classes[&"hunter"], items[&"worn_bow"], items[&"hide_vest"],
			Appearance.humanoid(O.HUNTER, H.HOOD, P.BOW, Color("4f8a3c"), Color("8a5a35"), Color("d9a47c"), Color("3b2a1e"))),
		_hero(&"ignatius", "Ignatius Emberwick", "Pyromancer (Expelled)",
			"Was asked to leave the Academy after the third library fire.",
			classes[&"mage"], items[&"apprentice_wand"], items[&"linen_robe"],
			Appearance.humanoid(O.MAGE, H.WIZARD_HAT, P.STAFF_CRYSTAL, Color("7a4fc9"), Color("f2a93b"), Color("f2c9a0"), Color("eeeeee"))),
		_hero(&"lyra", "Lyra Moonwhisper", "Silver Sharpshooter",
			"A wandering archer looking for a cause worth her arrows.",
			classes[&"hunter"], items[&"worn_bow"], items[&"hide_vest"],
			Appearance.humanoid(O.HUNTER, H.HAIR_BUN, P.BOW, Color("3aa6a0"), Color("e9e1cf"), Color("c98f6b"), Color("c7d3f0"))),
	]
	return out


static func _hero(id: StringName, name: String, title: String, bio: String, hero_class: HeroClass,
		weapon: Weapon, armor: Armor, appearance: Appearance) -> HeroDefinition:
	var h := HeroDefinition.new()
	h.id = id
	h.display_name = name
	h.title = title
	h.bio = bio
	h.hero_class = hero_class
	h.starting_weapon = weapon
	h.starting_armor = armor
	h.appearance = appearance
	return h
