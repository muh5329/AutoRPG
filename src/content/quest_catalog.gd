class_name QuestCatalog
extends RefCounted
## Quests for Oakhaven and Glimmerdeep Cave.


static func build(items: Dictionary) -> Array[Quest]:
	var q1 := _quest(&"strength_in_numbers", "Strength in Numbers", &"aldric", "Captain Aldric",
		"Gather a full party of five heroes.",
		"Captain Aldric won't let a party of three walk into Glimmerdeep. Adventurers often drink at the Sleepy Griffin Inn — maybe some of them are looking for work.",
		60, 60)
	q1.objectives.append(_party_size("Recruit heroes at the Sleepy Griffin Inn", 5))
	q1.offer_text = "Three heroes? Against whatever's crawling out of Glimmerdeep? No. Head to the Sleepy Griffin — there are always sellswords nursing an ale there. Come back with five."
	q1.in_progress_text = "Still short-handed. The Sleepy Griffin is just west of the fountain."
	q1.complete_text = "Now THAT is a party. Here — take this for the road. Gods keep you."

	var q2 := _quest(&"prepared_for_worst", "Prepared for the Worst", &"aldric", "Captain Aldric",
		"Buy a Health Potion and learn where to rest.",
		"Aldric insists the party carries potions — heroes drink them automatically in battle when badly hurt. Tilda's shop is east of the fountain. He also wants you to know where to rest: Bram runs the Sleepy Griffin Inn.",
		40, 40)
	q2.prerequisite_id = &"strength_in_numbers"
	q2.reward_items.append(items[&"potion_greater"])
	var buy := PurchaseObjective.new()
	buy.description = "Buy a Health Potion from Tilda"
	buy.item_id = &"potion_health"
	q2.objectives.append(buy)
	var rest := TalkObjective.new()
	rest.description = "Ask Bram at the Sleepy Griffin about resting"
	rest.npc_id = &"bram"
	q2.objectives.append(rest)
	q2.offer_text = "One more thing. Nobody walks into that cave without a potion on their belt. Tilda sells them — tell her I sent you. And have a word with Bram at the inn: a night's rest there will patch up any wound."
	q2.in_progress_text = "Tilda's Wares is east of the fountain, the Sleepy Griffin west. Potions and a bed — that's all I ask."
	q2.complete_text = "Good. Here's one of Tilda's grandmother's brews as well. Don't tell her I had a spare."

	var q3 := _quest(&"glimmerdeep", "Darkness in Glimmerdeep", &"maren", "Elder Maren",
		"Clear Glimmerdeep Cave and defeat whatever lurks within.",
		"The miners fled Glimmerdeep Cave north of town. Rats, goblins and worse now fill the tunnels, and something huge roars from the deepest chamber. Elder Maren begs you to clear it.",
		250, 300)
	q3.is_main_story = true
	q3.reward_items.append(items[&"glimmer_staff"])
	q3.objectives.append(_clear("Clear the rat-infested tunnels", &"cave_rats"))
	q3.objectives.append(_clear("Drive off the goblin raiders", &"cave_goblins"))
	q3.objectives.append(_clear("Burn out the spider nest", &"cave_spiders"))
	q3.objectives.append(_clear("Defeat Gorrak the Stonehide", &"cave_boss"))
	q3.offer_text = "Traveller... the crystals of Glimmerdeep have gone dark, and something foul has made its home there. Our miners barely escaped. Please — clear the cave, and the village will reward you."
	q3.in_progress_text = "The cave entrance is at the north road. Rest at the inn if your heroes are hurt."
	q3.complete_text = "Gorrak... slain? The crystals already sing again! Take this staff — it was carved from the first crystal ever mined in Glimmerdeep."

	var out: Array[Quest] = [q3, q1, q2]
	return out


static func _quest(id: StringName, title: String, giver_id: StringName, giver_name: String, summary: String,
		desc: String, gold: int, xp: int) -> Quest:
	var q := Quest.new()
	q.id = id
	q.title = title
	q.giver_id = giver_id
	q.giver_name = giver_name
	q.summary = summary
	q.description = desc
	q.reward_gold = gold
	q.reward_xp = xp
	return q


static func _clear(desc: String, encounter_id: StringName) -> QuestObjective:
	var o := ClearEncounterObjective.new()
	o.description = desc
	o.encounter_id = encounter_id
	return o


static func _party_size(desc: String, n: int) -> QuestObjective:
	var o := PartySizeObjective.new()
	o.description = desc
	o.required = n
	return o
