class_name HeroDefinition
extends Resource
## Authored data for a specific recruitable character (name, class, look, bio).

@export var id: StringName
@export var display_name: String
@export var title: String
@export_multiline var bio: String
@export var hero_class: HeroClass
@export var appearance: Appearance
@export var starting_weapon: Weapon
@export var starting_armor: Armor
