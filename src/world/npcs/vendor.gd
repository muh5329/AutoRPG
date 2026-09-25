class_name Vendor
extends FriendlyNPC
## Sells a fixed stock and buys anything back at half price.

@export var stock_ids: Array[StringName] = []
@export var shop_name: String = "Shop"


func get_stock() -> Array[Item]:
	return Content.items(stock_ids)


func _add_options(d: Dialogue) -> void:
	d.add_option("Browse wares", open_shop, true)


func open_shop() -> void:
	EventBus.shop_requested.emit(self)
