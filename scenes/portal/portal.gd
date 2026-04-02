class_name Portal
extends Area2D
## Portal controller that transitions players to the next scene.
##
## Detects player entry and changes scenes, with special handling for final portals
## that stops the HUD timer before transitioning.


const LEVEL_2_SCENE: String = "res://scenes/levels/level_2.tscn"

## Path to the next scene to load.
@export var next_scene: String = LEVEL_2_SCENE

## Whether this is the final portal of the level (triggers victory screen).
@export var is_final_portal: bool = false


# Called when a body enters the portal area.
# Detects player entry and transitions to the next scene.
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"): return

	if is_final_portal:
		var hud: CanvasLayer = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.stop_timer()

	Transition.change_scene(next_scene)
