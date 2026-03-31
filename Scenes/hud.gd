extends CanvasLayer
## Heads-up display controller responsible for presenting player information.
##
## Displays coins and lives counters, animates HUD icons, and manages the
## pause menu interface including pause toggling and menu navigation.

@onready var coins_label: Label = $HBoxContainer/CoinsLabel
@onready var lives_label: Label = $HBoxContainer2/CoinsLabel
@onready var coin_icon: AnimatedSprite2D = $HBoxContainer/CoinIcon
@onready var heart_icon: AnimatedSprite2D = $HBoxContainer2/HeartIcon
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var pause_button: TextureButton = $PauseButton
@onready var click_sound: AudioStreamPlayer = $AudioStreamPlayer
@onready var time_label: Label = $HBoxContainer3/TimeLabel
@onready var clock_icon: AnimatedSprite2D = $HBoxContainer3/AnimatedSprite2D

var elapsed_time: float = 0.0
var running: bool = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	coin_icon.play("idle")
	heart_icon.play("idle")
	clock_icon.play("idle")
	update_coins(0)
	update_lives(3)
	pause_menu.visible = false

func _process(delta: float) -> void:
	if get_tree().paused or not running:
		return
	elapsed_time += delta
	SaveManager.last_time = elapsed_time
	var minutes: int = int(elapsed_time / 60)
	var seconds: int = int(elapsed_time) % 60
	time_label.text = "TIME = %02d:%02d" % [minutes, seconds]

## Stops the timer — called by the player on death.
func stop_timer() -> void:
	running = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()

## Updates the coin counter displayed on the HUD.
func update_coins(amount: int) -> void:
	coins_label.text = "COINS = " + str(amount)
	SaveManager.last_score = amount

## Updates the lives counter displayed on the HUD.
func update_lives(amount: int) -> void:
	lives_label.text = "LIVES = " + str(amount)

func _toggle_pause() -> void:
	var paused: bool = not get_tree().paused
	get_tree().paused = paused
	pause_menu.visible = paused

func _play_click() -> void:
	click_sound.play()

func _on_pause_button_pressed() -> void:
	_play_click()
	_toggle_pause()

func _on_btn_retomar_pressed() -> void:
	_play_click()
	_toggle_pause()

func _on_btn_reiniciar_pressed() -> void:
	_play_click()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_btn_menu_pressed() -> void:
	_play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_btn_deletar_pressed() -> void:
	get_tree().quit()
