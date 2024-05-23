extends Area2D

var movement_vector := Vector2(0, -1)

var speed := 60
var angular_speed = randf_range(-1, 1)

func _ready():
	rotation = randf_range(0, TAU)

func _process(delta):
	$Sprite2D.rotation += delta * angular_speed

func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta

	var screen_size = get_viewport_rect().size

	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0

	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0
