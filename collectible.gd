extends Area2D

# -- Resource com os dados do coletável --
@export var data: CollectibleData

# -- Referências --
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var coin_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	if data:
		sprite.sprite_frames = data.frames
		sprite.play("idle")


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("collect"):
		body.collect(data)
		coin_sound.play()
		sprite.visible = false
		await coin_sound.finished
		queue_free()
