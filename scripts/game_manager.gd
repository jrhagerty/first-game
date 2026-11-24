extends Node

var score = 0
var highest_unlocked_level: int = 1

func _ready() -> void:
	load_progress()

func add_point():
	score += 1

func unlock_level(level: int) -> void:
	if level > highest_unlocked_level:
		highest_unlocked_level = level
		save_progress()
		
func save_progress() -> void:
	var file = FileAccess.open("user://progress.save", FileAccess.WRITE)
	file.store_var(highest_unlocked_level)
	
func load_progress() -> void:
	if FileAccess.file_exists("user://progress.save"):
		var file = FileAccess.open("user://progress.save", FileAccess.READ)
		highest_unlocked_level = file.get_var()
