class_name RecruitableHero
extends FriendlyNPC
## A hero waiting in the tavern who joins the party when asked.

@export var hero_id: StringName

var definition: HeroDefinition


func _ready() -> void:
	definition = Content.hero(hero_id)
	display_name = definition.display_name
	title = "%s · %s" % [definition.hero_class.display_name, CombatTypes.role_name(definition.hero_class.role)]
	appearance = definition.appearance
	if GameState.party.has_definition(hero_id):
		queue_free()
		return
	super()


func _add_options(d: Dialogue) -> void:
	if GameState.party.is_full():
		d.pages.append("Your party looks full, friend.")
		return
	d.add_option("Join my party!", _join, true)


func _join() -> void:
	var hero := GameState.recruit(definition)
	if hero == null:
		return
	remove_from_group(WorldEntity.INTERACTABLE_GROUP)
	var zone := get_zone()
	if zone:
		zone.party_controller.spawn_follower_at(hero, global_position, rotation.y)
	queue_free()
