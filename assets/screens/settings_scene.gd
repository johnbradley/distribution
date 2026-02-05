extends PanelContainer

func _ready() -> void:
    %MusicToggle.button_pressed = GameManager.music_enabled
    %SFXToggle.button_pressed = GameManager.sfx_enabled
    %Back.grab_focus()

func _on_music_toggled(enabled: bool) -> void:
    GameManager.music_enabled = enabled
    GameManager.apply_audio_settings()
    GameManager.save_progress()

func _on_sfx_toggled(enabled: bool) -> void:
    GameManager.sfx_enabled = enabled
    GameManager.apply_audio_settings()
    GameManager.save_progress()

func _on_reset_data_pressed() -> void:
    GameManager.reset_progress()
    GameManager.show_start_scene()

func _on_back_pressed() -> void:
    GameManager.show_start_scene()
