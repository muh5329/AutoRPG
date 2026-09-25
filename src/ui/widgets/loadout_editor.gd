class_name LoadoutEditor
extends BoxContainer
## Edits a hero's ability loadout: unlock with skill points, enable/disable, reorder priority.
## `compact` = horizontal chips (pre-battle); otherwise detailed rows (party screen).

var hero: Hero
var compact := false


func setup(hero_: Hero, compact_: bool) -> LoadoutEditor:
	hero = hero_
	compact = compact_
	vertical = not compact
	add_theme_constant_override("separation", 6 if compact else 8)
	hero.changed.connect(_queue_rebuild)
	_rebuild()
	return self


func _exit_tree() -> void:
	if hero and hero.changed.is_connected(_queue_rebuild):
		hero.changed.disconnect(_queue_rebuild)


var _rebuild_queued := false


## Rebuilding is deferred: the pressed button must not be freed inside its own signal.
func _queue_rebuild() -> void:
	if not _rebuild_queued:
		_rebuild_queued = true
		_rebuild.call_deferred()


func _rebuild() -> void:
	_rebuild_queued = false
	UiKit.clear(self)
	var slots := hero.loadout.slots()
	for i in slots.size():
		add_child(_chip(slots[i], i, slots.size()) if compact else _row(slots[i], i, slots.size()))


func _chip(slot: AbilityLoadout.Slot, index: int, count: int) -> Control:
	var a := slot.ability
	var unlocked := hero.is_unlocked(a)
	var active := unlocked and slot.enabled
	var chip := UiKit.panel(Color("fff8ea") if active else Color("e7e0d2"), a.fx_color.darkened(0.2) if active else Color("b3ab9c"), 10, 2, 5)
	chip.tooltip_text = "%s\n%s%s" % [a.display_name, a.get_tooltip(), "" if unlocked else "\n(Locked — unlock in the Party screen)"]
	var row := UiKit.hbox(4)
	chip.add_child(row)
	if unlocked:
		row.add_child(_arrow(&"arrow_up", func() -> void: hero.loadout.move(a, -1), index > 0, true))
	row.add_child(AbilityIcon.new().setup(a, 34, not active))
	var name_label := UiKit.label(a.display_name, 15, UiKit.INK if active else UiKit.INK_SOFT, 600)
	name_label.custom_minimum_size.x = 92
	name_label.clip_text = true
	row.add_child(name_label)
	if unlocked:
		row.add_child(_toggle(a, slot.enabled))
		row.add_child(_arrow(&"arrow_down", func() -> void: hero.loadout.move(a, 1), index < count - 1, true))
	else:
		row.add_child(UiKit.icon(&"lock", UiKit.INK_SOFT, 20))
	return chip


func _row(slot: AbilityLoadout.Slot, index: int, count: int) -> Control:
	var a := slot.ability
	var unlocked := hero.is_unlocked(a)
	var active := unlocked and slot.enabled
	var card := UiKit.panel(Color("fff8ea") if active else Color("eee7d8"), a.fx_color.darkened(0.25) if active else UiKit.BORDER, 12, 2, 8)
	var row := UiKit.hbox(10)
	card.add_child(row)
	var prio := UiKit.title("%d" % (index + 1), 22, UiKit.GOLD_DARK if active else UiKit.INK_SOFT)
	prio.custom_minimum_size.x = 18
	row.add_child(prio)
	row.add_child(AbilityIcon.new().setup(a, 48, not active))
	var text := UiKit.vbox(2)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var head := UiKit.hbox(6)
	head.add_child(UiKit.label(a.display_name, 19, UiKit.INK, 650))
	for tag_name in a.get_tag_names():
		var tag := UiKit.panel(a.fx_color.darkened(0.35), Color(0, 0, 0, 0), 8, 0, 3)
		tag.add_child(UiKit.label(tag_name, 12, Color.WHITE, 600))
		head.add_child(tag)
	text.add_child(head)
	text.add_child(UiKit.wrap(UiKit.label(a.get_tooltip(), 14, UiKit.INK_SOFT)))
	row.add_child(text)
	if unlocked:
		var controls := UiKit.hbox(4)
		controls.add_child(_toggle(a, slot.enabled))
		controls.add_child(_arrow(&"arrow_up", func() -> void: hero.loadout.move(a, -1), index > 0))
		controls.add_child(_arrow(&"arrow_down", func() -> void: hero.loadout.move(a, 1), index < count - 1))
		row.add_child(controls)
	elif hero.can_unlock(a):
		row.add_child(UiKit.button("Unlock (1 SP)", func() -> void: hero.unlock(a)))
	else:
		var lock := UiKit.hbox(4)
		lock.add_child(UiKit.icon(&"lock", UiKit.INK_SOFT, 22))
		var need := "Lv %d" % a.unlock_level if hero.level < a.unlock_level else "Need SP"
		lock.add_child(UiKit.label(need, 15, UiKit.INK_SOFT, 600))
		row.add_child(lock)
	return card


func _toggle(a: Ability, enabled: bool) -> Button:
	var b := UiKit.button("", func() -> void: hero.loadout.set_enabled(a, not enabled), "SecondaryButton" if not enabled else "")
	b.custom_minimum_size = Vector2(34, 34)
	b.tooltip_text = "Enabled — click to disable" if enabled else "Disabled — click to enable"
	var g := UiKit.icon(&"check" if enabled else &"cross", UiKit.INK if enabled else UiKit.INK_SOFT, 20)
	g.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	g.position -= Vector2(10, 10)
	b.add_child(g)
	b.add_theme_stylebox_override("normal", _small_style(enabled))
	b.add_theme_stylebox_override("hover", _small_style(enabled, 0.1))
	b.add_theme_stylebox_override("pressed", _small_style(enabled, -0.05))
	return b


func _arrow(glyph: StringName, action: Callable, enabled: bool, tiny := false) -> Button:
	var b := UiKit.button("", action, "SecondaryButton")
	var sz := 26.0 if tiny else 34.0
	b.custom_minimum_size = Vector2(sz, sz)
	b.disabled = not enabled
	b.tooltip_text = "Raise priority" if glyph == &"arrow_up" else "Lower priority"
	var g := UiKit.icon(glyph, UiKit.INK if enabled else Color("b3ab9c"), sz * 0.55)
	g.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	g.position -= Vector2(sz * 0.275, sz * 0.275)
	b.add_child(g)
	for state in ["normal", "hover", "pressed", "disabled"]:
		var s := UiKit.style(Color("fff8ea") if state != "hover" else Color("fff0c2"), UiKit.BORDER, 8, 2, 0, 2)
		b.add_theme_stylebox_override(state, s)
	return b


static func _small_style(enabled: bool, lighten := 0.0) -> StyleBoxFlat:
	var bg := (UiKit.GREEN if enabled else Color("e7e0d2")).lightened(lighten)
	return UiKit.style(bg, bg.darkened(0.3), 8, 2, 0, 2)
