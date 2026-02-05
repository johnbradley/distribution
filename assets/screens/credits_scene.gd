extends PanelContainer

func _ready() -> void:
    %Back.grab_focus()

func _on_back_pressed() -> void:
    GameManager.show_start_scene()


func _on_credits_text_meta_clicked(meta: Variant) -> void:
    OS.shell_open(meta)
