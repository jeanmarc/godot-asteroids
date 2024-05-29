class_name Asteroid extends Area2D

signal exploded(pos, size)

enum AsteroidSize{LARGE, MEDIUM, SMALL}
@export var size := AsteroidSize.LARGE

@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D

var movement_vector := Vector2(0, -1)
var speed := 60.0
var angular_speed = randf_range(-1, 1)

var points: int:
	get:
		match size:
			AsteroidSize.LARGE:
				return 100
			AsteroidSize.MEDIUM:
				return 50
			AsteroidSize.SMALL:
				return 25
			_:
				return 0

func _ready():
	rotation = randf_range(0, TAU)
	rotation = 0

	match size:
		AsteroidSize.LARGE:
			speed = randf_range(40.0, 60.0)
			sprite.texture = preload("res://assets/AsteroidBig.png")
			cshape.shape = preload("res://resources/asteroid_cshape_large.tres")
		AsteroidSize.MEDIUM:
			speed = randf_range(80.0, 100.0)
			sprite.texture = preload("res://assets/AsteroidMedium.png")
			cshape.shape = preload("res://resources/asteroid_cshape_medium.tres")
		AsteroidSize.SMALL:
			speed = randf_range(80.0, 160.0)
			sprite.texture = preload("res://assets/AsteroidSmall.png")
			cshape.shape = preload("res://resources/asteroid_cshape_small.tres")

func _process(delta):
	sprite.rotation += delta * angular_speed
	cshape.rotation += delta * angular_speed

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
	emit_signal("exploded", global_position, size, points)
	queue_free()

func _on_body_entered(body: Player):
	if body:
		print(Time.get_unix_time_from_system(), " ", body.name," hit " + self.name)
		var dist = global_position.distance_to(body.global_position)
		var collisionDist = cshape.shape.radius + body.cshape.shape.radius
		print("I am at ", cshape.global_position, ", player is at ", body.cshape.global_position, "distance is ", dist, " collisionSize is ", collisionDist)
		if body.alive:
			if dist <= collisionDist + 2:
				body.die(self)
			else:
				print("Too far, won't kill player")
		else:
			print("I see it's already dead")
	else:
		print("was not a player")
