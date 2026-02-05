extends Node2D

func _ready() -> void:
    if OS.has_feature("web"):
        %Exit.hide()
    %Start.grab_focus()

func _on_exit_pressed() -> void:
    GameManager.exit_game()

func _on_start_pressed() -> void:
    if GameManager.seen_how_to_play:
        GameManager.show_level_select_scene()
    else:
        GameManager.show_instructions_scene()

func _on_instructions_pressed() -> void:
    GameManager.show_instructions_scene()

func _on_credits_pressed() -> void:
    GameManager.show_credits_scene()

func _on_settings_pressed() -> void:
    GameManager.show_settings_scene()
