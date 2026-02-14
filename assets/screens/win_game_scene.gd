extends PanelContainer

@onready var ok: Button = %OkButton

func _ready() -> void:
    ok.grab_focus()

func _on_button_pressed() -> void:
    GameManager.show_start_scene()
