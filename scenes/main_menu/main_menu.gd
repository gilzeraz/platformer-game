class_name MainMenu
extends Control
## Main menu controller responsible for configuring UI elements and handling menu actions.
##
## Initializes button and label theme overrides, controls the player preview animation,
## and processes menu actions such as starting a new game, continuing from a save,
## or exiting the application.

const LEVEL_1_SCENE: String = "res://scenes/levels/level_1.tscn"

@onready var player_image: AnimatedSprite2D = $AnimatedSprite2D
@onready var continue_button: Button = $VBoxContainer/continue


func _ready() -> void:
	continue_button.disabled = not SaveManager.has_save()
	Transition.fade_in_only()
	player_image.play("idle")


# Starts a new game from level 1.
func _on_newgame_pressed() -> void:
	SaveManager.delete_save()
	Transition.change_scene(LEVEL_1_SCENE)


# Continues from the last saved game.
func _on_continue_pressed() -> void:
	var data: Dictionary = SaveManager.load_data()
	Transition.change_scene(data["scene"])


# Exits the application.
func _on_exit_pressed() -> void:
	get_tree().quit()
