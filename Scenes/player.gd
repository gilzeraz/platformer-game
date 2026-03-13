## Player.gd
## Controlador principal do jogador.
##
## Responsabilidades:
## - Movimento
## - Pulo duplo
## - Sistema de vidas e dano
## - Autosave
## - Coleta de itens
## - Câmera com limite horizontal

extends CharacterBody2D


#==============================================================================
# Movement Constants
#==============================================================================

const SPEED: float = 250.0
const JUMP_FORCE: float = -350.0
const GRAVITY: float = 900.0
const MAX_JUMPS: int = 2


#==============================================================================
# Player State
#==============================================================================

var extra_lives: int = 3
var coins: int = 0
var is_dead: bool = false
var is_invincible: bool = false
var jump_count: int = 0


#==============================================================================
# Autosave
#==============================================================================

const SAVE_INTERVAL: float = 10.0
var save_timer: float = 0.0


#==============================================================================
# Spawn
#==============================================================================

var spawn_position: Vector2
var camera_fixed_y: float


#==============================================================================
# Node References
#==============================================================================

@onready var animated_sprite: AnimatedSprite2D = $Sprite2D
@onready var hud = $"../HUD"

@onready var death_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var walking_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D2
@onready var jump_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D3
@onready var respawn_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D4
@onready var camera: Camera2D = $Camera2D


#==============================================================================
# Initialization
#==============================================================================

func _ready() -> void:
	add_to_group("player")
	spawn_position = position
	_load_save()
	hud.update_coins(coins)
	hud.update_lives(extra_lives)
	animated_sprite.frame_changed.connect(_on_frame_changed)
	camera_fixed_y = camera.global_position.y
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 9999999
	camera.limit_bottom = 2000


func _load_save() -> void:
	var data: Dictionary = SaveManager.load_data()
	if data.is_empty():
		return
	extra_lives = data["lives"]
	coins = data["coins"]
	position = Vector2(data["pos_x"], data["pos_y"])
	spawn_position = position


#==============================================================================
# Main Physics Loop
#==============================================================================

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_handle_autosave(delta)
	_apply_gravity(delta)
	_handle_movement()
	_handle_jump()
	_update_animation(Input.get_axis("move_left", "move_right"))
	move_and_slide()
	_update_camera()


#==============================================================================
# Camera
#==============================================================================

func _update_camera() -> void:
	var target_x: float = clamp(global_position.x, float(camera.limit_left), float(camera.limit_right))
	camera.global_position = Vector2(target_x, camera_fixed_y)


#==============================================================================
# Movement
#==============================================================================

func _handle_movement() -> void:
	var direction: float = Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or jump_count < MAX_JUMPS:
			velocity.y = JUMP_FORCE
			jump_count += 1
			jump_sound.play()
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		jump_count = 0
	else:
		velocity.y += GRAVITY * delta


#==============================================================================
# Animation
#==============================================================================

func _update_animation(direction: float) -> void:
	if not is_on_floor():
		animated_sprite.play("jump")
		walking_sound.stop()
		return
	if direction != 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")
		walking_sound.stop()


func _on_frame_changed() -> void:
	if animated_sprite.animation != "walk":
		return
	if not is_on_floor():
		return
	if animated_sprite.frame == 0 or animated_sprite.frame == 3:
		walking_sound.play()


#==============================================================================
# Autosave
#==============================================================================

func _handle_autosave(delta: float) -> void:
	save_timer += delta
	if save_timer < SAVE_INTERVAL:
		return
	save_timer = 0.0
	SaveManager.save(self)


#==============================================================================
# Damage System
#==============================================================================

## Recebe dano, perde uma vida e fica invencível temporariamente.
func take_damage() -> void:
	if is_dead or is_invincible:
		return
	extra_lives -= 1
	hud.update_lives(extra_lives)
	SaveManager.save(self)
	if extra_lives <= 0:
		die()
		return
	is_invincible = true
	await _blink(1.0)
	is_invincible = false


#==============================================================================
# Death System
#==============================================================================

## Inicia a sequência de morte: toca animação e sons, depois respawna ou encerra.
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
		hud.update_lives(extra_lives)
		SaveManager.save(self)
		_respawn()
	else:
		_game_over()


func _respawn() -> void:
	position = spawn_position
	velocity = Vector2.ZERO
	is_dead = false
	respawn_sound.play()
	await _blink(1.0)


func _game_over() -> void:
	SaveManager.delete_save()
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")


func _blink(duration: float) -> void:
	var elapsed: float = 0.0
	const INTERVAL: float = 0.1
	while elapsed < duration:
		animated_sprite.visible = !animated_sprite.visible
		await get_tree().create_timer(INTERVAL).timeout
		elapsed += INTERVAL
	animated_sprite.visible = true
	



#==============================================================================
# Collectibles
#==============================================================================

## Processa a coleta de um item. Adiciona vida extra ou moedas conforme [CollectibleData].
func collect(data: CollectibleData) -> void:
	if data.is_extra_life:
		extra_lives += 1
	else:
		coins += data.coin_value
	hud.update_coins(coins)
	hud.update_lives(extra_lives)
	SaveManager.save(self)


## Adiciona [amount] moedas à contagem do jogador e atualiza o HUD.
func add_score(amount: int) -> void:
	coins += amount
	hud.update_coins(coins)
	SaveManager.save(self)


#==============================================================================
# Input
#==============================================================================

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		hud._toggle_pause()


#==============================================================================
# Signals
#==============================================================================

func _on_killzone_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()


func _on_feet_area_entered(area: Area2D) -> void:
	if area.name != "Jumpbox":
		return
	velocity.y = JUMP_FORCE
	var enemy: BaseEnemy = area.get_parent()
	enemy.die()
