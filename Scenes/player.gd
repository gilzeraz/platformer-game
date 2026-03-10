extends CharacterBody2D

# -- Constantes de movimento --
const SPEED: float = 350.0
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

func _ready() -> void:
	# Salva a posição inicial ao entrar na cena
	spawn_position = position

func _physics_process(delta: float) -> void:
	# Bloqueia controle se morreu
	if is_dead:
		return

	# Aplica gravidade quando no ar
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Movimento horizontal
	var direction: float = Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED

	# Pulo
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	# Vira o sprite dependendo da direção
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Atualiza animação
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

# Chamada quando o player toma dano / cai no buraco
func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.play("death")

	# Espera a animação de morte terminar
	await animated_sprite.animation_finished

	if extra_lives > 0:
		extra_lives -= 1
		_respawn()
	else:
		# TODO: mostrar tela de Game Over
		print("Game Over")

func _respawn() -> void:
	position = spawn_position
	velocity = Vector2.ZERO
	is_dead = false

	# Pisca por 1 segundo
	await _blink(1.0)

func _blink(duration: float) -> void:
	var elapsed: float = 0.0
	var interval: float = 0.1

	while elapsed < duration:
		animated_sprite.visible = !animated_sprite.visible
		await get_tree().create_timer(interval).timeout
		elapsed += interval

	# Garante que fica visível no final
	animated_sprite.visible = true
