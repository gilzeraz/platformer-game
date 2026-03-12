extends Control

const FONT = preload("res://assets/environment/monogram.ttf")

@onready var player_image: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	$VBoxContainer/continue.disabled = not SaveManager.has_save()

	for node in $VBoxContainer.get_children():
		if node is Button:
			node.custom_minimum_size = Vector2(250, 60)
			node.add_theme_font_override("font", FONT)
			node.add_theme_font_size_override("font_size", 24)

		if node is Label:
			node.add_theme_font_override("font", FONT)
			node.add_theme_font_size_override("font_size", 48)

	player_image.play("idle")


func _on_newgame_pressed() -> void:
	SaveManager.delete_save()
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")


func _on_continue_pressed() -> void:
	var data = SaveManager.load_data()
	get_tree().change_scene_to_file(data["scene"])


func _on_exit_pressed() -> void:
	get_tree().quit()
