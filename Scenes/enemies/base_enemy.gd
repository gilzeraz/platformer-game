## BaseEnemy.gd
## Controlador base para todos os inimigos.
##
## Responsabilidades:
## - Patrulha automática
## - Perseguição ao detectar o player
## - Sistema de morte com animação e som
## - Dano ao player via hitbox

class_name BaseEnemy
extends CharacterBody2D


#==============================================================================
# Constants
#==============================================================================

const SPEED: float = 60.0
const CHASE_SPEED: float = 120.0
const GRAVITY: float = 900.0
const PATROL_DISTANCE: float = 100.0


#==============================================================================
# State
#==============================================================================

var is_chasing: bool = false
var is_dead: bool = false
var direction: float = 1.0
var start_position: Vector2
var target: Node2D = null


#==============================================================================
# Node References
#==============================================================================

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D


#==============================================================================
# Initialization
#==============================================================================

func _ready() -> void:
	start_position = global_position


#==============================================================================
# Main Physics Loop
#==============================================================================

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if is_chasing and target and is_instance_valid(target):
		var dir: float = sign(target.global_position.x - global_position.x)
		velocity.x = dir * CHASE_SPEED
		animated_sprite.flip_h = dir < 0
	else:
		_handle_patrol()
	animated_sprite.play("walk")
	move_and_slide()


#==============================================================================
# Patrol
#==============================================================================

func _handle_patrol() -> void:
	velocity.x = direction * SPEED
	if global_position.x > start_position.x + PATROL_DISTANCE:
		direction = -1
	elif global_position.x < start_position.x - PATROL_DISTANCE:
		direction = 1
	animated_sprite.flip_h = direction < 0


#==============================================================================
# Death System
#==============================================================================

## Inicia a sequência de morte, concede pontos ao player e remove o inimigo.
func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.play("death")
	death_sound.play()
	var player: Node = get_tree().get_first_node_in_group("player")
	if player:
		player.add_score(5)
	await animated_sprite.animation_finished
	await death_sound.finished
	queue_free()


#==============================================================================
# Signals
#==============================================================================

## Inicia perseguição ao detectar o player na área de detecção.
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_chasing = true
		target = body


## Para a perseguição após 5 segundos fora da área de detecção.
func _on_detection_area_body_exited(body: Node2D) -> void:
	await get_tree().create_timer(5.0).timeout
	if body == target:
		is_chasing = false
		target = null


## Aplica dano ao player ao entrar em contato com a hitbox do inimigo.
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage()
		is_chasing = false
