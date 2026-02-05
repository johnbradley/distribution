extends Node2D

func _on_exit_pressed() -> void:
	GameManager.exit_game()

func _on_start_pressed() -> void:
	GameManager.show_game_scene()
