extends CharacterBody2D

# -- Constantes de movimento --
const SPEED: float = 250.0
const JUMP_FORCE: float = -350.0
const GRAVITY: float = 900.0

# -- Variáveis de estado --
var extra_lives: int = 3
var coins: int = 0
var is_dead: bool = false

# -- Posição inicial de spawn --
var spawn_position: Vector2 = Vector2.ZERO

# -- Referências aos nós --
@onready var animated_sprite: AnimatedSprite2D = $Sprite2D
@onready var hud = $"../HUD"

func _ready() -> void:
	spawn_position = position
	hud.update_coins(coins)
	hud.update_lives(extra_lives)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	var direction: float = Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	_update_animation(direction)
	move_and_slide()
	# Teste de morte — remover depois
	if Input.is_action_just_pressed("ui_cancel"):
		die()

func _update_animation(direction: float) -> void:
	if not is_on_floor():
		animated_sprite.play("jump")
	elif direction != 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.play("death")
	await animated_sprite.animation_finished
	if extra_lives > 0:
		extra_lives -= 1
		_respawn()
	else:
		print("Game Over")

func _respawn() -> void:
	position = spawn_position
	velocity = Vector2.ZERO
	is_dead = false
	await _blink(1.0)

func _blink(duration: float) -> void:
	var elapsed: float = 0.0
	var interval: float = 0.1
	while elapsed < duration:
		animated_sprite.visible = !animated_sprite.visible
		await get_tree().create_timer(interval).timeout
		elapsed += interval
	animated_sprite.visible = true

func _on_killzone_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()

func collect(data: CollectibleData) -> void:
	if data.is_extra_life:
		extra_lives += 1
	else:
		coins += data.coin_value
	hud.update_coins(coins)
	hud.update_lives(extra_lives)

func add_score(amount: int) -> void:
	coins += amount
	hud.update_coins(coins)
