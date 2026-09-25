class_name WalkableArea
extends RefCounted
## 2D (XZ-plane) navigation bounds: union of walkable shapes minus blockers.
## Cheap, deterministic and good enough for hand-built zones.

var _walkable: Array[Dictionary] = []
var _blockers: Array[Dictionary] = []


func add_rect(center: Vector2, size: Vector2) -> void:
	_walkable.append({ "rect": Rect2(center - size * 0.5, size) })


func add_circle(center: Vector2, radius: float) -> void:
	_walkable.append({ "c": center, "r": radius })


func block_rect(center: Vector2, size: Vector2) -> void:
	_blockers.append({ "rect": Rect2(center - size * 0.5, size) })


func block_circle(center: Vector2, radius: float) -> void:
	_blockers.append({ "c": center, "r": radius })


func is_walkable(p: Vector3) -> bool:
	var q := Vector2(p.x, p.z)
	for b in _blockers:
		if _inside(b, q):
			return false
	for w in _walkable:
		if _inside(w, q):
			return true
	return false


## Best reachable point moving from -> to (slides along edges).
func resolve(from: Vector3, to: Vector3) -> Vector3:
	if is_walkable(to):
		return to
	var slide_x := Vector3(to.x, to.y, from.z)
	if is_walkable(slide_x):
		return slide_x
	var slide_z := Vector3(from.x, to.y, to.z)
	if is_walkable(slide_z):
		return slide_z
	return from


static func _inside(shape: Dictionary, q: Vector2) -> bool:
	if shape.has("rect"):
		return (shape.rect as Rect2).has_point(q)
	return q.distance_to(shape.c) <= shape.r
