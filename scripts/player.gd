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
@onready var footstep_sound: AudioStreamPlayer2D = $FootstepSound
@onready var revive_sound: AudioStreamPlayer2D = $ReviveSound

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
	
	var anim_base: String
	
	if is_dashing:
		anim_base = "dash"
	elif is_on_floor():
		anim_base = "idle" if direction == 0 else "run"
	else:
		anim_base = "jump"
		
	var dir_suffix = "_right" if facing_direction > 0 else "_left"
	var anim_name = anim_base + dir_suffix
	
	if animated_sprite_2d.sprite_frames.has_animation(anim_name):
		animated_sprite_2d.flip_h=false
		animated_sprite_2d.play(anim_name)
	else:
		push_warning("Missing animation: " + anim_name)
	
		
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

func _on_footstep_timer_timeout() -> void:
	footstep_sound.play()

func _on_animated_sprite_2d_frame_changed() -> void:
	if not is_on_floor() or is_dashing:
		return
	if animated_sprite_2d.animation not in ["run_left", "run_right"]:
		return
	if animated_sprite_2d.frame in [1, 8]:
		footstep_sound.play()
		
func _ready() -> void:
	if KillZone.player_died:
		KillZone.player_died = false
		revive_sound.play()
		await FX.appear(animated_sprite_2d, 0.25).finished
		FX.clear(animated_sprite_2d)
