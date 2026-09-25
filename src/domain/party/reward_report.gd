class_name RewardReport
extends RefCounted
## What the player just received (battle victory, quest turn-in). Displayed by the UI.

var xp: int = 0
var gold: int = 0
var items: Array[Item] = []
## { hero: Hero, level: int } per hero that levelled.
var level_ups: Array[Dictionary] = []
