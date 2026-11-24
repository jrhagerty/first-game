extends Area2D
class_name KillZone

@onready var death_sound: AudioStreamPlayer2D = $DeathSound

static var player_died: bool = false
var is_dying = false


func _on_body_entered(body):
	if is_dying:
		return
		
	if not body is CharacterBody2D:
		return
	
	is_dying = true
	print("You died!")
	death_sound.play()
	body.set_physics_process(false)
	body.get_node("CollisionShape2D").set_deferred("disabled", true)
	await FX.dissolve(body.get_node("AnimatedSprite2D"), 0.3).finished
	await get_tree().create_timer(0.15).timeout
	KillZone.player_died = true
	SceneTransition.change_scene(get_tree().current_scene.scene_file_path)
