extends CanvasLayer
## Game Over screen controller.
##
## Displayed when the player runs out of lives.  
## Provides options to restart the game, return to the main menu,
## or delete the existing save data.


func _on_btn_tentar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")


func _on_btn_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


## Deletes the current save file and returns to the main menu.
func _on_btn_deletar_pressed() -> void:
	SaveManager.delete_save()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
