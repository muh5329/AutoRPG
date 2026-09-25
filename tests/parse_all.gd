extends Node
## Loads every script in src/ so parse/compile errors surface in one run.
## godot --headless --path . res://tests/parse_all.tscn

func _ready() -> void:
	var failures := 0
	var files := _collect("res://src")
	for f in files:
		var s := load(f)
		if s == null or (s is GDScript and not (s as GDScript).can_instantiate()):
			failures += 1
			print("FAILED: ", f)
	print("Checked %d scripts, %d failures" % [files.size(), failures])
	get_tree().quit(1 if failures > 0 else 0)


func _collect(dir: String) -> PackedStringArray:
	var out := PackedStringArray()
	var d := DirAccess.open(dir)
	for sub in d.get_directories():
		out.append_array(_collect(dir.path_join(sub)))
	for file in d.get_files():
		if file.ends_with(".gd"):
			out.append(dir.path_join(file))
	return out
