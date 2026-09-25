class_name BossEncounter
extends Encounter
## Boss fight: the boss shouts an intro and the player chooses to engage.


func begin(zone: Zone) -> void:
	var boss_name := definition.monsters[0].display_name
	var d := Dialogue.new(boss_name, [definition.intro_line])
	d.appearance = definition.monsters[0].appearance
	d.add_option("Prepare for battle!", func() -> void: zone.start_encounter(self), true)
	d.add_option("Back away...", func() -> void: zone.push_player_back_from(self))
	for a in avatars:
		a.face_point(zone.player.global_position)
	EventBus.dialogue_requested.emit(d)
