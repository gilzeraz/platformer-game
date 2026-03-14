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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Disable the continue button if no save file exists.
	continue_button.disabled = not SaveManager.has_save()

	for node: Node in $VBoxContainer.get_children():
		if node is Button:
			node.custom_minimum_size = Vector2(250, 60)
			node.add_theme_font_override("font", FONT)
			node.add_theme_font_size_override("font_size", 24)

		if node is Label:
			node.add_theme_font_override("font", FONT)
			node.add_theme_font_size_override("font_size", 48)

	# Start the idle animation for the player preview sprite.
	player_image.play("idle")

# Handles the new game button press.
func _on_newgame_pressed() -> void:
	SaveManager.delete_save()
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")


func _on_continue_pressed() -> void:
	# Handles the continue button press.
	var data: Dictionary = SaveManager.load_data()
	get_tree().change_scene_to_file(data["scene"])


func _on_exit_pressed() -> void:
	# Handles the exit button press.
	get_tree().quit()
