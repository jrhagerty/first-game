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

func _on_start_game_pressed() -> void:
	click.play()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_version_notes_pressed() -> void:
	version_and_credit.play()
	$MenuContainer.hide()
	$VersionNotes.show()

func _on_credits_pressed() -> void:
	version_and_credit.play()
	$MenuContainer.hide()
	$CreditsPanel.show()
	credits_scroll_position = 0.0
	credits_scroll.scroll_vertical = 0
	credits_scrolling = true

func _on_version_back_button_pressed() -> void:
	back.play()
	$VersionNotes.hide()
	$MenuContainer.show()
	await get_tree().process_frame
	version_scroll.scroll_vertical = 0
	
func _on_credit_back_button_pressed() -> void:
	back.play()
	credits_scrolling = false
	$CreditsPanel.hide()
	$MenuContainer.show()

func _on_start_game_mouse_entered() -> void:
	hover.play()

func _on_version_notes_mouse_entered() -> void:
	hover.play()

func _on_credits_mouse_entered() -> void:
	hover.play()
