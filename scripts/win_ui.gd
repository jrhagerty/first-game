extends CanvasLayer

@onready var win_panel: ColorRect = $winPanel
@onready var coin_count_label: Label = $winPanel/CoinCountLabel

func _ready() -> void:
	win_panel.hide()
	var sword = get_parent().get_node("Sword")
	sword.connect("level_completed", _on_level_completed)

func _on_level_completed() -> void:
	coin_count_label.text = "You Won and Collected: " + str(GameManager.score) + " coins!"
	win_panel.show()
	get_tree().paused = true
