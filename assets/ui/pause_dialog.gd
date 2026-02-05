extends Control

func _ready() -> void:
    GameManager.game_state_changed.connect(_on_game_state_changed)

func _on_game_state_changed(game_state: GameManager.GameState) -> void:
    visible = game_state == GameManager.GameState.PAUSED
    if visible:
        %ResumeButton.grab_focus()

# When user presses escape show pause menu
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        if GameManager.is_game_paused():
            GameManager.resume_game()
        else:
            GameManager.pause_game()

func _on_resume_button_pressed() -> void:
    GameManager.resume_game()

func _on_restart_button_pressed() -> void:
    GameManager.show_game_scene()

func _on_quit_button_pressed() -> void:
    GameManager.show_start_scene()
