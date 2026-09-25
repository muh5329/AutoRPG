class_name ShopWindow
extends UiWindow
## Buy from a vendor's stock or sell from the bag.

enum Tab { BUY, SELL }

var vendor: Vendor
var _tab := Tab.BUY
var _rows: VBoxContainer
var _gold: Label
var _buy_tab: Button
var _sell_tab: Button
var _refresh_queued := false


func _init(vendor_: Vendor = null) -> void:
	vendor = vendor_
	window_title = vendor.shop_name if vendor else "Shop"
	window_size = Vector2(900, 660)


func _build(b: VBoxContainer) -> void:
	var top := UiKit.hbox(10)
	_buy_tab = UiKit.button("Buy", func() -> void: _switch(Tab.BUY), "TabButton", 120)
	_sell_tab = UiKit.button("Sell", func() -> void: _switch(Tab.SELL), "TabButton", 120)
	for t in [_buy_tab, _sell_tab]:
		t.toggle_mode = true
	top.add_child(_buy_tab)
	top.add_child(_sell_tab)
	top.add_child(UiKit.spacer())
	top.add_child(UiKit.icon(&"coin", Color.WHITE, 30))
	_gold = UiKit.label("", 22, UiKit.INK, 650)
	top.add_child(_gold)
	b.add_child(top)
	_rows = UiKit.vbox(8)
	b.add_child(UiKit.scroll(_rows, 480))
	GameState.inventory.changed.connect(_queue_refresh)
	GameState.wallet.changed.connect(_queue_refresh.unbind(1))


func _exit_tree() -> void:
	GameState.inventory.changed.disconnect(_queue_refresh)
	for c in GameState.wallet.changed.get_connections():
		if c.callable.get_object() == self:
			GameState.wallet.changed.disconnect(c.callable)


func _switch(tab: Tab) -> void:
	_tab = tab
	_queue_refresh()


func _queue_refresh() -> void:
	if not _refresh_queued:
		_refresh_queued = true
		refresh.call_deferred()


func refresh() -> void:
	_refresh_queued = false
	_buy_tab.button_pressed = _tab == Tab.BUY
	_sell_tab.button_pressed = _tab == Tab.SELL
	_gold.text = "%d" % GameState.wallet.gold
	UiKit.clear(_rows)
	if _tab == Tab.BUY:
		for item in vendor.get_stock():
			_rows.add_child(_row(item, item.price, "Buy", GameState.wallet.can_afford(item.price), func() -> void: _buy(item), GameState.inventory.count_of(item)))
	else:
		var entries := GameState.inventory.entries()
		if entries.is_empty():
			_rows.add_child(UiKit.label("Nothing to sell.", 18, UiKit.INK_SOFT))
		for e in entries:
			var it := e.item
			_rows.add_child(_row(it, it.get_sell_price(), "Sell", true, func() -> void: GameState.sell(it), e.quantity))


func _row(item: Item, price: int, verb: String, enabled: bool, action: Callable, owned: int) -> Control:
	var card := UiKit.panel(Color("fff8ea"), UiKit.BORDER, 14, 2, 10)
	var row := UiKit.hbox(12)
	card.add_child(row)
	row.add_child(ItemSlot.new().setup(item, 1, 64))
	var info := UiKit.vbox(2)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_child(UiKit.label(item.display_name, 20, item.get_rarity_color().darkened(0.2), 650))
	var detail := item.get_category()
	if item is Equipment:
		detail += "  ·  " + (item as Equipment).stats.describe_bonus()
	elif item is Potion:
		detail += "  ·  Restores %d%% HP" % roundi((item as Potion).heal_percent * 100)
	info.add_child(UiKit.label(detail, 15, UiKit.INK_SOFT))
	if owned > 0:
		info.add_child(UiKit.label("Owned: %d" % owned, 13, UiKit.TEAL, 600))
	row.add_child(info)
	var price_box := UiKit.hbox(4)
	price_box.add_child(UiKit.icon(&"coin", Color.WHITE, 22))
	price_box.add_child(UiKit.label("%d" % price, 20, UiKit.INK if enabled else UiKit.RED, 650))
	row.add_child(price_box)
	var b := UiKit.button(verb, action, "" if verb == "Buy" else "SecondaryButton", 100)
	b.disabled = not enabled
	row.add_child(b)
	return card


func _buy(item: Item) -> void:
	if GameState.buy(item):
		EventBus.toast.emit("Bought %s" % item.display_name, &"reward")
