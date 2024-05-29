extends Control

@onready var score = $Score:
	set(value):
		score.text = "SCORE: " + str(value)

var live_scn = preload("res://scenes/ui_life.tscn")
@onready var lives = $Lives

func init_lives(amount: int):
	for ul in lives.get_children():
		ul.queue_free()

	for i in amount:
		lives.add_child(live_scn.instantiate())
