extends CanvasLayer
## Heads-up display controller responsible for presenting player information.
##
## Displays coins and lives counters, animates HUD icons, and manages the
## pause menu interface including pause toggling and menu navigation.


## Label displaying the current number of collected coins.
@onready var coins_label: Label = $HBoxContainer/CoinsLabel

## Label displaying the current number of remaining lives.
@onready var lives_label: Label = $HBoxContainer2/CoinsLabel

## Animated icon representing coins in the HUD.
@onready var coin_icon: AnimatedSprite2D = $HBoxContainer/CoinIcon

## Animated icon representing player lives.
@onready var heart_icon: AnimatedSprite2D = $HBoxContainer2/HeartIcon

## Pause menu interface shown when the game is paused.
@onready var pause_menu: CanvasLayer = $PauseMenu

## Button used to toggle the pause state from the HUD.
@onready var pause_button: TextureButton = $PauseButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	coin_icon.play("idle")
	heart_icon.play("idle")

	update_coins(0)
	update_lives(3)

	pause_menu.visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()


## Updates the coin counter displayed on the HUD.
func update_coins(amount: int) -> void:
	coins_label.text = "COINS = " + str(amount)


## Updates the lives counter displayed on the HUD.
func update_lives(amount: int) -> void:
	lives_label.text = "LIVES = " + str(amount)


## Toggles the paused state of the game and shows or hides the pause menu.
func _toggle_pause() -> void:
	var paused: bool = not get_tree().paused
	get_tree().paused = paused
	pause_menu.visible = paused


func _on_pause_button_pressed() -> void:
	_toggle_pause()


func _on_btn_retomar_pressed() -> void:
	_toggle_pause()


func _on_btn_reiniciar_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_btn_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_btn_deletar_pressed() -> void:
	SaveManager.delete_save()
	get_tree().paused = false
	get_tree().reload_current_scene()
