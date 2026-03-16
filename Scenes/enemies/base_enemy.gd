extends CharacterBody2D
class_name BaseEnemy
## Base controller for all enemies.
##
## Handles patrol, player detection, chase, attack with animation,
## damage dealt only during attack frames, death system and scoring.

#region Constants
## Movement speed during patrol, in pixels per second.
const SPEED: float = 60.0
## Movement speed while chasing the player, in pixels per second.
const CHASE_SPEED: float = 120.0
## Gravitational acceleration applied when airborne, in pixels/s².
const GRAVITY: float = 900.0
## Maximum patrol distance from [member start_position], in pixels.
const PATROL_DISTANCE: float = 100.0
## Distance from player required to trigger the attack, in pixels.
const ATTACK_RANGE: float = 40.0
## Cooldown between attacks, in seconds.
const ATTACK_COOLDOWN: float = 1.2
#endregion

#region State
var is_chasing: bool = false
var is_dead: bool = false
var is_attacking: bool = false
var direction: float = 1.0
var start_position: Vector2
var target: Node2D = null
var attack_timer: float = 0.0
#endregion

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = global_position
	# Hitbox shape starts disabled; only enabled during attack impact frame.
	hitbox_shape.set_deferred("disabled", true)


# Physics processing entry point.
func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Decrease attack cooldown every frame.
	if attack_timer > 0.0:
		attack_timer -= delta

	if is_attacking:
		# Freeze horizontal movement while attacking.
		velocity.x = 0
		return

	if is_chasing and target and is_instance_valid(target):
		_handle_chase()
	else:
		_handle_patrol()

	move_and_slide()


# Moves toward the player; triggers attack when close enough.
func _handle_chase() -> void:
	var distance: float = abs(target.global_position.x - global_position.x)

	if distance <= ATTACK_RANGE and attack_timer <= 0.0:
		_start_attack()
		return

	var dir: float = sign(target.global_position.x - global_position.x)
	velocity.x = dir * CHASE_SPEED
	animated_sprite.flip_h = dir < 0
	animated_sprite.play("walk")


# Handles patrol movement within the defined patrol distance.
func _handle_patrol() -> void:
	velocity.x = direction * SPEED

	if global_position.x > start_position.x + PATROL_DISTANCE:
		direction = -1.0
	elif global_position.x < start_position.x - PATROL_DISTANCE:
		direction = 1.0

	animated_sprite.flip_h = direction < 0
	animated_sprite.play("walk")


# Starts the attack sequence.
func _start_attack() -> void:
	is_attacking = true
	velocity.x = 0
	animated_sprite.play("attack")

	# Wait for the animation to finish, then reset attack state.
	await animated_sprite.animation_finished

	hitbox_shape.set_deferred("disabled", true)
	is_attacking = false
	attack_timer = ATTACK_COOLDOWN


# Enables the hitbox shape on the frame where damage should occur.
# Connect AnimatedSprite2D > frame_changed signal to this function.
func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite.animation != "attack":
		hitbox_shape.set_deferred("disabled", true)
		return

	# Enable hitbox only on the impact frame (adjust index as needed).
	var is_impact_frame: bool = animated_sprite.frame == 2
	hitbox_shape.set_deferred("disabled", not is_impact_frame)


## Plays death animation, grants points and removes the enemy.
func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	hitbox_shape.set_deferred("disabled", true)

	animated_sprite.play("death")
	death_sound.play()

	var player: Node = get_tree().get_first_node_in_group("player")
	if player:
		player.add_score(5)

	await animated_sprite.animation_finished
	queue_free()

# Starts chasing upon detecting the player in the detection area.
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_chasing = true
		target = body


# Stops chasing 5 seconds after the player leaves the detection area.
func _on_detection_area_body_exited(body: Node2D) -> void:
	await get_tree().create_timer(5.0).timeout
	if body == target:
		is_chasing = false
		target = null


# Deals damage to the player — only valid during the attack animation.
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_attacking:
		body.take_damage()
