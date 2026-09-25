class_name PartyWindow
extends UiWindow
## Heroes: stats, equipment, skill points and ability loadouts.

var _selected: Hero
var _list: VBoxContainer
var _detail: VBoxContainer
var _refresh_queued := false


func _init() -> void:
	window_title = "Party"
	window_size = Vector2(1180, 760)


func _build(b: VBoxContainer) -> void:
	var cols := UiKit.hbox(16)
	cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	b.add_child(cols)
	_list = UiKit.vbox(8)
	_list.custom_minimum_size.x = 250
	cols.add_child(_list)
	_detail = UiKit.vbox(10)
	cols.add_child(UiKit.scroll(_detail, 600))
	_selected = GameState.party.members()[0]
	GameState.party.changed.connect(_queue_refresh)
	GameState.inventory.changed.connect(_queue_refresh)


func _exit_tree() -> void:
	GameState.party.changed.disconnect(_queue_refresh)
	GameState.inventory.changed.disconnect(_queue_refresh)


func _queue_refresh() -> void:
	if not _refresh_queued:
		_refresh_queued = true
		refresh.call_deferred()


func refresh() -> void:
	_refresh_queued = false
	UiKit.clear(_list)
	for hero in GameState.party.members():
		_list.add_child(_hero_button(hero))
	_list.add_child(UiKit.spacer(false))
	_list.add_child(UiKit.wrap(UiKit.label("Recruit more heroes at the Sleepy Griffin Inn. (%d/%d)" % [GameState.party.size(), Party.MAX_SIZE], 14, UiKit.INK_SOFT)))
	_build_detail()


func _hero_button(hero: Hero) -> Control:
	var selected := hero == _selected
	var card := UiKit.panel(Color("fff0c2") if selected else Color("fff8ea"), UiKit.GOLD_DARK if selected else UiKit.BORDER, 14, 3 if selected else 2, 8)
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			_selected = hero
			_queue_refresh())
	var row := UiKit.hbox(8)
	card.add_child(row)
	var p := Portrait.new().setup(Portraits.for_hero(hero), 56, hero.get_hero_class().color)
	p.set_dimmed(not hero.is_alive())
	row.add_child(p)
	var info := UiKit.vbox(2)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_child(UiKit.label(hero.display_name.split(" ")[0], 18, UiKit.INK, 650))
	info.add_child(UiKit.label("Lv %d %s" % [hero.level, hero.get_hero_class().display_name], 14, UiKit.INK_SOFT))
	var hp := UiKit.bar(UiKit.GREEN, 10)
	hp.set_value(hero.current_hp, hero.get_max_hp(), true)
	info.add_child(hp)
	row.add_child(info)
	if hero.skill_points > 0:
		var badge := UiKit.panel(UiKit.RED, Color.WHITE, 10, 2, 3)
		badge.add_child(UiKit.label("%d SP" % hero.skill_points, 13, Color.WHITE, 650))
		badge.tooltip_text = "Unspent skill points"
		row.add_child(badge)
	return card


func _build_detail() -> void:
	UiKit.clear(_detail)
	var h := _selected
	var c := h.get_hero_class()
	# Header
	var header := UiKit.hbox(16)
	header.add_child(Portrait.new().setup(Portraits.for_hero(h), 120, c.color))
	var id := UiKit.vbox(4)
	id.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	id.add_child(UiKit.title(h.display_name, 30))
	id.add_child(UiKit.label(h.definition.title, 17, UiKit.INK_SOFT))
	var role := UiKit.hbox(6)
	role.add_child(UiKit.icon(UiKit.role_glyph(c.role), c.color, 24))
	role.add_child(UiKit.label("%s · %s · Level %d" % [c.display_name, CombatTypes.role_name(c.role), h.level], 18, UiKit.INK, 600))
	id.add_child(role)
	var xp_row := UiKit.hbox(8)
	xp_row.add_child(UiKit.label("XP", 14, UiKit.INK_SOFT, 650))
	var xp := UiKit.bar(Color("8e6bd6"), 14, 280, true)
	xp.set_value(h.xp, h.xp_to_next_level(), true)
	xp_row.add_child(xp)
	id.add_child(xp_row)
	id.add_child(UiKit.wrap(UiKit.label(h.definition.bio, 15, UiKit.INK_SOFT)))
	header.add_child(id)
	_detail.add_child(header)
	_detail.add_child(HSeparator.new())
	# Stats + equipment side by side
	var mid := UiKit.hbox(16)
	mid.add_child(_stats_panel(h))
	mid.add_child(_equipment_panel(h))
	_detail.add_child(mid)
	_detail.add_child(HSeparator.new())
	var ab_head := UiKit.hbox(8)
	ab_head.add_child(UiKit.title("Abilities", 24))
	ab_head.add_child(UiKit.spacer())
	var sp := UiKit.panel(UiKit.NAVY if h.skill_points == 0 else UiKit.RED, UiKit.GOLD, 10, 2, 6)
	sp.add_child(UiKit.label("Skill Points: %d" % h.skill_points, 16, Color.WHITE, 650))
	ab_head.add_child(sp)
	_detail.add_child(ab_head)
	_detail.add_child(UiKit.wrap(UiKit.label("Higher abilities are preferred when several are useful. Disabled abilities are never used. The basic attack is always available.", 14, UiKit.INK_SOFT)))
	_detail.add_child(LoadoutEditor.new().setup(h, false))


func _stats_panel(h: Hero) -> Control:
	var p := UiKit.panel(Color("fff8ea"), UiKit.BORDER, 14, 2, 12)
	p.custom_minimum_size.x = 300
	var v := UiKit.vbox(6)
	p.add_child(v)
	v.add_child(UiKit.label("Stats", 20, UiKit.INK, 650))
	var s := h.get_stats()
	var hp := UiKit.bar(UiKit.GREEN, 18, 0, true)
	hp.set_value(h.current_hp, s.max_hp, true)
	v.add_child(hp)
	for pair in [["Power", "%d" % roundi(s.power)], ["Armor", "%d  (-%d%% dmg)" % [roundi(s.armor), roundi((1.0 - s.mitigation()) * 100)]],
			["Haste", "%d%%" % roundi(s.haste * 100)], ["Crit", "%d%%" % roundi(s.crit * 100)]]:
		var r := UiKit.hbox()
		r.add_child(UiKit.label(pair[0], 17, UiKit.INK_SOFT))
		r.add_child(UiKit.spacer())
		r.add_child(UiKit.label(pair[1], 17, UiKit.INK, 650))
		v.add_child(r)
	return p


func _equipment_panel(h: Hero) -> Control:
	var p := UiKit.panel(Color("fff8ea"), UiKit.BORDER, 14, 2, 12)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := UiKit.vbox(8)
	p.add_child(v)
	v.add_child(UiKit.label("Equipment", 20, UiKit.INK, 650))
	for slot in [Equipment.Slot.WEAPON, Equipment.Slot.ARMOR]:
		var row := UiKit.hbox(10)
		var item := h.get_equipped(slot)
		if item:
			row.add_child(ItemSlot.new().setup(item, 1, 56))
		else:
			var empty := UiKit.panel(Color("eee7d8"), UiKit.BORDER, 12, 2, 6)
			empty.custom_minimum_size = Vector2(56, 56)
			row.add_child(empty)
		var info := UiKit.vbox(2)
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_child(UiKit.label(Equipment.SLOT_NAMES[slot], 13, UiKit.INK_SOFT, 600))
		if item:
			info.add_child(UiKit.label(item.display_name, 17, item.get_rarity_color().darkened(0.2), 650))
			info.add_child(UiKit.label(item.stats.describe_bonus(), 14, UiKit.INK_SOFT))
		else:
			info.add_child(UiKit.label("Empty", 17, UiKit.INK_SOFT))
		row.add_child(info)
		if item:
			var un := UiKit.button("Unequip", func() -> void: _unequip(h, slot), "SecondaryButton")
			un.add_theme_font_size_override("font_size", 14)
			row.add_child(un)
		v.add_child(row)
		# Equippable alternatives from the bag
		var options := UiKit.hbox(6)
		for e in GameState.inventory.entries_of(Equipment):
			var eq := e.item as Equipment
			if eq.get_slot() == slot and eq.can_be_equipped_by(h):
				var b := UiKit.button("Equip %s" % eq.display_name, func() -> void: _equip(h, eq), "SecondaryButton")
				b.add_theme_font_size_override("font_size", 14)
				b.tooltip_text = eq.get_tooltip()
				options.add_child(b)
		if options.get_child_count() > 0:
			v.add_child(options)
	return p


func _unequip(h: Hero, slot: Equipment.Slot) -> void:
	var item := h.unequip(slot)
	if item:
		GameState.inventory.add(item)


func _equip(h: Hero, item: Equipment) -> void:
	GameState.inventory.remove(item)
	var previous := h.equip(item)
	if previous:
		GameState.inventory.add(previous)
	EventBus.toast.emit("%s equipped %s" % [h.display_name.split(" ")[0], item.display_name], &"info")
