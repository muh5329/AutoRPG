class_name PartySizeObjective
extends QuestObjective
## Have `required` heroes in the party. Progress mirrors the absolute party size.


func advance(event: GameEvent, progress: int) -> int:
	if event.type == GameEvent.HERO_RECRUITED:
		return mini(maxi(progress, event.amount), required)
	return progress
