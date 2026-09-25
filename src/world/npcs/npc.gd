class_name NPC
extends Character
## Abstract non-player character: has a look, a floating name and can be talked to.

const NAMEPLATE_COLOR := Color("fff6de")

@export var appearance: Appearance
@export var title: String

var nameplate: Label3D
var _bubble: Label3D
var _home_facing: float


func _ready() -> void:
	super()
	_home_facing = rotation.y
	nameplate = _make_label(display_name if title == "" else "%s\n<%s>" % [display_name, title], 42, NAMEPLATE_COLOR)
	nameplate.position.y = model.get_height() + 0.35
	add_child(nameplate)


func _get_appearance() -> Appearance:
	return appearance


func is_interactable() -> bool:
	return true


func get_interaction_verb() -> String:
	return "Talk to"


func interact(player: PlayerAvatar) -> void:
	face_point(player.global_position)
	player.face_point(global_position)
	_on_interact(player)


## Subclasses decide what talking does.
func _on_interact(_player: PlayerAvatar) -> void:
	push_error("NPC._on_interact is abstract")


func turn_back_home() -> void:
	var t := create_tween()
	t.tween_property(self, "rotation:y", _home_facing, 0.4)
	_facing = _home_facing


## Speech bubble above the head for a few seconds (ambient barks).
func say(text: String, duration := 3.0) -> void:
	if _bubble:
		_bubble.queue_free()
	_bubble = _make_label(text, 40, Color("3b2f2a"))
	_bubble.outline_modulate = Color("fffaf0")
	_bubble.outline_size = 14
	_bubble.position.y = model.get_height() + 0.95
	_bubble.width = 620
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_bubble)
	var bubble := _bubble
	get_tree().create_timer(duration).timeout.connect(func() -> void:
		if is_instance_valid(bubble):
			bubble.queue_free())


static func _make_label(text: String, size: int, color: Color) -> Label3D:
	var l := Label3D.new()
	l.text = text
	l.font_size = size
	l.outline_size = 10
	l.modulate = color
	l.outline_modulate = Color(0.12, 0.1, 0.18, 0.85)
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.pixel_size = 0.0004
	l.fixed_size = true
	l.render_priority = 5
	l.outline_render_priority = 4
	return l
