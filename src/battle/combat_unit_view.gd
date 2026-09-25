class_name CombatUnitView
extends Node3D
## Presentation of one BattleUnit: walks into formation, animates attacks,
## spawns numbers and effects. Purely reacts to the model's signals.

const ENTER_SPEED := 9.0

var unit: BattleUnit
var director: BattleDirector
var model: CharacterModel
var home: Vector3
var home_yaw_deg: float

var _entering := true
var _cast_ring: MeshInstance3D
var _shield: MeshInstance3D
var _stun_fx: Node3D
var _buff_ring: MeshInstance3D


func setup(unit_: BattleUnit, director_: BattleDirector, start: Vector3, home_: Vector3, yaw_deg: float) -> CombatUnitView:
	unit = unit_
	director = director_
	home = home_
	home_yaw_deg = yaw_deg
	position = start
	name = "View_%s_%d" % [unit.team, unit.slot]
	return self


func _ready() -> void:
	model = ModelFactory.build(unit.combatant.get_appearance())
	add_child(model)
	rotation_degrees.y = home_yaw_deg
	if not unit.is_alive():
		model.play_death()
	unit.acted.connect(_on_acted)
	unit.cast_started.connect(_on_cast_started)
	unit.cast_ended.connect(_on_cast_ended)
	unit.damaged.connect(_on_damaged)
	unit.healed.connect(_on_healed)
	unit.absorbed.connect(_on_absorbed)
	unit.status_added.connect(_on_status_added)
	unit.status_removed.connect(_on_status_removed)
	unit.died.connect(_on_died)
	if unit.combatant is Boss:
		(unit.combatant as Boss).enraged.connect(_on_enraged)


func _process(delta: float) -> void:
	if _entering:
		var to := home - global_position
		to.y = 0.0
		if to.length() < 0.05:
			global_position = home
			_entering = false
			model.set_moving(false)
			rotation_degrees.y = home_yaw_deg
		else:
			global_position += to.normalized() * minf(ENTER_SPEED * delta, to.length())
			rotation.y = atan2(-to.x, -to.z)
			model.set_moving(true)
	if _stun_fx:
		_stun_fx.rotation.y += delta * 4.0


func is_in_formation() -> bool:
	return not _entering


func get_bar_anchor() -> Vector3:
	return global_position + Vector3.UP * (model.get_height() + 0.25)


func get_chest() -> Vector3:
	return global_position + Vector3.UP * model.get_height() * 0.55


# --- signal handlers ---------------------------------------------------------------------

func _on_acted(ability: Ability, targets: Array[BattleUnit]) -> void:
	var target_view := director.view_for(targets[0]) if not targets.is_empty() else null
	if target_view and target_view != self:
		_face(target_view.global_position)
	match ability.delivery:
		CombatTypes.Delivery.MELEE:
			if target_view:
				model.play_attack(target_view.global_position, true)
		CombatTypes.Delivery.PROJECTILE:
			for t in targets:
				var tv := director.view_for(t)
				if tv:
					model.play_attack(tv.global_position, false)
					Vfx.projectile(get_parent(), model.get_hand_position(), tv.get_chest(), ability.fx_color, ability.impact_delay())
		CombatTypes.Delivery.INSTANT:
			model.play_cast_pose()
		CombatTypes.Delivery.SELF:
			model.play_cast_pose()
			Vfx.ring(get_parent(), global_position, ability.fx_color, 2.2, 0.45)


func _on_cast_started(ability: Ability, _duration: float) -> void:
	_clear_cast_ring()
	_cast_ring = LowPoly.part(self, LowPoly.torus(0.55, 0.72, 18, 3), Color(ability.fx_color, 0.75),
		Vector3(0, 0.05, 0), Vector3.ZERO, Vector3(1, 0.3, 1), 2.5)
	model.play_cast_pose()


func _on_cast_ended(_interrupted: bool) -> void:
	_clear_cast_ring()


func _on_damaged(amount: float, is_crit: bool, school: int, is_tick: bool) -> void:
	var color := Color("ffffff") if school == CombatTypes.School.PHYSICAL else Color("d6a8ff")
	if unit.team == CombatTypes.Team.HEROES:
		color = Color("ff6b6b")
	var text := str(roundi(amount))
	if is_crit:
		text += "!"
	Vfx.floating_text(get_parent(), get_chest() + Vector3.UP * 0.4, text, color, 62 if is_crit else (34 if is_tick else 46))
	if not is_tick:
		model.play_hit()


func _on_healed(amount: float, is_crit: bool, is_tick: bool) -> void:
	if amount < 1.0:
		return
	Vfx.floating_text(get_parent(), get_chest() + Vector3.UP * 0.4, "+%d%s" % [roundi(amount), "!" if is_crit else ""],
		Color("7dff8a"), 34 if is_tick else 46)
	if not is_tick:
		model.play_heal()
		Vfx.pillar(get_parent(), global_position, Color("9cf29a"))


func _on_absorbed(amount: float) -> void:
	Vfx.floating_text(get_parent(), get_chest() + Vector3.UP * 0.6, "Absorb %d" % roundi(amount), Color("ffe38a"), 30)


func _on_status_added(status: StatusEffect) -> void:
	if status is ShieldStatus:
		if _shield == null:
			_shield = LowPoly.part(self, LowPoly.sphere(0.85, 12, 8), Color(1.0, 0.92, 0.55, 0.16),
				Vector3.UP * 0.8, Vector3.ZERO, Vector3(1, 1.05, 1), 0.6)
	elif status.prevents_action():
		if _stun_fx == null:
			_stun_fx = Node3D.new()
			_stun_fx.position.y = model.get_height() + 0.15
			add_child(_stun_fx)
			for i in 3:
				var ang := TAU * i / 3.0
				LowPoly.part(_stun_fx, LowPoly.prism(Vector3(0.14, 0.14, 0.05)), status.color,
					Vector3(cos(ang) * 0.35, 0, sin(ang) * 0.35), Vector3.ZERO, Vector3.ONE, 2.0)
		Vfx.floating_text(get_parent(), get_bar_anchor(), status.display_name, status.color, 32)
	elif status is TauntStatus:
		Vfx.floating_text(get_parent(), get_bar_anchor(), "Taunted!", status.color, 30, 0.6)
	elif status is StatModifierStatus and not status.is_harmful:
		if _buff_ring:
			_buff_ring.queue_free()
		_buff_ring = LowPoly.part(self, LowPoly.torus(0.62, 0.7, 20, 3), Color(status.color, 0.6),
			Vector3(0, 0.08, 0), Vector3.ZERO, Vector3(1, 0.3, 1), 2.0)
		Vfx.floating_text(get_parent(), get_bar_anchor(), status.display_name, status.color, 32)


func _on_status_removed(status: StatusEffect) -> void:
	if status is ShieldStatus and _shield and not unit.has_status(status.id):
		_shield.queue_free()
		_shield = null
	elif status.prevents_action() and _stun_fx and not unit.is_stunned():
		_stun_fx.queue_free()
		_stun_fx = null
	elif status is StatModifierStatus and _buff_ring:
		_buff_ring.queue_free()
		_buff_ring = null


func _on_enraged() -> void:
	var t := create_tween()
	t.tween_property(model, "scale", Vector3.ONE * 1.18, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Vfx.ring(get_parent(), global_position, Color("ff2d2d"), 3.5, 0.6)
	Vfx.burst(get_parent(), get_chest(), Color("ff5a3d"), 30, 4.0, 0.1)


func _on_died() -> void:
	_clear_cast_ring()
	for fx in [_shield, _stun_fx, _buff_ring]:
		if fx:
			fx.queue_free()
	_shield = null
	_stun_fx = null
	_buff_ring = null
	model.play_death()
	if unit.team == CombatTypes.Team.MONSTERS:
		# Defeated enemies sink away; fallen heroes stay down until the fight ends.
		var t := create_tween()
		t.tween_interval(1.0)
		t.tween_property(self, "scale", Vector3(0.01, 0.01, 0.01), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		t.tween_callback(func() -> void: visible = false)


func _clear_cast_ring() -> void:
	if _cast_ring:
		_cast_ring.queue_free()
		_cast_ring = null


func _face(point: Vector3) -> void:
	var d := point - global_position
	d.y = 0.0
	if d.length_squared() > 0.001:
		rotation.y = atan2(-d.x, -d.z)
