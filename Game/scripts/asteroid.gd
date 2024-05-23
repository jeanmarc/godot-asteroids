class_name Asteroid extends Area2D

signal exploded(pos, size)

enum AsteroidSize{LARGE, MEDIUM, SMALL}
@export var size := AsteroidSize.LARGE

@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D

var movement_vector := Vector2(0, -1)

var speed := 60
var angular_speed = randf_range(-1, 1)

func _ready():
	rotation = randf_range(0, TAU)

	match size:
		AsteroidSize.LARGE:
			speed = randf_range(40, 60)
			sprite.texture = preload("res://assets/AsteroidBig.png")
			cshape.shape = preload("res://resources/asteroid_cshape_large.tres")
		AsteroidSize.MEDIUM:
			speed = randf_range(80, 100)
			sprite.texture = preload("res://assets/AsteroidMedium.png")
			cshape.shape = preload("res://resources/asteroid_cshape_medium.tres")
		AsteroidSize.SMALL:
			speed = randf_range(80, 150)
			sprite.texture = preload("res://assets/AsteroidSmall.png")
			cshape.shape = preload("res://resources/asteroid_cshape_small.tres")

func _process(delta):
	$Sprite2D.rotation += delta * angular_speed

func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta

	var screen_size = get_viewport_rect().size
	var radius = cshape.shape.radius
	if global_position.y + radius < 0:
		global_position.y = screen_size.y + radius
	elif global_position.y - radius > screen_size.y:
		global_position.y = 0 - radius

	if global_position.x + radius < 0:
		global_position.x = screen_size.x + radius
	elif global_position.x - radius > screen_size.x:
		global_position.x = 0 - radius

func explode():
	emit_signal("exploded", global_position, size)
	queue_free()
