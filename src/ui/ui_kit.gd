class_name UiKit
extends RefCounted
## Palette, theme and small widget constructors shared by every screen.
## The look: warm parchment panels, gold buttons, navy headers (AFK Journey inspired).

const PARCHMENT := Color("fbf4e6")
const PARCHMENT_DARK := Color("f1e4c9")
const BORDER := Color("d9b77a")
const INK := Color("3b2f2a")
const INK_SOFT := Color("7a6a5c")
const GOLD := Color("f6c65b")
const GOLD_DARK := Color("c98a1e")
const NAVY := Color("2e3a66")
const NAVY_LIGHT := Color("45558f")
const TEAL := Color("3fb1a8")
const RED := Color("e0584a")
const GREEN := Color("5cc46a")
const CREAM_TEXT := Color("fff6de")
const DIM := Color(0.06, 0.05, 0.12, 0.55)

const FONT_PATH := "res://assets/fonts/Fredoka.ttf"

static var _theme: Theme
static var _fonts: Dictionary = {}


static func font(weight := 500) -> Font:
	if _fonts.has(weight):
		return _fonts[weight]
	var base: Font = load(FONT_PATH) if ResourceLoader.exists(FONT_PATH) else ThemeDB.fallback_font
	var fv := FontVariation.new()
	fv.base_font = base
	var ts := TextServerManager.get_primary_interface()
	fv.variation_opentype = { ts.name_to_tag("wght"): weight }
	_fonts[weight] = fv
	return fv


static func style(bg: Color, border := Color(0, 0, 0, 0), radius := 14, border_w := 0, shadow := 0,
		margin := 12) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_w)
	s.set_corner_radius_all(radius)
	s.set_content_margin_all(margin)
	s.anti_aliasing = true
	if shadow > 0:
		s.shadow_color = Color(0.05, 0.03, 0.1, 0.35)
		s.shadow_size = shadow
		s.shadow_offset = Vector2(0, shadow * 0.4)
	return s


static func theme() -> Theme:
	if _theme:
		return _theme
	var t := Theme.new()
	t.default_font = font(500)
	t.default_font_size = 19
	# Labels
	t.set_color("font_color", "Label", INK)
	# Panels
	t.set_stylebox("panel", "PanelContainer", style(PARCHMENT, BORDER, 18, 3, 10, 18))
	t.set_stylebox("panel", "Panel", style(PARCHMENT, BORDER, 18, 3, 10))
	# Buttons (gold primary)
	_button_styles(t, "Button", GOLD, GOLD_DARK, INK)
	t.set_font_size("font_size", "Button", 19)
	# Secondary / navy / danger variations
	t.set_type_variation("SecondaryButton", "Button")
	_button_styles(t, "SecondaryButton", Color("fff8ea"), BORDER, INK)
	t.set_type_variation("NavyButton", "Button")
	_button_styles(t, "NavyButton", NAVY_LIGHT, NAVY, CREAM_TEXT)
	t.set_type_variation("DangerButton", "Button")
	_button_styles(t, "DangerButton", Color("f08a7e"), Color("b8483c"), INK)
	t.set_type_variation("TabButton", "Button")
	_button_styles(t, "TabButton", PARCHMENT_DARK, BORDER, INK_SOFT)
	t.set_stylebox("pressed", "TabButton", style(GOLD, GOLD_DARK, 12, 2, 0, 8))
	# Scroll & separators
	t.set_stylebox("panel", "ScrollContainer", StyleBoxEmpty.new())
	t.set_stylebox("separator", "HSeparator", _line(BORDER))
	t.set_constant("separation", "HSeparator", 10)
	t.set_constant("separation", "VBoxContainer", 8)
	t.set_constant("separation", "HBoxContainer", 8)
	var grabber := style(BORDER, Color(0, 0, 0, 0), 6, 0, 0, 0)
	t.set_stylebox("grabber", "VScrollBar", grabber)
	t.set_stylebox("grabber_highlight", "VScrollBar", style(GOLD_DARK, Color(0, 0, 0, 0), 6, 0, 0, 0))
	t.set_stylebox("grabber_pressed", "VScrollBar", style(GOLD_DARK, Color(0, 0, 0, 0), 6, 0, 0, 0))
	t.set_stylebox("scroll", "VScrollBar", style(PARCHMENT_DARK, Color(0, 0, 0, 0), 6, 0, 0, 4))
	# Tooltips
	t.set_stylebox("panel", "TooltipPanel", style(NAVY, GOLD, 10, 2, 6, 10))
	t.set_color("font_color", "TooltipLabel", CREAM_TEXT)
	t.set_font_size("font_size", "TooltipLabel", 17)
	_theme = t
	return t


static func _button_styles(t: Theme, type: String, bg: Color, edge: Color, text: Color) -> void:
	var normal := style(bg, edge, 12, 2, 0, 10)
	normal.border_width_bottom = 5
	normal.content_margin_left = 18
	normal.content_margin_right = 18
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = bg.lightened(0.12)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = bg.darkened(0.08)
	pressed.border_width_bottom = 2
	pressed.content_margin_top = 13
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color("d8d2c6")
	disabled.border_color = Color("b3ab9c")
	t.set_stylebox("normal", type, normal)
	t.set_stylebox("hover", type, hover)
	t.set_stylebox("pressed", type, pressed)
	t.set_stylebox("disabled", type, disabled)
	t.set_stylebox("focus", type, StyleBoxEmpty.new())
	t.set_color("font_color", type, text)
	t.set_color("font_hover_color", type, text)
	t.set_color("font_pressed_color", type, text)
	t.set_color("font_focus_color", type, text)
	t.set_color("font_disabled_color", type, Color("8c8475"))


static func _line(color: Color) -> StyleBoxLine:
	var s := StyleBoxLine.new()
	s.color = color
	s.thickness = 2
	return s


# --- widget constructors -------------------------------------------------------------------

static func label(text: String, size := 19, color := INK, weight := 500) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if weight != 500:
		l.add_theme_font_override("font", font(weight))
	return l


static func title(text: String, size := 30, color := INK) -> Label:
	return label(text, size, color, 650)


static func outlined(l: Label, outline := Color(0.12, 0.08, 0.2), width := 8) -> Label:
	l.add_theme_color_override("font_outline_color", outline)
	l.add_theme_constant_override("outline_size", width)
	return l


static func wrap(l: Label) -> Label:
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = maxf(l.custom_minimum_size.x, 40.0)
	return l


static func button(text: String, on_pressed: Callable, variation := "", min_width := 0.0) -> Button:
	var b := Button.new()
	b.text = text
	if variation != "":
		b.theme_type_variation = variation
	if on_pressed.is_valid():
		b.pressed.connect(on_pressed)
	b.custom_minimum_size.x = min_width
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return b


static func vbox(sep := 8) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", sep)
	return v


static func hbox(sep := 8) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", sep)
	return h


static func panel(bg := PARCHMENT, border := BORDER, radius := 14, border_w := 2, margin := 12) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", style(bg, border, radius, border_w, 0, margin))
	return p


static func spacer(horizontal := true) -> Control:
	var c := Control.new()
	if horizontal:
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	else:
		c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return c


static func bar(fill: Color, height := 14.0, width := 0.0, show_text := false) -> Bar:
	var b := Bar.new()
	b.fill_color = fill
	b.custom_minimum_size = Vector2(width, height)
	b.show_text = show_text
	return b


static func icon(glyph: StringName, color := INK, size := 28.0) -> IconGlyph:
	var g := IconGlyph.new()
	g.glyph = glyph
	g.color = color
	g.custom_minimum_size = Vector2(size, size)
	return g


static func scroll(content: Control, min_height := 200.0) -> ScrollContainer:
	var s := ScrollContainer.new()
	s.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	s.custom_minimum_size.y = min_height
	s.size_flags_vertical = Control.SIZE_EXPAND_FILL
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.add_child(content)
	return s


static func clear(node: Node) -> void:
	for c in node.get_children():
		node.remove_child(c)
		c.queue_free()


static func item_glyph(item: Item) -> StringName:
	match item.icon:
		Item.Icon.POTION: return &"potion"
		Item.Icon.SWORD: return &"sword"
		Item.Icon.MACE: return &"mace"
		Item.Icon.STAFF: return &"staff"
		Item.Icon.BOW: return &"bow"
		Item.Icon.WAND: return &"wand"
		Item.Icon.PLATE, Item.Icon.LEATHER, Item.Icon.ROBE: return &"armor"
		_: return &"gem"


static func ability_glyph(ability: Ability) -> StringName:
	if ability.has_tag(CombatTypes.Tag.HEAL): return &"heart"
	if ability.has_tag(CombatTypes.Tag.INTERRUPT): return &"bolt"
	if ability.has_tag(CombatTypes.Tag.TANK): return &"roar"
	if ability.has_tag(CombatTypes.Tag.DEFENSIVE): return &"shield"
	if ability.has_tag(CombatTypes.Tag.CONTROL): return &"snow"
	if ability.has_tag(CombatTypes.Tag.DOT): return &"drop"
	if ability.has_tag(CombatTypes.Tag.AOE): return &"star"
	if ability.has_tag(CombatTypes.Tag.BUFF): return &"up"
	return &"flame" if ability.is_ranged() else &"sword"


static func role_glyph(role: CombatTypes.Role) -> StringName:
	match role:
		CombatTypes.Role.TANK: return &"shield"
		CombatTypes.Role.HEALER: return &"heart"
		CombatTypes.Role.RANGED_DPS: return &"bow"
		_: return &"sword"
