extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const DASH_SPEED = 400.0
const DASH_DURATION = 0.175
const DASH_DUST_SCENE = preload("res://scenes/dash_dust.tscn")

var is_dashing = false
var can_air_dash = true
var dash_timer = 0.0
var facing_direction = 1.0
var dash_direction = 1.0
var is_airborne = false
var has_jumped = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var afterimage: Afterimage2D = $AnimatedSprite2D/Afterimage2D
@onready var dash_sound: AudioStreamPlayer2D = $DashSound
@onready var landing_sound: AudioStreamPlayer2D = $LandingSound

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		jump_sound.play()
		has_jumped = true
		velocity.y = JUMP_VELOCITY

	# Input direction -1 0 1
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		facing_direction = sign(direction)
	
	# Flip the sprite
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true
	
	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("default")
		else:
			animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("jump")
		
	if is_on_floor():
		can_air_dash = true
		
	if Input.is_action_just_pressed("dash") and not is_on_floor() and can_air_dash:
		is_dashing = true
		can_air_dash = false
		dash_timer = DASH_DURATION
		velocity.y = 0
		dash_direction = facing_direction
		afterimage.emitting = true
		dash_sound.play()
		var dust = DASH_DUST_SCENE.instantiate()
		get_parent().add_child(dust)
		dust.global_position = global_position + Vector2(-facing_direction * 5, -20)
		var dust_sprite: AnimatedSprite2D = dust.get_node("AnimatedSprite2D")
		dust_sprite.flip_h = facing_direction < 0
		
	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0
		
		if dash_timer <= 0:
			is_dashing = false
			afterimage.emitting = false
	else:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	if not is_on_floor():
		is_airborne = true
	
	if not was_on_floor and is_on_floor() and is_airborne and has_jumped:
		landing_sound.play()
		is_airborne = false
