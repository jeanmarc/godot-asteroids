extends CharacterBody2D

@export var acceleration := 10.0
@export var max_speed := 400.0
@export var angular_acceleration := 10.0
@export var max_rotation := 10.0
var angular_speed: float

func _ready():
	angular_speed = 0.0

func _physics_process(delta):
	var input_vector := Vector2(0, Input.get_axis("forward", "back"))
	velocity += input_vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)

	var angular_direction := Input.get_axis("rotate_ccw", "rotate_cw")

	if angular_direction == 0:
		angular_speed = Vector2(angular_speed, 0).move_toward(Vector2.ZERO, 0.2).x
	else:
		angular_speed += angular_direction * delta * angular_acceleration

	angular_speed = clamp(angular_speed, -max_rotation, max_rotation)

	rotate(delta * angular_speed)

	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 1)

	move_and_slide()

	print(angular_speed)

	var screen_size = get_viewport_rect().size

	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0

	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0
