extends CharacterBody2D

# -- Constantes de movimento --
const SPEED: float = 250.0
const JUMP_FORCE: float = -350.0
const GRAVITY: float = 900.0

# -- Variáveis de estado --
var extra_lives: int = 3
var coins: int = 0
var is_dead: bool = false

# -- Autosave --
var save_timer: float = 0.0
const SAVE_INTERVAL: float = 10.0

# -- Posição inicial de spawn --
var spawn_position: Vector2 = Vector2.ZERO

# -- Referências aos nós --
@onready var animated_sprite: AnimatedSprite2D = $Sprite2D
@onready var hud = $"../HUD"
@onready var death_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var walking_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D2
@onready var jump_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D3
@onready var respawn_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D4

func _ready() -> void:
	add_to_group("player")
	spawn_position = position
	var data = SaveManager.load_data()
	if not data.is_empty():
		extra_lives = data["lives"]
		coins = data["coins"]
		position = Vector2(data["pos_x"], data["pos_y"])
		spawn_position = position
	hud.update_coins(coins)
	hud.update_lives(extra_lives)
	animated_sprite.frame_changed.connect(_on_frame_changed)

func _on_frame_changed() -> void:
	if animated_sprite.animation == "walk" and is_on_floor():
		if animated_sprite.frame == 0 or animated_sprite.frame == 3:
			walking_sound.play()

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Autosave
	save_timer += delta
	if save_timer >= SAVE_INTERVAL:
		save_timer = 0.0
		SaveManager.save(self)

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	var direction: float = Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE
		jump_sound.play()

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
		walking_sound.stop()
	elif direction != 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")
		walking_sound.stop()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.play("death")
	death_sound.play()
	await animated_sprite.animation_finished
	await death_sound.finished
	if extra_lives > 0:
		extra_lives -= 1
		hud.update_lives(extra_lives)  # ← adicione essa linha
		SaveManager.save(self)
		_respawn()
	else:
		SaveManager.delete_save()
		print("Game Over")
		queue_free()

func _respawn() -> void:
	position = spawn_position
	velocity = Vector2.ZERO
	is_dead = false
	respawn_sound.play()
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
	SaveManager.save(self)

func add_score(amount: int) -> void:
	coins += amount
	hud.update_coins(coins)
	SaveManager.save(self)

func _on_feet_area_entered(area: Area2D) -> void:
	if area.name == "Jumpbox":
		velocity.y = JUMP_FORCE
		var enemy: BaseEnemy = area.get_parent()
		enemy.die()
