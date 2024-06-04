extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var game_over = $UI/GameOver
@onready var game_over_label = $UI/GameOver/GameOver
@onready var respawn_timer = $RespawnTimer
@onready var win_timer = $CheckWinTimer
@onready var spawn_pos = $PlayerSpawnPos
@onready var spawn_area = $PlayerSpawnPos/PlayerSpawnArea
@onready var background = $Background
@onready var starfieldBack: GPUParticles2D = $Background/StarfieldBack
@onready var starfieldMiddle: GPUParticles2D = $Background/StarfieldMiddle
@onready var starfieldFront: GPUParticles2D = $Background/StarfieldFront

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
	get_tree().get_root().size_changed.connect(_on_screen_resize)
	_on_screen_resize()

	$GameMusic.play()
	game_over.visible = false
	score = 0
	lives = 4
	print("start")
	print(lives)

	player.connect("laser_shot", _on_player_laser_shot)
	player.connect("died", _on_player_died)
	respawn_timer.connect("timeout", _on_respawn_timer_timeout)
	win_timer.connect("timeout", check_for_win)

	for asteroid: Asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)
		asteroid.connect("body_entered", asteroid._on_body_entered)

func _on_screen_resize():
	var screen_size = get_viewport_rect().size
	background.global_position.x = screen_size.x
	background.global_position.y = screen_size.y / 2
	starfieldBack.process_material.emission_box_extents.y = screen_size.y / 2
	starfieldMiddle.process_material.emission_box_extents.y = screen_size.y / 2
	starfieldFront.process_material.emission_box_extents.y = screen_size.y / 2

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
		$GameMusic.stop()
		$GameOver.play()
		print("game over")


func _on_player_laser_shot(laser):
	$LaserSound.play (0.2)
	lasers.add_child(laser)

func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func check_for_win():
	var remaining = asteroids.get_child_count()
	print("Remaining asteroids: ", remaining)
	if remaining == 0:
		$GameMusic.stop()
		$GameWin.play()
		print("game won")
		win_timer.stop()
		game_over_label.text = "Victory!"
		game_over.visible = true

func _on_asteroid_exploded(pos, size, points):
	match size:
		Asteroid.AsteroidSize.LARGE:
			$BigImpact.play()
		Asteroid.AsteroidSize.MEDIUM:
			$SmallImpact.play()
		Asteroid.AsteroidSize.SMALL:
			$SmallImpact.play()
	score += points
	for i in range(5):
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			_:
				pass

	if size == Asteroid.AsteroidSize.SMALL:
		win_timer.start()

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


