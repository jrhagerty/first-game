extends CanvasLayer

@onready var pause_panel: Control = $panel
@onready var hover: AudioStreamPlayer = $"../Hover"
@onready var click: AudioStreamPlayer = $"../Click"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_panel.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	var paused = not get_tree().paused
	get_tree().paused = paused
	pause_panel.visible = paused
	
func _on_restart_button_pressed() -> void:
	click.play()
	SceneTransition.change_scene(get_tree().current_scene.scene_file_path)
	 
func _on_main_menu_button_pressed() -> void:
	click.play()
	SceneTransition.change_scene("res://scenes/main_menu.tscn")

func _on_resume_button_pressed() -> void:
	click.play()
	toggle_pause()

func _on_resume_button_mouse_entered() -> void:
	hover.play()

func _on_restart_button_mouse_entered() -> void:
	hover.play()

func _on_main_menu_button_mouse_entered() -> void:
	hover.play()
