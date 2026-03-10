extends CharacterBody2D

# -- Constantes de movimento --
const SPEED: float = 150.0
const JUMP_FORCE: float = -350.0
const GRAVITY: float = 900.0

# -- Referências aos nós --
@onready var animated_sprite: AnimatedSprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
	# Aplica gravidade quando no ar
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Movimento horizontal
	var direction: float = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED

	# Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE

	# Vira o sprite dependendo da direção
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Atualiza animação
	_update_animation(direction)

	move_and_slide()

func _update_animation(direction: float) -> void:
	if not is_on_floor():
		animated_sprite.play("jump")
	elif direction != 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")
