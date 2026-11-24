extends CanvasLayer

@onready var win_panel: ColorRect = $winPanel

func _ready() -> void:
	win_panel.hide()
	var sword = get_parent().get_node("Sword")
	sword.connect("level_completed", _on_level_completed)

func _on_level_completed() -> void:
	_go_to_level_02.call_deferred()

func _go_to_level_02() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level_02.tscn")
