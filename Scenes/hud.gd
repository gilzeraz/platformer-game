extends CanvasLayer

@onready var coins_label: Label = $HBoxContainer/CoinsLabel
@onready var lives_label: Label = $HBoxContainer2/CoinsLabel
@onready var coin_icon: AnimatedSprite2D = $HBoxContainer/CoinIcon
@onready var heart_icon: AnimatedSprite2D = $HBoxContainer2/HeartIcon
@onready var pause_menu: CanvasLayer = $PauseMenu
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


## Atualiza o contador de moedas exibido no HUD.
func update_coins(amount: int) -> void:
	coins_label.text = "COINS = " + str(amount)


## Atualiza o contador de vidas exibido no HUD.
func update_lives(amount: int) -> void:
	lives_label.text = "LIVES = " + str(amount)


func _toggle_pause() -> void:
	var paused := not get_tree().paused
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
