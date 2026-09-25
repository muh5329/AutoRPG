class_name Item
extends Resource
## Abstract base for every item definition (shared, immutable data).
## Inventory stores definitions + quantities; there are no per-instance rolls yet (YAGNI).

enum Rarity { COMMON, UNCOMMON, RARE, EPIC }

const RARITY_COLORS := {
	Rarity.COMMON: Color("8a8f98"),
	Rarity.UNCOMMON: Color("3fa34d"),
	Rarity.RARE: Color("3b7dd8"),
	Rarity.EPIC: Color("9b4dd6"),
}

## Icon shapes understood by ItemIcon (UI layer).
enum Icon { POTION, SWORD, MACE, STAFF, BOW, WAND, PLATE, LEATHER, ROBE, GEM }

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var price: int = 10
@export var rarity: Rarity = Rarity.COMMON
@export var icon: Icon = Icon.GEM
@export var icon_color: Color = Color.WHITE


func get_sell_price() -> int:
	return maxi(1, price / 2)


func get_rarity_color() -> Color:
	return RARITY_COLORS[rarity]


## Can several copies share one inventory slot?
func is_stackable() -> bool:
	return false


## Category label shown in tooltips ("Potion", "Weapon"...). Override in subclasses.
func get_category() -> String:
	return "Item"


## Multi-line tooltip body. Subclasses extend with their own details.
func get_tooltip() -> String:
	return description
