extends Control

@onready var credits_scroll: ScrollContainer = $CreditsPanel/CreditMargins/CreditsContent/CreditsScroll
@onready var version_scroll: ScrollContainer = $VersionNotes/VersionMargins/VersionNotesContent/VersionScroll
@onready var hover: AudioStreamPlayer = $Hover
@onready var click: AudioStreamPlayer = $Click
@onready var back: AudioStreamPlayer = $Back
@onready var version_and_credit: AudioStreamPlayer = $"Version and Credit"

var credits_scroll_position := 0.0
var credits_scroll_speed := 35.0
var credits_scrolling := false

func _process(delta):
	if credits_scrolling:
		credits_scroll_position += credits_scroll_speed * delta
		credits_scroll.scroll_vertical = int(credits_scroll_position)
		

func ui_transition(from: Control, to: Control) -> void:
	var tween = create_tween()
	tween.tween_property(from, "modulate:a", 0.0, 0.15)
	await tween.finished
	
	from.hide()
	to.modulate.a = 0.0
	to.show()
	
	tween = create_tween()
	tween.tween_property(to, "modulate:a", 1.0, 0.15)
	await tween.finished

func _on_start_game_pressed() -> void:
	click.play()
	SceneTransition.change_scene("res://scenes/game.tscn")

func _on_level_select_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.15).timeout
	SceneTransition.change_scene("res://scenes/level_select.tscn")

func _on_version_notes_pressed() -> void:
	version_and_credit.play()
	ui_transition($MenuContainer, $VersionNotes)

func _on_credits_pressed() -> void:
	version_and_credit.play()
	credits_scroll_position = 0.0
	credits_scroll.scroll_vertical = 0
	credits_scrolling = true
	ui_transition($MenuContainer, $CreditsPanel)

func _on_version_back_button_pressed() -> void:
	back.play()
	await get_tree().process_frame
	version_scroll.scroll_vertical = 0
	ui_transition($VersionNotes, $MenuContainer)
	
func _on_credit_back_button_pressed() -> void:
	back.play()
	credits_scrolling = false
	ui_transition($CreditsPanel, $MenuContainer)

func _on_start_game_mouse_entered() -> void:
	hover.play()

func _on_version_notes_mouse_entered() -> void:
	hover.play()

func _on_credits_mouse_entered() -> void:
	hover.play()

func _on_version_back_button_mouse_entered() -> void:
	hover.play()

func _on_credit_back_button_mouse_entered() -> void:
	hover.play()

func _on_level_select_mouse_entered() -> void:
	hover.play()
