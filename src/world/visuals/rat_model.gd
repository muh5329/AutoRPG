class_name RatModel
extends CharacterModel
## Round cave rat.


func get_height() -> float:
	return 0.75 * _base_scale


func _shadow_radius() -> float:
	return 0.36


func _build() -> void:
	var fur := appearance.primary_color
	var pink := appearance.secondary_color
	_p(body, LP.sphere(0.3, 9, 6), fur, Vector3(0, 0.3, 0.02), Vector3.ZERO, Vector3(1, 0.85, 1.35))
	_p(body, LP.sphere(0.22, 8, 5), fur.lightened(0.08), Vector3(0, 0.36, -0.38), Vector3.ZERO, Vector3(1, 0.95, 1.1))
	_p(body, LP.cone(0.11, 0.2, 6), fur.lightened(0.15), Vector3(0, 0.32, -0.6), Vector3(-90, 0, 0))
	_p(body, LP.sphere(0.04, 5, 3), pink, Vector3(0, 0.32, -0.71))
	for side: int in [-1, 1]:
		_p(body, LP.cylinder(0.1, 0.1, 0.025, 8), pink, Vector3(0.14 * side, 0.55, -0.34), Vector3(75, 0, 15 * side))
		_p(body, LP.sphere(0.035, 5, 3), Color("d6282b"), Vector3(0.09 * side, 0.42, -0.54), Vector3.ZERO, Vector3.ONE, 1.5)
		for z: float in [-0.18, 0.2]:
			_p(body, LP.cylinder(0.04, 0.045, 0.16, 5), fur.darkened(0.3), Vector3(0.17 * side, 0.08, z))
	var prev := Vector3(0, 0.3, 0.38)
	for i in 5:
		var next := prev + Vector3(sin(i * 0.9) * 0.06, 0.05 - i * 0.02, 0.13)
		_segment(body, prev, next, 0.03 - i * 0.004, pink)
		prev = next
	hand_anchor = Vector3(0, 0.34, -0.65)
