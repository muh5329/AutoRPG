class_name PreBattleWindow
extends UiWindow
## Shown when an encounter triggers: review enemies, tune each hero's ability
## priorities, then Fight or Retreat.

var director: BattleDirector


func _init(director_: BattleDirector = null) -> void:
	director = director_
	pauses_exploration = false
	closable = false
	var def := director.get_encounter_definition() if director else null
	window_title = ("BOSS: %s" % def.display_name) if def and def.is_boss else ("Encounter: %s" % (def.display_name if def else ""))
	window_size = Vector2(1240, 720)


func _build(b: VBoxContainer) -> void:
	var def := director.get_encounter_definition()
	# Enemies
	var enemies := UiKit.panel(Color("3a2e4f"), Color("8a6bd6"), 14, 2, 12)
	var er := UiKit.hbox(10)
	enemies.add_child(er)
	er.add_child(UiKit.icon(&"skull", Color("ff8a8a"), 34))
	er.add_child(UiKit.label("Enemies:", 19, UiKit.CREAM_TEXT, 650))
	var counts := {}
	for m in def.monsters:
		counts[m.display_name] = counts.get(m.display_name, 0) + 1
	for n in counts:
		var chip := UiKit.panel(Color("5a4775"), Color(0, 0, 0, 0), 10, 0, 6)
		chip.add_child(UiKit.label("%s%s" % [n, (" x%d" % counts[n]) if counts[n] > 1 else ""], 17, Color.WHITE, 600))
		er.add_child(chip)
	er.add_child(UiKit.spacer())
	er.add_child(UiKit.label("Rewards: %d XP · %d Gold" % [def.total_xp(), def.total_gold()], 16, Color("ffd97a"), 600))
	b.add_child(enemies)
	b.add_child(UiKit.wrap(UiKit.label("Heroes fight on their own. Arrange each hero's abilities: earlier chips are preferred, and the green toggle allows or forbids a skill. Tanks taunt, healers heal, damage dealers interrupt casters.", 15, UiKit.INK_SOFT)))
	# Party rows
	var rows := UiKit.vbox(8)
	for hero in GameState.party.members():
		rows.add_child(_hero_row(hero))
	b.add_child(UiKit.scroll(rows, 440))
	# Actions
	var actions := UiKit.hbox(12)
	var potions := GameState.inventory.entries_of(Potion)
	var pc := 0
	for e in potions:
		pc += e.quantity
	actions.add_child(UiKit.icon(&"potion", Color("e0453a"), 30))
	actions.add_child(UiKit.label("%d potions (auto-used below 30%% HP)" % pc, 16, UiKit.INK_SOFT))
	actions.add_child(UiKit.spacer())
	actions.add_child(UiKit.button("Retreat", _retreat, "SecondaryButton", 160))
	var fight := UiKit.button("FIGHT!", _fight, "", 220)
	fight.add_theme_font_size_override("font_size", 24)
	actions.add_child(fight)
	b.add_child(actions)


func _hero_row(hero: Hero) -> Control:
	var card := UiKit.panel(Color("fff8ea"), UiKit.BORDER, 14, 2, 8)
	var row := UiKit.hbox(10)
	card.add_child(row)
	var p := Portrait.new().setup(Portraits.for_hero(hero), 58, hero.get_hero_class().color)
	p.set_dimmed(not hero.is_alive())
	row.add_child(p)
	var info := UiKit.vbox(2)
	info.custom_minimum_size.x = 190
	info.add_child(UiKit.label(hero.display_name.split(" ")[0], 18, UiKit.INK, 650))
	var role := UiKit.hbox(4)
	role.add_child(UiKit.icon(UiKit.role_glyph(hero.get_role()), hero.get_hero_class().color, 18))
	role.add_child(UiKit.label("Lv %d %s" % [hero.level, CombatTypes.role_name(hero.get_role())], 14, UiKit.INK_SOFT))
	info.add_child(role)
	var hp := UiKit.bar(UiKit.GREEN if hero.is_alive() else UiKit.RED, 12)
	hp.set_value(hero.current_hp, hero.get_max_hp(), true)
	info.add_child(hp)
	row.add_child(info)
	if hero.is_alive():
		row.add_child(LoadoutEditor.new().setup(hero, true))
	else:
		row.add_child(UiKit.label("Fallen — rest at the inn to revive.", 16, UiKit.RED, 600))
	return card


func _fight() -> void:
	force_close()
	director.start_fight()


func _retreat() -> void:
	force_close()
	director.retreat()
