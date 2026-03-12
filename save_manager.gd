extends Node

const SAVE_PATH = "user://save.dat"

func save(player) -> void:
	var data = {
		"lives": player.extra_lives,
		"coins": player.coins,
		"scene": player.get_tree().current_scene.scene_file_path,
		"pos_x": player.position.x,
		"pos_y": player.position.y
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()

func load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = file.get_var()
	file.close()
	return data

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
