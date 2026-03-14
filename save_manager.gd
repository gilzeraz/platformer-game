extends Node
## Utility responsible for managing the game save system.
##
## Handles serialization and persistence of player progress including
## lives, coins, current scene, and player position.


## File path used to store the save data.
const SAVE_PATH: String = "user://save.dat"


## Saves the current player state to disk.
func save(player: Node) -> void:
	var data: Dictionary = {
		"lives": player.extra_lives,
		"coins": player.coins,
		"scene": player.get_tree().current_scene.scene_file_path,
		"pos_x": player.position.x,
		"pos_y": player.position.y
	}

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()


## Loads save data from disk and returns it as a Dictionary.
func load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH): return {}

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data: Dictionary = file.get_var()
	file.close()

	return data


## Returns [code]true[/code] if a save file exists.
func has_save() -> bool: return FileAccess.file_exists(SAVE_PATH)


## Deletes the save file if it exists.
func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
