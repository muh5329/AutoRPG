class_name Dialogue
extends RefCounted
## A short conversation: pages of text from one speaker, then choices.

class Option:
	extends RefCounted
	var label: String
	var action: Callable
	## Accent the button (quest offers, purchases...).
	var highlighted: bool

	func _init(label_: String, action_: Callable = Callable(), highlighted_ := false) -> void:
		label = label_
		action = action_
		highlighted = highlighted_


var speaker: String
## Optional: lets the UI render the speaker's portrait.
var appearance: Appearance
var pages: PackedStringArray = []
var options: Array[Option] = []


## pages_ may be an Array or PackedStringArray of strings.
func _init(speaker_: String, pages_ = []) -> void:
	speaker = speaker_
	pages = PackedStringArray(pages_)


func add_option(label: String, action: Callable = Callable(), highlighted := false) -> Dialogue:
	options.append(Option.new(label, action, highlighted))
	return self
