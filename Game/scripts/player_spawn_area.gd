extends Area2D

var is_empty: bool:
	get:
		return !has_overlapping_areas() and !has_overlapping_bodies()

