extends CharacterBody2D
## Main controller for the player character.
##
## Responsibilities:
## - Horizontal movement and double jump
## - Life and damage system
## - Autosave system
## - Item collection
## - Camera with horizontal limits


## Horizontal movement speed in pixels per second.
const SPEED: float = 250.0

## Initial vertical velocity applied when jumping.
const JUMP_FORCE: float = -350.0

## Gravitational acceleration applied while airborne, in pixels/s².
const GRAVITY: float = 900.0

## Maximum number of jumps allowed before landing.
const MAX_JUMPS: int = 2


## Number of extra lives available to the player.
var extra_lives: int = 3

## Total number of coins collected.
var coins: int = 0

## Indicates whether the player is currently dead.
var is_dead: bool = false

## Indicates whether the player is temporarily invincible.
var is_invincible: bool = false

## Current number of jumps performed since the last time the player touched the floor.
var jump_count: int = 0


## Time interval between automatic saves, in seconds.
const SAVE_INTERVAL: float = 10.0
const INTERVAL: float = 0.1

## Timer used to track the autosave interval.
var save_timer: float = 0.0


## Position where the player respawns after death.
var spawn_position: Vector2

## Fixed vertical camera position used to prevent vertical camera movement.
var camera_fixed_y: float


## Reference to the player's animated sprite.
@onready var animated_sprite: AnimatedSprite2D = $Sprite2D

## Reference to the HUD node responsible for displaying lives and coins.
@onready var hud = $"../HUD"

## Sound played when the player dies.
@onready var death_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

## Sound played when the player walks.
@onready var walking_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D2

## Sound played when the player jumps.
@onready var jump_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D3

## Sound played when the player respawns.
@onready var respawn_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D4

## Camera attached to the player.
@onready var camera: Camera2D = $Camera2D


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


func _physics_process(delta: float) -> void:
	if is_dead: return

	_handle_autosave(delta)
	_apply_gravity(delta)
	_handle_movement()
	_handle_jump()

	_update_animation(Input.get_axis("move_left", "move_right"))

	move_and_slide()

	_update_camera()


func _update_camera() -> void:
	var target_x: float = clamp(
		global_position.x,
		float(camera.limit_left),
		float(camera.limit_right)
	)

	camera.global_position = Vector2(target_x, camera_fixed_y)


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
	if animated_sprite.animation != "walk": return

	if not is_on_floor(): return

	if animated_sprite.frame == 0 or animated_sprite.frame == 3:
		walking_sound.play()


func _handle_autosave(delta: float) -> void:
	save_timer += delta

	if save_timer < SAVE_INTERVAL: return

	save_timer = 0.0

	SaveManager.save(self)


## Applies damage to the player, reducing lives and granting temporary invincibility.
func take_damage() -> void:
	if is_dead or is_invincible: return

	extra_lives -= 1
	hud.update_lives(extra_lives)

	SaveManager.save(self)

	if extra_lives <= 0:
		die()
		return

	is_invincible = true

	await _blink(1.0)

	is_invincible = false


## Starts the death sequence and handles respawn or game over.
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

	while elapsed < duration:
		animated_sprite.visible = !animated_sprite.visible
		await get_tree().create_timer(INTERVAL).timeout
		elapsed += INTERVAL

	animated_sprite.visible = true


## Processes the collection of an item and updates player resources accordingly.
func collect(data: CollectibleData) -> void:
	if data.is_extra_life:
		extra_lives += 1
	else:
		coins += data.coin_value

	hud.update_coins(coins)
	hud.update_lives(extra_lives)

	SaveManager.save(self)


## Adds coins to the player score and updates the HUD.
func add_score(amount: int) -> void:
	coins += amount
	hud.update_coins(coins)

	SaveManager.save(self)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		hud._toggle_pause()


func _on_killzone_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()


func _on_feet_area_entered(area: Area2D) -> void:
	if area.name != "Jumpbox":
		return

	velocity.y = JUMP_FORCE

	var enemy: BaseEnemy = area.get_parent()
	enemy.die()
