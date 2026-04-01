extends Area2D

@export var next_scene: String = "res://scenes/level_2.tscn"
@export var is_final_portal: bool = false

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if is_final_portal:
		var hud: CanvasLayer = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.stop_timer()

	Transition.change_scene(next_scene)
