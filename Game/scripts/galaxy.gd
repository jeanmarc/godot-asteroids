extends Node2D

@onready var lasers = $Lasers


func _on_player_laser_shot(laser):
	lasers.add_child(laser)
