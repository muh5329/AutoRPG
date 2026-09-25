class_name SpiderModel
extends CharacterModel
## Eight-legged cave spider with a glowing abdomen mark.


func get_height() -> float:
	return 1.0 * _base_scale


func _shadow_radius() -> float:
	return 0.55


func _build() -> void:
	var shell := appearance.primary_color
	var mark := appearance.secondary_color
	_p(body, LP.sphere(0.38, 9, 6), shell, Vector3(0, 0.55, 0.32), Vector3.ZERO, Vector3(1, 0.85, 1.15))
	_p(body, LP.sphere(0.12, 6, 4), mark, Vector3(0, 0.84, 0.36), Vector3.ZERO, Vector3(1, 0.4, 1.4), 1.2)
	_p(body, LP.sphere(0.24, 8, 5), shell.lightened(0.08), Vector3(0, 0.45, -0.14))
	for i in 4:
		var ex := -0.09 + (i % 2) * 0.18
		var ey := 0.5 + (i / 2) * 0.07
		_p(body, LP.sphere(0.035, 5, 3), Color("ff3344"), Vector3(ex, ey, -0.35), Vector3.ZERO, Vector3.ONE, 2.0)
	for side: int in [-1, 1]:
		_p(body, LP.cone(0.035, 0.14, 5), Color("efe6d0"), Vector3(0.06 * side, 0.33, -0.32), Vector3(180, 0, 0))
	var dark := shell.darkened(0.35)
	for side: int in [-1, 1]:
		for zi: float in [-0.26, -0.09, 0.08, 0.25]:
			var hip := Vector3(0.16 * side, 0.45, zi - 0.05)
			var knee := Vector3(0.58 * side, 0.82, zi * 1.7)
			var foot := Vector3(0.86 * side, 0.0, zi * 2.3)
			_segment(body, hip, knee, 0.035, dark)
			_segment(body, knee, foot, 0.028, dark)
	hand_anchor = Vector3(0, 0.45, -0.4)
