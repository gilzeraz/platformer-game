extends Area2D
## Collectible item controller.
##
## Handles the interaction between the player and a collectible object.
## When collected, it sends its associated [CollectibleData] to the player,
## plays a sound, hides the sprite, and removes itself from the scene.


## Resource containing the collectible configuration and behavior data.
@export var data: CollectibleData


@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var coin_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if data:
		sprite.sprite_frames = data.frames
		sprite.play("idle")


# Called when a body enters the collectible area.
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("collect"):
		body.collect(data)
		coin_sound.play()
		sprite.visible = false

		await coin_sound.finished

		queue_free()
