class_name Inventory
extends RefCounted
## The party's shared bag. Stackable items share one entry; others get one entry each.

signal changed

## One slot in the bag.
class Entry:
	extends RefCounted
	var item: Item
	var quantity: int

	func _init(item_: Item, quantity_: int) -> void:
		item = item_
		quantity = quantity_


var _entries: Array[Entry] = []


func add(item: Item, quantity: int = 1) -> void:
	assert(item != null and quantity > 0)
	if item.is_stackable():
		var existing := _find(item)
		if existing:
			existing.quantity += quantity
		else:
			_entries.append(Entry.new(item, quantity))
	else:
		for i in quantity:
			_entries.append(Entry.new(item, 1))
	changed.emit()


func remove(item: Item, quantity: int = 1) -> bool:
	if count_of(item) < quantity:
		return false
	var left := quantity
	for i in range(_entries.size() - 1, -1, -1):
		var e := _entries[i]
		if e.item != item:
			continue
		var take := mini(left, e.quantity)
		e.quantity -= take
		left -= take
		if e.quantity == 0:
			_entries.remove_at(i)
		if left == 0:
			break
	changed.emit()
	return true


func count_of(item: Item) -> int:
	var total := 0
	for e in _entries:
		if e.item == item:
			total += e.quantity
	return total


func entries() -> Array[Entry]:
	return _entries.duplicate()


## Entries filtered by item class, e.g. entries_of(Potion).
func entries_of(script: Script) -> Array[Entry]:
	var out: Array[Entry] = []
	for e in _entries:
		if is_instance_of(e.item, script):
			out.append(e)
	return out


func first_of(script: Script) -> Item:
	for e in _entries:
		if is_instance_of(e.item, script):
			return e.item
	return null


func is_empty() -> bool:
	return _entries.is_empty()


func _find(item: Item) -> Entry:
	for e in _entries:
		if e.item == item:
			return e
	return null
