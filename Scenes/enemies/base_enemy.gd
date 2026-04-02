class_name BaseEnemy
extends CharacterBody2D
## Base controller for enemy characters.
##
## Handles enemy behavior including patrol, chase, attack, and death sequences.
## Enemies patrol within a defined distance, chase the player when detected,
## and perform timed attacks within a specified range.


## Gravitational acceleration applied while airborne in pixels per second squared.
const GRAVITY: float = 900.0

## Horizontal patrol movement speed in pixels per second.
@export var speed: float = 60.0
## Horizontal chase movement speed when pursuing the player in pixels per second.
@export var chase_speed: float = 120.0
## Maximum distance from start position for patrol movement in pixels.
@export var patrol_distance: float = 100.0
## Maximum distance for attack triggering in pixels.
@export var attack_range: float = 40.0
## Time between consecutive attacks in seconds.
@export var attack_cooldown: float = 1.0
## Score value awarded to the player when this enemy is defeated.
@export var score_value: int = 5

var is_chasing: bool = false
var is_dead: bool = false
var is_attacking: bool = false
var direction: float = 1.0
var start_position: Vector2
var target: Node2D = null
var attack_timer: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	start_position = global_position
	animated_sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	if is_dead: return
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	attack_timer -= delta
	if is_chasing and target and is_instance_valid(target):
		var dist: float = abs(target.global_position.x - global_position.x)
		if dist <= attack_range and attack_timer <= 0.0:
			_start_attack()
		elif not is_attacking:
			var dir: float = sign(target.global_position.x - global_position.x)
			velocity.x = dir * chase_speed
			animated_sprite.flip_h = dir < 0
			animated_sprite.play("walk")
	else:
		if not is_attacking:
			_handle_patrol()
	if is_attacking:
		velocity.x = 0.0
	move_and_slide()


# Handles patrol movement within the defined distance.
func _handle_patrol() -> void:
	velocity.x = direction * speed
	if global_position.x > start_position.x + patrol_distance:
		direction = -1
	elif global_position.x < start_position.x - patrol_distance:
		direction = 1
	animated_sprite.flip_h = direction < 0
	animated_sprite.play("walk")


# Initiates an attack sequence and triggers damage application.
func _start_attack() -> void:
	is_attacking = true
	attack_timer = attack_cooldown
	animated_sprite.play("attack")
	_apply_damage_on_hit()


# Applies damage to the target after a delay during the attack animation.
func _apply_damage_on_hit() -> void:
	var fps: float = animated_sprite.sprite_frames.get_animation_speed("attack")
	var frame_count: float = animated_sprite.sprite_frames.get_frame_count("attack")
	var total_duration: float = frame_count / fps

	await get_tree().create_timer(total_duration * 0.5).timeout

	if is_dead or not is_attacking: return

	if target and is_instance_valid(target):
		var dist: float = global_position.distance_to(target.global_position)
		if dist <= attack_range * 1.5:
			target.take_damage()


# Handles animation completion events.
func _on_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false


# Handles enemy death and cleanup.
func die() -> void:
	if is_dead: return
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.play("death")
	death_sound.play()
	var player: Node = get_tree().get_first_node_in_group("player")
	if player:
		player.add_score(score_value)
	await animated_sprite.animation_finished
	await death_sound.finished
	queue_free()


# Starts chasing when the player enters the detection area.
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_chasing = true
		target = body


# Stops chasing after a delay when the player leaves the detection area.
func _on_detection_area_body_exited(body: Node2D) -> void:
	await get_tree().create_timer(5.0).timeout
	if body == target:
		is_chasing = false
		target = null


# Placeholder for hitbox collision detection.
func _on_hitbox_body_entered(_body: Node2D) -> void:
	pass
