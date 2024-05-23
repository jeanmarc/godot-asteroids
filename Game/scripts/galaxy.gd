extends Node2D

@onready var lasers = $Lasers


func _on_player_laser_shot(laser):
	lasers.add_child(laser)

func _process(delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
