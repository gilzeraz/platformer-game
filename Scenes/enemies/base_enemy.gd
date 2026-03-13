extends CharacterBody2D
class_name BaseEnemy
## Base controller for all enemies.
##
## Responsibilities:
## - Automatic patrol between two extremes defined by [constant PATROL_DISTANCE]
## - Chase the player upon detection via [method _on_detection_area_body_entered]
## - Death system with animation and sound via [method die]
## - Player damage via hitbox in [method _on_hitbox_body_entered]
##
## [b]Usage:[/b] Attach to a [CharacterBody2D] with [AnimatedSprite2D]
## and [AudioStreamPlayer2D] as direct children.
##
## [codeblock]
## # Example: kill the enemy externally
## func _on_bullet_hit(enemy: BaseEnemy) -> void:
##     enemy.die()
## [/codeblock]


## Movement speed during patrol, in pixels per second.
const SPEED: float = 60.0

## Movement speed while chasing the player, in pixels per second.
const CHASE_SPEED: float = 120.0

## Gravitational acceleration applied when the enemy is not on the floor, in pixels/s².
const GRAVITY: float = 900.0

## Maximum patrol distance from [member start_position], in pixels.
const PATROL_DISTANCE: float = 100.0


## Whether the enemy is actively chasing the player.
var is_chasing: bool = false

## Whether the enemy has already died. Prevents multiple executions of [method die].
var is_dead: bool = false

## Current horizontal patrol direction. [code]1.0[/code] = right, [code]-1.0[/code] = left.
var direction: float = 1.0

## Initial position recorded in [method _ready], used as the patrol center.
var start_position: Vector2

## Reference to the player node being chased. [code]null[/code] when not chasing.
var target: Node2D = null


## Enemy animated sprite. Must be a direct child named [code]AnimatedSprite2D[/code].
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

## Sound player triggered on death. Must be a direct child named [code]AudioStreamPlayer2D[/code].
@onready var death_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	start_position = global_position


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


func _handle_patrol() -> void:
	velocity.x = direction * SPEED

	if global_position.x > start_position.x + PATROL_DISTANCE:
		direction = -1
	elif global_position.x < start_position.x - PATROL_DISTANCE:
		direction = 1

	animated_sprite.flip_h = direction < 0


## Starts the death sequence, grants points to the player, and removes the enemy from the scene.
##
## Plays the [code]death[/code] animation and death sound in parallel, waits for both
## to finish, then calls [method Node.queue_free].
## [br]Grants [code]5[/code] points to the first node in the [code]player[/code] group
## via [method add_score].
## [br][br][color=yellow]Warning:[/color] Multiple calls are ignored via [member is_dead].
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


## Starts chasing upon detecting the player in the detection area.
##
## Connect to the [code]body_entered[/code] signal of an [Area2D] child named
## [code]DetectionArea[/code]. Only nodes in the [code]player[/code] group trigger the chase.
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_chasing = true
		target = body


## Stops chasing after [code]5[/code] seconds outside the detection area.
##
## Connect to the [code]body_exited[/code] signal of an [Area2D] child named
## [code]DetectionArea[/code]. The delay prevents abrupt cancellations caused by
## momentary exits from the area.
func _on_detection_area_body_exited(body: Node2D) -> void:
	await get_tree().create_timer(5.0).timeout

	if body == target:
		is_chasing = false
		target = null


## Deals damage to the player upon contact with the enemy hitbox.
##
## Connect to the [code]body_entered[/code] signal of an [Area2D] child named
## [code]Hitbox[/code]. Calls [method take_damage] on the player and stops the chase.
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage()
		is_chasing = false
