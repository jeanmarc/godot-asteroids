class_name Player extends CharacterBody2D

signal laser_shot(laser)
signal died

@export var acceleration := 10.0
@export var max_speed := 400.0
@export var angular_acceleration := 10.0
@export var max_rotation := 10.0

@onready var muzzle = $Muzzle
@onready var sprite = $Sprite2D

var laser_scene = preload("res://scenes/laser.tscn")

var angular_speed: float
var shoot_cooldown = false
var alive := true

@export var fire_rate := 0.2

func _ready():
	alive = true
	angular_speed = 0.0

func _process(_delta):
	if Input.is_action_pressed("fire"):
		if !shoot_cooldown:
			shoot_laser()
			shoot_cooldown = true
			$MuzzleCooldown.wait_time = fire_rate
			$MuzzleCooldown.start()


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

	var screen_size = get_viewport_rect().size

	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0

	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0

func shoot_laser():
	var l = laser_scene.instantiate()
	l.global_position = muzzle.global_position
	l.rotation = rotation
	emit_signal("laser_shot", l)


func _on_muzzle_cooldown_timeout():
	shoot_cooldown = false

func die():
	if alive:
		alive = false
		sprite.visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
		emit_signal("died")

func respawn(pos):
	if !alive:
		alive = true
		global_position = pos
		velocity = Vector2.ZERO
		angular_speed = 0
		sprite.visible = true
		process_mode = Node.PROCESS_MODE_INHERIT
