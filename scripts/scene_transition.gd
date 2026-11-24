extends CanvasLayer

var fade_rect: ColorRect
var transition := false

func _ready() -> void:
	layer = 100.0
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_rect.modulate.a = 0.0
	add_child(fade_rect)
	
func change_scene(path: String) -> void:
	if transition:
		return
	
	transition = true
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.15)
	await tween.finished
	
	get_tree().paused = false
	
	var error = get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("Couldn't load scene " + path)
		fade_rect.modulate.a = 0.0
		transition = false
		return
	await get_tree().process_frame
	
	tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.15)
	await tween.finished
	
	transition = false
