extends Node

func _ready() -> void:
    %Ok.grab_focus()

func _on_button_pressed() -> void:
    GridData.reset()
    GameManager.show_game_scene()
