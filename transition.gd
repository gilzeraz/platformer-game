extends CanvasLayer
## Scene transition controller that manages fade in/out effects.
##
## Handles smooth transitions between scenes with fade animations,
## and provides utilities for fade-only effects at game start.

## Duration of fade animation in seconds.
const FADE_DURATION: float = 0.5

@onready var overlay: ColorRect = $Overlay


func _ready() -> void:
	overlay.modulate.a = 0.0
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer = 10


# Performs a fade out, changes scene, then fades in.
func change_scene(path: String) -> void:
	await _fade_out()
	get_tree().change_scene_to_file(path)
	await _fade_in()


# Darkens the screen with a fade effect.
func _fade_out() -> void:
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween: Tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, FADE_DURATION)
	await tween.finished


# Lightens the screen with a fade effect.
func _fade_in() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, FADE_DURATION)
	await tween.finished
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE


# Performs only a fade in effect, used at game start.
func fade_in_only() -> void:
	overlay.modulate.a = 1.0
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade_in()

