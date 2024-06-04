extends Button

func _on_pressed():
	print("resetting...")
	get_tree().reload_current_scene()
