extends CharacterBody2D

const SPEED = 70.0
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var floor_ray_cast: RayCast2D = $FloorRayCast

var direction = 1.0
var floor_ray_distance = 7.5

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if direction == 1.0 and ray_cast_right.is_colliding():
		direction = -1.0
	if ray_cast_left.is_colliding():
		direction = 1.0
	
	floor_ray_cast.position.x = floor_ray_distance * direction
	floor_ray_cast.force_raycast_update()
	
	if is_on_floor() and not floor_ray_cast.is_colliding():
		direction *= -1.0
		floor_ray_cast.position.x = floor_ray_distance * direction
		floor_ray_cast.force_raycast_update()
	
	animated_sprite_2d.flip_h = direction < 0
	
	velocity.x = direction * SPEED
	move_and_slide()
