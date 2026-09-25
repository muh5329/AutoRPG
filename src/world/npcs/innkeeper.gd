class_name Innkeeper
extends Vendor
## A vendor who also lets the party rest to full health.

@export var rest_cost: int = 10


func _add_options(d: Dialogue) -> void:
	if GameState.party.needs_rest():
		d.add_option("Rest for the night (%d gold)" % rest_cost, _rest, true)
	super(d)


func _rest() -> void:
	if GameState.rest(rest_cost):
		say("Sleep well!")
	turn_back_home()
