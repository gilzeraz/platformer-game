## GameOver.gd
## Tela exibida ao esgotar todas as vidas do jogador.

extends CanvasLayer


func _on_btn_tentar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")


func _on_btn_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_btn_deletar_pressed() -> void:
	SaveManager.delete_save()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
