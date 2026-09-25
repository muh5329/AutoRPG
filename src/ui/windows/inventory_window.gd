class_name InventoryWindow
extends UiWindow
## The party bag: use potions and equip gear.

var _grid: GridContainer
var _detail: VBoxContainer
var _selected: Item
var _refresh_queued := false


func _init() -> void:
	window_title = "Bag"
	window_size = Vector2(1000, 640)


func _build(b: VBoxContainer) -> void:
	var top := UiKit.hbox(8)
	top.add_child(UiKit.icon(&"coin", Color.WHITE, 30))
	top.add_child(UiKit.label("%d Gold" % GameState.wallet.gold, 22, UiKit.INK, 650))
	b.add_child(top)
	var cols := UiKit.hbox(16)
	cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	b.add_child(cols)
	_grid = GridContainer.new()
	_grid.columns = 6
	_grid.add_theme_constant_override("h_separation", 8)
	_grid.add_theme_constant_override("v_separation", 8)
	var grid_scroll := UiKit.scroll(_grid, 480)
	grid_scroll.custom_minimum_size.x = 520
	cols.add_child(grid_scroll)
	var detail_panel := UiKit.panel(Color("fff8ea"), UiKit.BORDER, 14, 2, 14)
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail = UiKit.vbox(8)
	detail_panel.add_child(_detail)
	cols.add_child(detail_panel)
	GameState.inventory.changed.connect(_queue_refresh)
	GameState.party.changed.connect(_queue_refresh)


func _exit_tree() -> void:
	GameState.inventory.changed.disconnect(_queue_refresh)
	GameState.party.changed.disconnect(_queue_refresh)


func _queue_refresh() -> void:
	if not _refresh_queued:
		_refresh_queued = true
		refresh.call_deferred()


func refresh() -> void:
	_refresh_queued = false
	UiKit.clear(_grid)
	var entries := GameState.inventory.entries()
	if _selected and GameState.inventory.count_of(_selected) == 0:
		_selected = null
	if _selected == null and not entries.is_empty():
		_selected = entries[0].item
	for e in entries:
		var slot := ItemSlot.new().setup(e.item, e.quantity, 78)
		slot.selected = e.item == _selected
		var it := e.item
		slot.pressed.connect(func() -> void:
			_selected = it
			_queue_refresh())
		_grid.add_child(slot)
	if entries.is_empty():
		_grid.add_child(UiKit.label("Your bag is empty.", 18, UiKit.INK_SOFT))
	_build_detail()


func _build_detail() -> void:
	UiKit.clear(_detail)
	if _selected == null:
		_detail.add_child(UiKit.wrap(UiKit.label("Select an item to see what it does.", 18, UiKit.INK_SOFT)))
		return
	var it := _selected
	var head := UiKit.hbox(10)
	head.add_child(ItemSlot.new().setup(it, 1, 64))
	var names := UiKit.vbox(2)
	names.add_child(UiKit.label(it.display_name, 22, it.get_rarity_color().darkened(0.2), 650))
	names.add_child(UiKit.label("%s · %s" % [it.get_category(), Item.Rarity.keys()[it.rarity].capitalize()], 15, UiKit.INK_SOFT))
	head.add_child(names)
	_detail.add_child(head)
	_detail.add_child(UiKit.wrap(UiKit.label(it.get_tooltip(), 16)))
	_detail.add_child(UiKit.label("Sells for %d gold" % it.get_sell_price(), 14, UiKit.INK_SOFT))
	_detail.add_child(HSeparator.new())
	if it is Consumable:
		_detail.add_child(UiKit.label("Use on:", 17, UiKit.INK, 650))
		for hero in GameState.party.members():
			var b := UiKit.button("%s  (%d/%d HP)" % [hero.display_name, roundi(hero.current_hp), roundi(hero.get_max_hp())],
				func() -> void: _use(it as Consumable, hero), "SecondaryButton")
			b.disabled = not (it as Consumable).can_use_on(hero)
			_detail.add_child(b)
	elif it is Equipment:
		_detail.add_child(UiKit.label("Equip on:", 17, UiKit.INK, 650))
		for hero in GameState.party.members():
			var eq := it as Equipment
			var ok := eq.can_be_equipped_by(hero)
			var b := UiKit.button(hero.display_name if ok else "%s — %s" % [hero.display_name, eq.get_restriction_text(hero)],
				func() -> void: _equip(eq, hero), "SecondaryButton")
			b.disabled = not ok
			_detail.add_child(b)


func _use(item: Consumable, hero: Hero) -> void:
	if item.use_on(hero):
		GameState.inventory.remove(item)
		EventBus.toast.emit("%s used on %s" % [item.display_name, hero.display_name.split(" ")[0]], &"info")


func _equip(item: Equipment, hero: Hero) -> void:
	GameState.inventory.remove(item)
	var previous := hero.equip(item)
	if previous:
		GameState.inventory.add(previous)
	EventBus.toast.emit("%s equipped %s" % [hero.display_name.split(" ")[0], item.display_name], &"info")
