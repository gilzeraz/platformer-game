# portal.gd
extends Area2D

@export var next_scene: String = "res://scenes/level_2.tscn"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("PEGA ELE")
		get_tree().change_scene_to_file(next_scene)
