extends PanelContainer

func _ready() -> void:
    %Back.grab_focus()

func _on_back_pressed() -> void:
    GameManager.show_start_scene()
