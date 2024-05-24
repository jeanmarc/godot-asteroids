extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var respawn_timer = $RespawnTimer

var asteroid_scene = preload("res://scenes/asteroid.tscn")

var score := 0:
	set(value):
		score = value
		hud.score = score

var lives := 3

func _ready():
	score = 0
	lives = 3
	print("start")
	print(lives)

	player.connect("laser_shot", _on_player_laser_shot)
	player.connect("died", _on_player_died)

	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)

func _on_player_died():
	if lives > 0:
		lives -= 1
		print(lives)
		respawn_timer.start()
	else:
		print("game over")
		get_tree().reload_current_scene()

func _on_player_laser_shot(laser):
	lasers.add_child(laser)

func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func _on_asteroid_exploded(pos, size, points):
	score += points
	for i in range(3):
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				pass

func spawn_asteroid(pos, size):
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)


func _on_respawn_timer_timeout():
	player.respawn($PlayerSpawnPos.position)
