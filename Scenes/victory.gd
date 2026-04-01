extends CanvasLayer

@onready var score_label: Label = $VBoxContainer2/ScoreContainer/ScoreLabel
@onready var coin_icon: AnimatedSprite2D = $VBoxContainer2/ScoreContainer/AnimatedSprite2D
@onready var time_label: Label = $VBoxContainer2/HBoxContainer/TimeLabel
@onready var clock_icon: AnimatedSprite2D = $VBoxContainer2/HBoxContainer/AnimatedSprite2D
@onready var player_image: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	coin_icon.play("idle")
	player_image.play("idle")
	clock_icon.play("idle")
	score_label.text = "SCORE " + str(SaveManager.last_score)

	var t: int = int(SaveManager.last_time)
	var minutes: int = int(t / 60)
	var seconds: int = t % 60
	time_label.text = "TIME %02d:%02d" % [minutes, seconds]

func _on_btn_tentar_pressed() -> void:
	SaveManager.last_score = 0
	SaveManager.last_time = 0.0
	Transition.change_scene("res://scenes/level_1.tscn")

func _on_btn_menu_pressed() -> void:
	SaveManager.last_score = 0
	SaveManager.last_time = 0.0
	Transition.change_scene("res://scenes/main_menu.tscn")

func _on_btn_deletar_pressed() -> void:
	get_tree().quit()
