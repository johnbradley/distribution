extends Node

func _ready() -> void:
    %Play.grab_focus()

func _on_back_pressed() -> void:
    GameManager.show_start_scene()

func _on_play_pressed() -> void:
    GameManager.show_level_select_scene()
