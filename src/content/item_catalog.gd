class_name ItemCatalog
extends RefCounted
## Every item in the first iteration.

const W := Weapon.WeaponType
const A := Armor.ArmorType
const R := Item.Rarity
const I := Item.Icon


static func build() -> Array[Item]:
	var out: Array[Item] = [
		_potion(&"potion_health", "Health Potion", "A cork-stoppered vial of red tonic.", 0.4, 25, R.COMMON, Color("e0453a")),
		_potion(&"potion_greater", "Greater Health Potion", "Brewed by Tilda's grandmother. Tastes of cherries.", 0.7, 60, R.UNCOMMON, Color("ff5f8f")),
		# Starting gear
		_weapon(&"rusty_sword", "Rusty Sword", "Better than a stick. Barely.", W.SWORD, StatBlock.make(0, 2, 0), 10, R.COMMON, I.SWORD, Color("b0a695")),
		_weapon(&"apprentice_staff", "Apprentice Staff", "Carved from temple ash.", W.STAFF, StatBlock.make(0, 2, 0), 10, R.COMMON, I.STAFF, Color("b98a52")),
		_weapon(&"worn_bow", "Worn Bow", "The string has been replaced twice.", W.BOW, StatBlock.make(0, 2, 0), 10, R.COMMON, I.BOW, Color("a9804f")),
		_weapon(&"apprentice_wand", "Apprentice Wand", "Hums faintly.", W.WAND, StatBlock.make(0, 2, 0), 10, R.COMMON, I.WAND, Color("9b7fd1")),
		_armor(&"worn_plate", "Worn Plate", "Dented but dependable.", A.PLATE, StatBlock.make(30, 0, 10), 15, R.COMMON, I.PLATE, Color("9aa4b1")),
		_armor(&"hide_vest", "Hide Vest", "Stitched from boar hide.", A.LEATHER, StatBlock.make(15, 0, 5), 12, R.COMMON, I.LEATHER, Color("9b6b43")),
		_armor(&"linen_robe", "Linen Robe", "Simple and clean.", A.CLOTH, StatBlock.make(10, 0, 3), 12, R.COMMON, I.ROBE, Color("e9e1cf")),
		# Vendor stock
		_weapon(&"iron_longsword", "Iron Longsword", "Balanced steel from Oakhaven's forge.", W.SWORD, StatBlock.make(40, 8, 0), 120, R.UNCOMMON, I.SWORD, Color("cfd8e3")),
		_weapon(&"blessed_mace", "Blessed Mace", "Warm to the touch.", W.MACE, StatBlock.make(20, 9, 0), 110, R.UNCOMMON, I.MACE, Color("f2d36b")),
		_weapon(&"yew_longbow", "Yew Longbow", "Long draw, true flight.", W.BOW, StatBlock.make(0, 10, 0, 0.0, 0.03), 120, R.UNCOMMON, I.BOW, Color("c9a26b")),
		_weapon(&"ember_wand", "Ember Wand", "Smells faintly of smoke.", W.WAND, StatBlock.make(0, 11, 0, 0.05), 130, R.UNCOMMON, I.WAND, Color("ff8a3d")),
		_armor(&"reinforced_plate", "Reinforced Plate", "Riveted steel plates over mail.", A.PLATE, StatBlock.make(60, 0, 20), 140, R.UNCOMMON, I.PLATE, Color("c3ccd8")),
		_armor(&"ranger_leathers", "Ranger Leathers", "Soft, silent, supple.", A.LEATHER, StatBlock.make(30, 0, 12, 0.03), 100, R.UNCOMMON, I.LEATHER, Color("6f8f47")),
		_armor(&"silk_vestments", "Silk Vestments", "Embroidered with protective sigils.", A.CLOTH, StatBlock.make(25, 6, 8), 100, R.UNCOMMON, I.ROBE, Color("8fb4ff")),
		# Rewards
		_weapon(&"stonehide_cleaver", "Stonehide Cleaver", "Gorrak's own blade, still gritty with cave dust.", W.SWORD, StatBlock.make(100, 16, 10), 300, R.RARE, I.SWORD, Color("8a7f72")),
		_weapon(&"glimmer_staff", "Glimmerdeep Crystal Staff", "A staff topped with a singing cave crystal.", W.STAFF, StatBlock.make(40, 20, 0, 0.10), 450, R.EPIC, I.STAFF, Color("6ee7ff")),
	]
	return out


static func _potion(id: StringName, name: String, desc: String, pct: float, price: int, rarity: Item.Rarity, color: Color) -> Potion:
	var p := Potion.new()
	_base(p, id, name, desc, price, rarity, I.POTION, color)
	p.heal_percent = pct
	return p


static func _weapon(id: StringName, name: String, desc: String, type: Weapon.WeaponType, stats: StatBlock,
		price: int, rarity: Item.Rarity, icon: Item.Icon, color: Color) -> Weapon:
	var w := Weapon.new()
	_base(w, id, name, desc, price, rarity, icon, color)
	w.weapon_type = type
	w.stats = stats
	return w


static func _armor(id: StringName, name: String, desc: String, type: Armor.ArmorType, stats: StatBlock,
		price: int, rarity: Item.Rarity, icon: Item.Icon, color: Color) -> Armor:
	var a := Armor.new()
	_base(a, id, name, desc, price, rarity, icon, color)
	a.armor_type = type
	a.stats = stats
	return a


static func _base(item: Item, id: StringName, name: String, desc: String, price: int, rarity: Item.Rarity,
		icon: Item.Icon, color: Color) -> void:
	item.id = id
	item.display_name = name
	item.description = desc
	item.price = price
	item.rarity = rarity
	item.icon = icon
	item.icon_color = color
