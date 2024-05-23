extends CharacterBody2D

@export var acceleration := 10.0
@export var maxSpeed := 400

func _physics_process(delta):
	var input_vector := Vector2(0, Input.get_axis("forward", "back"))
	velocity += input_vector * acceleration
	velocity = velocity.limit_length(maxSpeed)

	move_and_slide()

	var screen_size = get_viewport_rect().size

	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0

	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0
