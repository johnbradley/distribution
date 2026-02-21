extends Control

@onready var reason: Label = %Reason

func _ready() -> void:
    GameManager.game_state_changed.connect(_on_game_state_changed)

func _on_game_state_changed(game_state: GameManager.GameState) -> void:
    visible = game_state == GameManager.GameState.LOST
    if visible:
        %Button.grab_focus()
        if GridData.lost_boxes > GridData.max_boxes_lost:
            reason.text = "too many boxes lost"
        else:
            reason.text = "out of downtime"

func _on_button_pressed() -> void:
    GridData.reset()
    GameManager.show_game_scene()
