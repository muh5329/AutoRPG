extends SceneTree
## Headless balance test: runs every cave encounter N times with the party
## at the level they would realistically have, and prints win rates.
## Run: godot --headless --script res://tests/battle_sim.gd

const RUNS := 40


func _init() -> void:
	var classes := _index(ClassCatalog.build())
	var items := _index(ItemCatalog.build())
	var heroes := _index(HeroCatalog.build(classes, items))
	var monsters := _index(MonsterCatalog.build_monsters())
	var encounters := MonsterCatalog.build_encounters(monsters, items)
	var levels := { &"cave_rats": 1, &"cave_goblins": 2, &"cave_spiders": 3, &"cave_boss": 4 }
	for party_size in [3, 5]:
		print("=== Party of %d ===" % party_size)
		for enc in encounters:
			var wins := 0
			var total_time := 0.0
			var hp_left := 0.0
			var deaths := 0
			for run in RUNS:
				var party: Array[Hero] = []
				var ids := [&"garrick", &"seraphine", &"wren", &"ignatius", &"lyra"]
				for i in party_size:
					var h := Hero.new(heroes[ids[i]], levels[enc.id])
					for a in h.get_hero_class().abilities:
						h.unlock(a)
					party.append(h)
				var inv := Inventory.new()
				inv.add(items[&"potion_health"], 2)
				var battle := Battle.new(party, enc.spawn_monsters(), inv, run)
				var t := 0.0
				while not battle.is_over and t < 240.0:
					battle.tick(0.05)
					t += 0.05
				if battle.victory:
					wins += 1
				total_time += t
				for h in party:
					hp_left += h.get_hp_ratio()
					if not h.is_alive():
						deaths += 1
			print("%-22s lvl %d  win %3d%%  avg %.1fs  avg hp %.0f%%  deaths/run %.2f" % [
				enc.display_name, levels[enc.id], wins * 100 / RUNS, total_time / RUNS,
				hp_left / (RUNS * party_size) * 100.0, float(deaths) / RUNS])
	_campaign(heroes, encounters, items, 3)
	_campaign(heroes, encounters, items, 5)
	_trace_one(heroes, monsters, encounters, items)
	quit()


## Realistic run: HP carries over, XP levels heroes, skill points spent as earned.
func _campaign(heroes: Dictionary, encounters: Array, items: Dictionary, size: int) -> void:
	print("=== Campaign, party of %d (HP carries over, no resting) ===" % size)
	var wins := 0
	for run in RUNS:
		var session := GameSession.new()
		var ids := [&"garrick", &"seraphine", &"wren", &"ignatius", &"lyra"]
		for i in size:
			session.party.add(Hero.new(heroes[ids[i]]))
		session.inventory.add(items[&"potion_health"], 3)
		var ok := true
		for enc in encounters:
			for h in session.party.members():
				for a in h.get_hero_class().abilities:
					h.unlock(a)
			var battle := Battle.new(session.party.living(), enc.spawn_monsters(), session.inventory, run * 10)
			while not battle.is_over and battle.elapsed < 240.0:
				battle.tick(0.05)
			if not battle.victory:
				if run < 3:
					print("  run %d lost at %s (lvl %d)" % [run, enc.display_name, session.party.average_level()])
				ok = false
				break
			session.grant(enc.total_xp(), enc.total_gold(), enc.loot)
			session.recover_after_victory()
			if run < 3:
				var hp := PackedStringArray()
				for h in session.party.members():
					hp.append("%d%%" % roundi(h.get_hp_ratio() * 100))
				print("  run %d won %-22s in %5.1fs lvl %d hp %s" % [run, enc.display_name, battle.elapsed, session.party.average_level(), " ".join(hp)])
		if ok:
			wins += 1
	print("  full clear rate: %d%%" % (wins * 100 / RUNS))


func _trace_one(heroes: Dictionary, _monsters: Dictionary, encounters: Array, items: Dictionary) -> void:
	print("=== Trace: boss, party of 5, level 4 ===")
	var party: Array[Hero] = []
	for id in [&"garrick", &"seraphine", &"wren", &"ignatius", &"lyra"]:
		var h := Hero.new(heroes[id], 4)
		for a in h.get_hero_class().abilities:
			h.unlock(a)
		party.append(h)
	var inv := Inventory.new()
	inv.add(items[&"potion_health"], 2)
	var battle := Battle.new(party, encounters[3].spawn_monsters(), inv, 7)
	var counts := {}
	battle.unit_acted.connect(func(u: BattleUnit, a: Ability, _t: Array[BattleUnit]) -> void:
		var key := "%s: %s" % [u.get_name(), a.display_name]
		counts[key] = counts.get(key, 0) + 1)
	battle.message.connect(func(m: String) -> void: print("  [%.1f] %s" % [battle.elapsed, m]))
	while not battle.is_over and battle.elapsed < 240.0:
		battle.tick(0.05)
	var keys := counts.keys()
	keys.sort()
	for k in keys:
		print("  %-40s x%d" % [k, counts[k]])
	print("  victory=%s time=%.1f" % [battle.victory, battle.elapsed])


func _index(arr: Array) -> Dictionary:
	var d := {}
	for e in arr:
		d[e.id] = e
	return d
