extends Area2D
class_name KillZone

@onready var timer: Timer = $Timer
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
	Engine.time_scale = 0.5
	body.set_physics_process(false)
	body.get_node("CollisionShape2D").set_deferred("disabled", true)
	await FX.dissolve(body.get_node("AnimatedSprite2D"), 0.4).finished
	timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	KillZone.player_died = true
	get_tree().reload_current_scene()
