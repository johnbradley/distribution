extends Control

@onready var next_button: Button = %NextButton

func _ready() -> void:
    GameManager.game_state_changed.connect(_on_game_state_changed)

func _on_game_state_changed(game_state: GameManager.GameState) -> void:
    visible = game_state == GameManager.GameState.WIN
    if visible:
        next_button.grab_focus()

func _on_button_pressed() -> void:
    GridData.reset()
    GameManager.show_game_scene()
