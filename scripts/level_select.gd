extends Control

@onready var level_2_button_2: Button = $CenterContainer/VBoxContainer/Level2Button2
@onready var hover: AudioStreamPlayer = $Hover
@onready var click: AudioStreamPlayer = $Click
@onready var back: AudioStreamPlayer = $Back

func _ready() -> void:
	level_2_button_2.disabled = GameManager.highest_unlocked_level < 2

func _on_level_1_button_pressed() -> void:
	click.play()
	SceneTransition.change_scene("res://scenes/game.tscn")
	
func _on_level_2_button_2_pressed() -> void:
	click.play()
	SceneTransition.change_scene("res://scenes/level_01.tscn")
	
func _on_back_button_pressed() -> void:
	click.play()
	SceneTransition.change_scene("res://scenes/main_menu.tscn")

func _on_level_1_button_mouse_entered() -> void:
	hover.play()

func _on_level_2_button_2_mouse_entered() -> void:
	hover.play()

func _on_back_button_mouse_entered() -> void:
	hover.play()
