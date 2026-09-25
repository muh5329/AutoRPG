class_name Wallet
extends RefCounted
## The party's gold.

signal changed(gold: int)

var gold: int = 0


func _init(starting := 0) -> void:
	gold = starting


func can_afford(amount: int) -> bool:
	return gold >= amount


func earn(amount: int) -> void:
	gold += maxi(amount, 0)
	changed.emit(gold)


func spend(amount: int) -> bool:
	if not can_afford(amount):
		return false
	gold -= amount
	changed.emit(gold)
	return true
