extends CanvasLayer

@onready var coins_label: Label = $CoinsLabel
@onready var lives_label: Label = $LivesLabel

func _ready() -> void:
	update_coins(0)
	update_lives(3)

func update_coins(amount: int) -> void:
	coins_label.text = "Coins: " + str(amount)

func update_lives(amount: int) -> void:
	lives_label.text = "Lives: " + str(amount)
	
func _on_reset_pressed() -> void:
	SaveManager.delete_save()
	get_tree().reload_current_scene()
