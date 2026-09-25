class_name BattleResultWindow
extends UiWindow
## Victory / defeat summary with rewards and level-ups.

var victory: bool
var definition: EncounterDefinition
var report: RewardReport
var on_continue: Callable


func _init(victory_ := true, definition_: EncounterDefinition = null, report_: RewardReport = null, on_continue_ := Callable()) -> void:
	victory = victory_
	definition = definition_
	report = report_
	on_continue = on_continue_
	pauses_exploration = false
	closable = false
	window_title = "Victory!" if victory else "Defeat"
	window_size = Vector2(720, 0)


func _build(b: VBoxContainer) -> void:
	var banner := UiKit.title("%s %s" % [definition.display_name, "cleared!" if victory else "overwhelmed your party..."], 26, UiKit.GOLD_DARK if victory else UiKit.RED)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.add_child(banner)
	if victory and report:
		var line := UiKit.hbox(14)
		line.alignment = BoxContainer.ALIGNMENT_CENTER
		line.add_child(UiKit.icon(&"star", Color("b28dff"), 30))
		line.add_child(UiKit.label("+%d XP" % report.xp, 24, UiKit.INK, 650))
		line.add_child(UiKit.icon(&"coin", Color.WHITE, 30))
		line.add_child(UiKit.label("+%d Gold" % report.gold, 24, UiKit.INK, 650))
		b.add_child(line)
		if not report.items.is_empty():
			b.add_child(UiKit.label("Loot", 18, UiKit.INK_SOFT, 650))
			var loot := UiKit.hbox(10)
			loot.alignment = BoxContainer.ALIGNMENT_CENTER
			for item in report.items:
				var v := UiKit.vbox(2)
				var slot := ItemSlot.new().setup(item, 1, 64)
				slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
				v.add_child(slot)
				var n := UiKit.label(item.display_name, 13, item.get_rarity_color().darkened(0.2), 600)
				n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				v.add_child(n)
				loot.add_child(v)
			b.add_child(loot)
		var heroes := UiKit.hbox(10)
		heroes.alignment = BoxContainer.ALIGNMENT_CENTER
		for hero in GameState.party.members():
			var v := UiKit.vbox(2)
			v.add_child(Portrait.new().setup(Portraits.for_hero(hero), 64, hero.get_hero_class().color))
			var leveled := report.level_ups.any(func(lu: Dictionary) -> bool: return lu.hero == hero)
			var l := UiKit.label(("LEVEL %d!" % hero.level) if leveled else ("Lv %d" % hero.level), 14, UiKit.GOLD_DARK if leveled else UiKit.INK_SOFT, 650)
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			v.add_child(l)
			heroes.add_child(v)
		b.add_child(heroes)
		if not report.level_ups.is_empty():
			var hint := UiKit.label("New skill points! Open the Party screen (P) to unlock abilities.", 15, UiKit.TEAL, 600)
			hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			b.add_child(hint)
	elif not victory:
		b.add_child(UiKit.wrap(UiKit.label("Your heroes will be carried back to the Sleepy Griffin Inn and patched up. Try unlocking abilities, buying gear, recruiting more heroes or reordering ability priorities.", 17)))
	var btn := UiKit.button("Continue" if victory else "Return to the Inn", _continue, "", 260)
	var center := CenterContainer.new()
	center.add_child(btn)
	b.add_child(center)


func _continue() -> void:
	force_close()
	if on_continue.is_valid():
		on_continue.call()
