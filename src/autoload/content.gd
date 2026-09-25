extends Node
## Autoload "Content": read-only registry of every definition in the game,
## looked up by id. Built once at startup from the catalogs.

var _classes: Dictionary = {}
var _heroes: Dictionary = {}
var _items: Dictionary = {}
var _monsters: Dictionary = {}
var _encounters: Dictionary = {}
var _quests: Dictionary = {}


func _ready() -> void:
	_index(_classes, ClassCatalog.build())
	_index(_items, ItemCatalog.build())
	_index(_heroes, HeroCatalog.build(_classes, _items))
	_index(_monsters, MonsterCatalog.build_monsters())
	_index(_encounters, MonsterCatalog.build_encounters(_monsters, _items))
	_index(_quests, QuestCatalog.build(_items))


func hero_class(id: StringName) -> HeroClass: return _lookup(_classes, id)
func hero(id: StringName) -> HeroDefinition: return _lookup(_heroes, id)
func item(id: StringName) -> Item: return _lookup(_items, id)
func monster(id: StringName) -> MonsterDefinition: return _lookup(_monsters, id)
func encounter(id: StringName) -> EncounterDefinition: return _lookup(_encounters, id)
func quest(id: StringName) -> Quest: return _lookup(_quests, id)


func items(ids: Array) -> Array[Item]:
	var out: Array[Item] = []
	for id in ids:
		out.append(item(id))
	return out


func _index(registry: Dictionary, entries: Array) -> void:
	for e in entries:
		assert(not registry.has(e.id), "Duplicate content id: %s" % e.id)
		registry[e.id] = e


func _lookup(registry: Dictionary, id: StringName) -> Variant:
	assert(registry.has(id), "Unknown content id: %s" % id)
	return registry.get(id)
