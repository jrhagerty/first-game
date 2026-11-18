extends CanvasLayer

@onready var win_panel: ColorRect = $winPanel
@onready var coin_count_label: Label = $winPanel/VBoxContainer/CoinCountLabel
@onready var click: AudioStreamPlayer = $"../Click"
@onready var hover: AudioStreamPlayer = $"../Hover"

func _ready() -> void:
	win_panel.hide()
	var sword = get_parent().get_node("Sword")
	sword.connect("level_completed", _on_level_completed)

func _on_level_completed() -> void:
	coin_count_label.text = "You Won and Collected: " + str(GameManager.score) + " coins!"
	win_panel.show()
	get_tree().paused = true
	
func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	GameManager.score = 0
	click.play()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_replay_button_pressed() -> void:
	get_tree().paused = false
	GameManager.score = 0
	click.play()
	get_tree().reload_current_scene()

func _on_main_menu_button_mouse_entered() -> void:
	hover.play()

func _on_replay_button_mouse_entered() -> void:
	hover.play()
