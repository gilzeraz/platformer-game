extends Control
## Main menu controller responsible for configuring UI elements and handling menu actions.
##
## Initializes button and label theme overrides, controls the player preview animation,
## and processes menu actions such as starting a new game, continuing from a save,
## or exiting the application.

## Font resource used to style menu buttons and labels.
const FONT: FontFile = preload("res://assets/environment/monogram.ttf")

@onready var player_image: AnimatedSprite2D = $AnimatedSprite2D
@onready var continue_button: Button = $VBoxContainer/continue


func _ready() -> void:
	continue_button.disabled = not SaveManager.has_save()
	Transition.fade_in_only()

	for node: Node in $VBoxContainer.get_children():
		if node is Button:
			var button: Button = node
			button.custom_minimum_size = Vector2(250, 60)
			button.add_theme_font_override("font", FONT)
			button.add_theme_font_size_override("font_size", 24)

		if node is Label:
			var label: Label = node
			label.add_theme_font_override("font", FONT)
			label.add_theme_font_size_override("font_size", 48)

	player_image.play("idle")


# Starts a new game from level 1.
func _on_newgame_pressed() -> void:
	SaveManager.delete_save()
	Transition.change_scene("res://scenes/level_1.tscn")


# Continues from the last saved game.
func _on_continue_pressed() -> void:
	var data: Dictionary = SaveManager.load_data()
	Transition.change_scene(data["scene"])


# Exits the application.
func _on_exit_pressed() -> void:
	get_tree().quit()

