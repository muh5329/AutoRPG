class_name AbilityIcon
extends PanelContainer
## Rounded tile showing an ability's glyph in its effect colour.

func setup(ability: Ability, size_px := 44.0, dimmed := false) -> AbilityIcon:
	custom_minimum_size = Vector2(size_px, size_px)
	mouse_filter = Control.MOUSE_FILTER_PASS
	tooltip_text = "%s\n%s" % [ability.display_name, ability.get_tooltip()]
	var bg := ability.fx_color.darkened(0.45) if not dimmed else Color("8c8475")
	add_theme_stylebox_override("panel", UiKit.style(bg, bg.darkened(0.3), 10, 2, 0, 3))
	var g := UiKit.icon(UiKit.ability_glyph(ability), ability.fx_color.lightened(0.2) if not dimmed else Color("d8d2c6"), size_px - 10)
	add_child(g)
	return self
