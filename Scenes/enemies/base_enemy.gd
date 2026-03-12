class_name BaseEnemy
extends CharacterBody2D

const SPEED: float = 60.0
const CHASE_SPEED: float = 120.0
const GRAVITY: float = 900.0
const PATROL_DISTANCE: float = 100.0

var is_chasing: bool = false
var is_dead: bool = false
var direction: float = 1.0
var start_position: Vector2
var target: Node2D = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	start_position = global_position

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if is_chasing and target and is_instance_valid(target):
		var dir: float = target.global_position.x - global_position.x
		dir = sign(dir)
		velocity.x = dir * CHASE_SPEED
		animated_sprite.flip_h = dir < 0
	else:
		velocity.x = direction * SPEED
		if global_position.x > start_position.x + PATROL_DISTANCE:
			direction = -1
		elif global_position.x < start_position.x - PATROL_DISTANCE:
			direction = 1
		animated_sprite.flip_h = direction < 0
	animated_sprite.play("walk")
	move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	is_chasing = true
	target = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	await get_tree().create_timer(5.0).timeout
	if body == target:
		is_chasing = false
		target = null

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.play("death")
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.add_score(5)
	await animated_sprite.animation_finished
	queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	print("hitbox: ", name, " tocou em: ", body.name, " grupos: ", body.get_groups())
	if body.is_in_group("player"):
		body.die()
		is_chasing = false
