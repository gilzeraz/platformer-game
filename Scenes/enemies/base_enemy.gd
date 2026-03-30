extends CharacterBody2D
class_name BaseEnemy

const SPEED: float = 60.0
const CHASE_SPEED: float = 120.0
const GRAVITY: float = 900.0
const PATROL_DISTANCE: float = 100.0
## Distância em pixels para iniciar o ataque ao player.
const ATTACK_RANGE: float = 40.0
## Intervalo mínimo entre ataques, em segundos.
const ATTACK_COOLDOWN: float = 1.0

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
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	attack_timer -= delta

	if is_chasing and target and is_instance_valid(target):
		var dist: float = abs(target.global_position.x - global_position.x)

		if dist <= ATTACK_RANGE and attack_timer <= 0.0:
			_start_attack()
		elif not is_attacking:
			var dir: float = sign(target.global_position.x - global_position.x)
			velocity.x = dir * CHASE_SPEED
			animated_sprite.flip_h = dir < 0
			animated_sprite.play("walk")
	else:
		if not is_attacking:
			_handle_patrol()
			animated_sprite.play("walk")

	if is_attacking:
		velocity.x = 0.0

	move_and_slide()


func _handle_patrol() -> void:
	velocity.x = direction * SPEED
	if global_position.x > start_position.x + PATROL_DISTANCE:
		direction = -1
	elif global_position.x < start_position.x - PATROL_DISTANCE:
		direction = 1
	animated_sprite.flip_h = direction < 0


## Inicia a animação de ataque e agenda o dano no frame correto.
func _start_attack() -> void:
	is_attacking = true
	attack_timer = ATTACK_COOLDOWN
	animated_sprite.play("attack")


## Chamado quando qualquer animação termina.
func _on_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false

		# Verifica se o player ainda está no alcance e aplica o dano
		if target and is_instance_valid(target):
			var dist: float = global_position.distance_to(target.global_position)
			if dist <= ATTACK_RANGE:
				target.take_damage()


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


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_chasing = true
		target = body


func _on_detection_area_body_exited(body: Node2D) -> void:
	await get_tree().create_timer(5.0).timeout
	if body == target:
		is_chasing = false
		target = null


# Hitbox agora não causa mais dano — contato puro não machuca o player.
func _on_hitbox_body_entered(_body: Node2D) -> void:
	pass
