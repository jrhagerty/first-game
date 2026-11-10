extends Area2D

signal level_completed

var collected: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not collected:
		collected = true
		level_completed.emit()
		queue_free()
