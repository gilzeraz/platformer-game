class_name BaseEnemy
extends CharacterBody2D


@export var speed = 300.0
@export var jump_velocity = -400.0
@export var health: float = 100.0



const CHASE_SPEED: float = 120.0
const GRAVITY: float = 900.0
const PATROL_DISTANCE: float = 100.0

# -- Variáveis de estado --
var is_chasing: bool = false
var is_dead: bool = false
var direction: float = 1.0
var start_position: Vector2

# -- Referências --
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea

func _ready() -> void:
	start_position = position

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Aplica gravidade
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Movimento
	var current_speed: float = CHASE_SPEED if is_chasing else speed
	velocity.x = direction * current_speed

	# Patrulha — vira ao chegar no limite
	if not is_chasing:
		if position.x > start_position.x + PATROL_DISTANCE:
			direction = -1.0
		elif position.x < start_position.x - PATROL_DISTANCE:
			direction = 1.0

	# Vira o sprite
	animated_sprite.flip_h = direction < 0

	# Animação
	animated_sprite.play("walk")

	move_and_slide()

# Detecta o player
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_chasing = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_chasing = false

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.play("hurt")
	await animated_sprite.animation_finished
	queue_free()


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.die()
