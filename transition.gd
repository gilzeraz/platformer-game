extends CanvasLayer

@onready var overlay: ColorRect = $Overlay

const FADE_DURATION: float = 0.5

func _ready() -> void:
	overlay.modulate.a = 0.0
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer = 10

## Faz fade out, troca de cena, depois fade in.
func change_scene(path: String) -> void:
	await _fade_out()
	get_tree().change_scene_to_file(path)
	await _fade_in()

## Escurece a tela.
func _fade_out() -> void:
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween: Tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, FADE_DURATION)
	await tween.finished

## Clareia a tela.
func _fade_in() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, FADE_DURATION)
	await tween.finished
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

## Faz apenas o fade in — usado na primeira cena do jogo.
func fade_in_only() -> void:
	overlay.modulate.a = 1.0
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade_in()
