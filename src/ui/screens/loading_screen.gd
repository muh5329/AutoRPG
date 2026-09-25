class_name LoadingScreen
extends Control
## Full-screen transition card: destination title, rotating tip, progress bar, spinner.

const TIPS := [
	"Tanks taunt automatically — keep your Warrior's Taunting Roar enabled.",
	"Abilities higher in a hero's list are preferred when several are useful.",
	"Heroes drink potions on their own when they drop below 30% health.",
	"Interrupt enemy casters! Hunters, Mages and Warriors all carry an interrupt.",
	"Rest at the Sleepy Griffin Inn to fully heal your party.",
	"Spend skill points in the Party screen (P) to unlock new abilities.",
	"Bosses can't be stunned, and some of their casts can't be interrupted.",
	"Press Tab in battle to speed things up.",
]

var _title: Label
var _subtitle: Label
var _tip: Label
var _bar: Bar
var _spinner: IconGlyph


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	theme = UiKit.theme()
	var bg := TextureRect.new()
	var grad := Gradient.new()
	grad.set_color(0, Color("2b2350"))
	grad.set_color(1, Color("0f1a2e"))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0.3, 1)
	bg.texture = gt
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var col := UiKit.vbox(14)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.custom_minimum_size.x = 820
	center.add_child(col)
	_spinner = UiKit.icon(&"gem", Color("7fd8f2"), 72)
	_spinner.pivot_offset = Vector2(36, 36)
	var sp_center := CenterContainer.new()
	sp_center.add_child(_spinner)
	col.add_child(sp_center)
	_title = UiKit.outlined(UiKit.title("", 54, Color("fff3d1")), Color(0.08, 0.05, 0.15), 10)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_title)
	_subtitle = UiKit.label("", 20, Color(1, 1, 1, 0.8))
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_subtitle)
	_bar = UiKit.bar(UiKit.GOLD, 20, 820)
	_bar.set_ratio(0.0, true)
	col.add_child(_bar)
	_tip = UiKit.wrap(UiKit.label("", 18, Color("ffe6a3")))
	_tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_tip)
	visible = false


func _process(delta: float) -> void:
	if visible:
		_spinner.rotation += delta * 2.2


func show_card(title: String, subtitle: String) -> void:
	_title.text = title
	_subtitle.text = subtitle
	_tip.text = "Tip: " + TIPS[randi() % TIPS.size()]
	_bar.set_ratio(0.0, true)
	visible = true
	modulate.a = 0.0
	var t := create_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.25)
	await t.finished


func set_progress(r: float) -> void:
	_bar.set_ratio(r)


func hide_card() -> void:
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.35)
	await t.finished
	visible = false
