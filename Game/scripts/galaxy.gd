extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var game_over = $UI/GameOver
@onready var respawn_timer = $RespawnTimer
@onready var spawn_pos = $PlayerSpawnPos
@onready var spawn_area = $PlayerSpawnPos/PlayerSpawnArea

var asteroid_scene = preload("res://scenes/asteroid.tscn")

var score: int:
	set(value):
		score = value
		hud.score = score

var lives: int:
	set(value):
		lives = value
		hud.init_lives(value)

func _ready():
	$GameMusic.play()
	game_over.visible = false
	score = 0
	lives = 4
	print("start")
	print(lives)

	player.connect("laser_shot", _on_player_laser_shot)
	player.connect("died", _on_player_died)
	respawn_timer.connect("timeout", _on_respawn_timer_timeout)

	for asteroid: Asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)
		asteroid.connect("body_entered", asteroid._on_body_entered)

func _on_player_died():
	$Crash.play(2.0)
	player.global_position = spawn_pos.global_position
	if lives > 1:
		lives -= 1
		print(lives)
		respawn_timer.start(2)
	else:
		lives = 0
		game_over.visible = true
		print("game over")


func _on_player_laser_shot(laser):
	$LaserSound.play (0.2)
	lasers.add_child(laser)

func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func _on_asteroid_exploded(pos, size, points):
	match size:
		Asteroid.AsteroidSize.LARGE:
			$BigImpact.play()
		Asteroid.AsteroidSize.MEDIUM:
			$SmallImpact.play()
		Asteroid.AsteroidSize.SMALL:
			$SmallImpact.play()
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
	a.connect("body_entered", a._on_body_entered)
	asteroids.call_deferred("add_child", a)


func _on_respawn_timer_timeout():
	if spawn_area.is_empty:
		player.respawn($PlayerSpawnPos.position)
	else:
		print("waiting for area to clear...")
		respawn_timer.start(0.2)


